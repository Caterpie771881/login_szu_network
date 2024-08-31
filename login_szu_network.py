import requests
import getpass

print('正在登陆szu校园网, 请保证主机位于深圳大学局域网下')
myid = input('请输入账号: ')
password = getpass.getpass('请输入密码: ')

resp = requests.post(
    url='https://drcom.szu.edu.cn/',
    headers={
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:129.0) Gecko/20100101 Firefox/129.0',
        'Accept-Language': 'zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5,en-US;q=0.3,en;q=0.2',
        'Accept-Encoding': 'gzip, deflate, br, zstd',
        'Content-Type': 'application/x-www-form-urlencoded',
        'Origin': 'https://drcom.szu.edu.cn',
        'Connection': 'keep-alive',
        'Referer': 'https://drcom.szu.edu.cn/a70.htm',
        'Upgrade-Insecure-Requests': '1',
        'Sec-Fetch-Dest': 'document',
        'Sec-Fetch-Mode': 'navigate',
        'Sec-Fetch-Site': 'same-origin',
        'Sec-Fetch-User': '?1',
        'Priority': 'u=0, i',
    },
    data=f"DDDDD={myid}&upass={password}&R1=0&R2=&R6=0&para=00&0MKKey=123456"
)

if "Dr.COMWebLoginID_3.htm" in resp.text:
    print("登陆成功")
else:
    print("登陆失败")
