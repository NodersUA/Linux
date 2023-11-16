#!/bin/bash

# source <(curl -s https://raw.githubusercontent.com/NodersUA/Linux/main/cleaner.sh)

#UPDATE APT
if ! dpkg -s bc &> /dev/null; then
sudo apt update && apt upgrade -y
apt install bc -y
fi

# check scripts folder existing
mkdir -p ~/scripts/

# restart rsyslog to clean disk space
systemctl restart rsyslog

# Add cleaner.sh to scripts folder
tee $HOME/scripts/cleaner.sh > /dev/null <<EOF
#!/bin/bash

get_space_percent() {
    # Отримати відсоток вільного місця на диску
    local space_percent=\$(df -h / | awk 'NR==2 {print \$5}' | tr -d '%')
    echo "\$space_percent"
}

clean_syslog() {
    # remove syslog
    SIZE=\$(du -s /var/log | cut -f 1)
    GB=\$(echo "scale=0; \$SIZE/1024/1024" | bc)
    if [ \$(echo "\$GB > 10" | bc) -eq 1 ]; then
      echo "\$(date) | \$GB GB - clean syslog"
      rm /var/log/syslog*
      systemctl restart rsyslog
    fi

}

#clean_subspace_logs() {
#    # remove subspace log files
#    SIZE=\$(du -s \$HOME/.local/share/pulsar/logs | cut -f 1)
#    GB=\$(echo "scale=0; \$SIZE/1024/1024" | bc)
#   if [ \$(echo "\$GB > 10" | bc) -eq 1 ]; then
#      echo "\$(date) | \$GB GB - clean subspace_log"
#      rm /root/.local/share/pulsar/logs/*
#      systemctl restart subspaced
#    fi
#}

clean_starknet() {
    SIZE=\$(du -s \$HOME/pathfinder | cut -f 1)
    GB=\$(echo "scale=0; \$SIZE/1024/1024" | bc)
    if [ \$(echo "\$GB > 400" | bc) -eq 1 ]; then
      echo "\$(date) | Starknet size - \$GB GB - clean node"
      docker stop pathfinder
      rm -rf \$HOME/pathfinder
      docker start pathfinder
    fi
}

download_snapshot() {
    cmd="echo '3' | source <(curl -s https://raw.githubusercontent.com/NodersUA/Scripts/main/nibiru/nibiru)"
    eval \$cmd
}

# Функція для виконання команди з перевіркою на помилку sequence
execute_with_sequence_check() {
  cmd=\$1
  expected_sequence=\$(nibid query account $NIBIRU_ADDRESS | grep -oP '(?<=sequence: ")[^"]+' | awk '{print \$1}')
  if [ -z "\$sequence" ]; then sequence=\$expected_sequence; else sequence=\$(expr \$sequence + 1); fi
  new_cmd="\$cmd --sequence=\$sequence -y"
  echo \$new_cmd
  eval \$new_cmd
  sleep 3
}

check_and_clean() {
    # Функція для визначення, чи потрібно виконати очищення
    local space_percent=\$(get_space_percent)
    if [ "\$space_percent" -ge 95 ]; then
        echo "\$(date) | Space is below 95% - cleaning"
        voting_power=\$(echo "\$(nibid status)" | grep -o '"VotingPower":"[0-9]*"' | cut -d':' -f2 | tr -d '"')
        echo "Nibiru voing power = \$voting_power"

        if [ "\$voting_power" == 0 ]; then
            echo "Download snapshot"
            download_snapshot
        else
            echo "Begin redelegate..."
            output=\$(nibid q oracle aggregate-votes | grep 'voter')

            # Перевіряємо, чи змінна не є порожньою
            while [ -z "\$output" ]
            do
              # Виконуємо команду ще раз та зберігаємо результат у змінну
               output=\$(nibid q oracle aggregate-votes | grep 'voter')
               sleep 2
            done

            valoper=\$(echo "\$output" | grep 'voter' | shuf -n 1 | sed 's/voter: //' | tr -d '[:space:]')
            echo \$valoper
            redelegate_value=\$((voting_power - 20))
            echo \$redelegate_value
            execute_with_sequence_check "nibid tx staking redelegate $NIBIRU_VALOPER \$valoper \${redelegate_value}000000unibi --from wallet --fees 7500unibi --gas=300000"
            MESSAGE="🏓 [\$HOSTNAME] >>> Redelegate \$redelegate_value nibi to \$valoper"
            curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_API_KEY/sendMessage" -d "chat_id=$MONITORING_CHAT_ID" -d "text=\$MESSAGE"

        fi

    else
        echo "\$(date) | Space is above 95% - no cleaning required"
    fi
}

while true; do
    clean_syslog
    clean_subspace_logs
    #check_and_clean
    clean_starknet
    sleep 600
done

EOF

chmod +x ~/scripts/cleaner.sh

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
