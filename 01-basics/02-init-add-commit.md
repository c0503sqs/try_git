# init、add、commit

## 能学到什么

- 新建仓库：`git init` 和 `git clone` 的区别
- `git add` 的几种写法和 `-p` 的用法
- 写出可读的提交信息
- 用 `--amend` 修补上一次提交

## 新建仓库

```bash
mkdir my-project && cd my-project
git init
```

实测输出：

```text
Initialized empty Git repository in /Users/shenqiusheng/workspaces/try_git/.git/
```

`git init` 只做一件事：在目录下创建 `.git/` 子目录。里面的东西是 git 的全部数据：

```text
.git/
├── HEAD          # 当前在哪个分支
├── config        # 本仓库的配置
├── index         # 暂存区
├── objects/      # 所有文件内容和提交对象
└── refs/         # 分支和 tag 指向哪里
```

**删掉 `.git/` 等于删掉全部历史**。反过来，只要 `.git/` 还在，工作区文件删光也能恢复。

常用变体：

```bash
git init -b main          # 初始分支叫 main（2.28+）
git init --bare repo.git  # 裸仓库，没有工作区，通常用作远端
```

`git clone` 则是「复制一个已有仓库」：

```bash
git clone https://github.com/cli/cli.git
git clone git@github.com:cli/cli.git
git clone --depth 1 https://github.com/cli/cli.git   # 只拉最近一次提交
```

区别：`init` 从零开始，`clone` 自带远端配置和完整历史。

## add：挑选要提交的内容

```bash
git add README.md        # 单个文件
git add src/             # 整个目录
git add .                # 当前目录下所有改动（含新文件）
git add -A               # 整个仓库所有改动
git add -u               # 只加已跟踪文件的修改和删除，不含新文件
```

**`-p`（patch）是最值得学的写法**：它把改动拆成一个个 hunk，让你逐块决定要不要暂存。

```bash
git add -p
```

交互提示：

```text
@@ -1,3 +1,4 @@
 apple
 banana
 cherry
+date
(1/1) Stage this hunk [y,n,q,a,d,s,e,?]?
```

常用按键：

| 键 | 含义 |
| --- | --- |
| `y` | 暂存这一块 |
| `n` | 跳过这一块 |
| `s` | 把这一块再拆小 |
| `e` | 手动编辑要暂存的行 |
| `q` | 退出，已选的不撤销 |
| `?` | 查看全部按键 |

用途：一次改了三个不相关的 bug，想拆成三个提交时，`git add -p` 比手动改文件快得多。

## commit：把暂存区写进历史

```bash
git commit -m "feat: 添加水果清单"
```

不带 `-m` 会打开编辑器写多行信息。

常用组合：

```bash
git commit -am "fix: 修正拼写"   # 对已跟踪文件先 add 再 commit（新文件无效）
git commit --amend               # 修改上一次提交（信息或内容）
git commit --amend --no-edit     # 补文件但保留原提交信息
```

`--amend` 的实际效果是**用新提交替换上一个提交**，不是「修改」：

```text
修改前：  A ← B
修改后：  A ← B'
```

所以已经推送到远端的提交不要 amend，否则本地和远端分叉，只能靠 force push 解决。

## 提交信息怎么写

最小要求是让人在 `git log --oneline` 里看得懂：

```text
feat: 添加水果清单
fix: 修复空列表导出崩溃
docs: 补充安装说明
refactor: 拆分配置加载逻辑
```

格式是 `类型: 描述`，具体规范（Conventional Commits、正文、脚注）见 `try_markdown` 的「提交信息与 PR 描述」一课，这里不重复。

常见但无效的写法：

| 不推荐 | 问题 |
| --- | --- |
| `update` | 更新了什么？ |
| `fix bug` | 哪个 bug？ |
| `修改` | 等于没说 |
| `WIP` | 提交进主干了就永远查不到上下文 |

## 一次完整的首次提交流程

```bash
mkdir demo && cd demo
git init -b main
printf '# Demo\n' > README.md
git add README.md
git commit -m "docs: 初始化项目说明"
git log --oneline
```

```text
4c1b7a2 docs: 初始化项目说明
```

## 注意事项

1. **提交前先看 `git diff --staged`**。它才是你即将提交的内容；`git status` 只告诉你哪些文件变了。
2. **`git add .` 会把不该提交的文件也加进去**。先配好 `.gitignore`，见下一课。
3. **`--amend` 会改变提交哈希**。已经 push 过的提交 amend 后需要 `git push --force-with-lease`，并且在多人分支上要提前沟通。
4. **`-m` 里可以写多行**：`git commit -m "标题" -m "正文"` 会生成标题 + 空行 + 正文。
5. **提交粒度**：一个提交只做一件事。改了三处不相关的代码就拆三次提交，回滚和 review 都更容易。
6. **空提交**：`git commit --allow-empty -m "chore: 触发 CI"` 可以创建不含改动的提交，偶尔用于触发流水线。

## 练习

1. 在 `.sandbox/` 下新建一个目录，`git init -b main`，提交两个文件。
2. 修改两个文件的不同位置，用 `git add -p` 只暂存其中一个 hunk，提交后确认另一个仍是未暂存状态。
3. 用 `git commit --amend --no-edit` 把漏掉的文件补进上一次提交，观察 `git log --oneline` 里的哈希变化。

---

上一篇：[三区模型](01-three-trees.md) · 下一篇：[status 与 diff](03-status-diff.md)
