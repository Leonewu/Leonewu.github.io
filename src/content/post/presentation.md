---
title: "网络请求和状态管理"
date: 2019-03-06T10:22:03+08:00
draft: false
tags: ["umiJs"]
categories: ["umiJs"]
author: "leone"
comment: true
---



## 网络请求和状态管理

src/services/model 存放请求相关的文件  
src/models 存放状态相关文件

## 网络请求

@umijs/plugin-request 基于 umi-request 和 ahooks 的 useRequest 提供了一套统一的网络请求和错误处理方案  

### umi-request 和 axios 的区别

#### axios

- axios 浏览器端本质是基于 ajax 的封装
- 支持取消请求，原理是使用 xhr.abort() 取消，在此基础上封装 cancelToken
- 支持 Promise API 和 并发请求 `axios.all([request1(), request2()])`
- 客户端支持 CSRF 防范，需要配置 cxrfToken

#### umi-request

- 基于 fetch 的封装，可以看成是 fetch 版的 axios
- fetch 属于 es6 语法，需要 polyfill
- 支持取消请求，原理是 AbortController, 需要额外的 polyfill
- 支持跨域 `{ mode: 'cors' }`
- fetch 默认不携带 cookie， 需要配置 `{ credentials: 'include | same-origin | omit' }`，umi-request 的默认值是 `same-origin`，即跨域请求不带 cookie，与 axios 默认配置一致
- 支持 Promise API
- 虽然不支持 csrf，但我们也用不到，用到也可以自己写

### 配置和使用

在旧 op 系统我们使用的是单一的 axios 实例，对该实例进行修改，使用时再单独引入
umi-request 也可以有类似的实现，但更便捷的方法是通过配置项修改全局的实例

- 全局配置
在 src/app.ts 导出 request 对象配置全局的 request

```js
// src/app.ts

import { RequestConfig } from 'umi'
export const request: RequestConfig = {
  timeout: 1000,
  errorConfig: {},
  middlewares: [],
  requestInterceptors: [],
  responseInterceptors: []
}
```  

除了 errorConfig 和 middlewares 以外其它配置都是直接透传 umi-request 的全局配置

- 使用

```js
// 使用全局的 request 对象
import { request } from 'umi'

export default () => {
  async function fetchData() {
    return request({
      method: 'post'
    })
  }
  return {
    fetchData
  }
}

// hooks 方式
import { useRequest } from 'umi'

export default () => {
  const { data, error, loading } = useRequest(() => {
    return services.getUserList('/api/test')
  })
  if (loading) {
    return <div>loading...</div>
  }
  if (error) {
    return <div>{error.message}</div>
  }
  return <div>{data.name}</div>
}
```

## 状态管理

旧 op 用的是 vuex，写法上有清晰的 state，getter，mutation，action  
umi 也有类似的插件 @umijs/plugin-dva，思想与 vuex 一致，概念和用法有少许差别  
我们使用的状态管理插件是 @umijs/plugin-initial-state 与 @umijs/plugin-model，用法上相比于 dva 简洁

### useModel & useInitialState

ant-design-pro 默认存在两个 store，intialState 和 model  

initialState 使用的是 @umijs/plugin-initial-state，通过在 src/app.ts 导出方法 getInitialState 开启，该方法会在整个应用最开始执行，返回值会作为全局共享的数据，一般只是用来存放登录信息。该方法是同步方法，会阻塞页面加载，所以不能存放大量请求  
示例：

```js
// src/app.ts getIntialState

export async function getInitialState() {
  const currentUser = await fetchXXX()
  return {
    currentUser
  }
}


// 组件内使用

import { useModel } from 'umi'
export default () => {
  const { initialState, loading, error, refresh, setInitialState } = useModel('@@initialState')
  return <>{initialState}</>
}
```

model 使用的是 @umijs/plugin-model，约定 src/models 目录下的文件为项目的 model 文件，虽然也是全局的状态管理，但写法上更加模块化

```js
// src/model/user.ts

import { useState, useCallback } from 'react'
export default function useAuthModel() {
  const [user, setUser] = useState(null)
  const signin = useCallback((account, password) => {
    setUser({ user: XXX })
  }, [])
  const signout = useCallback(() => {
    setUser(null)
  }, [])
  return {
    user,
    signin,
    signout
  }
}


// 组件内使用

import { useModel } from 'umi'
export default () => {
  const { user, fetchUser } = useModel('user', model => ({ user: model.user, fetchUser: model.fetchUser }))
  return <>{user}</>
}
```

#### 状态初始化入口

- initialState 定义的状态初始化入口在 src/app.ts/getIntitialState 中
- useModel 定义的状态在分散的组件中初始化即可
- 如果 useModel 定义的状态需要在最开始初始化，~~请在 src/components/RightContent/index.tsx 渲染时初始化~~请在自定义 layout 渲染时初始化，目前自定义 layout 还在开发中

注意事项：

1. 由于 initialState 是同步方法，如果响应时间太长，请求太多都会阻塞应用加载，导致白屏时间过长，故 initialState 只存放登录信息
2. useModel 方法有第二个参数，使用时最好显示声明需要使用的变量，如下

```js
// src/models/user.ts

import { useState, useCallback } from 'react'
export default function useAuthModel() {
  const [user, setUser] = useState(null)
  const [auth, setAuth] = useState(null)
  const signin = useCallback((account, password) => {
    setUser({ user: XXX })
  }, [])
  const signout = useCallback(() => {
    setUser(null)
  }, [])
  const fetchAuth = useCallback(() => {
    setAuth({ auth: XXX })
  }, [])
  return {
    user,
    signin,
    signout,
    auth,
    fetchAuth
  }
}

// 示例一
import { useModel } from 'umi'
export default () => {
  const { user, fetchUser } = useModel('user')
  return <>{user}</>
}

// 示例二
import { useModel } from 'umi'
export default () => {
  const { user, fetchUser } = useModel('user', model => ({ user: model.user, fetchUser: model.fetchUser }))
  return <>{user}</>
}
```

示例一中没有显示声明 userModel 的第二个参数，只要模块 user 更新了(即使只有 auth 更新)，都会导致组件重新渲染
