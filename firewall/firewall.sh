#!/bin/bash

sudo apt-get update && sudo apt-get install -y ufw && sudo apt-get install -y fail2ban

ufw allow 22
ufw allow 80
ufw allow 443

ufw deny out from any to 10.0.0.0/8
ufw deny out from any to 172.16.0.0/12
ufw deny out from any to 192.168.0.0/16
ufw deny out from any to 100.64.0.0/10
ufw deny out from any to 198.18.0.0/15
ufw deny out from any to 169.254.0.0/16

cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
