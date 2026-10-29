# Git 与 GitHub 学习手册

一套中文实操教程：从本地 `git` 命令，到 `gh` CLI，再到 GitHub 平台功能。

每一课按 **能学到什么 → 命令 → 实际输出 → 注意事项 → 练习** 编排。资料在仓库里读，命令在 `.sandbox/` 里跑。

> **怎么读**：先看一课的「能学到什么」，把「命令」复制到沙箱里执行，对照「实际输出」确认自己看到的一样，最后看「注意事项」。跑坏了就重建沙箱，见 [练习沙箱](labs/README.md)。

## 适合谁

- 用过 `git clone` / `git commit`，但说不清暂存区和工作区区别的人
- 只会 `git push`，遇到冲突、想撤销就慌的人
- 想用 `gh` 和 GitHub 的 Issues / Actions / Releases 把协作流程跑通的人

## 学习路线

| 阶段 | 主题 | 你将学会 | 预计时间 |
| --- | --- | --- | --- |
| 0 | [准备](#00-准备) | 安装、身份配置、gh 登录与权限 | 20 分钟 |
| 1 | [本地基础](#01-本地基础) | 三区模型、提交、查看历史、忽略文件 | 60 分钟 |
| 2 | [分支与撤销](#02-分支与撤销) | 分支、合并、冲突、rebase、撤销、reflog | 90 分钟 |
| 3 | [远程协作](#03-远程协作) | remote/fetch/pull/push、追踪分支、tag、PR 流程 | 70 分钟 |
| 4 | [gh CLI](#04-gh-cli) | repo/issue/pr/run/release/gist/api/alias | 90 分钟 |
| 5 | [GitHub 平台](#05-github-平台功能) | Issues、Projects、Actions、安全、模板、权限 | 90 分钟 |
| 6 | [进阶](#06-进阶) | bisect、worktree、submodule、LFS、hooks、签名 | 80 分钟 |
| 7 | [端到端实战](#07-端到端实战) | issue → 分支 → PR → CI → 合并 → 发布 | 60 分钟 |

## 目录

### 00 准备

- [安装与配置](00-setup/01-install-and-config.md)
- [gh 登录与权限](00-setup/02-gh-auth.md)

### 01 本地基础

- [三区模型：工作区、暂存区、版本库](01-basics/01-three-trees.md)
- [init、add、commit](01-basics/02-init-add-commit.md)
- [status 与 diff](01-basics/03-status-diff.md)
- [log：查看历史](01-basics/04-log.md)
- [.gitignore：忽略文件](01-basics/05-gitignore.md)

### 02 分支与撤销

- [branch 与 switch](02-branching/01-branch-switch.md)
- [merge 与冲突解决](02-branching/02-merge-and-conflict.md)
- [rebase：变基](02-branching/03-rebase.md)
- [stash：临时存档](02-branching/04-stash.md)
- [reset、restore、revert：三种撤销](02-branching/05-reset-restore-revert.md)
- [reflog：后悔药](02-branching/06-reflog.md)

### 03 远程协作

- [remote、fetch、pull、push](03-remotes/01-remote-fetch-pull-push.md)
- [追踪分支](03-remotes/02-tracking-branch.md)
- [tag 与版本号](03-remotes/03-tag.md)
- [fork 与 upstream](03-remotes/04-fork-and-upstream.md)
- [Pull Request 流程](03-remotes/05-pull-request-flow.md)

### 04 gh CLI

- [gh repo](04-gh-cli/01-repo.md)
- [gh issue](04-gh-cli/02-issue.md)
- [gh pr](04-gh-cli/03-pr.md)
- [gh run 与 workflow](04-gh-cli/04-run-and-workflow.md)
- [gh release](04-gh-cli/05-release.md)
- [gh gist](04-gh-cli/06-gist.md)
- [gh api：万能逃生口](04-gh-cli/07-api.md)
- [alias 与扩展](04-gh-cli/08-alias-and-extension.md)

### 05 GitHub 平台功能

- [Issues、标签与指派](05-github/01-issues-and-labels.md)
- [Projects 与 Milestones](05-github/02-projects-and-milestones.md)
- [Actions：自动化工作流](05-github/03-actions.md)
- [Releases 与 Pages](05-github/04-releases-and-pages.md)
- [安全：Dependabot、Code scanning、Secret scanning](05-github/05-security.md)
- [模板与 CODEOWNERS](05-github/06-templates-and-codeowners.md)
- [Rulesets 与权限](05-github/07-rulesets-and-permissions.md)
- [Codespaces、Webhooks、Insights](05-github/08-codespaces-webhooks-insights.md)

### 06 进阶

- [bisect：二分定位坏提交](06-advanced/01-bisect.md)
- [worktree：一份仓库多个工作区](06-advanced/02-worktree.md)
- [submodule：子模块](06-advanced/03-submodule.md)
- [LFS：管理大文件](06-advanced/04-lfs.md)
- [hooks：本地钩子](06-advanced/05-hooks.md)
- [签名提交](06-advanced/06-signed-commits.md)

### 07 端到端实战

- [从 issue 到 release](07-workflows/01-issue-to-release.md)

### 练习

- [练习 1：制造并解决一次冲突](exercises/01-conflict.md)（[答案](exercises/01-solution.md)）
- [练习 2：撤销一次误操作](exercises/02-undo.md)（[答案](exercises/02-solution.md)）
- [练习 3：用 gh 走一遍完整 PR 流程](exercises/03-gh-pr.md)（[答案](exercises/03-solution.md)）

### 速查

- [git / gh 一页速查](CHEATSHEET.md)
- [练习沙箱使用说明](labs/README.md)

## 本项目的约定

1. **术语保留英文**（index、fast-forward、rebase、detached HEAD），解释用中文。命令里的参数保持原样，方便复制。
2. **命令与输出对照**。每课的「实际输出」来自真实运行，环境为 macOS 14 + git 2.39.5 + gh 2.102.0，核对日期 2026-10。GitHub 界面与新版 git 可能略有差异。
3. **危险命令只在沙箱里做**。`reset --hard`、`rebase`、`push --force` 这类会改写或丢失历史的命令，全部配合 [`.sandbox/`](labs/README.md) 练习。
4. **不引入构建工具**。克隆后直接读，不需要装依赖。
5. **写作规范不在这里重复**。提交信息格式与 PR 描述模板见另一个学习项目 `try_markdown` 的「提交信息与 PR 描述」一课；本项目的 [Pull Request 流程](03-remotes/05-pull-request-flow.md) 只讲 git / gh 侧的操作。

## 开始之前，先跑三条

```bash
git --version
gh auth status
git config user.name && git config user.email
```

三条都有正常输出，就可以从 [安装与配置](00-setup/01-install-and-config.md) 开始。

## 参考资料

- [Pro Git（中文版）](https://git-scm.com/book/zh/v2)——最完整的 git 教材
- [git 命令手册](https://git-scm.com/docs)——每个命令的完整参数
- [gh 手册](https://cli.github.com/manual/)——所有 `gh` 子命令
- [GitHub Docs（中文）](https://docs.github.com/zh)——平台功能的官方说明
