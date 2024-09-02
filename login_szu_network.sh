#!/bin/bash

show_logo() {
echo "  _             _                                                                    _     "
echo " | |           (_)                                             _                    | |    "
echo " | | ___   ____ _ ____        ___ _____ _   _      ____   ____| |_ _ _ _  ___   ____| |  _ "
echo " | |/ _ \ / _  | |  _ \      /___|___  ) | | |    |  _ \ / _  )  _) | | |/ _ \ / ___) | / )"
echo " | | |_| ( ( | | | | | |    |___ |/ __/| |_| |    | | | ( (/ /| |_| | | | |_| | |   | |< ( "
echo " |_|\___/ \_|| |_|_| |_|    (___/(_____)\____|    |_| |_|\____)\___)____|\___/|_|   |_| \_)"
echo "         (_____|                                                                           "
}

network_notfound() {
    echo -n "当前主机似乎并未接入深圳大学局域网, 是否仍要登陆? [y/N] "
    read X
    if [ "$X" = "y" ] || [ "$X" = "Y" ]; then
        echo -n "请选择登入方式: [1] 无线网 [2] 有线网 "
        read X
        if [ "$X" = 1 ]; then
            NW='无线网'
        elif [ "$X" = 2 ]; then
            NW='有线网'
        else
            exit 1
        fi
    else
        exit 1
    fi
}

wlan_login() {
    RESP=$(curl -s 'https://drcom.szu.edu.cn/' -X POST \
        -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:129.0) Gecko/20100101 Firefox/129.0' \
        -H 'Accept: */*' \
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
        --data-raw "DDDDD=$ID&upass=$PASSWORD&0MKKey=123456")

    if echo "$RESP" | grep -q "Dr.COMWebLoginID_3.htm"; then
        echo "登陆成功"
        return 1
    else
        echo "登陆失败"
        return 0
    fi
}

wired_login() {
    IP=$(hostname -I | awk '{print $1}')
    RESP=$(curl -s "http://172.30.255.42:801/eportal/portal/login" -G \
        -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:129.0) Gecko/20100101 Firefox/129.0' \
        -H 'Accept: */*' \
        -H 'Accept-Language: zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5,en-US;q=0.3,en;q=0.2' \
        -H 'Accept-Encoding: gzip, deflate, br, zstd' \
        -H 'Connection: keep-alive' \
        -H "Referer: http://172.30.255.42/" \
        -d "callback=dr1003" \
        -d "login_method=1" \
        -d "wlan_user_ip=$IP" \
        -d "wlan_ac_ip=172.30.255.41" \
        -d "user_account=%2C0%2C$ID" \
        -d "user_password=$PASSWORD")
    #FIXME: 这个地方的判别规则还未验证
    if echo "$RESP" | grep -q "Portal"; then
        echo "登陆成功"
        return 1
    elif echo "$RESP" | grep -1 "IP"; then
        echo "登陆成功"
        return 2
    else
        echo "登陆失败"
        return 0
    fi
}

set_timed_task() {
    # echo -n "是否需要设置定时任务防掉线? [y?N] "
    # read X
    # if [ "$X" = "y" ] || [ "$X" = "Y" ]; then
    #     echo -n "请输入间隔时间(单位: min) [1-59] "
    #     read T
    #     if [[ "$T" =~ ^[1-59]$ ]]; then
    #         # 写入定时脚本
    #         */"$T" * * * * /path/to/myscript.sh
    #         echo "已创建定时任务"
    #     else
    #         echo "创建定时任务失败"
    #     fi
    # fi
}

show_logo
echo "正在检查网络环境..."
ping -c 1 -W 1 'drcom.szu.edu.cn' &> /dev/null
if [ $? -eq 0 ]; then
    echo "检查完成, 当前正处在深圳大学WLAN局域网下"
    NW='无线网'
else
    ping -c 1 -W 1 '172.30.255.42' &> /dev/null
    if [ $? -eq 0 ]; then
        echo "检查完成, 当前正处在深圳大学有线局域网下"
        NW='有线网'
    else
        network_notfound
    fi
fi

echo "正在登陆szu校园网 [$NW]"
echo -n "请输入账号: "
read ID
echo -n "请输入密码: "
read -s PASSWORD
echo ""

if [ "$NW" = '无线网' ]; then
    wlan_login
    if [ $? -eq 1 ]; then
        set_timed_task
    fi
elif [ "$NW" = '有线网' ]; then
    wired_login
    if [ $? -eq 1 ]; then
        set_timed_task
    fi
else
    echo "未知的网络: $NW"
fi
