---
name: podcast-to-html
description: 将小宇宙播客链接转化为交互式知识萃取网页。用户发送小宇宙分享链接，自动提取音频、调用 AnyGen 生成结构化 HTML 知识页面。
user-invocable: true
metadata: {"openclaw": {"primaryEnv": "ANYGEN_API_KEY"}}
---

## Trigger

When the user sends a 小宇宙 (xiaoyuzhoufm.com) podcast share link, execute this skill.

## Workflow

You are an automation agent. Follow these steps exactly:

### Step 0: Check API Key

First, check if the `ANYGEN_API_KEY` environment variable is set:

```bash
echo $ANYGEN_API_KEY
```

If the output is empty or the variable is not set:
1. Ask the user: "此 Skill 需要 AnyGen API Key 才能运行。请提供你的 AnyGen API Key（格式：sk-ag-...）："
2. Wait for the user to provide the key.
3. Once received, save it to the OpenClaw config file by running:

```bash
CONFIG_FILE="$HOME/.openclaw/openclaw.json"

# Read existing config or create new one
if [ -f "$CONFIG_FILE" ]; then
  EXISTING_CONFIG=$(cat "$CONFIG_FILE")
else
  EXISTING_CONFIG='{}'
fi

# Use jq to merge the new API key into the config
echo "$EXISTING_CONFIG" | jq '.skills.entries["podcast-to-html"].enabled = true | .skills.entries["podcast-to-html"].env.ANYGEN_API_KEY = "<USER_PROVIDED_KEY>"' > "$CONFIG_FILE"
```

Replace `<USER_PROVIDED_KEY>` with the actual key the user provided.

4. Tell the user: "✅ API Key 已保存到 ~/.openclaw/openclaw.json，下次使用时无需再次输入。请重新发送小宇宙链接以继续。"
5. Stop here. The user needs to restart the session or re-trigger the skill for the env var to be loaded.

If `ANYGEN_API_KEY` is already set, proceed to Step 1.

### Step 1: Extract Audio URL

The user will provide a 小宇宙 link like `https://www.xiaoyuzhoufm.com/episode/<id>`.

Use the exec tool to run the following command to extract the audio URL:

```bash
curl -sL "<user_provided_url>" | grep -oiE 'https?://[^"'"'"' <>]+\.(mp3|m4a)[^"'"'"' <>]*' | head -1
```

If that fails, try alternative extraction:
```bash
curl -sL "<user_provided_url>" | grep -oP '"enclosure":\{"url":"[^"]+' | head -1 | sed 's/"enclosure":{"url":"//'
```

Save the extracted audio URL as `AUDIO_URL`.

If no audio URL is found, tell the user: "抱歉，无法从该链接中提取音频文件地址，请确认链接是否正确。"

### Step 2: Create AnyGen Task

Use the exec tool to call the helper script that creates the AnyGen task:

```bash
bash {baseDir}/create_task.sh "$AUDIO_URL"
```

This script will:
- Read the updated prompt template (with Artifact/preview requirements)
- Replace the audio URL placeholder with the actual URL
- Call the AnyGen API with operation=website
- Return the task creation response

Parse the response JSON. Extract `task_id` and `task_url`. If `success` is not `true`, tell the user the error.

### Step 3: Poll Task Status Until Fully Completed

IMPORTANT: Do NOT send the task_url to the user until the task status is `completed`. The user must receive a fully generated page, not a still-loading one.

Use a polling loop with the exec tool. Poll every 15 seconds, for up to 15 minutes:

```bash
curl -sS "https://www.anygen.io/v1/openapi/tasks/<task_id>" \
  -H "Authorization: Bearer $ANYGEN_API_KEY"
```

Check the `status` field in the response:
- If `status` is `completed` → proceed to Step 4.
- If `status` is `failed` → tell the user: "❌ 任务失败: <error message>" and stop.
- Otherwise (pending / processing) → wait 15 seconds and poll again.

While waiting, give the user a brief status update every ~45 seconds:
- "⏳ AnyGen 正在生成中，请稍候..."
- If `progress` field is available, include it: "⏳ 正在生成中... (进度: XX%)"

Do NOT reveal the task_url during polling. Keep the user informed but patient.

### Step 4: Return Result (Only After Completion)

ONLY when `status` == `completed`:
- Send the user: "✅ 知识萃取完成！请访问: <task_url>"
- `task_url` is the value returned from the create task response (e.g. `https://www.anygen.io/task/xxx`)
- If `output.file_url` also exists, include it as an additional download link.

If polling exceeds 15 minutes and the task is still not completed:
- Tell the user: "⏳ 任务生成时间较长，我会把链接留给你，生成完毕后即可访问: <task_url>"
- This is the ONLY scenario where you may send the link before completion.

## Important Notes

- Always substitute the real audio URL into the prompt before sending to AnyGen.
- The `ANYGEN_API_KEY` is managed by Step 0. If not set, the skill will ask the user for it and save it automatically.
- Do not ask the user for confirmation before proceeding — just execute the full pipeline automatically once a valid 小宇宙 link is detected (after API key is confirmed).
