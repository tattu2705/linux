# Fix "Hash mismatch" when `apt update`:

```bash
sudo bash
mkdir /etc/gcrypt
echo all >> /etc/gcrypt/hwf.deny
sudo apt-get update
```
