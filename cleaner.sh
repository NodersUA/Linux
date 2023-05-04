#!/bin/bash

# check scripts folder existing
mkdir -p $HOME/scripts/

# Add cleaner.sh to scripts folder
tee $HOME/scripts/cleaner.sh > /dev/null <<EOF
#!/bin/bash
while true
do
    date
    # remove syslog
    rm /var/log/syslog*
    # remove subspace log files
    rm $HOME/.local/share/subspace-cli/logs/*
    sleep 600
    echo "===================================="
done
EOF

chmod +x $HOME/scripts/cleaner.sh

# Create logs cleaner service file
sudo tee /etc/systemd/system/cleaner.service > /dev/null <<EOF
[Unit]
Description=Logs Cleaner Service
After=network.target

[Service]
User=$USER
ExecStart=$HOME/scripts/cleaner.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Start cleaner service file
systemctl daemon-reload
systemctl enable cleaner
systemctl restart cleaner
