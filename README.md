⚠ 深大校园网认证方式已在 2025 年 1 月替换为 srun 认证系统, 这意味着该项目已经失效。由于老系统 (drcom) 和新系统 (srun) 认证流程差别非常大, 该项目不再进行维护。需要替代方案的同学, 可以在 github 寻找 srun 的登录脚本

# login_szu_network

一个用于在命令行环境下登陆深大校园网的脚本

效果展示:

![example](./example.png)

# 使用说明

目前该项目仅支持 linux 系统

## 下载项目

```sh
git clone https://github.com/Caterpie771881/login_szu_network.git
```

## 给脚本赋予执行权限

```sh
cd login_szu_network
chmod +x login_szu_network.sh
```

## 使用 bash 执行脚本
```sh
bash login_szu_network.sh
```

# 更加跨平台的选择

什么? 你说你包不用 linux 的?

没关系, 跨平台的 python 版脚本供您选择, 只要您的操作系统支持 python, 都能使用该项目快乐上网

**注意: python 脚本的功能相对 shell 脚本要落后, 想要使用账号保存/定时任务等功能请尽量使用 shell 脚本**

## 配置 python 环境

根据自己的操作系统使用对应的配置方式, 这里不展开

## 下载项目

```sh
git clone https://github.com/Caterpie771881/login_szu_network.git
```

## 执行脚本
```sh
python login_szu_network/login_szu_network.py
```

# 先有鸡还是先有蛋
“想要上网就得先下载这个脚本，但是要下载这个脚本就得先上网”

我知道你很急, 但是你先别急

对于这个哲学问题, 有几个解决办法:

1. 使用U盘等介质将本项目拷贝到机器上
2. 如果你使用 ssh 连接到机器上, 那应该可以 ctrl-C ctrl-V 将文件内容拷贝过去
3. 使用 scp、curl 等远程传输方式将本项目传输到目标主机
4. 手动将精简版脚本 `lite.sh` 写入机器(不推荐, 容易敲错)

以防有人不知道怎么做:
```sh
# 这里假设主机上没有 vi/nano 等文本编辑器
touch lite.sh
echo 'curl -s "https://drcom.szu.edu.cn/" -X POST \'>>lite.sh
echo '-H "Content-Type:application/x-www-form-urlencoded" \'>>lite.sh
echo '--data-raw "DDDDD=$1&upass=$2&0MKKey=123456"'>>lite.sh
# 使用方式
chmod +x lite.sh
bash lite.sh 这里填您的账号 这里填您的密码
```

# 免责声明

在使用本开源项目之前，请仔细阅读以下免责声明。下载、安装、使用或以任何方式处理项目中的任何文件，即表示您同意接受本免责声明的所有条款和条件

1. 本项目仅用作学习用途，请不要用该项目擅自登录其他同学的账号、对校园网进行攻击或用作其他违法违规活动，否则您需要自行承担因违反法律或法规而导致的所有责任和后果

2. 请使用者知悉此风险：由于目前深大网络对每个账号同时登录的设备数量是有严格限制的，如果使用此项目登录校园网，可能会导致其他设备的网络掉线。作者对该风险可能产生的损失概不负责

3. 没有人能保证深圳大学校园网的认证方式一直不发生变化，因此该项目可能在未来的某一天失效。作者只能保证在毕业前（也就是 2026 年 9 月之前）受理用户发现的问题