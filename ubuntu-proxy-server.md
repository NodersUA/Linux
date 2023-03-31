## Step 1 — Installing Squid Proxy
```bash
sudo apt update && sudo apt install squid -y
```
```bash
systemctl status squid.service
```
```bash
# Output
# ● squid.service - Squid Web Proxy Server
#     Loaded: loaded (/lib/systemd/system/squid.service; enabled; vendor preset: enabled)
#     Active: active (running) since Wed 2021-12-15 21:45:15 UTC; 2min 11s ago
```
```bash
sudo nano /etc/squid/squid.conf
```

Press ctrl+w to search `include /etc/squid/conf.d/*` if you want to limit access to the proxy only from a specific IP

Add row `acl localnet src <your_ip_address>`

Replace `<your_ip_address>` with the IP address from which you will use the proxy

```bash
# Exemple
#
# INSERT YOUR OWN RULE(S) HERE TO ALLOW ACCESS FROM YOUR CLIENTS
#
include /etc/squid/conf.d/*
# Example rule allowing access from your local networks.
acl localnet src your_ip_address
# Adapt localnet in the ACL section to list your (internal) IP networks
# from where browsing should be allowed
#http_access allow localnet
http_access allow localhost
```

You can allow access from any IP to your proxy. To do this, add the following lines to the file
```bash
# And finally deny all other access to this proxy
http_access deny all
```
 ```bash
# Exemple
#
# INSERT YOUR OWN RULE(S) HERE TO ALLOW ACCESS FROM YOUR CLIENTS
#
include /etc/squid/conf.d/*
# Example rule allowing access from your local networks.
# Adapt localnet in the ACL section to list your (internal) IP networks
# from where browsing should be allowed
#http_access allow localnet
http_access allow localhost

# And finally deny all other access to this proxy
http_access deny all
```
