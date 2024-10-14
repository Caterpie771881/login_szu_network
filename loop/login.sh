#!/bin/bash

NW=$1
ID=$2
PASSWORD=$3
T=$4

log() {
    filename="`dirname $0`/task.log"
    message=$1
    echo $message && echo $message >> $filename
}

wired() {
    RESP=$(curl -s "http://172.30.255.42:801/eportal/portal/login" -G \
    -d "user_account=$ID" \
    -d "user_password=$PASSWORD")
    if echo "$RESP" | grep -q "Portal"; then
        log "[INFO] 登陆成功"
    elif echo "$RESP" | grep -q "IP"; then
        log "[INFO] 登陆成功"
    else
        log "[WARN] 登陆失败"
        FAIL+=1
    fi
}

wlan() {
    RESP=$(curl -s "https://drcom.szu.edu.cn/" -X POST \
    -H "Content-Type:application/x-www-form-urlencoded" \
    --data-raw "DDDDD=$ID&upass=$PASSWORD&0MKKey=123456")
    if echo "$RESP" | grep -q "Dr.COMWebLoginID_3.htm"; then
        log "[INFO] 登陆成功"
    else
        log "[WARN] 登陆失败"
        FAIL+=1
    fi
}

log "[INFO] 定时任务开始"

FAIL=0

while true; do
    log "[INFO] `date`: 执行连接任务"
    if [ "$NW" = '无线网' ]; then
        wlan
    elif [ "$NW" = '有线网' ]; then
        wired
    else
        log "[ERROR] 未知的网络: $NW"
        break
    fi
    if [ $FAIL > 5 ]; then
        log "[ERROR] 失败次数过多, 已结束任务"
        break
    fi
    sleep $(($T*60))
done
