# LFS：管理大文件

## 能学到什么

- 为什么大文件不适合直接提交
- 用 Git LFS 跟踪大文件
- 克隆、拉取、迁移已有大文件
- 知道 GitHub 的大小限制和配额

## 为什么需要 LFS

git 会把每个版本的文件完整存进对象库。一个 200 MB 的视频，改 10 次就是 2 GB，而且 clone 时所有人都要下载全部历史。

GitHub 的限制：

| 限制 | 数值 |
| --- | --- |
| 单文件警告 | 50 MB |
| 单文件硬限制 | 100 MB |
| 仓库推荐上限 | 1 GB（超出会提醒） |

超过 100 MB 的文件直接推不上去：

```text
remote: error: File big.zip is 150.00 MB; this exceeds GitHub's file size limit of 100.00 MB
```

## LFS 的原理

LFS 把大文件存到单独的存储，仓库里只保留一个**指针文件**：

```text
version https://git-lfs.github.com/spec/v1
oid sha256:4d7a214614ab2935c943f9e0ff69d22eadbb8f32b1258daaa5e2ca24d17e2393
size 123456789
```

检出时由 LFS 客户端把指针替换成真实文件。

## 安装与启用

```bash
brew install git-lfs        # macOS
git lfs install             # 每个用户执行一次
```

`git lfs install` 会写入全局 hooks，让 clone/checkout 自动处理指针。

## 跟踪文件类型

```bash
git lfs track "*.psd"
git lfs track "*.mp4"
git lfs track "assets/**/*.zip"
```

会写入 `.gitattributes`：

```text
*.psd filter=lfs diff=lfs merge=lfs -text
*.mp4 filter=lfs diff=lfs merge=lfs -text
assets/**/*.zip filter=lfs diff=lfs merge=lfs -text
```

**`.gitattributes` 必须提交**，否则别人 clone 后不知道哪些文件走 LFS。

然后正常提交：

```bash
git add .gitattributes
git add design.psd
git commit -m "feat: 添加设计稿"
git push
```

## 查看

```bash
git lfs ls-files
git lfs status
git lfs env
```

`git lfs ls-files` 列出当前被 LFS 管理的文件：

```text
a1b2c3d4e5 * design.psd
```

## 克隆与拉取

装了 LFS 后普通 clone 会自动下载大文件。CI 里没装时：

```bash
git lfs install --local      # 只对当前仓库
git lfs pull                 # 显式拉取
```

只想拿指针、不要大文件（比如做静态检查）：

```bash
GIT_LFS_SKIP_SMUDGE=1 git clone <url>
```

之后需要时再 `git lfs pull`。

## 把已有大文件迁进 LFS

已经提交过的大文件，需要用 `git lfs migrate` 重写历史：

```bash
git lfs migrate import --include="*.psd,*.mp4" --everything
```

`--everything` 会重写所有分支和 tag。**这会改变所有相关提交的哈希**，推送时必须 force push：

```bash
git push --force-with-lease --all
git push --force-with-lease --tags
```

执行前：

1. 备份仓库
2. 通知所有协作者
3. 确认没有人有未推送的工作

## GitHub 配额

LFS 存储和流量有免费额度，超出按量计费。查看用量：Settings → Billing → Git LFS Data。

大文件很多时，考虑：

- Release 附件（单文件 2 GB）
- 对象存储（S3、R2）
- 构建时下载，不纳入仓库

## 注意事项

1. **`.gitattributes` 不提交，LFS 等于没配**。别人 clone 会拿到指针文件而不是内容。
2. **LFS 只对新加入的文件生效**。已经提交的历史文件要 `migrate` 才会转过去。
3. **migrate 会重写历史**，协作分支上执行前必须全员同步。
4. **LFS 不是免费无限存储**，视频、数据集很容易超配额。
5. **CI 要装 git-lfs**，很多基础镜像默认没有。
6. **LFS 文件不能直接 diff**，`git diff` 只会显示指针变化。
7. **删除 LFS 文件不会立刻释放配额**，历史里的对象仍占空间，需要清理或联系支持。

## 练习

1. `git lfs install` 后跟踪 `*.bin`，确认 `.gitattributes` 生成并提交。
2. 提交一个较大的二进制文件，用 `git lfs ls-files` 确认它走 LFS。
3. 用 `GIT_LFS_SKIP_SMUDGE=1 clone` 得到指针，再 `git lfs pull` 取回内容。
4. 在一个测试仓库里用 `git lfs migrate import` 迁移历史文件，比较迁移前后的 `git log` 哈希。

---

上一篇：[submodule：子模块](03-submodule.md) · 下一篇：[hooks：本地钩子](05-hooks.md)
