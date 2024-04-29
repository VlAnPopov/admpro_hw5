#!/bin/bash
# настройка стенда
#install zfs repo
report_file="/home/vagrant/report"
yum -y update
yum install -y http://download.zfsonlinux.org/epel/zfs-release.el7_8.noarch.rpm
#import gpg key 
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux
#install DKMS style packages for correct work ZFS
yum install -y epel-release kernel-devel zfs
#change ZFS repo
yum-config-manager --disable zfs
yum-config-manager --enable zfs-kmod
yum install -y zfs
#Add kernel module zfs
modprobe zfs
#install wget
yum install -y wget
# сооружаем три пула zfs
zpool create otus1 mirror /dev/sdb /dev/sdc
zpool create otus2 mirror /dev/sdd /dev/sde
zpool create otus3 mirror /dev/sdf /dev/sdg
zpool create otus4 mirror /dev/sdh /dev/sdi
# задаём методы компрессии
zfs set compression=lzjb otus1
zfs set compression=lz4 otus2
zfs set compression=gzip-9 otus3
zfs set compression=zle otus4
# качаем тестовый файл
for i in {1..4}; do wget -P /otus$i https://gutenberg.org/cache/epub/2600/pg2600.converter.log; done
# выведем информацию о файле
echo "Результаты сжатия:" > ${report_file}
ls -l /otus* >> ${report_file}
zfs list >> ${report_file}
# Определение настроек пула
# качаем архив
wget -O archive.tar.gz --no-check-certificate 'https://drive.usercontent.google.com/download?id=1MvrcEp-WgAQe57aDEzxSRalPAwbNN1Bb&export=download' 
#  И распаковываем его
tar -xzvf archive.tar.gz
# Импортируем пул
zpool import -d zpoolexport/ otus
# выводим информацию
echo "Свойства пула:" >> ${report_file}
zpool get all otus >> ${report_file}
# Работа со снэпшотом
# Качаем файл
wget -O otus_task2.file --no-check-certificate 'https://drive.usercontent.google.com/download?id=1wgxjih8YZ-cqLqaZVa0lA3h3Y029c3oI&export=download'
# восстанавливаем файловую систему
zfs receive otus/test@today < otus_task2.file
# ищем файл с сообщением, выводим его содержимое
echo "Искомая строка:" >> ${report_file}
find /otus/test -name "secret_message" -exec cat {} \; >> ${report_file}
