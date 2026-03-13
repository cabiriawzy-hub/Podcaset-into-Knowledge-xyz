#!/bin/bash
# Helper script to create AnyGen task with the new prompt

AUDIO_URL="$1"

if [ -z "$AUDIO_URL" ]; then
  echo "Usage: $0 <audio_url>"
  exit 1
fi

if [ -z "$ANYGEN_API_KEY" ]; then
  echo "Error: ANYGEN_API_KEY environment variable is not set"
  exit 1
fi

# Read the prompt template and replace placeholder
PROMPT=$(cat << 'PROMPT_END'
# Role: 顶级知识萃取专家 & 全栈交互设计师

## Background
我将为你提供一个播客节目的内容源（见下方的 Input Source）。这是一个非常有价值的信息源，我希望你能帮我将它"榨干"，提取出所有对个人成长、认知提升或具体实践有帮助的精华内容，并将其转化为一个高度结构化、且可以直接在网页上交互预览的完整网页项目。

## Input Source
AUDIO_URL_PLACEHOLDER

## Task
1. **深度分析与萃取**：读取并深度理解上述播客内容，从多个维度提取核心价值。
2. **知识拓展**：基于提取出的内容，主动提供相关的补充知识，打破信息孤岛。
3. **前端项目生成**：将所有提取和拓展的内容，生成一个完整的交互式网页项目。

## Extraction Dimensions (萃取维度)
请严格按照以下 6 个维度对内容进行结构化拆解：
1. 🎯 **核心主题 (Themes)**：这期播客探讨了哪几个核心议题？（用一句话总结并加上 3-5 个关键词）。
2. 💡 **关键观点 (Viewpoints)**：嘉宾或主播提出了哪些反常识、有洞见或核心的论点？
3. 📊 **硬核信息 (Information)**：提到了哪些具体的数据、事实、案例或研究报告？
4. 🔄 **思考角度 (Thinking Angles)**：讲者是用什么框架、模型或视角来分析问题的？（例如：第一性原理、历史唯物视角、心理学视角等）。
5. 🛠️ **行动建议 (Actionable Advice)**：有哪些我可以立刻应用到生活或工作中的具体步骤或建议？
6. 🔗 **补充知识 (Supplementary Knowledge)**：[发挥你的 AI 优势] 针对播客中提到的专有名词、理论、书籍或相关人物，提供简明扼要的背景补充和延伸阅读建议。

## Output Requirements (交互式网页项目/Artifact 格式要求)
请务必直接触发平台的 Artifact (独立网页预览) 功能，将交付物做成可直接预览的交互式网页项目，并严格遵循以下标准：

1. **动态真实标题 (Dynamic Title)**：网页的 `<title>` 标签以及页面内的 `<h1>` 顶部主标题，必须直接使用该期播客分享的具体核心主题（例如"探讨中美欧三角关系的底层逻辑"）。严禁在标题中使用"播客知识萃取"、"内容总结"、"摘要"等机械、通用的占位词。
2. **直接触发预览**：严禁任何解释说明、开场白或结语，直接输出可触发平台预览的网页项目即可。
3. **UI 设计与高级感 (UI Design & Premium Feel)**：采用现代、高级的 SaaS UI 风格（类似 Linear、Vercel 或 Notion），具有清晰的空间层级感。
   - **浅色模式 (Light Mode)**：全局背景使用高级浅灰色（如 `#F9FAFB` 或 `#F3F4F6`），内容卡片使用纯白色（`#FFFFFF`），配合细微的 1px 边框（`solid #E5E7EB`）和极其柔和的扩散阴影，营造悬浮效果。
   - **深色模式 (Dark Mode)**：全局背景使用深蓝灰色（如 `#0F172A` 或 `#111111`），内容卡片使用稍微提亮的色调（如 `#1E293B` 或 `#1C1C1E`），文字使用清晰的灰白色。
   - **排版 (Typography)**：增强标题与正文的字号对比，提高行高，确保充足的留白（呼吸感）。默认包含浅色/深色模式切换功能。
4. **交互特性 (Interactive Features，重点)**：
   - **标签页 (Tabs)**：将上述 6 个萃取维度设计为可点击的标签页，避免单页过长。
   - **折叠面板 (Accordion/Collapsible Panels)**：对于"硬核信息"和"补充知识"等细节，使用折叠面板，点击即可展开。
   - **思维导图 (Mind Map，如果适用)**：在"核心主题"部分，使用 Mermaid.js 渲染思维导图展示内容脉络。**配色要求**：使用 Mermaid 的 `%%{init}%%` 指令自定义节点颜色，采用低饱和度的"莫兰迪色系"（如雾霾蓝、鼠尾草绿、米色等）来区分层级。整体视觉必须柔和、精致、不刺眼——避免使用鲜艳或高饱和度的颜色。
   - **任务清单 (Checklist/Task List)**：将"行动建议"做成带有 Checkbox 的待办事项，点击可勾选（纯前端交互即可）。

## Workflow
请立即开始深度解析 Input Source 中的内容，并严格按照上述要求，直接生成可供交互预览的网页项目。
PROMPT_END
)

# Replace placeholder with actual audio URL
PROMPT="${PROMPT//AUDIO_URL_PLACEHOLDER/$AUDIO_URL}"

# Create the task
curl -sS https://www.anygen.io/v1/openapi/tasks \
  -H 'Content-Type: application/json' \
  --data-binary @- << EOF
{
  "auth_token": "Bearer $ANYGEN_API_KEY",
  "operation": "website",
  "language": "zh-CN",
  "prompt": $(echo "$PROMPT" | jq -Rs .)
}
EOF
