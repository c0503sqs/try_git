# 练习沙箱

`git` 有一部分命令会**改写历史或丢数据**：`reset --hard`、`rebase`、`push --force`、`filter-repo`。这些命令值得学会，但不值得在本项目里试。

所以本项目把练习和资料分开：

| 目录 | 用途 | 能否乱来 |
| --- | --- | --- |
| 仓库根目录（`00-setup/` … `07-workflows/`） | 教程正文 | 不要做实验，只提交正常改动 |
| `.sandbox/` | 一次性练习仓库 | 随便折腾，删了重建即可 |

`.sandbox/` 已写进 `.gitignore`，不会进入版本库。

## 新建沙箱

```bash
labs/new-sandbox.sh demo
cd .sandbox/demo
```

脚本会创建一个只有 3 个提交的小仓库：

```text
* feat: 添加 date
* feat: 添加水果清单
* docs: 初始化沙箱项目
```

`--force` 可以删掉重建：

```bash
labs/new-sandbox.sh demo --force
```

> 沙箱里用的是独立身份 `Try Git <try-git@example.com>`，不会动你的全局配置。

## 建议的工作方式

1. 读一课，复制里面的命令到沙箱里跑。
2. 跑坏了就 `labs/new-sandbox.sh <名字> --force`。
3. 想验证「命令到底改了什么」，先 `git status` + `git log --oneline --graph --all` 拍个快照，再执行，再拍一次对比。

## 沙箱也救不了的情况

- 你 `cd` 到主仓库后跑 `git reset --hard`。
- 你 `push --force` 到真实的远程仓库。

做任何一条之前，先看一遍这一课开头的**风险提示**。
