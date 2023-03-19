#!bin/bash

# Сщздание разделов
echo
(
	# Создаем раздел подкачки
	echo n;
	echo ;
	echo ;
	echo +2G;
	echo y;
	
	# Создаем основной раздел
	echo n;
	echo ;
	echo ;
	echo ;
	echo y;

	# Меняем тип раздела подкачки на Linux SWAP
	echo t;
	echo 6;
	echo 19;

	# Сохраняем изменения 
	echo w;
) | fdisk /dev/nvme0n1

echo 'Разметка диска'
fdisk -l

# Форматированиие дисков

mkswap /dev/nvme0n1p6
swapon /dev/nvme0n1p6
mkfs.ext4 /dev/nvme0n1p7

# Монтирование дисков
mount /dev/nvme0n1p7 /mnt

# Обновление ключей
pacman -Syy
pacman -S archlinux-keyring
pacman-key --init
pacman-key --populate archlinux

# Установка основных пакетов
pacstrap /mnt base base-devel linux linux-firmware nano dhcpcd netctl

# Настройка системы
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt

# Настройка региона
ln -sf /usr/shaere/zoneinfo/Europe/Moscow

# Настройка часов
hwclock --systohc

# Добавляем локали
echo "en_US.UFT-8 UFT-8" > /etc/locale.gen
echo "ru_RU.UFT-8 UFT-8" >> /etc/locale.gen
locale-gen

# Создание компбютера и пользователя
read -p "Введите имя компьютера: " hostname
read -p "Введите имя пользователя: " username

echo 'Прописываем имя компьютера'
echo $hostname > /etc/hostname
echo "127.0.0.1    localhost" >> /etc/hosts
echo "::1          localhost" >> /etc/hosts
echo "127.0.1.1    "$hostname".localdomain    "$hostname >> /etc/hosts

echo 'Создаем root пароль'
passwd

useradd -m $username
echo 'Устанавливаем пароль пользователя'
passwd $username

# Добавление пользователя в группы
usermod -aG wheel,audio,video,storage $username

# Установка sudo
pacman -S sudo
echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers

# Настройка сети
pacman -S networkmanager iwd

systemctl enable NetworkManager
systemctl enable iwd
systemctl enable dhcpcd

# Установка rEFInd
pacman -S refind gdisk
refind-install
lsblk
echo "\"Boot with minimal options\"   \"ro root=UUID=9ce61738-4be1-8f05-5acacf852090\"" > /boot/refind-linux.conf
cat /boot/refind-linux.conf

exit



