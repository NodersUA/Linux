#!/bin/bash

# Logo
curl -s https://raw.githubusercontent.com/NodersUA/Scripts/main/logo.sh | bash

CPU_THRESHOLD=98
RAM_THRESHOLD=98
DISK_THRESHOLD=90

CPU_NOTIFICATION=False
RAM_NOTIFICATION=False
DISC_NOTIFICATION=True


# Need ssh not to prompt for typing YES

# Update the repositories
echo -e "\e[1m\e[32m ****** Update the repositories ****** \e[0m" && sleep 1
if ! command -v pip &> /dev/null; then
sudo apt update && apt upgrade -y
apt install pip -y
fi

#=======================================================================

# Clone repository
echo -e "\e[1m\e[32m ***** Clone repository ***** \e[0m" && sleep 1
cd $HOME && git clone git@github.com:NodersUA/monitoring.git # git clone https://github.com/NodersUA/monitoring
# cd ~/monitoring && git remote set-url origin git@github.com:NodersUA/monitoring.git   # TEMP ~
cd ~/monitoring && git fetch && git reset --hard && git pull
cd ~/monitoring && pip install -r requirements.txt

#=======================================================================

# Create config.conf
echo -e "\e[1m\e[32m ****** Create config.conf ****** \e[0m" && sleep 1
source $HOME/.bash_profile

if [ -z "$TELEGRAM_API_KEY" ]; then
  echo "*********************"
  echo -e "\e[1m\e[32m	Enter your TELEGRAM_API_KEY:\e[0m"
  read TELEGRAM_API_KEY
  echo "==================================================="
  echo 'export TELEGRAM_API_KEY='$TELEGRAM_API_KEY >> $HOME/.bash_profile
  source $HOME/.bash_profile
fi

if [ -z "$MONITORING_CHAT_ID" ]; then
  echo "*********************"
  echo -e "\e[1m\e[32m	Enter your MONITORING_CHAT_ID:\e[0m"
  read MONITORING_CHAT_ID
  echo "==================================================="
  echo 'export MONITORING_CHAT_ID='$MONITORING_CHAT_ID >> $HOME/.bash_profile
  source $HOME/.bash_profile
fi

if [ -z "$MP_API_KEY" ]; then
  echo "*********************"
  echo -e "\e[1m\e[32m	Enter your MONITORING_CHAT_ID:\e[0m"
  read MP_API_KEY
  echo "==================================================="
  echo 'export MP_API_KEY='$MP_API_KEY >> $HOME/.bash_profile
  source $HOME/.bash_profile
fi

tee $HOME/monitoring/config.conf > /dev/null <<EOF
[Telegram]
TELEGRAM_API_KEY = $TELEGRAM_API_KEY
CHAT_ID = $MONITORING_CHAT_ID

[MP]
MP_API_KEY = $MP_API_KEY

[Thresholds]
CPU_THRESHOLD = $CPU_THRESHOLD
RAM_THRESHOLD = $RAM_THRESHOLD
DISK_THRESHOLD = $DISK_THRESHOLD

[Notifications]
CPU_NOTIFICATION = $CPU_NOTIFICATION
RAM_NOTIFICATION = $RAM_NOTIFICATION
DISC_NOTIFICATION = $DISC_NOTIFICATION
EOF

echo "*****************************"
echo -e "\e[1m\e[32m CPU_THRESHOLD  = $CPU_THRESHOLD \e[0m"
echo -e "\e[1m\e[32m RAM_THRESHOLD  = $RAM_THRESHOLD \e[0m"
echo -e "\e[1m\e[32m DISK_THRESHOLD = $DISK_THRESHOLD \e[0m"
echo "*****************************"
sleep 1

#=======================================================================

# Run Monitoring service file
echo -e "\e[1m\e[32m ****** Create Monitoring service file ****** \e[0m" && sleep 1
sudo tee /etc/systemd/system/alertd.service > /dev/null <<EOF
[Unit]
Description=Monitoring Service
After=network.target

[Service]
User=$USER
Restart=always
RestartSec=3
ExecStart=/usr/bin/python3 $HOME/monitoring/alert.py
WorkingDirectory=$HOME/monitoring

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable alertd
sudo systemctl restart alertd


# Run Services Monitoring service file
echo -e "\e[1m\e[32m ****** Create Services Monitoring service file ****** \e[0m" && sleep 1
sudo tee /etc/systemd/system/servicesd.service > /dev/null <<EOF
[Unit]
Description=Services Monitoring Service
After=network.target

[Service]
User=$USER
Restart=always
RestartSec=3
ExecStart=/usr/bin/python3 $HOME/monitoring/services.py
WorkingDirectory=$HOME/monitoring

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable servicesd
sudo systemctl restart servicesd


echo '=============== SETUP FINISHED ==================='
echo -e "\e[1m\e[32m Check logs ===> journalctl -u alertd -f -o cat \e[0m"
echo -e "\e[1m\e[32m Restart ======> systemctl restart alertd \e[0m"
echo "*****************************"
echo -e "\e[1m\e[32m Check logs ===> journalctl -u servicesd -f -o cat \e[0m"
echo -e "\e[1m\e[32m Restart ======> systemctl restart servicesd \e[0m"
echo "*****************************"

# sudo journalctl -u alertd -f -o cat
# sudo journalctl -u servicesd -f -o cat
