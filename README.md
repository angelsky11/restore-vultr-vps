# vultrvps
一键从快照新建vultr vps脚本

**依赖jq**
https://github.com/stedolan/jq

**需要修改脚本内以下几个值**

```
#vultr api
API_KEY='YOUR_API_KEY'
#地区
REGION_ID='YOUR_REGION_ID'
#套餐种类
PLAN_ID='YOUR_PLAN_ID'
#快照编号
SNAPSHOT_ID='YOUR_SNAPSHOT_ID'
#主机标签
VPS_LABEL='YOUR_ID'
```

**REGION_ID列表**
```
    "DCID": "6","name": "Atlanta"
    
    "DCID": "2","name": "Chicago"
    
    "DCID": "3","name": "Dallas"
    
    "DCID": "5","name": "Los Angeles"
    
    "DCID": "39","name": "Miami"
    
    "DCID": "1","name": "New Jersey"
    
    "DCID": "4","name": "Seattle"
    
    "DCID": "12","name": "Silicon Valley"

    "DCID": "40","name": "Singapore"

    "DCID": "7","name": "Amsterdam"
 
    "DCID": "25","name": "Tokyo"
 
    "DCID": "8","name": "London"

    "DCID": "24","name": "Paris"
 
    "DCID": "9","name": "Frankfurt"

    "DCID": "22","name": "Toronto"

    "DCID": "19","name": "Sydney"
```

**PLAN_ID列表**
```
    "PLAN_ID": "201","name": "1024 MB RAM,25 GB SSD,1.00 TB BW"
    
    "PLAN_ID": "202","name": "2048 MB RAM,55 GB SSD,2.00 TB BW"

    "PLAN_ID": "203","name": "4096 MB RAM,80 GB SSD,3.00 TB BW"

    "PLAN_ID": "204","name": "8192 MB RAM,160 GB SSD,4.00 TB BW"
 
    "PLAN_ID": "205","name": "16384 MB RAM,320 GB SSD,5.00 TB BW"

    "PLAN_ID": "206","name": "32768 MB RAM,640 GB SSD,6.00 TB BW"

    "PLAN_ID": "207","name": "65536 MB RAM,1280 GB SSD,10.00 TB BW"

    "PLAN_ID": "208","name": "98304 MB RAM,1600 GB SSD,15.00 TB BW"
```
