#!/bin/bash

#vultr api
API_KEY='YOUR_VULTR_API_KEY'
#server酱开关，0为关闭，1为开启
NOTIFICATION=0
#server酱api
SERVERCHAN_KEY='YOUR_SERVERCHAN_API_KEY'

PARM=$1
#ping检测的次数
PINGTIMES=30

readonly API_KEY
readonly NOTIFICATION
readonly SERVERCHAN_KEY
readonly PARM
readonly PINGTIMES

ADD_RESULT=0

echo -e '*****************************************************************'
echo -e '***************************** START *****************************'
echo -e '*****************************************************************'

echo -e "System is $(uname)"
case $(uname) in
	"Darwin")
		# Mac OS X 操作系统
		CHECK_PING="100.0% packet loss"
		SED_OPT='-i ""'
		;;
	"Linux")
		# GNU/Linux操作系统
		CHECK_PING="100% packet loss"
		SED_OPT='-i'
		;;
	*)
		echo -e "Unsupport System"
		exit 0	
		;;
esac

#定义主进程
function main {

	#从vultr获取vps列表
	local json=$(curl -H 'API-Key: '$API_KEY'' https://api.vultr.com/v1/server/list -s)
	
	#获取vps数量
	local NUM_VPS=$(echo $json | jq -r '.|length')
	
	for (( i = 0 ; i < $NUM_VPS ; i++ ))
	do
		echo -e '=========================seq '$i' start========================='
		
		#取得vps各项参数
		local MAIN_IP=$(echo $json | jq -r '[.[]]['$i'].main_ip')
		local VPSID=$(echo $json | jq -r '[.[]]['$i'].SUBID')
		local REGION_ID=$(echo $json | jq -r '[.[]]['$i'].DCID')
		local VPS_LOCATION=$(echo $json | jq -r '[.[]]['$i'].location')
		local VPSPLANID=$(echo $json | jq -r '[.[]]['$i'].VPSPLANID')
		local VPS_LABEL=$(echo $json | jq -r '[.[]]['$i'].label')
		local SNAPSHOT_ID=$(echo $(get_snapshot_id $VPS_LABEL))
		
		echo -e "1. checking vps "$MAIN_IP
		
		#获取vps电源状态并检测
		local POWER_STATUS=$(echo $json | jq -r '[.[]]['$i'].power_status')
		if [ $POWER_STATUS != 'running' ]
		then
			echo -e "2. this vps is not power on, skipped"
		else
			#检测snapshot_id
			if [ "$SNAPSHOT_ID" == 'NOTFOUND' ]
			then
				echo -e "3. snapshot of this vps is NOT found, skipped"
			else
				#执行ping检测
				ping -c $PINGTIMES $MAIN_IP > temp.txt 2>&1
				grep "$CHECK_PING" temp.txt
				if [ $? != 0 ]
				then
					echo -e "2. this vps is alive, nothing happened"
				else
					echo -e "2. this vps is dead, process start"
					#删除vps
					destroyVPS $API_KEY $VPSID
					#根据原参数新建vps
					createVPS $API_KEY $REGION_ID $VPSPLANID $SNAPSHOT_ID $VPS_LABEL
					#发送通知
					if [ $NOTIFICATION = 1 ]
					then
						local count=$(sed -n '1p' count.txt )
						let count=$count+1
						sed $SED_OPT "1s/^.*$/${count}/" count.txt
						if [ $ADD_RESULT = 0 ]
						then
							text="服务器下线啦！"
							desp="您在${VPS_LOCATION}的${VPS_LABEL}服务器IP:${MAIN_IP}无法连接被删除并已新建服务器。"
						else
							text="请手动修复错误！"
							desp="您在${VPS_LOCATION}的${VPS_LABEL}服务器IP:${MAIN_IP}无法连接被删除但新建服务器错误，请手动修复！"
						fi
						notification "${text}" "${desp}"
					fi
				fi
				rm -rf temp.txt
			fi	
		fi 
	done
}

#定义函数根据传入参数获取SNAPSHOTID
function get_snapshot_id {

	#读取snapshot列表
	local snapshotjson=$(curl -H 'API-Key: '$API_KEY'' https://api.vultr.com/v1/snapshot/list -s)
	#读取snapshot数量
	local NUM_SNAPSHOT=$(echo $snapshotjson | jq -r '.|length')
	
	#查找snapshot
	local SNAPSHOT_ID='NOTFOUND'
	for (( i = 0 ; i < $NUM_SNAPSHOT ; i++ ))
	do
		local snapshotid=$(echo $snapshotjson | jq -r '[.[]]['$i'].SNAPSHOTID')
		local description=$(echo $snapshotjson | jq -r '[.[]]['$i'].description')
		if [ "$1" = "$description" ]
		then
			local SNAPSHOT_ID=$snapshotid
		fi
	done
	echo -e $SNAPSHOT_ID
}

#定义函数根据VPSID删除vps
function destroyVPS {
	echo -e "3. start to delete this VPS $2"
	#删除vps
 	curl -H 'API-Key: '$1'' https://api.vultr.com/v1/server/destroy --data 'SUBID='$2'' -s
 	echo -e "4. this vps has been deleted!"
}

#定义函数根据参数新建vps
function createVPS {
	echo -e "5. start to create vps with localtion $2 plan $3 snapshot $4 label $5"
	#请求新建vps
	local result=$(curl -H 'API-Key: '$1'' https://api.vultr.com/v1/server/create --data 'DCID='$2'' --data 'VPSPLANID='$3'' --data 'OSID=164' --data 'SNAPSHOTID='$4'' --data 'label='$5'' --data 'ipv6=enable' -s)
 	#根据返回输出判断是否新建成功
	if ( echo $result | grep 'Server add failed' )
	then
		echo -e "6. create vps faild, please create manually!"	
		ADD_RESULT=1
	else 
		echo -e "6. new vps has been created!"
		ADD_RESULT=0
	fi
}

#定义函数发送serverChan通知
function notification {
	local json=$(curl -s https://sc.ftqq.com/$SERVERCHAN_KEY.send --data-urlencode "text=$1" --data-urlencode "desp=$2")
	errno=$(echo $json | jq .errno)
	errmsg=$(echo $json | jq .errmsg)
	if [ $errno = 0 ]
	then
		echo -e 'notice send success'
	else
		echo -e 'notice send faild'
		echo -e "the error message is ${errmsg}"	
	fi
}

#定义函数发送每日报告通知
function daily_check {
	local count1=$(sed -n '1p' count.txt )
	text="每日报告"
	desp="本日总共删除并新建${count1}个服务器"
	notification "${text}" "${desp}"
	local count2=$(sed -n '2p' count.txt )
	let count2=${count2}+${count1}
	sed $SED_OPT "1s/^.*$/0/" count.txt
	sed $SED_OPT "2s/^.*$/${count2}/" count.txt
}

#定义函数发送每周报告通知
function weekly_check {
	local count=$(sed -n '2p' count.txt )
	text="每周报告"
	desp="本周总共删除并新建${count}个服务器"
	notification "${text}" "${desp}"
	sed $SED_OPT "2s/^.*$/0/" count.txt
}

#根据参数执行主进程
case $PARM in
	main)
		main $API_KEY
		;;
	daily)
		#发送每日报告
		daily_check
		;;
	weekly)
		#发送每周报告
		weekly_check
		;;
	*)
		#参数错误，退出	
		echo -e "input PARM error, exit"
		echo -e "PARM is ${PARM}"
		;;	
esac		

echo -e '*****************************************************************'
echo -e '****************************** END ******************************'
echo -e '*****************************************************************'

exit 0
