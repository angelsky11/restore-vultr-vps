#!/bin/bash

#修改为自己的api_key
API_KEY='YOUR_API_KEY'
#修改为VPS总数
NUM_VPS=YOUR_NUMBER
#修改为SNAPSHOT总数
NUM_SNAPSHOT=YOUR_NUMBER

readonly API_KEY
readonly NUM_VPS
readonly NUM_SNAPSHOT

SNAPSHOT_ID='aaa'

if [ "$(uname)" = "Darwin" ]
then
	# Mac OS X 操作系统
	CHECK_PARM="100.0% packet loss"
fi
if [ "$(uname)" = "Linux " ]
then
	# GNU/Linux操作系统
	CHECK_PARM="100% packet loss"
fi

#程序主进程
function main {
	#从vultr获取vps列表
	json=$(curl -H 'API-Key: '$1'' https://api.vultr.com/v1/server/list -s)
	
	for (( i = 0 ; i < $NUM_VPS ; i++ ))
	do
		echo '=========================seq '$i' start========================='
		MAIN_IP=$(echo $json | jq -r '[.[]]['$i'].main_ip')
		echo "1. checking vps "$MAIN_IP
		ping -W 2 -c 3 $MAIN_IP | grep "$CHECK_PARM"
		if [ $? != 0 ]
		then
			echo "2. this vps is alive, nothing happened"
		else
			echo "2. this vps is dead, process start"
			#获取当前vps参数
			VPSID=$(echo $json | jq -r '[.[]]['$i'].SUBID')
			REGION_ID=$(echo $json | jq -r '[.[]]['$i'].DCID')
			VPSPLANID=$(echo $json | jq -r '[.[]]['$i'].VPSPLANID')
			VPS_LABEL=$(echo $json | jq -r '[.[]]['$i'].label')
			destroyVPS $API_KEY $VPSID
			createVPS $API_KEY $REGION_ID $VPSPLANID $(echo $(get_snapshot_id $VPS_LABEL)) $VPS_LABEL
		fi
	done
}

#根据vps label获取snapshot ID
function get_snapshot_id {
	local snapshotjson=$(curl -H 'API-Key: '$API_KEY'' https://api.vultr.com/v1/snapshot/list -s)
	for (( i = 0 ; i < $NUM_SNAPSHOT ; i++ ))
	do
		local snapshodid=$(echo $snapshotjson | jq -r '[.[]]['$i'].SNAPSHOTID')
		local description=$(echo $snapshotjson | jq -r '[.[]]['$i'].description')
		if [ "$1" = "$description" ]
		then
			SNAPSHOT_ID=$snapshodid
		fi
	done
	echo $SNAPSHOT_ID
}

#根据vps id删除vps
function destroyVPS {
	echo "3. start to delete this VPS $2"
	#销毁之前的vps		
 	#curl -H 'API-Key: '$1'' https://api.vultr.com/v1/server/destroy --data 'SUBID='$2''
 	echo '4. this vps has been deleted!'
	
}

#根据参数新建vps
function createVPS {
	echo "5. start to create vps with localtion $2 plan $3 snap $4 label $5"
	#请求新建vps
	#curl -H 'API-Key: '$1'' https://api.vultr.com/v1/server/create --data 'DCID='$2'' --data 'VPSPLANID='$3'' --data 'OSID=164' --data 'SNAPSHOTID='$4'' --data 'label='$5'' --data 'ipv6=enable' -s
	echo '6. new vps has been created!'
}

#执行主进程
main $API_KEY
