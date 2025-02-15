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

input_id_and_pwd() {
    echo -n "请输入账号: "
    read ID
    echo -n "请输入密码: "
    read -s PASSWORD
    echo ""
}

remember_me() {
    echo -n "是否要保存账密信息? [y/N] "
    read X
    local filename="`dirname $0`/memory"
    if [ "$X" = "y" ] || [ "$X" = "Y" ]; then
        ID_=`echo $ID |tr -d '\n' |od -An -tx1|tr -d '*\n' |tr ' ' %`
        PASSWORD_=`echo $PASSWORD |tr -d '\n' |od -An -tx1 |tr -d '*\n' |tr ' ' %`
        echo "$ID_;$PASSWORD_" > $filename
    fi
}

urldecode() {
    local regex='s/\\/\\\\/g;s/\(%\)\([0-9a-fA-F][0-9a-fA-F]\)/\\x\2/g'
    printf $(echo -n $1 | sed $regex) 2>/dev/null
}

read_memory() {
    local filename="`dirname $0`/memory"
    ID_=`cat $filename | awk -F';' '{print \$1}'`
    ID=$(urldecode $ID_)
    PASSWORD_=`cat $filename | awk -F';' '{print \$2}'`
    PASSWORD=$(urldecode $PASSWORD_)
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

browser='User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:129.0) Gecko/20100101 Firefox/129.0'
wlan_login() {
    RESP=$(curl -s 'https://drcom.szu.edu.cn/' -X POST \
        -H "$browser" \
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
        -H "$browser" \
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
    elif echo "$RESP" | grep -q "IP"; then
        echo "登陆成功"
        return 2
    else
        echo "登陆失败"
        return 0
    fi
}

set_timed_task() {
    echo -n "是否需要设置定时任务防掉线? [y/N] "
    read X
    if [ "$X" = "y" ] || [ "$X" = "Y" ]; then
        check_screen
        CHECK=$?
        if [ $CHECK -eq 0 ]; then
            echo "screen 功能异常, 可能无法设置定时任务"
            echo "是否仍要尝试创建? [y/N]"
            read X
            if [ "$X" = 'y' ] || [ "$X" = 'Y' ]; then
                :
            else
                return 0
            fi
        elif [ $CHECK -eq 2 ]; then
            echo "已存在定时任务, 是否覆盖或停止任务?"
            echo "[1]覆盖 [2]停止 [other]保持不变"
            read X
            if [ "$X" = '1' ]; then
                close_timed_task
            elif [ "$X" = '2' ]; then
                close_timed_task
                echo "已停止"
                return 0
            else
                return 0
            fi
        fi
        create_timed_task
    fi
}

create_timed_task() {
    echo -n "请输入间隔时间(单位: min) "
    read T
    if ! [[ "$T" =~ ^[0-9]+$ ]]; then
        echo "非法输入, 已停止创建定时任务"
        return 0
    fi
    local filename="`dirname $0`/loop/login.sh"
    chmod +x $filename
    create_screen login_szu_network "bash $filename $NW $ID $PASSWORD $T"
    echo "已创建定时任务"
}

close_timed_task() {
    PID=`screen -ls | grep -w login_szu_network | awk '{print $1}' | cut -d '.' -f1`
    kill -9 $PID
    screen -wipe &> /dev/null
}

check_screen() {
    screen --version &> /dev/null
    if [ $? -eq 0 ]; then
        screen_sessions=$(screen -ls)
        if echo "$screen_sessions" | grep -q "login_szu_network"; then
            return 2
        fi
        return 1
    fi
    return 0
}

create_screen() {
    screen -dmS login_szu_network
    screen -x -S $1 -p 0 -X stuff "$2\n"
}

after_login() {
    if [ $MEM -eq 0 ]; then
        remember_me
    fi
    set_timed_task
}

#=============== mian ===============

show_logo

check_screen
if [ $? -eq 2 ]; then
    filename="`dirname $0`/loop/task.log"
    if tail -n 1 $filename | grep "ERROR"; then
        close_timed_task
    else
        echo -n "检测到已存在的定时任务, 是否要停止? [y/N]"
        read X
        if [ "$X" = "y" ] || [ "$X" = "Y" ]; then
            close_timed_task
        fi
    fi
fi

echo "正在检查网络环境..."
ping -c 1 -W 1 'drcom.szu.edu.cn' &> /dev/null
if [ $? -eq 0 ]; then
    echo "检查完成, 当前正处在深圳大学WLAN环境下"
    NW='无线网'
else
    ping -c 1 -W 1 '172.30.255.42' &> /dev/null
    if [ $? -eq 0 ]; then
        echo "检查完成, 当前正处在深圳大学有线网络环境下"
        NW='有线网'
    else
        network_notfound
    fi
fi

echo "正在登陆szu校园网 [$NW]"
read_memory
MEM=0
if [ $? -eq 0 ]; then
    echo -n "检测到用户记录: [$ID]; 是否使用该用户登录 [Y/n] "
    read X
    if [ "$X" = "n" ] || [ "$X" = "N" ]; then
        input_id_and_pwd
    else
        MEM=1
    fi
else
    input_id_and_pwd
fi

if [ "$NW" = '无线网' ]; then
    wlan_login
    if [ $? -eq 1 ]; then
        after_login
    fi
elif [ "$NW" = '有线网' ]; then
    wired_login
    if [ $? -eq 1 ]; then
        after_login
    fi
else
    echo "未知的网络: $NW"
fi
