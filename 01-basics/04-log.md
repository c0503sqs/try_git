# log：查看历史

## 能学到什么

- 用 `--oneline --graph --all` 一眼看全历史
- 按作者、时间、文件、内容搜索提交
- 自定义输出格式
- 用 `git show` 看单次提交

## 最常用的组合

```bash
git log --oneline --graph --all --decorate
```

沙箱里的真实输出：

```text
* a8636f3 (HEAD -> main) feat: 添加 date
* f183ba8 feat: 添加水果清单
* 48138fd docs: 初始化沙箱项目
```

| 参数 | 作用 |
| --- | --- |
| `--oneline` | 每个提交一行：短哈希 + 标题 |
| `--graph` | 用 ASCII 画分支合并结构 |
| `--all` | 显示所有分支和 tag，不只当前分支 |
| `--decorate` | 显示 `HEAD`、分支名、tag 指向哪个提交（新版 git 默认开启） |

日常可以配成别名：

```bash
git config --global alias.lg "log --oneline --graph --all --decorate"
```

## 默认输出

```bash
git log -1
```

```text
commit a8636f3500ff3f4f1f0c1ee548c8df5d21da39fc
Author: Try Git <try-git@example.com>
Date:   Thu Oct 29 20:54:52 2026 +0800

    feat: 添加 date
```

四部分：完整哈希、作者、时间、提交信息。`a8636f3` 是完整哈希 `a8636f35...` 的缩写，git 会自动选择不歧义的最短长度。

## 限制数量

```bash
git log -3                 # 最近 3 条
git log -n 5               # 同上
git log --since="2 weeks ago"
git log --until="2026-10-01"
git log --author="Try Git"
git log --grep="date"      # 搜索提交信息
git log --first-parent     # 只看主线，忽略被合并进来的提交
```

组合：

```bash
git log --since="1 month ago" --author="c0503sqs" --oneline
```

## 按文件

```bash
git log -- fruits.txt          # 影响这个文件的提交
git log --stat -- fruits.txt   # 附带每次的改动行数
git log -p -- fruits.txt       # 附带完整 diff
```

`--` 后面是路径，用来和分支名、选项区分开。**养成加 `--` 的习惯**，文件名和分支名重名时不会出错。

## 按内容搜索：pickaxe

```bash
git log -S "date" --oneline
```

```text
a8636f3 feat: 添加 date
```

`-S` 找出「某字符串出现次数发生变化」的提交，也就是谁加进来、谁删掉了这段代码。比 grep 历史文件准确得多。

相关参数：

| 参数 | 作用 |
| --- | --- |
| `-S <string>` | 字符串数量变化 |
| `-G <regex>` | diff 内容匹配正则 |
| `--grep <regex>` | 匹配提交信息 |

## 自定义格式

```bash
git log --pretty=format:'%h %an %ar %s' -3
```

```text
a8636f3 Try Git 15 seconds ago feat: 添加 date
f183ba8 Try Git 15 seconds ago feat: 添加水果清单
48138fd Try Git 15 seconds ago docs: 初始化沙箱项目
```

常用占位符：

| 占位符 | 含义 |
| --- | --- |
| `%h` / `%H` | 短 / 完整哈希 |
| `%an` / `%ae` | 作者名 / 邮箱 |
| `%ad` | 作者日期（配 `--date=short` 等） |
| `%ar` | 相对时间（「15 seconds ago」） |
| `%s` | 标题 |
| `%b` | 正文 |
| `%d` | 装饰（分支、tag） |

```bash
git log --date=short --pretty=format:'%h %ad %an %s'
```

```text
a8636f3 2026-10-29 Try Git feat: 添加 date
f183ba8 2026-10-29 Try Git feat: 添加水果清单
48138fd 2026-10-29 Try Git docs: 初始化沙箱项目
```

想导出给别的工具处理，末尾加 `--no-merges` 并配合 `| cat` 去掉分页：

```bash
git --no-pager log --pretty=format:'%H,%ad,%an,%s' --date=short > history.csv
```

## show：看单个提交

```bash
git show HEAD
git show a8636f3
git show HEAD~1          # 上一个提交
git show HEAD:fruits.txt # 某个提交里某个文件的内容
```

`git show HEAD` 的输出和 `git log -1 -p` 一样：提交信息 + 完整 diff。

## 其他有用的查看方式

```bash
git log --oneline --graph --all --decorate
git log --merges --oneline          # 只看合并提交
git log --no-merges --oneline       # 排除合并提交
git log --reverse --oneline         # 从旧到新
git shortlog -sn                    # 按作者统计提交数
git blame README.md                 # 每一行是谁改的
```

## 注意事项

1. **`git log` 默认分页**，看到 `:` 是在 `less` 里。`q` 退出，`/` 搜索，空格翻页。
2. **只显示当前分支**。看不到其他分支的提交时，加 `--all`。
3. **合并提交默认压缩显示**。想看被合并分支的全部提交，用 `git log --graph --all` 或对某个提交加 `-m`。
4. **`git log -p` 在大仓库上很慢**，加路径或 `-n` 限制范围。
5. **时间顺序不等于拓扑顺序**。`--date-order` / `--topo-order` 可以控制排序；多分支并行时 `--graph` 更可靠。
6. **`git blame` 找的是最后一次改动**，不是真正的责任人。重构、格式化会污染归属，重大决策还要看提交信息和 PR。

## 练习

1. 用 `--oneline --graph --all` 查看沙箱历史，数出有几个提交。
2. 用 `-S` 找出哪次提交引入了 `date`，再用 `git show` 看它的完整改动。
3. 写一条 `--pretty=format` 命令，输出「短哈希 | 日期 | 标题」，日期用 `YYYY-MM-DD`。
4. 用 `git shortlog -sn` 看每个作者贡献了多少提交。

---

上一篇：[status 与 diff](03-status-diff.md) · 下一篇：[.gitignore：忽略文件](05-gitignore.md)
