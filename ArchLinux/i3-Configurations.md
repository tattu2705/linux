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
