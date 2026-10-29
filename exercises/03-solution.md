# 练习 3 参考答案

## 完整命令

```bash
# 1. 准备仓库
gh repo create gh-pr-lab --private --clone --add-readme
cd gh-pr-lab

# 2. 建标签和 issue
gh label create test-label --color 0e8a16 --description "练习用"
issue_url=$(gh issue create \
  --title "README 补充使用说明" \
  --body "在 README 里加一段快速开始。" \
  --label test-label \
  --assignee @me)
issue_num=$(echo "$issue_url" | grep -oE '[0-9]+$')
echo "issue: #$issue_num"

# 3. 拉分支
gh issue develop "$issue_num" --checkout

# 4. 改代码并提交
printf '\n## 快速开始\n\n1. 克隆仓库\n2. 运行示例\n' >> README.md
git add README.md
git commit -m "docs: 补充快速开始"
git push -u origin HEAD

# 5. 开 PR
gh pr create \
  --base main \
  --title "docs: 补充快速开始" \
  --body "## 做了什么

- README 增加快速开始

Closes #$issue_num"

# 6. 查看状态
gh pr view --json state,mergeable
gh pr checks

# 7. 合并并删除分支
gh pr merge --squash --delete-branch

# 8. 同步本地
git switch main
git pull
```

## 验证

```bash
# issue 已关闭
gh issue view "$issue_num" --json state --jq '.state'
# CLOSED

# PR 已合并
gh pr list --state merged --limit 1

# 远端分支已删除
git ls-remote --heads origin

# 本地 main 包含提交
git log --oneline -3
```

## 关于 CI

新建的空仓库通常没有 `.github/workflows/`，所以 `gh pr checks` 可能输出：

```text
no checks reported on the 'docs/...' branch
```

这不是错误，说明仓库没有配置任何检查。想看到 CI，先在仓库里加一个 workflow，再开 PR。

## 常见问题

| 现象 | 原因 | 处理 |
| --- | --- | --- |
| `gh issue develop` 报 403 | 没有推送权限或分支已存在 | 检查仓库权限，换分支名 |
| `gh pr create` 提示没有提交 | 分支和 base 相同 | 确认提交已推送到该分支 |
| `Closes` 没生效 | 写在了评论里，或 PR 未合并 | 写进 PR 描述，合并后检查 |
| 合并被拒 | 分支保护要求 review/CI | 找 reviewer 或管理员 |
| `--delete-branch` 后本地分支还在 | 合并时你不在该分支 | 手动 `git branch -d` |
| 标签创建失败 | 同名标签已存在或颜色格式错 | `gh label list` 确认 |

## 如果合并后发现错了

已经合并的 PR 不要 `reset`，用 `revert`：

```bash
git switch main
git pull
git revert <merge-commit-sha> -m 1
git push
```

或者用 `gh pr revert`（如果版本支持），本质也是创建反向 PR。

## 想一想

1. 为什么 PR 描述里写 `Closes #42` 能自动关闭 issue，而 `Refs #42` 不能？
2. `--squash` 合并后，原来分支上的多个提交去哪了？
3. 如果合并方式被仓库限制为只允许 merge commit，`--squash` 会怎样？

---

上一篇：[练习 3：用 gh 走一遍完整 PR 流程](03-gh-pr.md) · 下一篇：[速查表](../CHEATSHEET.md)
