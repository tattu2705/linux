# i3 configurations

> Some shits configs

- i3:
  - https://gist.github.com/fjpalacios/441f2f6d27f25ee238b9bfcb068865db

- rofi:
  - https://github.com/adi1090x/rofi

- Install `yay`

- Install `polybar-git`:

```shell
yay -S polybar-git
```

- Polybar customizations:

  - https://github.com/adi1090x/polybar-themes

- fish:
  - https://github.com/oh-my-fish/oh-my-fish

- open-vm-tools

  ```shell
  sudo pacman -S open-vm-tools gtkmm3 --noconfirm --needed
  sudo systemctl enable --now vmtoolsd.service vmware-vmblock-fuse.service
  ```
  
  Add this line to i3 config file:
  
  ```shell
  exec --no-startup-id vmware-user &
  ```
  
- Kitty terminal
  - https://github.com/dexpota/kitty-themes

- zram:

```shell
sudo modprobe zram
sudo bash -c 'echo "lz4" > /sys/block/zram0/comp_algorithm'
sudo bash -c 'echo "4096M" > /sys/block/zram0/disksize'
sudo mkswap --label zram0 /dev/zram0
sudo swapon --priority=100 /dev/zram0
```

  - config files:
  ```shell
  # /etc/modules-load.d/zram.conf
  zram
  ```
  
  ```shell
  # /etc/modules-load.d/zram.conf
  options zram num_devices=1
  ```
  
  ```shell
  # /etc/udev/rules.d/99-zram.rules
  KERNEL=="zram0", ATTR{comp_algorithm}="zstd", ATTR{disksize}="4096M", RUN="/usr/bin/mkswap /dev/zram0", TAG+="systemd"
  ```
  
  ```shell
  # /etc/fstab
  /dev/zram0	none	swap	sw,pri=100	0 0
  ```
  
  ```shell
  # /etc/mkinitcpio.conf (add to MODULE=())
  MODULES=(zram)
  ```
  
```shell
sudo mkinitcpio -p linux
```
  
- vim
  - https://github.com/junegunn/vim-plug
  - https://github.com/joshdick/onedark.vim
  - https://github.com/vim-airline/vim-airline
