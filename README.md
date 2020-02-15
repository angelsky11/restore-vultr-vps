# 说明
脚本需在墙内机器运行，自动检测vps连通性，如果不通，则删除当前vps，并且根据label查找有相同description的snapshot，并根据原vps参数从查找到的snapshot中恢复新建vps，如果找不到对应的snapshot或者vps状态不是运行中则不做操作。

要求每个vps的label唯一并且有对应的同description的snapshot，且每个snapshot的description唯一。

依赖jq


https://github.com/stedolan/jq



安装jq
```bash
wget http://stedolan.github.io/jq/download/linux64/jq -O /usr/local/bin/jq
chmod +x /usr/local/bin/jq
```

# 使用方法

下载脚本

```
wget https://raw.githubusercontent.com/angelsky11/restore-vultr-vps/master/restore-vps.sh
```

需要修改为自己的Vultr API_KEY


```bash
#vultr api
API_KEY='YOUR_VULTR_API_KEY'
```

运行

```bash
chmod +x restore-vps.sh
./restore-vps.sh main
```

可添加定时任务每10分钟检测一次


运行`crontab -e`后添加下面一行：
```
*/10 * * * * /YOUR_PATH/restore-vps.sh main
```
如果不想10分钟一次请自行搜索crontab用法


# server酱微信消息推送

https://sc.ftqq.com


修改以下两个参数
```bash
#server酱开关，0为关闭，1为开启
NOTIFICATION=0
#server酱api
SERVERCHAN_KEY='YOUR_SERVERCHAN_API'
```
  

还可添加每日报告及每周报告任务


运行`crontab -e`后添加下面两行：
```
30 22 * * * /YOUR_PATH/restore-vps.sh daily
31 22 * * 7 /YOUR_PATH/restore-vps.sh weekly
```
