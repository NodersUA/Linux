## Add ssh key
```bash
# Create .ssh directory
mkdir -p ~/.ssh
```
```bash
# Replace `public_key_string` to your public key
echo public_key_string >> ~/.ssh/authorized_keys
```
```bash
chmod -R go= ~/.ssh
```
## Disabling password authentication on the server
```bash
sudo nano /etc/ssh/sshd_config
```
> Press ctrl+w to seach `PasswordAuthentication`

![image](https://user-images.githubusercontent.com/79005788/229323096-837944a7-1474-4034-ae1d-1b4b220cffb2.png)

```bash
sudo systemctl restart ssh
```
