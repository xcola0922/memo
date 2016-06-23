#!/bin/bash

#define 定義埠號
srcPortNumber1="22"
dstPortNumber1="2222"
srcPortNumber2="23"
dstPortNumber2="2023"
srcPortNumber3="21,81,102,502,514,1234,1962,4000,4001,5001,5120,7000:7025,20000,32764" #Multiport最多只能塞15個PORT
srcPortNumber4="44818,49152,58455"
srcPortNumber5="21,80,81,102,443,502,514,1234,1962,4000,4001,5001,5120,7000:7025"
srcPortNumber6="20000,32764,44818,49152,58455"


#flush all rules 
iptables -F
iptables -X
iptables -Z


#all drop
iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT

#input
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -i lo -j ACCEPT


#localhost
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

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
