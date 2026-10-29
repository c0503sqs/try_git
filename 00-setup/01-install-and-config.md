# 安装与配置

## 能学到什么

- 确认自己的 git 版本
- **配置身份**：不配 `user.name` / `user.email` 就无法提交
- 分清 system / global / local 三层配置的覆盖关系
- 用 alias 把常用命令变短

## 检查安装

```bash
git --version
```

macOS 上实测输出：

```text
git version 2.39.5 (Apple Git-154)
```

如果命令不存在：

| 系统 | 安装方式 |
| --- | --- |
| macOS | `xcode-select --install`，或 `brew install git` |
| Ubuntu / Debian | `sudo apt install git` |
| Windows | 下载 [Git for Windows](https://git-scm.com/download/win)，或用 `winget install Git.Git` |

> `brew install git` 装的版本通常比系统自带的新。两者可以共存，`which git` 看当前用的是哪个。

## 第一件事：配置身份

每次 `git commit` 都会把作者名字和邮箱写进历史。没配置时，git 会直接拒绝提交：

```text
Author identity unknown

*** Please tell me who you are.

Run

  git config --global user.email "you@example.com"
  git config --global user.name "Your Name"
```

配置：

```bash
git config --global user.name "你的名字"
git config --global user.email "you@example.com"
```

**邮箱用什么？**

- 想让 GitHub 把提交算到你账号名下：用你 GitHub 账号里已验证的邮箱。
- 不想公开真实邮箱：用 GitHub 提供的 noreply 地址，形如 `12345678+username@users.noreply.github.com`，在 GitHub 的 Settings → Emails 里能看到专属的那一串。
- 只对当前仓库生效：把 `--global` 换成 `--local`。

本项目采用的就是「仅本仓库 + noreply」：

```bash
git config user.name "c0503sqs"
git config user.email "c0503sqs@users.noreply.github.com"
```

## 三层配置

git 的配置按范围分三层，**范围越小优先级越高**：

| 层级 | 命令 | 文件位置 | 作用范围 |
| --- | --- | --- | --- |
| system | `git config --system` | `/etc/gitconfig`（macOS 在 CommandLineTools 目录下） | 整台机器 |
| global | `git config --global` | `~/.gitconfig` | 当前用户的所有仓库 |
| local | `git config --local` 或不带范围 | `.git/config` | 仅当前仓库 |

查看某个配置最终生效的值，以及它来自哪个文件：

```bash
git config --list --show-origin
```

本项目里的一条真实输出（节选）：

```text
file:/Library/Developer/CommandLineTools/usr/share/git-core/gitconfig	init.defaultbranch=main
file:/Users/shenqiusheng/.gitconfig	credential.https://github.com.helper=!/opt/homebrew/bin/gh auth git-credential
file:.git/config	user.name=c0503sqs
file:.git/config	user.email=c0503sqs@users.noreply.github.com
```

从下往上看：身份来自仓库的 `.git/config`，凭据来自用户级配置，默认分支来自系统级。

## 常用配置

```bash
# 新仓库默认分支叫 main（git 2.28 起支持）
git config --global init.defaultBranch main

# 让 git 正确显示中文文件名，而不是 "\344\270\255" 这种八进制转义
git config --global core.quotepath false

# 换行符：macOS / Linux 用 lf；Windows 上建议配合 .gitattributes 使用
git config --global core.autocrlf input

# 拉取时不自动 rebase，保持 merge 行为（个人偏好，按团队约定改）
git config --global pull.rebase false
```

## alias：给命令起短名

```bash
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.lg "log --oneline --graph --all --decorate"
```

之后：

```bash
git st
git lg
```

带参数的 alias 如果要以 shell 命令执行，前面加 `!`：

```bash
git config --global alias.roots "!git rev-list --max-parents=0 HEAD"
git roots
```

`git config --global --list | grep alias` 可以查看所有别名。删掉用：

```bash
git config --global --unset alias.st
```

## 不同目录用不同身份

公司仓库和个人仓库用不同邮箱时，不必每次手动切。在 `~/.gitconfig` 里加：

```ini
[includeIf "gitdir:~/work/"]
    path = ~/.gitconfig-work
```

再在 `~/.gitconfig-work` 里写工作身份。`gitdir:` 里的路径必须以 `/` 结尾，否则不匹配子目录。

## 注意事项

1. **`--global` 不是全局生效**。它只对当前用户生效；仓库里的 `--local` 配置会覆盖它。
2. **改配置不影响已有提交**。历史里的作者信息是提交时写死的，改配置只影响之后的提交。
3. **邮箱写错，GitHub 不认贡献**。提交会显示成无头像的「未关联」作者；改了配置还要用 `git commit --amend --reset-author` 或交互式 rebase 修历史。
4. **不要在共享机器上把 token 写进配置**。凭据交给 `gh auth` 或系统钥匙串管理。
5. **`git config --list` 会重复显示**：同名配置在多层出现时都会列出来，用 `--show-origin` 才看得清哪条生效。

## 练习

1. 运行 `git config --list --show-origin`，找出你的 `user.email` 来自哪一层。
2. 在本仓库设置一个别名 `git last`，效果等于 `git log -1 --stat`。验证 `git last` 能跑。
3. 用 `git config --show-origin user.email` 查看当前值，再改成自己的邮箱，然后改回来。

---

上一篇：[README](../README.md) · 下一篇：[gh 登录与权限](02-gh-auth.md)
