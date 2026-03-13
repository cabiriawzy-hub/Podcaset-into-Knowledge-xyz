# podcast-to-html

将小宇宙播客链接转化为交互式知识萃取网页。

## 功能

自动从小宇宙播客链接提取音频，调用 AnyGen API 生成结构化的交互式 HTML 知识页面，包含:

- 🎯 核心主题提取
- 💡 关键观点总结
- 📊 硬核信息整理
- 🔄 思考角度分析
- 🛠️ 行动建议清单
- 🔗 补充知识拓展

## 使用方式

### 前置要求

- AnyGen API Key (格式: `sk-ag-...`)
- 支持 OpenClaw 的 Claude Code 环境

### 安装

1. 将此 Skill 放置在 OpenClaw skills 目录下
2. 首次使用时会提示输入 AnyGen API Key，输入后会自动保存到 `~/.openclaw/openclaw.json`

### 使用

直接发送小宇宙播客分享链接即可，例如:

```
https://www.xiaoyuzhoufm.com/episode/xxxxx
```

Skill 会自动:
1. 提取音频 URL
2. 创建 AnyGen 任务
3. 轮询任务状态
4. 返回生成的交互式网页链接

## 文件说明

- `SKILL.md` - Skill 定义和工作流程
- `create_task.sh` - AnyGen 任务创建脚本
- `README.md` - 本文档

## 技术栈

- Bash Shell
- AnyGen API
- OpenClaw Skill Framework

## License

MIT
