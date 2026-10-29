# bisect：二分定位坏提交

## 能学到什么

- 用 `git bisect` 在几十上百个提交里定位「第一个坏提交」
- 用 `git bisect run` 自动跑测试
- 知道退出码的含义
- 用 `bisect log` / `replay` 复盘

## 解决什么问题

「上周还好好的，现在坏了」——但中间有 200 个提交，不知道是哪个引入的。

逐个 checkout 测试太慢。`bisect` 用二分法：每次砍掉一半范围，200 个提交大约 8 次就能定位。

```text
good ... ? ? ? ? ? ? ? ? ... bad
          ↑ 每次测试中间那个
```

## 手动流程

```bash
git bisect start
git bisect bad                  # 当前版本是坏的
git bisect good v1.1.0          # 这个版本是好的
```

git 会切到一个中间的提交，输出：

```text
Bisecting: 1 revision left to test after this (roughly 1 step)
[bedf74e] commit 3
```

然后你测试当前代码：

- 有问题 → `git bisect bad`
- 没问题 → `git bisect good`
- 这个提交没法测（编译不过、依赖缺失）→ `git bisect skip`

重复，直到输出：

```text
bedf74ea4e00cf9f3f2520f8c402f3f14ae5fdb7 is the first bad commit
```

结束时：

```bash
git bisect reset      # 回到原来的分支
```

## 自动流程：bisect run

把手动判断写成脚本，返回码表达结果：

```bash
#!/usr/bin/env bash
if grep -q BUG app.txt; then
  exit 1      # 1 = bad
else
  exit 0      # 0 = good
fi
```

```bash
git bisect start
git bisect bad HEAD
git bisect good HEAD~4
git bisect run ./test.sh
```

实测输出：

```text
running  './test.sh'
Bisecting: 0 revisions left to test after this (roughly 0 steps)
[0507e98] commit 2
running  './test.sh'
bedf74ea4e00cf9f3f2520f8c402f3f14ae5fdb7 is the first bad commit
commit bedf74ea4e00cf9f3f2520f8c402f3f14ae5fdb7
Author: Try Git <try-git@example.com>
Date:   Thu Oct 29 21:03:15 2026 +0800

    commit 3

 app.txt | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)
bisect found first bad commit
```

### 退出码约定

| 退出码 | 含义 |
| --- | --- |
| `0` | good |
| `1`–`127`（除 125） | bad |
| `125` | skip（无法测试） |
| `128` 及以上 | 中止 bisect |

测试脚本里不要用 `exit 2` 表示「不确定」，那会被当成 bad。跳过一个提交用 `exit 125`。

## 用测试命令直接跑

不写脚本，直接跑已有测试：

```bash
git bisect run npm test
git bisect run -- ./scripts/check.sh --fast
```

注意：**退出码 0 才算 good**。很多测试工具失败时返回 1，正好符合约定。

## 记录与复盘

```bash
git bisect log > bisect.log
git bisect replay bisect.log
```

`log` 记录每一步的 good/bad/skip，出问题时可以重放。团队排查时把 log 贴进 issue 很有用。

## 自定义术语

适合「性能退化」这类不是「坏掉」的问题：

```bash
git bisect start --term-old=fast --term-new=slow
git bisect slow
git bisect fast
git bisect reset
```

## 注意事项

1. **bisect 会切到 detached HEAD**，结束一定 `git bisect reset`，否则你会停在某个历史提交上。
2. **未提交的改动会阻碍 bisect**。开始前提交或 stash，否则 git 会拒绝切换。
3. **测试脚本必须能独立运行**。依赖外部服务、数据库的测试要先准备好。
4. **skip 太多会降低准确度**。大量提交无法测试时，bisect 可能给出「无法确定」。
5. **退出码 128+ 会中止**，脚本里捕获异常时别让它冒泡成 128。
6. **bisect 只找第一个坏提交**，不负责修复；找到后用 `git show` 看改动，再决定 revert 还是修。
7. **合并历史会让范围判断变复杂**，`--first-parent` 可以限定只沿主线二分。

## 练习

1. 在沙箱里造 8 个提交，在第 5 个引入一个能被 `grep` 发现的错误，用 `git bisect run` 定位。
2. 故意让某个提交无法测试，用 `exit 125` 跳过，观察结果是否仍然正确。
3. 用 `git bisect log` 保存过程，`git bisect reset` 后再 `git bisect replay` 复现。
4. 用 `--term-old` / `--term-new` 把 good/bad 改成「快/慢」，模拟性能问题排查。

---

上一篇：[Codespaces、Webhooks、Insights](../05-github/08-codespaces-webhooks-insights.md) · 下一篇：[worktree：一份仓库多个工作区](02-worktree.md)
