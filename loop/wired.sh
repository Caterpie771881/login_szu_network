#!/bin/bash

ID=$1
PASSWORD=$2
T=$3

echo "[INFO] 定时任务开始"

while true; do
    echo "[INFO] `date`: 准备执行连接任务"
    curl -s "http://172.30.255.42:801/eportal/portal/login" -G \
    -d "user_account=$ID" \
    -d "user_password=$PASSWORD"
    sleep $(($T*60))
done
