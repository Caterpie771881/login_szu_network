#!/bin/bash

ID=$1
PASSWORD=$2
T=$3

echo "[INFO] 定时任务开始"

while true; do
    echo "[INFO] `date`: 执行连接任务"
    RESP=(curl -s "https://drcom.szu.edu.cn/" -X POST \
    -H "Content-Type:application/x-www-form-urlencoded" \
    --data-raw "DDDDD=$ID&upass=$PASSWORD&0MKKey=123456")
    if echo "$RESP" | grep -q "Dr.COMWebLoginID_3.htm"; then
        echo "[INFO] 登陆成功"
    else
        echo "[WARN] 登陆失败"
    fi
    sleep $(($T*60))
done
