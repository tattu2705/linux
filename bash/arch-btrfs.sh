#!/bin/bash

. arch-config.txt

error="\e[31m"
good="\e[32m"
greet="\e[34m"
check="\e[93m"
success="$good[\xE2\x9C\x94] Success "
fail="$error[x] Failed "

greeting(){
	echo -e "$greet""Welcome to my bull shit script!"
	echo -e "$greet""This script will help you to install ArchLinux with Btrfs in LVM, encrypted with LUKS, along side with Windows"
	sleep 5
}

checkNet(){
	echo -e "$check""[+] Checking for network connection"
	ping -c 1 8.8.8.8 >/dev/null 2>&1
	if [[ $? -eq 0 ]]; then
		echo -e "\t$success"
	else
		echo -e "\t$fail\nPlease check your connection!"
		exit
	fi
}

partition(){
	echo -e "$check""[+] Partitioning"
	echo -e "$greet""\t[*] Configuring LUKS in $root_part"
	echo $luks_pass | cryptsetup luksFormat $root_part >/dev/null 2>&1
	if [[ $? -gt 0 ]]; then
		echo -e "\t\t$fail""\nPlease check the parition again!"
		exit
	fi
	echo $luks_pass | cryptsetup luksOpen $root_part luks >/dev/null 2>&1
	echo -e "\t\t$success"
	
	echo -e "$greet""\t[*] Configuring LVM partitions in $root_part"
	pvcreate /dev/mapper/luks >/dev/null 2>&1
	vgcreate vg0 /dev/mapper/luks >/dev/null 2>&1
	lvcreate --size "$swap" vg0 --name swap >/dev/null 2>&1
	lvcreate -l 100%FREE vg0 --name root >/dev/null 2>&1
	echo -e "\t\t$success"

	echo -e "$greet""\t[*] Creating filesystems"
	mkswap /dev/mapper/vg0-swap >/dev/null 2>&1
	mkfs.btrfs /dev/mapper/vg0-root >/dev/null 2>&1
	echo -e "\t\t$success"

	echo -e "$greet""\t[*] Creating subvolumes"
	mount /dev/vg0/root /mnt >/dev/null 2>&1
	btrfs sub create /mnt/@ >/dev/null 2>&1
	btrfs sub create /mnt/@home >/dev/null 2>&1
	btrfs sub create /mnt/@pkg >/dev/null 2>&1
 	btrfs sub create /mnt/@snapshots >/dev/null 2>&1
 	umount /mnt >/dev/null 2>&1
	echo -e "\t\t$success"

	echo -e "\t$greet""[*] Mounting subvolumes"	
    	mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvol=@ /dev/vg0/root /mnt >/dev/null 2>&1
 	mkdir -p /mnt/{boot,home,var/cache/pacman/pkg,.snapshots,btrfs} >/dev/null 2>&1
   	mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvol=@home /dev/vg0/root /mnt/home >/dev/null 2>&1
   	mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvol=@pkg /dev/vg0/root /mnt/var/cache/pacman/pkg >/dev/null 2>&1
   	mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvol=@snapshots /dev/vg0/root /mnt/.snapshots >/dev/null 2>&1
   	mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvolid=5 /dev/vg0/root /mnt/btrfs >/dev/null 2>&1
	echo -e "\t\t$success"
	
	echo -e "\t$greet""[*] EFI partition"
	test `fdisk -lo Device,Type | grep $boot_part | awk {'printf $2'}`=="EFI"
	if [[ $? -gt 0 ]]; then
		echo -e "\t$fail""\n$boot_part seems not to be an EFI Partition, please check again!"
		exit
	fi
	mount $boot_part /mnt/boot >/dev/null 2>&1
	echo -e "\t\t$success"
}

sys_conf(){
	echo -e "$check""[+] Installing base system"
	pacstrap /mnt base base-devel linux linux-firmware vim nano os-prober btrfs-progs lvm2 --noconfirm >/dev/null 2>&1  
	echo -e "\n\t$success"

	echo -e "$check""[+] Generating fstab"
	genfstab -U /mnt >> /mnt/etc/fstab >/dev/null 2>&1
	echo -e "\t$success"

	echo -e "$check""[+] Setting locale"
	arch-chroot /mnt /bin/bash <<-EOF
	sed -i "s,#${locale},${locale}," /etc/locale.gen
	locale-gen >/dev/null 2>&1
	echo LANG=$locale > /etc/locale.conf >/dev/null 2>&1
    	export LANG=$locale >/dev/null 2>&1
	EOF
	echo -e "\t$success"

	echo -e "$check""[+] Setting timezone"
	arch-chroot /mnt /bin/bash <<-EOF
	ln -s /usr/share/zoneinfo/$timezone /etc/localtime >/dev/null 2>&1
	hwclock --systohc --utc >/dev/null 2>&1
	EOF
	echo -e "\t$success"

	echo -e "$check""[+] Setting hostname"
	echo "${hostname}" > /mnt/etc/hostname >/dev/null 2>&1
	echo -e "\t$success"

	echo -e "$check""[+] Configuring users"
	arch-chroot /mnt /bin/bash <<-EOF
	echo "root:${root_pass}" | chpasswd >/dev/null 2>&1
	sed -i "s,# %wheel ALL=(ALL) ALL,%wheel ALL=(ALL) ALL," /etc/sudoers
	useradd -m -G wheel -s /bin/bash $username >/dev/null 2>&1
	echo "${username}:${password}" | chpasswd >/dev/null 2>&1
	EOF
	echo -e "\t$success"
}

mkinitcpio(){
	echo -e "$check""[+] Configuring mkinitcpio"
	arch-chroot /mnt /bin/bash <<-EOF
	sed -i "s,^HOOKS.*,HOOKS=(base keyboard udev autodetect modconf block keymap encrypt lvm2 filesystems btrfs)," /etc/mkinitcpio.conf
	mkinitcpio -p linux >/dev/null 2>&1
	EOF
	echo -e "\t$success"
}

boot_conf(){
	echo -e "$check""[+] Configuring Boot Manager"
	arch-chroot /mnt /bin/bash <<-EOF
	os-prober >/dev/null 2>&1
	bootctl --path=/boot install >/dev/null 2>&1
	echo -e "title Arch Linux\nlinux /vmlinuz-linux\ninitrd /initramfs-linux.img\noptions cryptdevice=UUID=`blkid -s UUID -o value $root_part`:cryptlvm root=/dev/vg0/root rootflags=subvol=@ quiet rw" > /boot/loader/entries/arch.conf
	echo -e "default  arch.conf\ntimeout  5\nconsole-mode max\neditor   no" > /boot/loader/loader.conf
	EOF
	echo -e "\t$success"
}

desktop(){
	echo -e "$check""[+] Installing desktop environment: $de"
	arch-chroot /mnt /bin/bash <<-EOF
	pacman -Syu xorg xorg-server networkmanager --noconfirm >/dev/null 2>&1
	systemctl enable NetworkManager >/dev/null 2>&1
	if [[ $de == *"KDE"* ]]; then
		pacman -S plasma plasma-wayland-session kde-applications sddm --noconfirm >/dev/null 2>&1 
		systemctl enable sddm >/dev/null 2>&1
		echo -e "\n\t$success"
	elif [[ $de == *"Gnome"* ]]; then
		pacman -S gnome --noconfirm >/dev/null 2>&1 
		systemctl enable gdm >/dev/null 2>&1
		echo -e "\n\t$success"
	elif [[ $de == *"XFCE"* ]]; then
		pacman -S xfce4 xfce4-goodies lightdm lightdm-gtk-greeter --noconfirm >/dev/null 2>&1 
		systemctl enable lightdm >/dev/null 2>&1
		echo -e "\n\t$success"
	else
	    	echo -e "\t$fail""Wrong DE! No DE installed! But you can install it later in CLI mode, after reboot, login to your account, connect to your internet with nmtui."
		sleep 10
	fi
	mv .bashrc /mnt/home/${username}/.bashrc >/dev/null 2>&1
	EOF
}



final(){
	umount -R /mnt >/dev/null 2>&1
	echo -e "$greet""All settings are done! This will auto-reboot after 10s\n"
	sleep 10
	reboot
}


main(){
	greeting
	checkNet
	partition
	sys_conf
	mkinitcpio
	boot_conf
	desktop
	final
}

main 
