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

pacstrap /mnt base base-devel linux-zen linux-zen-headers linux-firmware "$UCODE"
genfstab -U /mnt >> /mnt/etc/fstab

echo "${YELLOW}Install fonts${RESET}"
pacstrap /mnt noto-fonts noto-fonts-extra adobe-source-han-sans-otc-fonts adobe-source-han-serif-otc-fonts noto-fonts-emoji

echo "${YELLOW}install grub${RESET}"
pacstrap /mnt grub efibootmgr os-prober breeze-grub
echo 'GRUB_THEME="/usr/share/grub/themes/breeze/theme.txt"' >> "/mnt/etc/default/grub"
arch-chroot "grub-install; grub-mkconfig -o /boot/grub/grub.cfg"
echo "${GREEN} GRUB_DISABLE_OS_PROPBER set \"ture\" defaultly.${RESET}"
echo "${GREEN} If you want to boot Windows through GRUB,${RESET}"
echo "${GREEN} Set GRUB_DISABLE_OS_PROPBER to \"false\" in \`/etc/default/grub\`,${RESET}"
echo "${GREEN} then run \`grub-mkconfig -o /boot/grub/grub.cfg\` again. ${RESET}"

echo "${YELLOW}install KDE Plasma${RESET}"
arch-chroot /mnt /bin/bash -c "pacman -S plasma kde-system ark dolphin kate sddm plasma-wayland-session sudo egl-wayland; systemctl enable sddm; systemctl enable NetworkManager; systemctl enable bluetooth"

echo "${YELLOW}install fcitx5${RESET}"
pacstrap /mnt fcitx5-im fcitx5-chinese-addons

echo "${YELLOW}Add Arch Linux CN repo${RESET}"
CNMIRRORS = ' ## Arch Linux CN repo mirrors

'
ARCHLINUXCN {
    echo "[archlinuxcn]" >> /etc/pacman.conf
    echo 'Include = /etc/pacman.d/archcn-mirrors' >> /etc/pacman.conf
}
sudo pacman -Sy && sudo pacman -S archlinuxcn-keyring