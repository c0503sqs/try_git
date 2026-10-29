# 签名提交

## 能学到什么

- 为什么需要签名提交
- 用 SSH key 签名（最简单）
- 用 GPG 签名
- 验证签名和排查 `Unverified`

## 为什么签名

提交里的作者名和邮箱是**可以随便填的**：

```bash
git -c user.name="Linus Torvalds" -c user.email="torvalds@linux-foundation.org" commit -m "..."
```

签名用密码学手段证明「这个提交确实由持有私钥的人创建」，GitHub 会显示 `Verified` 徽章。

适合：开源项目、发布 tag、需要审计的仓库。个人学习项目可选。

## 方案对比

| 方案 | 依赖 | 难度 | GitHub 支持 |
| --- | --- | --- | --- |
| SSH 签名 | 已有 SSH key | 低 | ✅ |
| GPG 签名 | 需要生成和管理 GPG key | 中 | ✅ |
| S/MIME | 证书 | 高 | ✅ |

推荐 SSH：大多数开发者已经有 SSH key，配置一行就够。需要 git 2.34+。

## SSH 签名

### 1. 确认有 SSH key

```bash
ls ~/.ssh/*.pub
```

没有就生成：

```bash
ssh-keygen -t ed25519 -C "you@example.com"
```

### 2. 配置 git

```bash
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519.pub
git config --global commit.gpgsign true
git config --global tag.gpgsign true
```

| 配置 | 作用 |
| --- | --- |
| `gpg.format ssh` | 用 SSH 而不是 GPG |
| `user.signingkey` | 公钥路径 |
| `commit.gpgsign` | 所有提交自动签名 |
| `tag.gpgsign` | tag 也签名 |

### 3. 上传签名公钥

GitHub → Settings → SSH and GPG keys → New SSH key → **Key type 选 `Signing Key`**。

> 认证用的 SSH key 和签名用的 key 是两个用途。同一个公钥可以上传两次，一次 Authentication、一次 Signing。

### 4. 验证

```bash
git commit -m "test: 验证签名"
git log --show-signature -1
```

```text
commit ...
Good "git" signature for you@example.com with ED25519 key SHA256:...
Author: ...
Date: ...
```

GitHub 上会显示 `Verified`。

## GPG 签名

### 1. 生成 key

```bash
gpg --full-generate-key
```

选择 RSA 4096 或 ed25519，填写真实姓名和**与 git 配置一致的邮箱**。

### 2. 找到 key id

```bash
gpg --list-secret-keys --keyid-format=long
```

```text
sec   rsa4096/ABCD1234EF567890 2026-10-29 [SC]
      ...
uid           [ultimate] Your Name <you@example.com>
```

`ABCD1234EF567890` 就是 key id。

### 3. 配置

```bash
git config --global user.signingkey ABCD1234EF567890
git config --global commit.gpgsign true
```

### 4. 上传公钥

```bash
gpg --armor --export ABCD1234EF567890
```

复制输出（包含 `BEGIN PGP PUBLIC KEY BLOCK`）到 GitHub → Settings → SSH and GPG keys → New GPG key。

### 5. 处理 TTY 问题

GPG 签名可能需要输入密码。macOS 上：

```bash
export GPG_TTY=$(tty)
```

写进 `~/.zshrc` 或 `~/.bashrc`。

## 验证

```bash
git log --show-signature -1
git verify-commit HEAD
git verify-tag v1.0.0
```

`git verify-commit` 只做本地验证；GitHub 显示 `Verified` 还需要公钥已经上传到账号。

## 签名 tag

```bash
git tag -s v1.0.0 -m "release 1.0.0"
```

`-s` 会签名，`-a` 只是附注 tag。验证：

```bash
git tag -v v1.0.0
```

发布版本用签名 tag，能防止 tag 被替换。

## 常见问题

| 现象 | 原因 | 处理 |
| --- | --- | --- |
| 提交显示 `Unverified` | 公钥没上传，或邮箱不匹配 | 上传对应公钥，检查 `user.email` |
| `gpg failed to sign the data` | GPG agent 没启动、TTY 不对 | `export GPG_TTY=$(tty)`，重启 agent |
| `error: gpg.ssh.program` | git 版本太旧 | 升级到 2.34+ |
| 签名成功但 GitHub 不认 | 上传的是 Authentication key 而不是 Signing key | 重新上传并选 Signing Key |
| 历史提交没有签名 | 签名只对之后的提交生效 | 需要的话用 rebase 重签，会改哈希 |

## 注意事项

1. **`user.email` 必须和 key 里的邮箱一致**（GPG）或和 GitHub 账号邮箱一致（SSH），否则显示 Unverified。
2. **签名会改变提交哈希**，对历史提交重签需要 rebase + force push。
3. **不要共享私钥**，签名身份等于账号身份。
4. **SSH 签名需要 git 2.34+**，老版本只能走 GPG。
5. **`commit.gpgsign` 是全局开关**，如果某个仓库不能用签名，可以 `git config --local commit.gpgsign false`。
6. **签名不加密内容**，提交内容仍然是明文。
7. **CI 里签名要注入私钥**，注意用环境变量和 secrets，别写进日志。

## 练习

1. 用 SSH key 配置签名，提交一次，用 `git log --show-signature` 验证。
2. 把公钥作为 Signing Key 上传到 GitHub，确认网页显示 Verified。
3. 创建一个签名 tag，用 `git tag -v` 验证。
4. 故意把 `user.email` 改成不匹配的地址，观察 GitHub 显示 Unverified。

---

上一篇：[hooks：本地钩子](05-hooks.md) · 下一篇：[从 issue 到 release](../07-workflows/01-issue-to-release.md)
