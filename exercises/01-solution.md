# 练习 1 参考答案

## 完整命令

```bash
labs/new-sandbox.sh conflict --force
cd .sandbox/conflict

# 1. 创建分支并修改
git switch -c feature/a
sed -i '' 's/cherry/cherry-pie/' fruits.txt     # macOS
# Linux 用：sed -i 's/cherry/cherry-pie/' fruits.txt
git commit -am "feat: 把 cherry 改成 cherry-pie"

# 2. 回到 main 修改同一行
git switch main
sed -i '' 's/cherry/cherry-tart/' fruits.txt
git commit -am "feat: 把 cherry 改成 cherry-tart"

# 3. 合并，制造冲突
git merge feature/a
```

预期输出：

```text
Auto-merging fruits.txt
CONFLICT (content): Merge conflict in fruits.txt
Automatic merge failed; fix conflicts and then commit the result.
```

## 解决冲突

打开 `fruits.txt`，会看到：

```text
apple
banana
<<<<<<< HEAD
cherry-tart
=======
cherry-pie
>>>>>>> feature/a
date
```

改成两行都保留：

```text
apple
banana
cherry-tart
cherry-pie
date
```

然后：

```bash
git add fruits.txt
git commit -m "merge: 合并 feature/a，保留两种 cherry 命名"
```

## 验证

```bash
git status
git log --oneline --graph --all
cat fruits.txt
```

预期：

```text
*   <merge commit> merge: 合并 feature/a，保留两种 cherry 命名
|\
| * <sha> feat: 把 cherry 改成 cherry-pie
* | <sha> feat: 把 cherry 改成 cherry-tart
|/
* <sha> feat: 添加 date
```

`fruits.txt`：

```text
apple
banana
cherry-tart
cherry-pie
date
```

## 如果不想要这次合并

在 `git commit` 之前：

```bash
git merge --abort
```

工作区回到合并前。已经 `git add` 也没关系，`--abort` 会一起撤销。

## 常见错误

| 错误 | 后果 | 修正 |
| --- | --- | --- |
| 只保留一边 | 另一边的功能丢失 | 重新合并，这次保留两行 |
| 忘了 `git add` | `git commit` 提示未解决 | 先 `git add fruits.txt` |
| 把冲突标记提交进去 | 代码/文本里出现 `<<<<<<<` | 全局搜索并修复 |
| 在合并提交里用 `--amend` | 只改一个父线，结构混乱 | 用新的合并提交修正 |
| 在主仓库做实验 | 污染教程仓库 | 只在 `.sandbox/` 操作 |

## 想一想

1. 为什么 git 不能自动合并这两处改动？
2. 如果两边改的是不同行，还会冲突吗？
3. `git merge --abort` 和 `git reset --hard` 在这个场景下有什么区别？

---

上一篇：[练习 1：制造并解决一次冲突](01-conflict.md) · 下一篇：[练习 2：撤销一次误操作](02-undo.md)
