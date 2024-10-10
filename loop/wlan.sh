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
    RESP=$(curl -s "https://drcom.szu.edu.cn/" -X POST \
    -H "Content-Type:application/x-www-form-urlencoded" \
    --data-raw "DDDDD=$ID&upass=$PASSWORD&0MKKey=123456")
    if echo "$RESP" | grep -q "Dr.COMWebLoginID_3.htm"; then
        log "[INFO] 登陆成功"
    else
        log "[WARN] 登陆失败"
    fi
    sleep $(($T*60))
done
