#!/bin/bash

apt install ufw -y

ufw allow 22
ufw allow 80
ufw allow 443

ufw enable

ufw deny out from any to 10.0.0.0/8
ufw deny out from any to 172.16.0.0/12
ufw deny out from any to 192.168.0.0/16
ufw deny out from any to 100.64.0.0/10
ufw deny out from any to 198.18.0.0/15
ufw deny out from any to 169.254.0.0/16

apt install fail2ban -y
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
