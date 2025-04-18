# 检查新空间是否被识别
#运行以下命令检查是否识别到新的磁盘空间：

fdisk -l

# 如果扩展了现有磁盘（如 /dev/sda），可以用以下命令重新扫描磁盘：

echo 1 > /sys/class/block/sda/device/rescan


#调整分区（如果使用 GPT 分区表）
#用 gdisk 或 parted 工具调整分区大小：

#使用 parted：


parted /dev/sda
#(parted) print                   # 查看分区信息
#(parted) resizepart 3 100%       # 将 sda3 分区扩展到磁盘的最大容量
#(parted) quit


# 扩展物理卷 (PV)：
pvresize /dev/sda3


# 检查分区更新：

partprobe /dev/sda



#确认卷组有可用空间
#运行以下命令，检查卷组 rl 的可用空间：


vgdisplay


# 扩展逻辑卷
# 假设你希望将所有可用空间分配给根分区，运行以下命令：

lvextend -l +100%FREE /dev/mapper/rl-root

# 扩展文件系统

xfs_growfs /

# 如果是 ext4 文件系统：
# 运行以下命令扩展文件系统（需要先卸载分区）：


resize2fs /dev/mapper/rl-root


yum install -y cloud-utils-growpart && echo 1 > /sys/class/block/sda/device/rescan  && growpart /dev/sda 3 &&  pvresize /dev/sda3 && lvextend -l +100%FREE /dev/rl/root  && xfs_growfs / 

#  验证扩展结果
# 使用以下命令检查根分区的容量是否已经增加：

df -h

# 固定IP
nmcli connection modify ens33 ipv4.method manual ipv4.addresses 192.168.1.92/24 ipv4.gateway 192.168.1.1 ipv4.dns "8.8.8.8 8.8.4.4"
nmcli connection up ens33

#禁用ipv6
nmcli connection modify ens33 ipv6.method "disabled"
nmcli connection down ens33 && nmcli connection up ens33
