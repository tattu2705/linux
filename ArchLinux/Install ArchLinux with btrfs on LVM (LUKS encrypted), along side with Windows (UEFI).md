# Install ArchLinux with btrfs on LVM (LUKS encrypted), along side with Windows (UEFI)

Well, just a bullsh*t instruction for someone like me, always forget things

Firstly, in my case, my filesystem, you should learn about your filesystems carefully before installing Arch:

- /dev/sda1 is the EFI partition, already have Windows EFI inside
- /dev/sda2 is for System Reserved
- /dev/sda3 is C:\ partition
- /dev/sda4 is for ArchLinux, which i formatted to ext4 using [Minitool Partion Wizard](https://www.minitool.com/partition-manager/partition-wizard-home.html?utm_source=minitool.com&utm_medium=redirection&utm_campaign=home-banner)

## Make install medium
- Download ArchLinux .iso from [here](https://archlinux.org/download/)

- Using some tools like [Rufus](https://rufus.ie/en_US/), [balena Etcher](https://www.balena.io/etcher/) to flash .iso file to your USB

## Pre-Installation
- Boot into your USB which has been flashed above

- Connect it to a network, by LAN or in my case, i used iwctl to connect to my Wifi

- Install some tools like vim or nano
    ```
        pacman -Syy vim nano --noconfirm 
    ```

## Encryption
- Create an encrypt container for the root file system, it will ask you for a passphare, just type in a strong passphrase
    ```
        cryptsetup luksFormat /dev/sda4
    ```
- Open the container (you can replace luks with any name you want, but remember it) and type in your passphrase
    ```
        cryptsetup luksOpen /dev/sda4 luks
    ```

## File System Creation
- Create 2 partitions, 8GB swap and rest for root
    ```shell
        pvcreate /dev/mapper/luks
        vgcreate vg0 /dev/mapper/luks
        lvcreate --size 8G vg0 --name swap
        lvcreate -l 100%FREE vg0 --name root
    ```

- Create filesystems on encrypted partitions
    ```shell
        mkswap /dev/mapper/vg0-swap
        mkfs.btrfs /dev/mapper/vg0-root
    ```

- Create subvolumes for root:
    ```shell
        mount /dev/vg0/root /mnt
        btrfs sub create /mnt/@
        btrfs sub create /mnt/@home
        btrfs sub create /mnt/@pkg
        btrfs sub create /mnt/@snapshots
        umount /mnt
    ```

- Mount the subvolumes
    ```shell
        mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvol=@ /dev/vg0/root /mnt
        mkdir -p /mnt/{boot,home,var/cache/pacman/pkg,.snapshots,btrfs}
        mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvol=@home /dev/vg0/root /mnt/home
        mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvol=@pkg /dev/vg0/root /mnt/var/cache/pacman/pkg
        mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvol=@snapshots /dev/vg0/root /mnt/.snapshots
        mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvolid=5 /dev/vg0/root /mnt/btrfs
    ```
    
- Mount the EFI partition
    ```shell
        mount /dev/sda1 /mnt/boot
    ```
    
- Install base system
    ```shell
        pacstrap /mnt base base-devel linux linux-firmware vim nano os-prober
    ```
- Generate /etc/fstab file
    ```shell
        genfstab -U /mnt >> /mnt/etc/fstab
    ```

- Change root to new system
    ```shell
        arch-chroot /mnt
    ```

- Set locale
    ```shell
        vim /etc/locale.gen
    ```
    Then uncomment the line specify your locale by deleting # in line start, with me, it is en_US.UTF-8 UTF-8.
    Save it and generate locale:
    ```shell
        locale-gen
    ```
    Set LANG variable:
    ```shell
        echo LANG=en_US.UTF-8 > /etc/locale.conf
        export LANG=en_US.UTF-8
    ```

- Set timezone
    ```shell
        ln -s /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime
    ```

- Set HW clock to UTC
    ```shell
        hwclock --systohc --utc
    ```
    
- Set hostname
    ```shell
        echo <Your_hostname> > /etc/hostname
    ```
    For example my hostname is arch: ```echo arch > /etc/hostname```

- Set root password
    ```shell
        passwd
    ```
    Then enter new password for root

- Setup NetworkManager
    ```shell 
        pacman -Syy networkmanager --noconfirm
    ```

- Add a user with sudo permissions
    ```shell
        visudo /etc/sudoers
    ```
    Uncomment by deleting # in line ```%wheel  ALL=(ALL)   ALL```, then save.
    
    ```shell
        useradd -m -G wheel -s /bin/bash <username>
        passwd <username>
    ```
    Type in new password for new user.

- Configure mkinitcpio
    ```shell
        vim /etc/mkinitcpio.conf
    ```
    Then edit the HOOK() line as bellow:
    
    ```shell
        HOOKS=(base keyboard udev autodetect modconf block keymap encrypt lvm2 filesystems btrfs)
    ```
    
    Then save
    
    ```shell
        mkinitcpio -p linux
    ```

- Configure Boot Manager
    ```shell
        bootctl --path=/boot install
        vim /boot/loader/entries/arch.conf
    ```
    Fill in as bellow:
    
    ```shell
        title Arch Linux
        linux /vmlinuz-linux
        initrd /initramfs-linux.img
        options cryptdevice=UUID=<UUID>:cryptlvm root=/dev/vg0/root rootflags=subvol=@ quiet rw
    ```
    
    You can get the UUID when in vim by pressing Esc then type ```:read ! blkid -s UUID -o value /dev/sda4```
    Save the file. Then:
    
    ```shell
        vim /boot/loader/loader.conf
    ```
    
    Fill with text bellow then Save:
    
    ```shell
        default  arch.conf
        timeout  5
        console-mode max
        editor   no
    ```
    
- Final step
    ```shell
        exit
        umount -R /mnt
        reboot
    ```
    
    Login to the user you created and enjoy

- Desktop environment
    + Enable NetworkManager to run automatically:
        ```shell
            sudo systemctl enable NetworkManager.service
            sudo systemctl start NetworkManager.service
        ```
    + Connect to network using [nmtui](https://linuxhint.com/arch_linux_network_manager/).
    + Update the system
        ```shell
            sudo pacman -Syu --noconfirm
        ```
    + Install Desktop Environment:
        * [GNOME](https://phoenixnap.com/kb/arch-linux-gnome)
        * [KDE](https://itsfoss.com/install-kde-arch-linux/)
        * [XFCE](https://linuxhint.com/install-xfce-arch-linux/)

# Hope this instruction will help!
