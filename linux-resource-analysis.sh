#!/bin/bash

### Color ###
RED="31"
GREEN="32"
YELLOW="33"
BOLDGREEN="\e[1;${GREEN}m"
BOLDYELLOW="\e[1;${YELLOW}m"
ITALICRED="\e[3;${RED}m"
ENDCOLOR="\e[0m"

### Function ###
hw1_function() {
	Verdor=$(dmidecode -t system | egrep "Manufacturer" | awk -F'Manufacturer:' {'print $2'} | sed -e 's/^[ ]*//g' | sed -e 's/[ ]*$//g' | awk {'print $1'} | cut -d',' -f1)
	if [[ "$Verdor" == HP ]]; then
		VENDOR="HP"
		ProductName=$(dmidecode -t system | egrep "Product Name" | awk -F'Product Name: ProLiant' {'print $2'} | sed -e 's/^[ ]*//g' | sed -e 's/[ ]*$//g')
		Platform="Linux"
	elif [[ "$Verdor" == VMware ]]; then
		VENDOR="VM"
		ProductName="VMware"
		Platform="Linux"
	elif [[ "$Verdor" == Stratus ]]; then
		VENDOR="VM"
		ProductName="EverRun"
		Platform="Linux"
	else
		echo "dmidecode -t system | egrep "Manufacturer""
	fi
	echo -e "$VENDOR\t$ProductName\t$Platform"
}
# hw1_function

os1_function() {
	if [ -f /etc/redhat-release ]; then
		OSVersion=`cat /etc/redhat-release | tr -c '[1-9]' ' ' | sed -e 's/^[ ]*//g' | sed -e 's/[ ]*$//g' | awk {'print $1'}`
	fi
	if [[ "$OSVersion" == 7 ]]; then
		OSName=$(cat /etc/redhat-release | awk {'print $1, $4'} | cut -d'.' -f1-2)
		OSBIT=$(getconf LONG_BIT)
		CPUcores=$(grep -c "model name" /proc/cpuinfo)
		MemoryTotalSize=$(dmidecode -t memory | egrep -v "No Module Installed" | egrep -i size | awk '{sum+=$2/1024} END {print sum " GB"}')
		DiskUsage=$(fdisk -l | egrep -v 'label|identifier|loop|mapper' | egrep 'Disk' | awk '{sum+=$3} END {print sum " GB"}')
		DiskType=SAS
		NICCount=$(ip addr | egrep 'eno|eth|ens|enp' | egrep -v 'veth|link|lo|docker|virbr|DOWN' | egrep 'state UP' | wc -l)
	elif [[ "$OSVersion" == 8 ]]; then
		OSName=$(cat /etc/redhat-release | awk {'print $1, $4'} | cut -d'.' -f1-2)
		OSBIT=$(getconf LONG_BIT)
		CPUcores=$(grep -c "model name" /proc/cpuinfo)
		MemoryTotalSize=$(dmidecode -t memory | egrep -v "No Module Installed" | egrep -i size | awk '{sum+=$2} END {print sum " GB"}')
		DiskUsage=$(fdisk -l | egrep -v 'label|identifier|loop|mapper' | egrep 'Disk' | awk '{sum+=$3} END {print sum " GB"}')
		DiskType=SAS
		NICCount=$(ip addr | egrep 'eno|eth|ens|enp' | egrep -v 'veth|link|lo|docker|virbr|DOWN' | egrep 'state UP' | wc -l)
	elif [[ "$OSVersion" == 6 || "$OSVersion" == 4 ]]; then
		OSName=$(cat /etc/redhat-release | awk {'print $1, $3'} | cut -d'.' -f1-2)
		OSBIT=$(getconf LONG_BIT)
		CPUcores=$(grep -c "model name" /proc/cpuinfo)
		MemoryTotalSize=$(dmidecode -t memory | egrep -v "No Module Installed" | egrep -i size | awk '{sum+=$2/1024} END {print sum " GB"}')
		DiskUsage=$(fdisk -l | egrep -v 'label|identifier|loop|mapper' | egrep 'Disk' | awk '{sum+=$3} END {print sum " GB"}')
		DiskType=SAS
		NICCount=$(ip addr | egrep 'eno|eth|ens|enp' | egrep -v 'veth|link|lo|docker|virbr|DOWN' | egrep 'UP' | wc -l)
	else
	echo -e "${ITALICRED}"
	echo """dmidecode -t system | egrep 'Manufacturer'
dmidecode -t system | egrep 'Product Name'
cat /etc/redhat-release
getconf LONG_BIT
grep -c processor /proc/cpuinfo

dmidecode -t memory | egrep -v 'No Module Installed' | egrep -i size
fdisk -l | egrep -v 'label|identifier|loop|mapper' | egrep 'Disk'
ip addr | egrep 'eno|eth|ens|enp' | egrep -v 'veth|link|lo|docker|virbr|DOWN' | grep UP"""
	echo -n -e "${ENDCOLOR}"
	fi
	echo -e "$OSName\t$OSBIT\t$CPUcores\t$MemoryTotalSize\t$DiskUsage\t$DiskType\t$NICCount"
}
# os1_function

utilization_function() {
	CPUPercent=$(top -b -n2 -p 1 | fgrep "Cpu(s)" | tail -1 | awk -F'id,' -v prefix="$prefix" '{ split($1, vs, ","); v=vs[length(vs)]; sub("%", "", v); printf "%s%.1f%%\n", prefix, 100 - v }')
	MEMORYPercent=$(free -m | awk 'NR==2{printf "%.1f%%\n",$3 * 100 / $2}')
	#DISKPercent=$(df -h | awk '$NF=="/"{printf "%s\n", $5}')
	echo -e "$CPUPercent\t$MEMORYPercent"
}
# utilization_function

apm_function() {
	if [ -f /usr/local/apache2/bin/apachectl ]; then
		ApacheVersion=`/usr/local/apache2/bin/apachectl -v | head -n1 | cut -d'/' -f2 | cut -d' ' -f1`
	elif [ -f `which httpd` ]; then
		HTTPD=`which httpd`
		ApacheVersion=`$HTTPD -v | head -n1 | cut -d'/' -f2 | cut -d' ' -f1`
	else
		ApacheVersion="No Apache!!!"
	fi

	if [ -f /usr/local/php/bin/php ]; then
		PHPVersion=`/usr/local/php/bin/php -v | head -n1 | cut -d' ' -f2`
	elif [ -f `which php` ]; then
		PHP=`which php`
		PHPVersion=`$PHP -v | head -n1 | cut -d' ' -f2`
	else
		PHPVersion="No PHP!!!"
	fi

	if [ -f /usr/local/mysql/bin/mysqladmin ]; then
		MySQLVersion=`/usr/local/mysql/bin/mysqladmin -V | cut -d' ' -f6 | cut -d',' -f1`
	elif [ -f `which mysqladmin` ]; then
		MySQL=`which mysqladmin`
		MySQLVersion=`$MySQL -V | cut -d' ' -f6 | cut -d',' -f1`
	else
		MySQLVersion="No MySQL!!!"
	fi
	echo -e "$ApacheVersion\t$PHPVersion\t$MySQLVersion"
}
# apm_function

mysql_function() {
	MySQLVer=`which mysqladmin`
	echo -n -e "${ITALICRED}$MySQLVer -V | cut -d' ' -f6 | cut -d',' -f1${ENDCOLOR}"
}
# mysql_function

### Main ###
LocalIP=`ip -4 a l $(ip route | head -1 | awk '/default/ {print $5}') | awk '/inet/ {print $2}' | awk -F'/' {'print $1'} | egrep -v 127.0.0.1 | tee ${outputfile}`
echo -e "\n${BOLDYELLOW}$LocalIP\t$HOSTNAME${ENDCOLOR}"

echo -e "\n${BOLDGREEN}`hw1_function`\t`os1_function`\t`utilization_function`${ENDCOLOR}"

echo -e "\n${BOLDGREEN}`apm_function`${ENDCOLOR}"

echo -e "\n${ITALICRED}`mysql_function`${ENDCOLOR}\n"
