# vultrvps
一键从快照新建vultr vps脚本

**依赖jq**


https://github.com/stedolan/jq



安装jq
```
wget http://stedolan.github.io/jq/download/linux64/jq -O /usr/local/bin/jq
chmod +x /usr/local/bin/jq
```

**需要修改为自己的Vultr API_KEY**


```
#vultr api
API_KEY='YOUR_VULTR_API_KEY'
```


**支持server酱提醒，如不需要请勿打开**


```
#server酱开关，0为关闭，1为开启
NOTIFICATION=0
#server酱api
SERVERCHAN_KEY='YOUR_SERVERCHAN_API'
```

本脚本执行后    
