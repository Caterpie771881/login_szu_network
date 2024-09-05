#!/bin/bash

ID=$1
PASSWORD=$2
T=$3

echo "[INFO] 定时任务开始"

while true; do
    echo "[INFO] `date`: 执行连接任务"
    RESP=(curl -s "http://172.30.255.42:801/eportal/portal/login" -G \
    -d "user_account=$ID" \
    -d "user_password=$PASSWORD")
    if echo "$RESP" | grep -q "Portal"; then
        echo "[INFO] 登陆成功"
    elif echo "$RESP" | grep -q "IP"; then
        echo "[INFO] 登陆成功"
    else
        echo "[WARN] 登陆失败"
    fi
    sleep $(($T*60))
done
