# Codemagic 打包指南（参考 hello me）

## 1. Apple Developer 准备

在 [Apple Developer](https://developer.apple.com) 创建：

| 资源 | Identifier |
|------|------------|
| 主 App | `io.github.YaoHuan123.mami-key` |
| 键盘扩展 | `io.github.YaoHuan123.mami-key.keyboard` |
| App Group | `group.io.github.YaoHuan123.mami-key` |

**Capabilities（两个 App ID 都要）：**

- App Groups → 勾选 `group.io.github.YaoHuan123.mami-key`
- 键盘扩展额外需要：**App Groups**（与主 App 同一 Group）

## 2. 描述文件（Provisioning Profiles）

在 Developer Portal 创建 **App Store** 类型描述文件并下载：

| Codemagic 引用名 | Bundle ID |
|------------------|-----------|
| `mami-key-appstore` | `io.github.YaoHuan123.mami-key` |
| `mami-key-keyboard-appstore` | `io.github.YaoHuan123.mami-key.keyboard` |

## 3. Codemagic 控制台配置

与 hello me 相同账号体系：

1. **Team settings → Code signing**
   - 证书：`app-common`（Distribution，与 hello me 共用）
   - 上传上述两个 `.mobileprovision`，引用名与 `codemagic.yaml` 一致

2. **Team settings → Integrations**
   - App Store Connect：`huanqi-asc`（已有则复用）

3. **Applications → Add application**
   - 连接 Git 仓库（GitHub / GitLab 等）
   - 选择 `codemagic.yaml`
   - Workflow：`mami-key-ios-appstore`

## 4. Git 仓库

远程：`git@github.com:YaoHuan123/mamikey.git`

| 分支 | 用途 |
|------|------|
| `ios` | Codemagic 自动构建（push 触发） |
| `main` | 默认主分支 |

```bash
git clone git@github.com:YaoHuan123/mamikey.git
cd mamikey
git checkout ios   # CI 构建分支
```

## 5. 构建流程说明

`codemagic.yaml` 执行步骤：

1. `scripts/codemagic-prebuild.sh` — 同步 Bundle ID、App Group、版本号
2. `xcode-project use-profiles` — 自动签名
3. `xcode-project build-ipa` — 打出 App Store IPA
4. 自动上传 **TestFlight**

无需 Node.js / CocoaPods（原生 Swift 工程）。

## 6. 与 hello me 的差异

| 项目 | hello me | Mami Key |
|------|----------|----------|
| 技术栈 | Capacitor + npm + pod install | 原生 Swift Xcode |
| 工程路径 | `apps/mobile/ios/App` | `ios/` |
| Scheme | `App` | `MamiKey` |
| 构建命令 | `--workspace App.xcworkspace` | `--project MamiKey.xcodeproj` |
| 描述文件 | 1 个 | 2 个（主 App + 键盘扩展） |

## 7. 台账登记（上线助手）

在 `E:\ios app 上线助手\app-registry.json` 新增：

```json
{
  "app_slug": "mami-key",
  "display_name": "Mami Key",
  "workflow_name": "Mami Key iOS App Store",
  "bundle_id": "io.github.YaoHuan123.mami-key",
  "api_base_url": "https://hellotita.top/mami-key/api",
  "repo_path": "E:\\apps\\mami key",
  "git_branch": "ios",
  "codemagic_workflow_id": "mami-key-ios-appstore",
  "codemagic_profile": "mami-key-appstore",
  "codemagic_certificate": "app-common",
  "asc_integration": "huanqi-asc",
  "privacy_policy_url": "https://hellotita.top/mami-key/privacy",
  "support_url": "https://hellotita.top/mami-key/support",
  "status": "立项"
}
```

键盘扩展描述文件 `mami-key-keyboard-appstore` 需在 Codemagic 单独上传（台账字段可写在 review_notes）。

## 8. 常见问题

**Q: 键盘扩展签名失败？**  
A: 确认两个描述文件都已上传，且 App Group 在两个 App ID 上均已启用。

**Q: 需要开启「完全访问」吗？**  
A: 用户使用键盘调用 AI 时需要；与打包无关，在审核备注中说明用途即可。

**Q: 本地 Mac 调试？**  
A: 见 `ios/README.md`；CI 打包不依赖本地 Mac。
