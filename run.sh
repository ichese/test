#!/bin/sh
#1为测试服 非1都为正式服
flag=0
if [ ! -z $2 ] 
then 
    if [ $2 = 1 ]
    then
        flag=0
    fi
fi
#如果想排查问题的话，建议设置gameboxip
app="agent-box"
gamebox_ip=""    
trap "" 2 9
#jt=`i=1;while [ $i -le 20 ]; do cat /jffs2/accelbox/ams/auth.amsdb | cut -d "\"" -f $i; let i++;done | grep -A 2 jwttoken | tail -n 1`
#uid=`i=1;while [ $i -le 20 ]; do cat /jffs2/accelbox/ams/login.amsdb | cut -d "\"" -f $i; let i++;done | grep -A 2 user_id | tail -n 1`
killall accel-guard 2>/dev/null
mv /jffs2/accelbox/accel-guard /jffs2/accelbox/accel-guard1 2>/dev/null
killall ams agent-box 2>/dev/null
check_ip(){
i=1
while [ $i -le 4 ]
do
    a=`echo $1 | cut -d '.' -f $i`
    if [  -z $a ]
    then
        echo "ip is wrong~"
        exit
    else
    	if [ $a -ge 0 ]
	then
	    echo "" >/dev/null
	else
	    echo "ip is wrong~"
            exit
	fi
    fi     
    let i++
done          
}
if [ -z $1 ]
then
    continue
else
    b=`echo $1 | awk -F '.' '{print$2}' | grep -Ev "^$" | wc -l`
    if [ $b -eq 0 ]
    then
        echo "ip is wrong~"
        exit
    fi
    check_ip $1
    oip=`cat /tmp/new_nodes.json  | grep -A 1 '"nodeId":101' | grep ip | cut -d ':' -f 2 | tr -d "\"|,"`
    sed -i "s/$oip/$1/g" /tmp/new_nodes.json 
fi
echo "please wait~~~~~~"
sn=`cat /builtin/device/SN`
key=`cat /builtin/security/secret`
timestamp=`date +%s`
sign=`echo -n "deviceId=$sn&timeStamp="$timestamp"&key=$key" | md5sum | awk '{print$1}'`
if [ $flag -eq 1 ]
then
    login_url='https://test-api.xunyou.mobi/api/v2/android/sessions?grant_type=game_box'
    auth_url='https://test-api.xunyou.mobi/api/v1/android/sessions?grant_type=client_credentials&version=2.0.0&service=game_box'
else
    login_url='https://api.xunyou.mobi/api/v2/android/sessions?grant_type=game_box'
    auth_url='https://api.xunyou.mobi/api/v1/android/sessions?grant_type=client_credentials&version=2.0.0&service=game_box'
fi
echo -ne "[---10%---]\r"
curl -s  -m 8 -H 'Authorization: WSSE profile="UsernameToken"' -H 'X-WSSE: UsernameToken Username="Game", PasswordDigest="hilhyuSEFI7SQOjuF2uZZGoWaes=", Nonce="1470538636", Created="2023-03-30T04:58:35Z"' \
        -H 'Content-Type:application/json' -H 'Expect:' -d '{"deviceId":"'$sn'","timeStamp":'$timestamp',"sign":"'$sign'"}' -X POST -i --url ''$login_url'' --compressed  -k  | grep '"resultCode":0' 2>&1 >/dev/null
if [ $? -ne 0 ]
then
    echo "login info wrong,bye~"
    exit
fi
echo -ne "[---20%---]\r"
login_result=`curl -s  -m 8 -H 'Authorization: WSSE profile="UsernameToken"' -H 'X-WSSE: UsernameToken Username="Game", PasswordDigest="hilhyuSEFI7SQOjuF2uZZGoWaes=", Nonce="1470538636", Created="2023-03-30T04:58:35Z"' \
        -H 'Content-Type:application/json' -H 'Expect:' -d '{"deviceId":"'$sn'","timeStamp":'$timestamp',"sign":"'$sign'"}' -X POST -i --url ''$login_url'' --compressed  -k`
userid=`echo ${login_result##*userId} | cut -d ',' -f 1 | tr -d '"|:'`
echo -ne "[---30%---]\r"
atoken=`echo ${login_result##*accessToken} | cut -d ',' -f 1 | tr -d '"|:'`
echo -ne "[---50%---]\r"
auth_result=`curl -s  -m 8 -H 'Content-Type: application/json' -H 'Expect:' -d '{"deviceId":"'$sn'", "userId":"'$userid'","token":"'$atoken'"}' -X POST -i  --url ''$auth_url'' --compressed  -k`
echo -ne "[---70%---]\r"
jwt=`echo ${auth_result##*accelToken} | cut -d ',' -f 1 | tr -d '"|:'`
echo -ne "[---100%---]\r"
gamebox_ip(){
    while [ 1 ]
    do 
        ip neigh | grep br0 | awk '{print$1}' | while read line
        do
            ipset add gamebox $line 2>/dev/null
        done
        sleep 1
    done
}
if [ -z $gamebox_ip ]
then
    gamebox_ip &
else
    ./$app -u $userid -t "Bearer $jwt"  -s black  -n ./new_nodes.json -d "101,101"  --gamebox-ip "$gamebox_ip" --ip-white-list wip.list --ip-black-list bip.list --domain-white-list w.list --domain-black-list b.list  --script box.lua | grep -Ev Courier
    exit
fi
./$app   \
	-u $userid \
	-t "Bearer $jwt" \
	-s black \
	-n ./new_nodes.json \
	-d "101,101" \
	--guid "android" \
	--game-uid "503e3a034af44631b497caa1b862d3ba" \
	--ip-white-list wip.list \
	--ip-black-list bip.list \
	--domain-white-list w.list \
	--domain-black-list b.list \
	--script box.lua | grep -Ev Courier


killall   run.sh
