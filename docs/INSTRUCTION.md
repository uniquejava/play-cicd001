1. 如果在执行本地命令时网络慢或timeout,请执行emea2或emea命令,这是我在.zshrc中定义的alias,用来设置http proxy(emea2和emea对应两个代理,一个不行就换另一个)
2. 这是前后端分离架构, 请设置合理的ingress rule, 通过 http://domain 访问前端,通过 http://domain/api 访问后端
3. 在重建重要的aws resource比如EKS, ECS时, 记得每次都取一个新的cluster名, 防止aws缓存
4. 给所有的aws resource打上合适的tag,方便维护
5. 不要轻易删除整个.terraform目录,仅删除需要升级的provider
6. 本地执行search(find命令)前能不能确认一下当前目录, 不要总是在子目录下find东西