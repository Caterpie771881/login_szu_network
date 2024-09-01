#!/bin/bash

echo "正在检查网络环境..."
ping -c 1 -W 1 'drcom.szu.edu.cn' &> /dev/null
if [ $? -eq 0 ]; then
    echo "检查完成, 当前正处在深圳大学局域网下"
else
    echo -n "检查完成, 当前主机似乎并未接入深圳大学局域网, 是否仍要登陆? [y/N] "
    read X
    if [ "$X" = "y" ] || [ "$X" = "Y" ]; then
        :
    else
        exit 1
    fi
fi

echo "正在登陆szu校园网, 请保证主机位于深圳大学局域网下"
echo -n "请输入账号: "
read ID
echo -n "请输入密码: "
read -s PASSWORD
echo ""

RESP=$(curl -s 'https://drcom.szu.edu.cn/' -X POST \
    -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:129.0) Gecko/20100101 Firefox/129.0' \
    -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/png,image/svg+xml,*/*;q=0.8' \
    -H 'Accept-Language: zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5,en-US;q=0.3,en;q=0.2' \
    -H 'Accept-Encoding: gzip, deflate, br, zstd' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    -H 'Origin: https://drcom.szu.edu.cn' \
    -H 'Connection: keep-alive' \
    -H 'Referer: https://drcom.szu.edu.cn/a70.htm' \
    -H 'Upgrade-Insecure-Requests: 1' \
    -H 'Sec-Fetch-Dest: document' \
    -H 'Sec-Fetch-Mode: navigate' \
    -H 'Sec-Fetch-Site: same-origin' \
    -H 'Sec-Fetch-User: ?1' \
    -H 'Priority: u=0, i' \
    --data-raw "DDDDD=$ID&upass=$PASSWORD&R1=0&R2=&R6=0&para=00&0MKKey=123456")

if echo "$RESP" | grep -q "Dr.COMWebLoginID_3.htm"; then
    echo "登陆成功"
else
    echo "登陆失败"
fi
