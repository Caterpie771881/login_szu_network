#!/bin/bash

ID=$1
PASSWORD=$2
T=$3

echo "[INFO] 定时任务开始"

while true; do
    echo "[INFO] `date`: 准备执行连接任务"
    curl -s "https://drcom.szu.edu.cn/" -X POST \
    -H "Content-Type:application/x-www-form-urlencoded" \
    --data-raw "DDDDD=$ID&upass=$PASSWORD&0MKKey=123456"
    sleep $(($T*60))
done
