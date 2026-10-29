# .gitignore：忽略文件

## 能学到什么

- 写出正确的忽略规则
- 理解「已跟踪的文件不会被忽略」
- 把已误提交的文件移出版本库
- 排查某条规则为什么没生效

## 为什么需要

构建产物、依赖目录、日志、密钥都不该进版本库：

```text
node_modules/
dist/
*.log
.env
.DS_Store
```

它们要么能重新生成，要么体积大，要么不该公开。`.gitignore` 就是告诉 git「这些不用管」。

## 基本语法

```gitignore
# 注释：以 # 开头

*.log                 # 所有 .log 文件（任意目录）
!important.log        # 例外：不忽略这个文件
build/                # 任意目录下名为 build 的目录
/dist                 # 只忽略根目录下的 dist
**/temp/              # 任意深度的 temp 目录
docs/*.tmp            # docs 下一层的 .tmp，不含更深层
```

规则要点：

| 写法 | 含义 |
| --- | --- |
| `/dist` | 锚定根目录，只匹配仓库根的 `dist` |
| `dist/` | 结尾斜杠表示目录 |
| `*.log` | 通配符，匹配任意层级 |
| `!name` | 取消前面的忽略，**顺序很重要** |
| `**` | 跨任意层级 |

## 真实效果

在仓库根写入：

```gitignore
.sandbox/
.DS_Store
```

之后：

```bash
git status
```

```text
On branch main
nothing to commit, working tree clean
```

`.sandbox/` 里的所有内容都不再出现。忽略的文件用 `--ignored` 才能看见：

```bash
git status --ignored -s
```

```text
!! .sandbox/
```

## 已跟踪的文件不会被忽略

这是最常见的困惑。`.gitignore` **只影响未跟踪文件**。如果某个文件已经被 `git add` 过，之后再加进 `.gitignore` 也无效。

现象：

```bash
echo "node_modules/" >> .gitignore
git status          # node_modules 里已提交的文件仍然被跟踪
```

解决：把它从版本库里移除（保留本地文件）：

```bash
git rm -r --cached node_modules
git commit -m "chore: 停止跟踪 node_modules"
```

`--cached` 表示只从索引里删，磁盘上的文件不动。**不加 `--cached` 会连本地文件一起删掉。**

## 排查规则为什么没生效

```bash
git check-ignore -v node_modules/index.js
```

输出会指出是哪一行规则命中的：

```text
.gitignore:1:node_modules/	node_modules/index.js
```

如果没有任何输出，说明这个文件没被忽略，或者它已经被跟踪。

再确认文件是否被跟踪：

```bash
git ls-files --error-unmatch path/to/file
```

## 全局忽略

不想每个仓库都写一遍 `.DS_Store`：

```bash
git config --global core.excludesFile ~/.gitignore_global
printf '.DS_Store\n.idea/\n.vscode/\n' > ~/.gitignore_global
```

优先级从高到低：

1. `.git/info/exclude`（本仓库私有，不提交）
2. `.gitignore`（随仓库提交，团队共享）
3. 全局 `core.excludesFile`（只影响你自己）

## `.gitignore` 该不该提交

**应该。** 团队需要同一套忽略规则。个人私有的临时忽略写进 `.git/info/exclude`，不要污染共享文件。

例外：规则里包含本地路径或个人信息时，放 `.git/info/exclude`。

## 常见模板

```gitignore
# 依赖
node_modules/
vendor/

# 构建产物
dist/
build/
*.o
*.class

# 日志与临时文件
*.log
*.tmp
.cache/

# 编辑器
.idea/
.vscode/
*.swp

# 环境与密钥
.env
.env.*
!.env.example

# 系统
.DS_Store
Thumbs.db
```

注意 `!.env.example`：先忽略所有 `.env.*`，再把示例文件排除在外，保证模板能提交。

## 注意事项

1. **规则顺序有影响**。`!` 必须写在被否定的规则之后，否则不生效。
2. **`build/` 和 `build` 不同**。带斜杠只匹配目录；不带斜杠同名文件也会被忽略。
3. **不能忽略 `.git/`**。git 有专门机制，`.gitignore` 里写 `.git/` 无效。
4. **忽略不等于删除**。文件还在磁盘上，只是 git 不看它。
5. **仓库根和子目录都可以有 `.gitignore`**，规则对所在目录及其子目录生效。多层规则叠加时，用 `git check-ignore -v` 定位。
6. **空目录不会被跟踪**。git 只跟踪文件；需要保留目录结构时放一个 `.gitkeep`。

## 练习

1. 在沙箱里新建 `logs/app.log` 和 `logs/keep.log`，写规则忽略 `*.log` 但保留 `keep.log`，用 `git status -s` 验证。
2. 先 `git add` 一个文件，再把它写进 `.gitignore`，确认它仍在版本库里；然后用 `git rm --cached` 移出。
3. 用 `git check-ignore -v` 查出一条规则的来源行号。

---

上一篇：[log：查看历史](04-log.md) · 下一篇：[branch 与 switch](../02-branching/01-branch-switch.md)
