# 练习 2：撤销一次误操作

## 目标

在沙箱里制造三种常见误操作，分别用正确的命令恢复。重点不是记住命令，而是判断「该用哪一种撤销」。

## 准备

```bash
labs/new-sandbox.sh undo --force
cd .sandbox/undo
git log --oneline
```

记下当前的提交哈希，后面要用。

## 场景 A：reset --hard 丢了一个提交

1. 修改 `fruits.txt`，提交一次：
   ```bash
   echo "kiwi" >> fruits.txt
   git commit -am "feat: 添加 kiwi"
   ```
2. 执行 `git reset --hard HEAD~1`，提交消失。
3. **恢复它**，让 `git log --oneline` 重新出现 `feat: 添加 kiwi`，并且 `fruits.txt` 里有 `kiwi`。

要求：使用 reflog，不要重新手写提交。

## 场景 B：把改动提交到了错误的分支

1. 切到 `main`，创建并切到 `feature/x`。
2. 在 `feature/x` 上提交一次 `feat: 添加 lemon`。
3. 发现应该在 `feature/y` 上做，而不是 `feature/x`。
4. 把这次提交**移动到** `feature/y`，并从 `feature/x` 移除。

提示：`git cherry-pick` 和 `git reset` 配合，或 `git rebase --onto`。

## 场景 C：误把不该提交的文件加了进去

1. 在 `main` 上创建 `secret.txt`，写入任意内容。
2. `git add secret.txt`，但**还没 commit**。
3. 取消暂存，保留工作区文件。
4. 把它加入 `.gitignore`，确认 `git status` 里不再出现。

## 验收标准

- [ ] 场景 A：`git log` 里有 `feat: 添加 kiwi`，文件内容包含 `kiwi`
- [ ] 场景 B：`feature/y` 有 `feat: 添加 lemon`，`feature/x` 没有
- [ ] 场景 C：`secret.txt` 仍在磁盘上，但 `git status` 不显示，`.gitignore` 包含它
- [ ] 全程只在 `.sandbox/undo` 操作

## 提示

| 场景 | 可能用到的命令 |
| --- | --- |
| A | `git reflog`、`git reset --hard HEAD@{n}` |
| B | `git cherry-pick`、`git reset --hard`、`git branch` |
| C | `git restore --staged`、`.gitignore` |

## 完成后

对照 [参考答案](02-solution.md)。

---

上一篇：[练习 1 参考答案](01-solution.md) · 下一篇：[练习 3：用 gh 走一遍完整 PR 流程](03-gh-pr.md)
