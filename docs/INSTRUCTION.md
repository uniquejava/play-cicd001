1. 如果在执行本地命令时网络慢或timeout,请执行emea2命令,这是我在.zshrc中定义的alias,用来设置http proxy
2. 这是前后端分离的架构, 请设置合理的ingress rule, 通过 http://domain访问前端,通过http://domain/api访问后端