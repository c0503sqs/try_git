# gh 登录与权限

## 能学到什么

- 用 `gh auth login` 登录 GitHub
- 读懂 `gh auth status` 里的每一项
- 知道 token scope 是什么，缺权限时怎么补
- 让 `git push` 自动复用 `gh` 的凭据

## 前置条件

已安装 `gh`：

```bash
gh --version
```

```text
gh version 2.102.0 (2026-09-30)
https://github.com/cli/cli/releases/tag/v2.102.0
```

macOS 安装：`brew install gh`；其他系统见 [cli.github.com](https://cli.github.com)。

## 登录

```bash
gh auth login
```

交互式提问依次是：

1. **What account do you want to log into?** → `GitHub.com`（公司自建实例选另一项）
2. **What is your preferred protocol for Git operations?** → `HTTPS` 或 `SSH`
   - HTTPS：由 `gh` 代管凭据，最省事
   - SSH：需要已有 SSH key 并上传到 GitHub
3. **Authenticate Git with your GitHub credentials?** → `Yes`
4. **How would you like to authenticate?** → `Login with a web browser`，然后用手机或浏览器输入一次性验证码

也可以用 token 直接登录（适合 CI 或远程机器）：

```bash
echo "$GITHUB_TOKEN" | gh auth login --with-token
```

## 查看登录状态

```bash
gh auth status
```

真实输出：

```text
github.com
  ✓ Logged in to github.com account c0503sqs (keyring)
  - Active account: true
  - Git operations protocol: https
  - Token: gho_************************************
  - Token scopes: 'gist', 'read:org', 'repo'
```

逐行读：

| 行 | 含义 |
| --- | --- |
| `account c0503sqs` | 当前登录的账号 |
| `(keyring)` | token 存在系统钥匙串里，而不是明文文件 |
| `Active account: true` | 同时登录多个账号时，这个是默认账号 |
| `Git operations protocol: https` | `git push/pull` 走 https，凭据由 gh 提供 |
| `Token scopes` | 这个 token 能干什么，见下一节 |

## token scope：权限的范围

`gh` 不会给你一个万能 token，而是按 scope 授权。常见的几个：

| scope | 能做什么 |
| --- | --- |
| `repo` | 读写公开和私有仓库的代码、issue、PR |
| `read:org` | 读取组织成员、团队信息 |
| `gist` | 创建和修改 gist |
| `workflow` | **提交和修改 `.github/workflows/` 下的文件** |
| `admin:org` | 管理组织、团队、成员 |
| `delete_repo` | 删除仓库（默认不给） |

> 本机当前 token 只有 `gist`、`read:org`、`repo`，**没有 `workflow`**。这意味着把带 workflow 的提交推上去会被拒绝：
>
> ```text
> ! [remote rejected] main -> main (refusing to allow a Personal Access Token to create or update workflow `.github/workflows/ci.yml` without `workflow` scope)
> ```

补充 scope：

```bash
gh auth refresh -s workflow
```

`-s` 是 `--scopes` 的缩写，可以写多个：`-s workflow,admin:org`。执行后会再走一次浏览器授权，**原有 scope 会保留**。

## 多账号切换

```bash
gh auth status          # 看有哪些账号
gh auth switch          # 交互式切换
gh auth switch -u 用户名  # 直接切到某个账号
gh auth logout          # 退出当前账号
```

## 让 git 复用 gh 的凭据

如果 `git push` 还在反复要密码：

```bash
gh auth setup-git
```

它会在 git 配置里写入：

```text
credential.https://github.com.helper=!/opt/homebrew/bin/gh auth git-credential
```

也就是让 git 在需要凭据时去问 `gh`。本项目机器上这条已经配好，所以 `git push` 不需要输密码。

## 环境变量：CI 里的做法

`gh` 按以下顺序找凭据：

1. `GH_TOKEN`
2. `GITHUB_TOKEN`
3. 配置文件 / 钥匙串

在 CI 里不要跑 `gh auth login`，直接设环境变量：

```bash
export GH_TOKEN="${{ secrets.GITHUB_TOKEN }}"
gh pr list
```

## 注意事项

1. **token 不要提交进仓库**。`gho_` 开头的是 OAuth token，泄漏后等同于账号被接管。泄漏了立刻去 GitHub Settings → Applications 撤销。
2. **scope 不足时错误信息很直接**：`HTTP 403: Resource not accessible by personal access token` 或上面那条 `without workflow scope`。按提示 `gh auth refresh -s <scope>` 即可。
3. **组织开启了 SAML SSO 时**，token 还需要为该组织授权。`gh auth status` 会提示，去 GitHub 的 Settings → Applications → 对应 token → Configure SSO 完成授权。
4. **`gh auth login` 会覆盖当前账号**。同时管理多个身份时用 `gh auth switch`，别反复登录。
5. **`git` 和 `gh` 是两套凭据**。`gh auth status` 正常不代表 `git push` 正常；后者看 `credential.helper`。

## 练习

1. 运行 `gh auth status`，说出你的 token 有哪些 scope。
2. 运行 `git config --get-all credential.https://github.com.helper`，确认 `gh` 已接管 git 凭据。
3. 用 `gh api user --jq '.login'` 打印当前账号名（`gh api` 的用法见 [gh api](../04-gh-cli/07-api.md)）。

---

上一篇：[安装与配置](01-install-and-config.md) · 下一篇：[三区模型](../01-basics/01-three-trees.md)
