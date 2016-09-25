#!/bin/bash
# System Optimize Script
# #

# User ID and System Platform Checking
if [ `/usr/bin/id -un` != "root" ]; then
       echo "This script must be run by root!"
      exit 1
fi

if [ `/bin/uname -p` != "x86_64" ]; then
       echo "This script must be run on x86_64 platform!"
      exit 1
fi
menu(){

cat <<EOF

--------------------------SYSTEM CUSTOMIZE AND OPTIMIZE SCRIPT-------------------
USER: `id -un`          HOST: `hostname`                        DATE: `date +%F`
SYSTEM: `sed 1q /etc/issue`
PLATFORM: `uname -i`
---------------------------------------------------------------------------------
1. Common Customization (History, Prompt ,Runlevel)
2. Common Security Enhancement (SElinux, Root SSH,Password Expiry, File Perm)
3. Advanced Security Enhancement (iptables)
4. System Services Optmization (Disable Unnecessary Services)
5. System Resources Limit Optimization(ulimit)
6. Kernel Optimization For Web Servers(Apache, Tomcat, Nginx)
7. Kernel Optimization For Database Servers(Oracle, Mysql)
8. Reboot OS
9. Quit
---------------------------------------------------------------------------------

EOF
}

commopt(){
# Customize Prompt and History Format
cat >> /etc/profile << EOF
HISTSIZE=2000
HISTTIMEFORMAT="%F %T "
HISTIGNORE="&:[ ]*:pwd:ls:ls -ltr:clear" # history doesn't record these commands"
export PROMPT_COLOR="\[\033[1;31m\]"
export CONSOLE_COLOR="\[\033[1;37m\]"
export DIR_COLOR="\[\033[1;37m\]"
export TIME_COLOR="\[\033[1;36m\]"
export PS1="$PROMPT_COLOR\u@\h $TIME_COLOR[\d \t] $DIR_COLOR\w \n$CONSOLE_COLOR$ "
EOF
echo "Added Time Format to history.."
sleep 2
echo "Look at your prompt...Have a new sight?!"
sleep 3
source /etc/profile
# Set Default Run Level 3
sed -i -e 's/id:.:initdefault:/id:3:initdefault:/' /etc/inittab
echo "Set runlevel to 3 completed.!"
sleep 3
}

commsec(){
# Disable SELINUX
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
echo "Disabled SELINUX."
sleep 3

# Disable ROOT login from SSH
sed -i -e 's/#*\(PermitRootLogin\).*/\1 no/' /etc/ssh/sshd_config
sed -i -e 's/#*\(UseDNS\).*/\1 no/' /etc/ssh/sshd_config
/etc/init.d/sshd reload
echo "Root login from ssh is disabled.!"
sleep 3
}

#iptables settings
advsec(){
iptables -F
iptables --delete-chain
iptables -A INPUT -p tcp --syn --dport 22 -m connlimit --connlimit-above 3 -j REJECT
/etc/init.d/iptables save
/etc/init.d/iptables restart
echo -e "\n iptables is set to allow maxinum 3 ssh connection from one IP!"

}
# Disable Unnecessary Services
disservice(){
chkconfig sendmail off
chkconfig acpid off
chkconfig atd off
chkconfig autofs off
chkconfig haldaemon off
chkconfig hplip off
chkconfig hidd off
chkconfig lm_sensors off
chkconfig ip6tables off
chkconfig kudzu off
chkconfig mcstrans off
chkconfig mdmonitor off
#chkconfig netfs off
chkconfig nfslock off
chkconfig isdn off
chkconfig bluetooth off
chkconfig cups off
echo "All Unnecessary Services are disabled.!"
sleep 3
}

# Set File limit
setlimit(){
cat >> /etc/security/limits.conf << EOF
*       soft    nofile  2048
*       hard    nofile  65536
*       soft    nproc   2048
*       hard    nproc   65536
EOF
echo -e "\nSet File Limit to 2048 65536 completed.!\n"
ulimit -a
sleep 3
}

# System Kernel Optimize
webkernelopt(){
cat >> /etc/sysctl.conf << EOF
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.ip_local_port_range = 9000 65536
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_synack_retries = 1
net.ipv4.tcp_syn_retries = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.core.rmem_default = 8388608
net.core.wmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.netdev_max_backlog = 262144
net.core.somaxconn = 262144
EOF
/sbin/sysctl -p
echo -e "\nAbove are your new Kernel parameters!"
sleep 8
}

dbkernelopt(){
cat >> /etc/sysctl.conf << EOF
kernel.core_uses_pid = 1
kernel.shmmax = 536870912
kernel.shmmni = 4096
kernel.shmall = 2097152
kernel.sem = 250 32000 100 128
net.core.rmem_default = 4194304
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048576
fs.aio-max-nr = 1048576
fs.file-max = 6815744
net.ipv4.ip_local_port_range = 9000 65536
EOF
/sbin/sysctl -p
echo -e "\nAbove are your new Kernel parameters!"
sleep 8
}

# System Password Expiry Enhancement
pwdexp(){
echo -e "\n\nYour password expiry will set as below!...\n"
cat <<EOF
PASS_MAX_DAYS   90
PASS_MIN_DAYS   7
PASS_MIN_LEN    9
PASS_WARN_AGE   14
EOF
sed -i -e 's/\(PASS_MAX_DAYS\).*[0-9]$/\1\t90/;s/\(PASS_MIN_DAYS\).*[0-9]$/\1\t7/;s/\(PASS_MIN_LEN\).*[0-9]$/\1\t9/;s/\(PASS_WARN_AGE\).*[0-9]$/\1\t14/;s/\(FAIL_DELAY\).*[0-9]$/\1\t5/' /etc/login.defs
sleep 3 && echo -e "\nDone..!"
}

# File Permission Enhancement
filepmn(){
chmod 600 /etc/sysctl.conf
chmod 750 /etc/init.d/functions
chmod 600 /etc/inittab
chmod 640 /etc/login.defs
}

# Prompt To Reboot OS
rebootos(){
echo -e "\n\nSystem optimization completed! Please reboot your system now!\n"
read -p "Reboot your system? yes/no ?" yn
case $yn in
yes|Y|y|Yes|YES)
echo "System is going to reboot now!!"
reboot
;;
*)
echo "Please reboot your system manually!"
exit 0
;;
esac
}

while :
do
menu
read -p "Please Enter Your Choice:" ch
case $ch in
1)
commopt
;;
2)
commsec
pwdexp
filepmn
;;
3)
advsec
;;
4)
disservice
;;
5)
setlimit
;;
6)
webkernelopt
;;
7)
dbkernelopt
;;
8)
rebootos
;;
9)
exit 0
;;
*)
echo "***Wrong Input!***"
sleep 2
;;
esac
done
