# Reverse

本目录整理 DBus 逆向分析结论、可修改项和危险接口。

## 文档

- [可修改项](./可修改项.md)
- [危险接口](./危险接口.md)
- [分析结论](./分析结论.md)

## 逆向原则

1. 先读 object/interface/property，不先调用 method。
2. 所有“修改”都必须从 RW Property 开始。
3. 所有系统级 method 默认危险。
4. 对象集合只读使用 `GetManagedObjects`，不要直接测试 `RemoveAllObjects`。
5. 对 Web 后台映射保持“推测/已验证”两级标注。
