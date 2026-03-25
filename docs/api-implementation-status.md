# API Implementation Status

Last updated: 2026-03-25

## Summary

当前项目已经把一条“可运行的基础商城主流程”接到了 `API.md`：

- 已实现：登录、注册、刷新 token、个人资料读写、首页数据、商品搜索、商品详情、个性化推荐、购物车读写、视频推荐读取、地址管理、普通下单、秒杀下单、订单查看、健康检查
- 部分实现：登录态缓存、统一响应解析、Docker Web 构建方案
- 未实现：无

## Implemented

| Interface | Status | Code / UI | Notes |
| --- | --- | --- | --- |
| `POST /api/auth/register` | Implemented | Code + UI | 注册页已实现，成功后会直接缓存登录态并返回主页 |
| `POST /api/auth/login` | Implemented | Code + UI | 登录页已改为邮箱密码登录，成功后缓存 token 和用户信息 |
| `POST /api/auth/refresh` | Implemented | Code | 已支持 access token 过期后的自动刷新与原请求重试 |
| `GET /api/user/profile` | Implemented | Code + UI | 我的页面会读取用户资料；请求失败时回退到本地缓存 |
| `PUT /api/user/profile` | Implemented | Code + UI | 我的页面已提供资料编辑页，可更新昵称和头像 URL |
| `GET /api/user/addresses` | Implemented | Code + UI | 地址页支持读取当前用户地址列表 |
| `POST /api/user/address` | Implemented | Code + UI | 地址页支持新增地址 |
| `PUT /api/user/address/:id` | Implemented | Code + UI | 地址页支持编辑地址 |
| `DELETE /api/user/address?id={id}` | Implemented | Code + UI | 地址页支持删除地址 |
| `GET /api/home/banners` | Implemented | Code + UI | 首页 banner 已对接真实接口 |
| `GET /api/home/categories` | Implemented | Code + UI | 首页分类区已对接真实接口 |
| `GET /api/home/recommend` | Implemented | Code + UI | 首页推荐商品已对接真实接口 |
| `GET /api/home/recommend/personalized` | Implemented | Code + UI | 首页在登录态下会展示“为你推荐”个性化商品区 |
| `GET /api/products/search` | Implemented | Code + UI | 首页已提供搜索入口，支持关键字和排序筛选 |
| `GET /api/products/:id` | Implemented | Code + UI | 商品详情页会按商品 ID 再拉详情 |
| `GET /api/cart` | Implemented | Code + UI | 购物车页支持读取列表；未登录时引导登录 |
| `POST /api/cart` | Implemented | Code + UI | 商品详情页支持选择数量并加入购物车 |
| `PUT /api/cart/:id` | Implemented | Code + UI | 购物车页支持调整数量和勾选状态 |
| `DELETE /api/cart?id={id}` | Implemented | Code + UI | 购物车页支持删除购物车项 |
| `GET /api/orders` | Implemented | Code + UI | 已提供订单列表页 |
| `GET /api/orders/:id` | Implemented | Code + UI | 已提供订单详情页 |
| `POST /api/orders` | Implemented | Code + UI | 购物车页支持选择地址并提交订单 |
| `POST /api/seckill/orders` | Implemented | Code + UI | 商品详情页已提供秒杀下单入口，支持选择地址后下单 |
| `GET /api/videos/recommend` | Implemented | Code + UI | 视频页支持读取推荐列表 |
| `GET /ping` | Implemented | Code + UI | 我的页已提供服务状态页，展示服务名和环境信息 |

## Partially Implemented

| Interface / Capability | Status | Notes |
| --- | --- | --- |
| `Authorization: Bearer <access_token>` | Partial | 已自动注入请求头，也支持 401 自动刷新与重试；但尚未做更细的并发/失效态交互处理 |
| Unified response `code/msg/data` | Partial | 已完成统一解析；还没有按业务码做更细粒度错误映射 |
| `GET /api/user/profile` 更新缓存 | Partial | 资料读取和编辑后会刷新本地用户缓存，但仍未拆分更细的本地状态同步策略 |
| Docker Web build | Implemented | 已提供 `web-build` 和 `web-preview` 服务，当前可成功构建 `build/web` |

## Not Implemented

当前 `API.md` 里的移动端业务接口已全部接入；`GET /metrics` 为监控抓取口，不作为移动端业务调用目标。

## Build Command

在 OrbStack / Docker 环境中可使用：

```bash
docker compose run --rm web-build
docker compose up web-preview
```

说明：

- 容器镜像：`plugfox/flutter:3.41.5-web`
- Web 构建产物输出到 `build/web`
- `web-preview` 会通过 `http://localhost:8081` 提供静态预览
- Flutter / Pub / 构建缓存都挂到外部 Docker volume `flutter`
