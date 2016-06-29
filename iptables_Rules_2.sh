iptables_rules.sh                                                                                                                             << buffers 
#!/bin/bash
   
#define 定義埠號，讓後面的規則可以套用，減少規則的行數
srcPortNumber1="22"
dstPortNumber1="2222"
srcPortNumber2="23"
dstPortNumber2="2023"
srcPortNumber3="21,81,102,502,514,1234,1962,4000,4001,5001,5120,7000:7025,20000,32764"
srcPortNumber4="44818,49152,58455"
srcPortNumber5="21,80,81,102,443,502,514,1234,1962,4000,4001,5001,5120,7000:7025"
srcPortNumber6="20000,32764,44818,49152,58455"
ip="192.168.1.1,192.168.1.2"

#flush all rules  清除所有規則，避免有舊的規則會造成干擾
iptables -F #清除所有的已訂定的規則
iptables -X #殺掉所有使用者 "自訂" 的 chain (應該說的是 tables ）
iptables -Z #將所有的 chain 的計數與流量統計都歸零

#all drop 設定封包進入基本規則
iptables -P INPUT DROP #阻擋所有進入的封包，以下規則除外
iptables -P OUTPUT ACCEPT #允許所有封包出去
iptables -P FORWARD ACCEPT #允許所有封包轉寄
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT #只要已建立或相關封包就予以通過，只要是不合法封包就丟棄

#allow
iptables -A INPUT -i lo -j ACCEPT #設定 lo 成為受信任的裝置，亦即進入 lo 的封包都予以接受
iptables -A OUTPUT -i lo -j ACCEPT #設定 lo 成為受信任的裝置，亦即出去 lo 的封包都予以接受

#下面的規則允許特定IP導到SSH 22 Port，這樣才能進行管理，因為後面的規則其它連線會導到kippo的port
iptables -t nat -A PREROUTING -i eth0 -p tcp -s $ip --dport 22 -j ACCEPT 
iptables -A INPUT -i eth0 -p tcp -s $ip --dport 22 -j ACCEPT #允許 SSH 22 PORT 連線進入

#PREROUTING 將外部連線進來的Port(22)重新導向到新的Port(2222)
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport $srcPortNumber1 -j REDIRECT --to-port $dstPortNumber1  #ssh
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport $srcPortNumber2 -j REDIRECT --to-port $dstPortNumber2  #telnet
#-t nat -A PREOUTING(網路位址的轉換)將外部連線進來的封包重新導向
#-i 指向網路卡
#-p tcp --dport $srcPortNumber 指定封包類型tcp，埠號對應最上面所定義的來源埠號數值
#-j REDIRECT --to-port $dstPortNumber 將封包導向最上面所定義的目的地埠號數值

iptables -t nat -A PREROUTING -i eth0 -p tcp --match multiport --dports $srcPortNumber5 -j REDIRECT --to-port $dstPortNumber2  #Multiple Port
iptables -t nat -A PREROUTING -i eth0 -p tcp --match multiport --dports $srcPortNumber6 -j REDIRECT --to-port $dstPortNumber2  #Multiple Port
#-p tcp --match multiport --dports $srcPortNumber 埠號對應最上面所定義的來源埠號數值，此為多埠號所使用的參數

#下面的規則允許PREROUTING進來的port可以進入到kippo的port
iptables -A INPUT -i eth0 -p tcp --match multiport --dport $dstPortNumber1 -j ACCEPT
iptables -A INPUT -i eth0 -p tcp --match multiport --dport $dstPortNumber2 -j ACCEPT
 
#list iptables　列出目前的防火牆規則
iptables -L -n -t nat
#iptables -L 列出目前的 table 的規則
#iptables -n 不進行 IP 與 HOSTNAME 的反查
#iptables -t nat 後面接 table ，例如 nat 或 filter ，若省略此項目，則使用預設的 filter 
