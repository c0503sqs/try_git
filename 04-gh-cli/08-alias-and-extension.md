# alias 与扩展

## 能学到什么

- 用 `gh alias` 把长命令变短
- 用 `--shell` 写带管道的别名
- 安装和升级 `gh` 扩展
- 知道别名和扩展各自的适用场景

## alias：命令别名

```bash
gh alias set pv 'pr view'
gh pv 123          # 等价于 gh pr view 123
```

带固定参数的别名：

```bash
gh alias set bugs 'issue list --label=bug'
gh bugs
```

覆盖已有别名：

```bash
gh alias set pv 'pr view --web' --clobber
```

查看和删除：

```bash
gh alias list
gh alias delete pv
```

`gh` 自带一个默认别名：

```text
co: Alias for "pr checkout"
```

也就是 `gh co 123` 等于 `gh pr checkout 123`。

## 用 shell 写复杂别名

默认别名只做参数替换，不能包含管道。需要 shell 语法时加 `--shell`（或 `-s`）：

```bash
gh alias set --shell my-prs 'pr list --author @me --json number,title --jq ".[] | \"\(.number) \(.title)\""'
```

原理是执行 `sh -c`，所以能写管道、重定向、变量：

```bash
gh alias set --shell failed-runs 'run list --status failure --limit 5'
gh alias set --shell today 'search issues --created ">=$(date +%Y-%m-%d)"'
```

> `--shell` 别名会执行任意 shell 命令。从别人那里复制别名时先读懂内容，不要直接 `gh alias import`。

## 从文件导入

```bash
gh alias import aliases.yml
```

`aliases.yml` 格式：

```yaml
pv: pr view
bugs: issue list --label=bug
```

导入会合并到现有别名，同名需要 `--clobber` 才能覆盖（按版本行为为准，导入前先 `gh alias list` 备份）。

## 扩展：给 gh 加新命令

扩展是独立的可执行文件，安装后像内置命令一样使用：

```bash
gh extension install owner/gh-extension-name
```

参数（来自 `gh extension install --help`）：

| 参数 | 作用 |
| --- | --- |
| `--force` | 强制升级，或忽略已是最新 |
| `--pin <ref>` | 固定到某个 tag 或提交 |

常用扩展：

```bash
gh extension install github/gh-copilot
gh extension install dlvhdr/gh-dash
gh extension install mislav/gh-branch
```

查看、升级、删除：

```bash
gh extension list
gh extension upgrade --all
gh extension remove gh-dash
gh extension search dash
```

安装后命令名通常是 `gh-` 后面的部分：

```bash
gh dash
gh copilot suggest "列出最近修改的 Python 文件"
```

## 自己写一个扩展

```bash
gh extension create my-tool
```

会生成一个仓库骨架，核心是一个名为 `gh-my-tool` 的可执行脚本。任何语言都行，只要：

1. 文件名以 `gh-` 开头
2. 可执行
3. 放到 `~/.local/share/gh/extensions/gh-my-tool/`（`gh extension install` 会自动处理）

最小示例：

```bash
#!/usr/bin/env bash
# gh-hello
echo "hello from gh extension"
gh api user --jq '.login'
```

## alias 还是扩展

| | alias | extension |
| --- | --- | --- |
| 本质 | 命令替换 / shell 片段 | 独立程序 |
| 复杂度 | 一行 | 任意 |
| 分发 | 手动或 `alias import` | 通过 GitHub 仓库 |
| 适合 | 常用命令缩写 | 新功能、复杂逻辑 |

简单缩写用 alias，需要状态、配置、多文件就别硬塞进 shell。

## 注意事项

1. **别名不能覆盖内置命令**（例如不能把 `pr` 定义成别的东西），会报冲突。
2. **`--shell` 别名有安全风险**，只导入自己写或审核过的。
3. **别名里不要硬编码仓库名**，用 `{owner}/{repo}` 占位符或 `-R` 参数更通用。
4. **扩展升级可能改变行为**，CI 或脚本里用 `--pin` 固定版本。
5. **扩展本质是可执行程序**，安装第三方扩展等于运行别人的代码，确认来源可信。
6. **`gh alias list` 的输出可以备份**，换机器时用 `gh alias import` 恢复。

## 练习

1. 创建一个别名 `gh pv` 等于 `gh pr view`，用 `gh alias list` 确认。
2. 用 `--shell` 写一个别名，列出自己最近 5 个 PR。
3. 安装一个官方扩展（如 `github/gh-copilot`），用 `gh extension list` 查看。
4. 用 `gh extension create demo-tool` 生成骨架，运行 `gh demo-tool` 看输出。

---

上一篇：[gh api：万能逃生口](07-api.md) · 下一篇：[Issues、标签与指派](../05-github/01-issues-and-labels.md)
