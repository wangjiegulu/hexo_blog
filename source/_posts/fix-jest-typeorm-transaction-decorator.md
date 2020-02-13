---
title: TypeORM @Transaction 时使用 Jest 进行单元测试
subtitle: ""
tags: ["nodejs", "express", "typeorm", "decorator", "transaction"]
header-img: "https://images.unsplash.com/photo-1516738901171-8eb4fc13bd20?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2100&q=80"
centercrop: false
hidden: false
copyright: true
---

# TypeORM @Transaction 时使用 Jest 进行单元测试

> 所有细节代码见这里：<https://github.com/wangjiegulu/express_server_demo>

当使用 `Service` 使用 `@Transcation` 进行事务操作时，无法进行单元测试。

[`AccountService`](https://github.com/wangjiegulu/express_server_demo/blob/master/src/bll/AccountService.ts#L29)：

```ts
@Service()
export default class AccountService {

    @Transaction()
    async loginByWechatMiniApp(loginDetail: any, @TransactionManager() manager?: EntityManager) {
        // 业务代码省略
    }

}
```

正常运行时没有问题，但是在执行如下单元测试时报错：

[`AccountService.test.ts`](https://github.com/wangjiegulu/express_server_demo/blob/master/src/test/bll/AccountService.test.ts#L29)：

```ts
describe("loginByWechatMiniApp", ()=>{

    beforeEach(()=>{
        mockRpGet.mockClear()
        mockFindOne.mockClear()
        mockSave.mockClear()
    })

    test("login success (user not exist)", async ()=>{
        // session result validate
        mockRpGet.mockReturnValue(Promise.resolve(sessionResult_validate))
        mockFindOne.mockReturnValueOnce(Promise.resolve(null)) // find userWechat

        const user = new User()
        mockSave.mockReturnValueOnce(Promise.resolve(user)) // save user
        const userWechat = new UserWechat()
        mockSave.mockReturnValueOnce(Promise.resolve(userWechat)) // save userWechat

        mockFindOne.mockReturnValueOnce(Promise.resolve(null)) // find userLogin

        const userLogin = new UserLogin()
        userLogin.token = "tokentoken"
        mockSave.mockReturnValueOnce(Promise.resolve(userLogin)) // save userLogin

        let result = await accountService.loginByWechatMiniApp(loginDetail_validate, entityManager)

        expect(mockRpGet).toBeCalledTimes(1)
        expect(mockFindOne).toBeCalledTimes(2)
        expect(mockSave).toBeCalledTimes(3)
        expect(result.user).toEqual(user)
        expect(result.loginInfo).toEqual(userLogin)
    })
})
```

会出现如下错误：

```
loginByWechatMiniApp › login success (login success (user not exist))

    ConnectionNotFoundError: Connection "default" was not found.

      at new ConnectionNotFoundError (src/error/ConnectionNotFoundError.ts:8:9)
      at ConnectionManager.get (src/connection/ConnectionManager.ts:40:19)
      at Object.getConnection (src/index.ts:253:35)
      at AccountService.descriptor.value (src/decorator/transaction/Transaction.ts:98:24)
      at src/test/bll/AccountService.test.ts:219:43
      at src/test/bll/AccountService.test.ts:8:71
      at __awaiter (src/test/bll/AccountService.test.ts:4:12)
      at Object.<anonymous> (src/test/bll/AccountService.test.ts:202:76)
```

这是因为 `@Transaction()` 中会执行 `getConnection()` 方法，但是因为单元测试没有执行数据库连接，所以会找不到可用的 connection，报这个错，因此，为了单元测试跑通，需要在运行单元测试时，忽略掉这个 `@Transcation()` 中会执行的逻辑，因为所有的数据库操作我们都会进行 mock。

所以，如下，我们可以通过自定义 `decorator` （`XTransaction`） 来处理，创建 [`typeorm.ext.ts`](https://github.com/wangjiegulu/express_server_demo/blob/master/src/ext/typeorm.ext.ts#L7)：

```ts
import { Transaction, TransactionManager } from 'typeorm';
import { isTestEnv } from '../util/appUtil';

export function XTransaction(connectionOrOptions?) {
    let result = null
    if (!isTestEnv()) {
        result = Transaction(connectionOrOptions)
    }
    return function (target, methodName, descriptor) {
        if (!isTestEnv()) {
            result(target, methodName, descriptor)
        }
    }
}

export function XTransactionManager() {
    let result = null
    if (!isTestEnv()) {
        result = TransactionManager()
    }
    return function (object, methodName, index) {
        if (!isTestEnv()) {
            result(object, methodName, index)
        }
    }
}
```

再编辑 [`package.json`](https://github.com/wangjiegulu/express_server_demo/blob/master/package.json#L10):

```json
{
    // ...
    "scripts": {
        // ...
        "test": "NODE_ENV=test jest"
        // ...
    },
    // ...
}
```

[`appUtil.ts`](https://github.com/wangjiegulu/express_server_demo/blob/master/src/util/appUtil.ts#L11)

```ts
export let isTestEnv = () => {
    return getEnv() === 'test'
}
```

然后替换掉 [`AccountService.ts`](https://github.com/wangjiegulu/express_server_demo/blob/master/src/bll/AccountService.ts#L29) 中的 `@Transaction` 即可：

```ts
@Service()
export default class AccountService {

    @XTransaction()
    async loginByWechatMiniApp(loginDetail: any, @XTransactionManager() manager?: EntityManager) {
        // 业务代码省略
    }

}
```

最终的代码：

- [`AccountService.ts`](https://github.com/wangjiegulu/express_server_demo/blob/master/src/bll/AccountService.ts)
- [`AccountService.test.ts`](https://github.com/wangjiegulu/express_server_demo/blob/master/src/test/bll/AccountService.test.ts#L88)
- [`typeorm.ext.ts`](https://github.com/wangjiegulu/express_server_demo/blob/master/src/ext/typeorm.ext.ts#L7)