#!/bin/bash

#修改为自己的api_key
API_KEY='YOUR_API'
#新建vps的机房id
REGION_ID='YOUR_REGION_ID'
#新建vps的套餐种类
PLAN_ID='YOUR_ID'
#新建vps的快照id
SNAPSHOT_ID='YOUR_SNAPSHOT_ID'
#新建vps标签
VPS_LABEL='YOUR_LABEL'

readonly API_KEY
readonly REGION_ID
readonly PLAN_ID
readonly SNAPSHOT_ID
readonly VPS_LABLE

#从vultr获取vps列表
curl -H 'API-Key: '$API_KEY'' https://api.vultr.com/v1/server/list -o vps.json -s

#按照格式获取json
cat vps.json | jq '[.[] | {vpsid:.SUBID,label:.label}]' > vpsf.json

for (( i = 0 ; i < 5 ; i++ ))
#for i in $(seq 0 ${#arrlength[*]})
do
	label=$(cat vpsf.json | jq -r '.['$i'].label')
	vpsid=$(cat vpsf.json | jq -r '.['$i'].vpsid')
	if [ $label = $VPS_LABEL ]
	then
		#销毁之前的vps		
 		curl -H 'API-Key: '$API_KEY'' https://api.vultr.com/v1/server/destroy --data 'SUBID='$vpsid''		
 		echo 'old vps has been deleted!'
	fi
done

#请求新建vps
curl -H 'API-Key: '${API_KEY}'' https://api.vultr.com/v1/server/create --data 'DCID='${REGION_ID}'' --data 'VPSPLANID='${PLAN_ID}'' --data 'OSID=164' --data 'SNAPSHOTID='${SNAPSHOT_ID}'' --data 'label='${VPS_LABEL}'' --data 'ipv6=enable'
echo 'new vps has been created!'

#删除临时文件
rm -rf vps.json
rm -rf vpsf.json
