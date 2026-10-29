# Pull Request 流程

## 能学到什么

- 从分支到合并的完整步骤
- `gh pr create` 的常用参数
- 更新落后分支、处理 review 意见
- 三种合并方式的区别

## 完整流程

```text
① 同步主分支
      │
② 新建功能分支
      │
③ 提交 + 推送
      │
④ 开 PR
      │
⑤ review / 改代码 / CI
      │
⑥ 合并
      │
⑦ 删除分支
```

### ① 同步主分支

```bash
git switch main
git pull --ff-only
```

起点必须是上游最新，否则 PR 会显示一堆不属于你的差异。

### ② 新建功能分支

```bash
git switch -c feat/search-by-tag
```

分支名带上类型和意图：`feat/`、`fix/`、`docs/`、`refactor/`。不要用 `test`、`dev`、`my-branch` 这种看不出目的的名字。

### ③ 提交并推送

```bash
git add -A
git commit -m "feat(search): 支持按标签过滤"
git push -u origin feat/search-by-tag
```

### ④ 开 PR

```bash
gh pr create --base main --head feat/search-by-tag \
  --title "feat(search): 支持按标签过滤" \
  --body "## 做了什么

- 新增 tag 过滤参数
- 补充单元测试

## 怎么验证

1. \`pnpm test\`
2. 搜索页输入标签，确认结果收窄

Closes #42"
```

交互式写法：

```bash
gh pr create --fill      # 用提交信息填标题和正文
gh pr create --draft     # 开草稿 PR，方便先看 CI
gh pr create --web       # 在浏览器里填
```

`--fill` 适合只有一个提交的 PR；多个提交时正文会变成提交列表，最好手写。

### ⑤ 处理 review 和 CI

```bash
gh pr view --web           # 打开 PR 页面
gh pr checks               # 看 CI 状态
gh pr diff                 # 看 diff
gh pr review --approve     # 你是 reviewer 时批准
gh pr review --request-changes -b "说明"   # 要求修改
```

改代码后继续提交并推送，PR 会自动更新：

```bash
git add -A
git commit -m "fix: 处理 review 意见，补充边界测试"
git push
```

### ⑥ 合并

```bash
gh pr merge --squash --delete-branch
gh pr merge --merge --delete-branch
gh pr merge --rebase --delete-branch
```

| 方式 | 结果 | 适合 |
| --- | --- | --- |
| `--merge` | 生成合并提交，保留分支结构 | 想保留完整开发历史 |
| `--squash` | 所有提交压成一个 | 分支提交很碎，主分支要干净 |
| `--rebase` | 提交逐个放到主分支后面，无合并提交 | 要求线性历史 |

合并方式由仓库设置决定，有些仓库只允许一种。`gh pr merge` 不带参数时会按可用方式提示。

### ⑦ 删除分支

```bash
git switch main
git pull
git branch -d feat/search-by-tag
```

远端分支用 `--delete-branch` 在合并时顺手删，或：

```bash
git push origin --delete feat/search-by-tag
```

## 更新落后的 PR 分支

主分支有新提交后，PR 页面会提示分支落后。两种处理：

```bash
# 合并主分支进来（简单，产生合并提交）
git fetch origin
git merge origin/main
git push

# 变基到主分支（历史线性，需要 force push）
git fetch origin
git rebase origin/main
git push --force-with-lease
```

> 如果分支是多人共用（比如 release 分支），**不要 rebase**，用 merge。

## PR 描述写什么

最小结构：

```markdown
## 做了什么
- 3–5 条，按重要性排序

## 为什么
背景、关联 issue、被否决的方案

## 怎么验证
评审者可以照着执行的步骤

Closes #42
```

完整的写法、Conventional Commits 规范、截图和折叠日志技巧，见 `try_markdown` 的「提交信息与 PR 描述」一课，这里不重复。

## 关联 issue

在 PR 描述里写：

```text
Closes #42
Fixes #43
Refs #44
```

| 关键字 | 合并后 |
| --- | --- |
| `Closes` / `Fixes` | 自动关闭 issue |
| `Refs` | 只建立引用，不关闭 |

## 常见问题

| 现象 | 原因 | 处理 |
| --- | --- | --- |
| PR 里出现别人的提交 | 分支基于旧 main，或 base 选错 | 同步主分支 / 改 base |
| 显示 `This branch has conflicts` | 主分支改了同一处 | 本地 merge 或 rebase 后推送 |
| CI 一直 pending | workflow 需要批准，或额度用尽 | 看 Actions 页面 |
| 无法合并，提示 review required | 分支保护规则 | 找 CODEOWNER 批准 |
| 合并后本地 main 落后 | 只在网页上合并了 | `git switch main && git pull` |

## 注意事项

1. **一个 PR 只做一件事**。混入无关改动会拖慢 review，也让回滚困难。
2. **PR 标题会成为 squash 后的提交信息**。按提交规范写，不要写「修改」「update」。
3. **不要 force push 到共享分支**。个人功能分支可以，release 或多人分支不行。
4. **草稿 PR 也值得早开**。让别人看到方向，比写完再推翻成本低。
5. **合并前确认 CI 和 review 都过了**。管理员可以绕过保护规则，但不要滥用。
6. **合并后删分支**。不删会让分支列表膨胀，也容易误以为工作还没完成。

## 练习

1. 在沙箱的裸仓库上模拟一次完整流程：建分支、提交、推送、用 `git log` 检查。
2. 在 GitHub 上找一个自己的仓库，用 `gh pr create --draft` 开一个草稿 PR，再 `gh pr ready` 转为正式。
3. 用 `gh pr checks` 看一次 CI 状态，用 `gh pr view --web` 打开页面。
4. 分别用 `--squash` 和 `--merge` 合并两个测试 PR，对比主分支的 `git log --graph`。

---

上一篇：[fork 与 upstream](04-fork-and-upstream.md) · 下一篇：[gh repo](../04-gh-cli/01-repo.md)
