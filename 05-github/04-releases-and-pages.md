# Releases 与 Pages

## 能学到什么

- Release 的组成和发布流程
- 用 GitHub Pages 托管静态站点
- 用 Actions 自动构建并部署 Pages
- 知道两者的权限和限制

## Release 回顾

Release = tag + 说明 + 附件。命令行的完整操作见 [gh release](../04-gh-cli/05-release.md)，这里只补平台侧的概念。

| 状态 | 谁可见 | 用途 |
| --- | --- | --- |
| Draft | 有写权限的人 | 先写好，等构建产物齐了再发 |
| Pre-release | 所有人 | 测试版、rc |
| Latest | 所有人 | 稳定版，仓库首页显示 |

发布后 GitHub 会提供：

- 源码 zip / tar.gz（自动生成）
- 你上传的二进制附件
- 每个附件的下载计数
- RSS / Atom feed

**不要上传构建产物到 git**，用 Release 附件。仓库只存源码。

## Pages 是什么

GitHub Pages 把仓库里的静态文件托管成网站：

```text
https://<user>.github.io/<repo>/
```

支持纯 HTML/CSS/JS、Jekyll、以及任何能产出静态文件的框架（Vite、Next 静态导出、Hugo 等）。

## 启用方式

仓库 → Settings → Pages → Build and deployment：

| Source | 说明 |
| --- | --- |
| Deploy from a branch | 选一个分支和目录（`/` 或 `/docs`） |
| GitHub Actions | 由 workflow 构建并部署（推荐） |

选分支方式最简单，但每次都要把构建产物提交进去。用 Actions 可以保持仓库干净。

## 用 Actions 部署

```yaml
name: pages

on:
  push:
    branches: [main]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: pages
  cancel-in-progress: true

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 22
      - run: npm ci
      - run: npm run build
      - uses: actions/configure-pages@v5
      - uses: actions/upload-pages-artifact@v3
        with:
          path: dist

  deploy:
    needs: build
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - id: deployment
        uses: actions/deploy-pages@v4
```

关键点：

| 部分 | 作用 |
| --- | --- |
| `permissions.pages: write` | 允许部署 |
| `permissions.id-token: write` | 用 OIDC 验证部署来源 |
| `upload-pages-artifact` | 把构建目录打成 Pages 产物 |
| `deploy-pages` | 发布到 Pages |
| `environment: github-pages` | 关联部署环境 |

## 纯静态文件

没有构建步骤时，直接把文件放在 `docs/`，Source 选分支的 `/docs` 目录即可。

或者用 Actions 上传一个目录：

```yaml
- uses: actions/upload-pages-artifact@v3
  with:
    path: site
```

## 自定义域名与 HTTPS

Settings → Pages → Custom domain：

1. 填域名，例如 `docs.example.com`
2. 在 DNS 里加 `CNAME` 记录指向 `<user>.github.io`
3. 等证书签发（通常几分钟到几小时）
4. 勾选 Enforce HTTPS

仓库里会生成一个 `CNAME` 文件，**不要删**。

## 常见问题

| 现象 | 原因 | 处理 |
| --- | --- | --- |
| 404 | Source 目录或分支不对 | 检查 Settings → Pages |
| 资源 404 | 站点部署在子路径，但资源用了绝对路径 `/app.js` | 配置 `base`（Vite）或 `basePath`（Next） |
| 部署卡住 | 缺少 `pages: write` 或 `id-token: write` | 补 permissions |
| 证书一直 pending | DNS 未生效 | `dig` 检查 CNAME |
| 私有仓库无法启用 | 套餐限制 | 看账户计划 |

## Release 和 Pages 的组合

常见做法：

1. 打 tag、发 Release，附件放构建产物
2. 同一次构建把文档部署到 Pages
3. README 里链接 Release 和 Pages

```yaml
on:
  release:
    types: [published]

jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: ./build.sh
      - run: gh release upload "${{ github.event.release.tag_name }}" dist/*.zip
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

`GITHUB_TOKEN` 默认有 `contents: write` 时才能上传附件；用 `permissions` 显式声明。

## 注意事项

1. **Pages 只托管静态文件**，没有服务端逻辑。需要 API 就用 Serverless 或独立服务。
2. **私有仓库的 Pages 可见性取决于套餐**，默认可能仍是公开的。
3. **部署有频率限制**，短时间内大量推送可能排队。
4. **`CNAME` 文件要保留**，删掉后自定义域名会失效。
5. **子路径部署必须配 base**，否则 CSS/JS 全部 404，这是最常见的 Pages 问题。
6. **Release 附件有大小限制**（单文件 2 GB），更大的产物用对象存储。
7. **不要用 Release 存密钥或内部构建**，公开仓库的 Release 所有人可见。

## 练习

1. 在一个测试仓库里启用 Pages，Source 选 `GitHub Actions`，用上面的 workflow 部署一个静态页。
2. 访问部署后的 URL，确认页面和资源都加载正常。
3. 创建一个 Release，上传一个 zip 附件，检查下载链接。
4. 用 `gh release view --json assets` 和 `gh api repos/{owner}/{repo}/pages` 查看状态。

---

上一篇：[Actions：自动化工作流](03-actions.md) · 下一篇：[安全：Dependabot、Code scanning、Secret scanning](05-security.md)
