#!/bin/bash

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
RESET=$(tput sgr0)

echo "${YELLOW}Install base system${RESET}"

UCODECHECK=$(cat /proc/cpuinfo | grep Intel)
if [ ! -n "$UCODECHECK" ]; then
    UCODE="amd-ucode"
    else
    UCODE="intel-ucode"
fi

pacstrap /mnt base base-devel sudo wget curl nano htop neofetch linux-zen linux-zen-headers linux-firmware "$UCODE"
genfstab -U /mnt >> /mnt/etc/fstab
sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /mnt/etc/sudoers

echo "${YELLOW}install grub${RESET}"
pacstrap /mnt grub efibootmgr os-prober breeze-grub
echo 'GRUB_THEME="/usr/share/grub/themes/breeze/theme.txt"' >> "/mnt/etc/default/grub"
arch-chroot /mnt /bin/bash -c "grub-install; grub-mkconfig -o /boot/grub/grub.cfg"
echo "${GREEN} GRUB_DISABLE_OS_PROPBER set \"ture\" defaultly.${RESET}"
echo "${GREEN} If you want to boot Windows through GRUB,${RESET}"
echo "${GREEN} Set GRUB_DISABLE_OS_PROPBER to \"false\" in \`/etc/default/grub\`,${RESET}"
echo "${GREEN} then run \`grub-mkconfig -o /boot/grub/grub.cfg\` again. ${RESET}"

echo "${YELLOW}install KDE Plasma${RESET}"
arch-chroot /mnt /bin/bash -c "pacman -S plasma kde-system ark dolphin kate sddm plasma-wayland-session egl-wayland; systemctl enable sddm; systemctl enable NetworkManager; systemctl enable bluetooth"

echo "${YELLOW}install fcitx5${RESET}"
pacstrap /mnt fcitx5-im fcitx5-chinese-addons

echo "${YELLOW}Add Arch Linux CN repo${RESET}"
arch-chroot /mnt /bin/bash -c "echo \"[archlinuxcn]\" >> /etc/pacman.conf"
arch-chroot /mnt /bin/bash -c "echo 'Include = /etc/pacman.d/archcn-mirrors' >> /etc/pacman.conf"
arch-chroot /mnt /bin/bash -c "curl -Ls \"https://github.com/MarksonHon/arch-install-scripts/raw/main/archcn-mirrors\" --output /etc/pacman.d/archcn-mirrors"
arch-chroot /mnt /bin/bash -c "pacman -Sy && pacman -S archlinuxcn-keyring"

echo "${YELLOW}Install fonts${RESET}"
arch-chroot /mnt /bin/bash -c "pacman -S noto-fonts noto-fonts-extra adobe-source-han-sans-otc-fonts adobe-source-han-mono-otc-fonts adobe-source-han-serif-otc-fonts noto-fonts-emoji --noconfirm"

echo "${YELLOW}Add User${RESET}"
read user_name
echo echo "${GREEN} Your username is $user_name ${RESET}"
arch-chroot /mnt /bin/bash -c "useradd -G wheel -m $user_name"
arch-chroot /mnt /bin/bash -c "passwd $user_name"

echo "${YELLOW}Set locale and timezone${RESET}"
arch-chroot /mnt /bin/bash -c "ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime"
arch-chroot /mnt /bin/bash -c "hwclock --systohc"
arch-chroot /mnt /bin/bash -c "sed -i 's/#zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen"
arch-chroot /mnt /bin/bash -c "echo 'LANG=zh_CN.UTF-8' > /etc/locale.conf"

echo "${YELLOW}Set fonts config${RESET}"
curl -sL "https://github.com/MarksonHon/arch-install-scripts/raw/main/fonts-config.xml" --output "/mnt/etc/fonts/conf.d/70-adobe-han.conf"
cat "/mnt/etc/fonts/conf.d/70-adobe-han.conf"