# for wlan
curl -s "https://drcom.szu.edu.cn/" -X POST \
-H "Content-Type:application/x-www-form-urlencoded" \
--data-raw "DDDDD=$1&upass=$2&0MKKey=123456"
# for wired
# curl -s "http://172.30.255.42:801/eportal/portal/login" -G \
# -d "user_account=$1" \
# -d "user_password=$2"