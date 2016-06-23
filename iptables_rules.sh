#!/bin/bash

#define 定義埠號，讓後面的規則可以套用，減少規則的行數
srcPortNumber1="22"
dstPortNumber1="2222"
srcPortNumber2="23"
dstPortNumber2="2023"
srcPortNumber3="21,81,102,502,514,1234,1962,4000,4001,5001,5120,7000:7025,20000,32764" #Multiport最多只能塞15個PORT
srcPortNumber4="44818,49152,58455"
srcPortNumber5="21,80,81,102,443,502,514,1234,1962,4000,4001,5001,5120,7000:7025"
srcPortNumber6="20000,32764,44818,49152,58455"


#flush all rules  清除所有規則，避免有舊的規則會造成干擾
iptables -F #清除所有的已訂定的規則
iptables -X #殺掉所有使用者 "自訂" 的 chain (應該說的是 tables ）
iptables -Z #將所有的 chain 的計數與流量統計都歸零


#all drop 設定封包進入基本規則
iptables -P INPUT DROP #阻擋所有進入的封包，以下規則除外
iptables -P OUTPUT ACCEPT #允許所有封包出去
iptables -P FORWARD ACCEPT #允許所有封包轉寄

#input
iptables -A INPUT -i lo -j ACCEPT #設定 lo 成為受信任的裝置，亦即進入 lo 的封包都予以接受
iptables -A OUTPUT -i lo -j ACCEPT #設定 lo 成為受信任的裝置，亦即出去 lo 的封包都予以接受


#localhost
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
#只要已建立或相關封包就予以通過，只要是不合法封包就丟棄

#PREROUTING
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport $srcPortNumber1 -j REDIRECT --to-port $dstPortNumber1  #ssh
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport $srcPortNumber2 -j REDIRECT --to-port $dstPortNumber2  #telnet
iptables -t nat -A PREROUTING -i eth0 -p tcp --match multiport --dports $srcPortNumber5 -j REDIRECT --to-port $dstPortNumber2  #Multiple Port
iptables -t nat -A PREROUTING -i eth0 -p tcp --match multiport --dports $srcPortNumber6 -j REDIRECT --to-port $dstPortNumber2  #Multiple Port

#OUTPUT
iptables -t nat -A OUTPUT -p tcp --dport $srcPortNumber1 -j REDIRECT --to-port $dstPortNumber1  #ssh_output
iptables -t nat -A OUTPUT -p tcp --dport $srcPortNumber2 -j REDIRECT --to-port $dstPortNumber2  #telnet_output
iptables -t nat -A OUTPUT -p tcp --match multiport --dports $srcPortNumber3 -j REDIRECT --to-port $dstPortNumber2  #Multiple Port1
iptables -t nat -A OUTPUT -p tcp --match multiport --dports $srcPortNumber4 -j REDIRECT --to-port $dstPortNumber2  #Multiple Port2

#list iptables
iptables -L -n -t nat
