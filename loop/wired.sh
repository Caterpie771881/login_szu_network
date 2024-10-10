#!/bin/bash

ID=$1
PASSWORD=$2
T=$3

log() {
    filename="`dirname $0`/task.log"
    message=$1
    echo $message && echo $message >> $filename
}

log "[INFO] 定时任务开始"

while true; do
    log "[INFO] `date`: 执行连接任务"
    RESP=$(curl -s "http://172.30.255.42:801/eportal/portal/login" -G \
    -d "user_account=$ID" \
    -d "user_password=$PASSWORD")
    if echo "$RESP" | grep -q "Portal"; then
        log "[INFO] 登陆成功"
    elif echo "$RESP" | grep -q "IP"; then
        log "[INFO] 登陆成功"
    else
        log "[WARN] 登陆失败"
    fi
    sleep $(($T*60))
done
