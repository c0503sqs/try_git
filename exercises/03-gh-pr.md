# 练习 3：用 gh 走一遍完整 PR 流程

## 目标

在一个**自己的测试仓库**里，用 `gh` 完成 issue → 分支 → PR → CI → 合并 → 删除分支的完整流程。

> 不要在本项目 `try_git` 里做，除非你已经把它推到了自己的 GitHub 账号并且愿意留下测试记录。建议新建一个空仓库专门练习。

## 准备

```bash
# 建一个测试仓库（私有，避免污染公开主页）
gh repo create gh-pr-lab --private --clone --add-readme
cd gh-pr-lab
```

如果你已经有仓库，确认：

```bash
gh auth status
gh repo view
```

## 任务

1. 用 `gh issue create` 建一条 issue，标题和正文自拟，加一个标签（先确保标签存在）。
2. 从 issue 拉分支：`gh issue develop <编号> --checkout`，或手动建分支。
3. 修改 `README.md`，提交一次，提交信息符合 `feat:` / `fix:` 规范。
4. 推送分支，用 `gh pr create` 开 PR，描述里包含 `Closes #<编号>`。
5. 用 `gh pr checks` 查看 CI；仓库没有 CI 时，说明你看到了什么。
6. 用 `gh pr view --json state,mergeable` 查看状态。
7. 用 `gh pr merge --squash --delete-branch` 合并。
8. 确认 issue 已关闭、远端分支已删除、本地主分支已同步。

## 验收标准

- [ ] issue 状态为 `CLOSED`
- [ ] PR 状态为 `MERGED`
- [ ] 远端分支已删除（`git ls-remote --heads origin` 里没有）
- [ ] 本地 `main` 包含这次提交
- [ ] 全程使用 `gh`，不是只在网页上点

## 提示

| 步骤 | 命令 |
| --- | --- |
| 建标签 | `gh label create test-label --color 0e8a16` |
| 建 issue | `gh issue create --title ... --body ... --label test-label` |
| 拉分支 | `gh issue develop <编号> --checkout` |
| 开 PR | `gh pr create --base main --body "Closes #<编号>"` |
| 看 CI | `gh pr checks` |
| 合并 | `gh pr merge --squash --delete-branch` |
| 同步 | `git switch main && git pull` |

## 完成后

对照 [参考答案](03-solution.md)。

---

上一篇：[练习 2 参考答案](02-solution.md) · 下一篇：[速查表](../CHEATSHEET.md)
