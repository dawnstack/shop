# API Implementation Status

Last updated: 2026-03-24

## Summary

当前项目已经把一条“可运行的基础商城主流程”接到了 `API.md`：

- 已实现：登录、首页数据、商品详情、购物车读取、个人资料读取、视频推荐读取
- 部分实现：登录态缓存、Bearer 鉴权、统一响应解析、Android Docker 编译方案
- 未实现：注册、刷新 token、地址管理、购物车写操作、订单、商品搜索等

## Implemented

| Interface | Status | Code / UI | Notes |
| --- | --- | --- | --- |
| `POST /api/auth/login` | Implemented | Code + UI | 登录页已改为邮箱密码登录，成功后缓存 token 和用户信息 |
| `GET /api/user/profile` | Implemented | Code + UI | 我的页面会读取用户资料；请求失败时回退到本地缓存 |
| `GET /api/home/banners` | Implemented | Code + UI | 首页 banner 已对接真实接口 |
| `GET /api/home/categories` | Implemented | Code + UI | 首页分类区已对接真实接口 |
| `GET /api/home/recommend` | Implemented | Code + UI | 首页推荐商品已对接真实接口 |
| `GET /api/products/:id` | Implemented | Code + UI | 商品详情页会按商品 ID 再拉详情 |
| `GET /api/cart` | Implemented | Code + UI | 购物车页支持读取列表；未登录时引导登录 |
| `GET /api/videos/recommend` | Implemented | Code + UI | 视频页支持读取推荐列表 |

## Partially Implemented

| Interface / Capability | Status | Notes |
| --- | --- | --- |
| `Authorization: Bearer <access_token>` | Partial | 已自动注入请求头，但还没有 401 自动刷新与重试 |
| Unified response `code/msg/data` | Partial | 已完成统一解析；还没有按业务码做更细粒度错误映射 |
| `GET /api/user/profile` 更新缓存 | Partial | 成功后会刷新本地用户缓存，但没有用户资料编辑入口 |
| Docker Android build | Partial | 已提供 `docker-compose.yml`；是否成功取决于宿主机 Docker/OrbStack 与当前源码可编译状态 |

## Not Implemented

### Auth

| Interface | Status | Notes |
| --- | --- | --- |
| `POST /api/auth/register` | Not implemented | 无注册页面、无请求实现 |
| `POST /api/auth/refresh` | Not implemented | 无 token 刷新逻辑 |

### User

| Interface | Status | Notes |
| --- | --- | --- |
| `PUT /api/user/profile` | Not implemented | 我的页面暂无资料编辑 |

### Address

| Interface | Status | Notes |
| --- | --- | --- |
| `GET /api/user/addresses` | Not implemented | 无地址列表模块 |
| `POST /api/user/address` | Not implemented | 无新增地址模块 |
| `PUT /api/user/address/:id` | Not implemented | 无编辑地址模块 |
| `DELETE /api/user/address?id={id}` | Not implemented | 无删除地址模块 |

### Product

| Interface | Status | Notes |
| --- | --- | --- |
| `GET /api/products/search` | Not implemented | 首页推荐和详情已实现，但搜索尚未开始 |

### Cart

| Interface | Status | Notes |
| --- | --- | --- |
| `POST /api/cart` | Not implemented | 详情页还没有加入购物车动作 |
| `PUT /api/cart/:id` | Not implemented | 购物车目前只读 |
| `DELETE /api/cart?id={id}` | Not implemented | 购物车目前只读 |

### Order

| Interface | Status | Notes |
| --- | --- | --- |
| `GET /api/orders` | Not implemented | 无订单页 |
| `GET /api/orders/:id` | Not implemented | 无订单详情页 |
| `POST /api/orders` | Not implemented | 无结算/下单流程 |

### Health

| Interface | Status | Notes |
| --- | --- | --- |
| `GET /ping` | Not implemented | 暂无单独健康检查命令或页面 |

## Build Command

在 OrbStack / Docker 环境中可使用：

```bash
docker compose run --rm android-build
```

说明：

- 容器镜像：`plugfox/flutter:3.41.5-android`
- 仅构建 Android APK
- Flutter / Gradle / 配置缓存都挂到外部 Docker volume `flutter`
- Android SDK 会持久化到 volume 内的 `/flutter/android-sdk`
