# 练习 2 参考答案

## 场景 A：用 reflog 恢复

```bash
cd .sandbox/undo

# 制造误操作
echo "kiwi" >> fruits.txt
git commit -am "feat: 添加 kiwi"
git reset --hard HEAD~1

# 找回
git reflog
```

输出里会有一条：

```text
<sha> HEAD@{1}: commit: feat: 添加 kiwi
```

```bash
git reset --hard HEAD@{1}
git log --oneline
cat fruits.txt
```

`kiwi` 回来了。

> 也可以直接 `git reset --hard <sha>`，用 reflog 里看到的哈希。`HEAD@{1}` 依赖当前编号，操作多了会变。

## 场景 B：把提交移到另一个分支

```bash
git switch main
git switch -c feature/x
echo "lemon" >> fruits.txt
git commit -am "feat: 添加 lemon"

# 记下提交哈希
git log --oneline -1
# 假设是 abc1234

git switch -c feature/y main

# 把提交复制到 feature/y
git cherry-pick abc1234

# 回到 feature/x，移除这个提交
git switch feature/x
git reset --hard HEAD~1
```

验证：

```bash
git switch feature/y && git log --oneline -3
git switch feature/x && git log --oneline -3
```

`feature/y` 有 `feat: 添加 lemon`，`feature/x` 没有。

> 如果 `feature/x` 上这个提交之后还有别的提交，不要用 `HEAD~1`，用交互式 rebase 或 `git rebase --onto`。

## 场景 C：取消暂存并忽略

```bash
git switch main
echo "dummy" > secret.txt
git add secret.txt

# 取消暂存，保留文件
git restore --staged secret.txt

# 加入忽略
echo "secret.txt" >> .gitignore

git status
```

`secret.txt` 不再出现在 status 里，但文件还在：

```bash
ls secret.txt
```

## 三种撤销的对应关系

| 场景 | 命令 | 为什么 |
| --- | --- | --- |
| 丢了提交 | `git reset --hard HEAD@{n}` | reflog 记录了指针移动 |
| 提交到错分支 | `cherry-pick` + `reset` | 复制到目标，再从原处移除 |
| 误 add | `git restore --staged` | 只动暂存区，不动文件 |

## 常见错误

| 错误 | 问题 | 修正 |
| --- | --- | --- |
| 用 `git reset --hard HEAD~1` 恢复 | 又删了一个提交 | 从 reflog 找正确位置 |
| cherry-pick 后忘记清理原分支 | 提交重复 | 在原分支 reset 或 revert |
| 用 `git restore` 而不是 `--staged` | 文件被删掉 | `git restore --staged` 只动索引 |
| `git stash` 当撤销用 | 内容还在 stash 里，容易忘 | 明确用 restore/reset |
| 没先记哈希就 reset | 找起来更麻烦 | 动手前 `git log --oneline -3` |

## 想一想

1. 哪种误操作 reflog 救不回来？
2. `git reset --hard` 和 `git revert` 对已推送分支的影响有什么不同？
3. 场景 B 里，如果 `feature/x` 已经推送过，`reset --hard` 后推送会发生什么？

---

上一篇：[练习 2：撤销一次误操作](02-undo.md) · 下一篇：[练习 3：用 gh 走一遍完整 PR 流程](03-gh-pr.md)
