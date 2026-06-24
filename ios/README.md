# Mami Key iOS

家长沟通 AI 键盘 — iOS v0.1

## 要求

- macOS + **Xcode 15+**（本地调试）
- 或 **Codemagic** 云端打包（见 [`docs/codemagic.md`](../docs/codemagic.md)）
- iOS 16+ 真机或模拟器（键盘扩展建议真机 + 微信测试）
- Apple Developer 账号（真机 / 上架需配置签名与 App Group）

## Bundle ID

| Target | Bundle ID |
|--------|-----------|
| MamiKey | `io.github.com.YaoHuan123.mamikey` |
| MamiKeyKeyboard | `io.github.com.YaoHuan123.mamikey.keyboard` |
| App Group | `group.io.github.YaoHuan123.mamikey` |

## 打开工程

```bash
open ios/MamiKey.xcodeproj
```

## 首次配置

1. 在 Xcode 中选择 **MamiKey** 与 **MamiKeyKeyboard** 两个 Target
2. 将 **Signing & Capabilities** 中的 Team 改为你的开发团队
3. 确认两个 Target 均已启用 App Group：`group.io.github.YaoHuan123.mamikey`
4. 若 Bundle ID 冲突，需与 `codemagic.yaml` 中 `BUNDLE_ID` 保持一致

## 运行

1. 先运行 **MamiKey** 主 App（安装到手机）
2. 系统设置 → 通用 → 键盘 → 添加 **Mami Key**
3. 进入 Mami Key 键盘设置 → 开启 **允许完全访问**（调用 AI 需要）
4. 打开主 App → **设置**：
   - 不填 API Key：使用 **演示模式（Mock）**，可完整体验流程
   - 填入 DeepSeek / OpenAI 兼容 API Key：关闭 Mock，走真实生成

## 使用流程

1. 微信中长按复制对方消息
2. 切换到 **Mami Key** 键盘
3. 点「读取剪贴板」确认消息
4. 选场景（对孩子 / 对老师）→ 子场景 → 风格
5. 点「生成 3 条回复」→ 点击一条插入输入框

## 工程结构

```
ios/
├── MamiKey/                 # 主 App：引导、设置、历史
├── MamiKeyKeyboard/         # 键盘扩展
├── MamiKeyShared/           # 共享：模型、Prompt、生成、额度
└── MamiKey.xcodeproj
```

## API 配置示例

| 字段 | 值 |
|------|-----|
| Base URL | `https://api.deepseek.com` |
| Model | `deepseek-chat` |
| API Key | 你的 Key |

## 已知限制（v0.1）

- 未接入 StoreKit，订阅为设置页调试开关
- 键盘需「完全访问」才能联网
- 剪贴板读取依赖用户先复制消息
- Windows 无法本地编译，需在 Mac 上构建

## 相关文档

- `TODO.md` — 任务进度
- `docs/MVP.md` — 功能清单
- `docs/prompts.md` — Prompt 模板
