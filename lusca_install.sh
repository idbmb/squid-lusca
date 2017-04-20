#!/bin/bash
# Version 1.0 / 2nd July, 2014
# LUSCA r14942 Automated Installation Script for Ubuntu flavor / jz
# Syed Jahanzaib / aacable @ hotmail.com  / https://aacable.wordpress.com

# Setting Variables . . . [JZ]
# You can change the URL if default url is not accessible in some cases.
#URL=http://aacable.rdo.pt/files/linux_related/lusca
URL=http://wifismartzone.com/files/linux_related/lusca
SQUID_DIR="/etc/squid"
CACHE_DIR="/cache-1"
pid=`pidof squid`
osver=`cat /etc/issue |awk '{print $1}'`
squidlabel="LUSCA_HEAD-r14942"

# Colors Config  . . . [[ JZ . . . ]]
ESC_SEQ="\x1b["
COL_RESET=$ESC_SEQ"39;49;00m"
COL_RED=$ESC_SEQ"31;01m"
COL_GREEN=$ESC_SEQ"32;01m"

# OS checkup for UBUNTU
echo -e "$COL_GREEN Lusca r14942 Automated Installation Script ver 1.0 for Ubuntu . . .$COL_RESET"
echo -e "$COL_GREEN Checking OS version, as it must be Ubuntu in order to Continue . . .$COL_RESET"
if [[ $osver == Ubuntu ]]; then
echo
echo -e "$COL_GREEN Ubuntu is installed with following information fetched. $COL_RESET"
lsb_release -a
sleep 3
else
echo -e "$COL_RED Sorry, it seems your Linux Distribution is not UBUNTU . Exiting ...$COL_RESET"
exit 1
fi

# Make sure only root can run our script / Checking if user is root, otherwise exit with error [[Jz]]
echo
echo -e "$COL_GREEN Verifying if you are logged in with root privileges  . . .$COL_RESET" 1>&2
FILE="/tmp/out.$$"
GREP="/bin/grep"
if [ "$(id -u)" != "0" ]; then
echo
echo -e "$COL_RED This script must be run as root, switch to root now . . .$COL_RESET" 1>&2
exit 1
fi

# Clearing previous download if any in /tmp folder
echo
echo -e "$COL_GREEN Clearing previous downloads if any in /tmp folder to avoid duplication$COL_RESET"
sleep 3

rm -fr /tmp/squid.conf
rm -fr /tmp/storeurl.txt
rm -fr /tmp/storeurl.pl
rm -fr /tmp/LUSCA_HEAD-r14942*

# Checking IF $URL is accessible m if YES then continue further , otherwise EXIT the script with ERROR ! [[ JZ .. . .]]
echo
echo -e "$COL_GREEN Checking if $URL is accessible in order to proceed further. . .!! $COL_RESET"
cd /tmp
wget -q $URL/squid.conf
{
if [ ! -f /tmp/squid.conf ]; then
echo
echo -e "$COL_RED ERROR: Unable to contact $URL, or possibly internet is not working or your IP is in black list at destination server  !! $COL_RESET"
echo -e "$COL_RED ERROR: Please check manual if $URL is accessible or not or if it have required files, JZ  !! $COL_RESET"
exit 0
fi
}
rm -fr /tmp/squid.conf
sleep 6
# Moving further . . .

clear
echo -e "$COL_GREEN You are logged in with root ID, Ok to proceed further . . .!! $COL_RESET"
echo

################################################################## [zaib]
echo
echo -e "$COL_GREEN Updating Ubuntu first . . . !! $COL_RESET"
apt-get update
echo
echo
echo -e "$COL_GREEN Installing required components . . . !! $COL_RESET"
sleep 3
apt-get install  -y gcc  build-essential   libstdc++6   unzip    bzip2   sharutils  ccze  libzip-dev  automake1.9  libfile-readbackwards-perl  dnsmasq

# Clearing OLD data files . . .
{
if [ -f $SQUID_DIR/squid.conf ]; then
echo
echo
echo -e "$COL_RED Previous SQUID configuration file found in $SQUID_DIR ! renaming it for backup purpose . . . $COL_RESET"
mv $SQUID_DIR/squid.conf $SQUID_DIR/squid.conf.old
else
echo
echo
echo -e "$COL_GREEN No Previous Squid configuration have been found in $SQUID_DIR. Proceeding further $COL_RESET"
fi
}

# Checking SQUID status if its already running - check by PID
if [ "$pid" == "" ]; then
echo
echo
echo -e "$COL_GREEN No SQUID instance found in memory , so it seems we are good to GO !!! $COL_RESET"
else
echo
echo -e "$COL_RED SQUID is already running, probably you have some previous copy of SQUID installation, Better to stop and remove all previous squid installation !! $COL_RESET"
echo
echo -e "$COL_RED KILLING PREVIOUS SQUID INSTANCE by killall -9 squid command  !! $COL_RESET"
killall -9 squid
sleep 3
fi

# Downloading Squid source package [zaib]
echo
echo
echo -e "$COL_GREEN Downloading SQUID source package in /tmp folder. . . !! $COL_RESET"
sleep 3

# Checking if /tmp folder is previously present or not . . .
{
if [ ! -d "/tmp" ]; then
echo
echo
echo -e "$COL_RED /tmp folder not found, Creating it so all downloads will be placed here  . . . $COL_RESET"
mkdir /tmp
else
echo
echo -e "$COL_GREEN /tmp folder is already present , so no need to create it, Proceeding further . . . $COL_RESET"
fi
}

cd /tmp

# Checking IF LUSCA_HEAD-r14942.tar.gz  installation file have been ALREADY downloaded in /tmp to avoid duplication! [[ JZ .. . .]]
{
if [ -f /tmp/LUSCA_HEAD-r14942.tar.gz ]; then
rm -fr /tmp/LUSCA_HEAD-r14942.tar.gz
fi
}

wget -c http://wifismartzone.com/files/linux_related/lusca/LUSCA_HEAD-r14942.tar.gz

# Checking IF LUSCA_HEAD-r14942 installation file have been downloaded properly. if YEs continue further , otherwise EXIT the script with ERROR ! [[ JZ .. . .]]
{
if [ ! -f /tmp/LUSCA_HEAD-r14942.tar.gz ]; then
echo
echo

echo -e "$COL_RED ERROR: SQUID source code package File could not be download or not found in /tmp/ !! $COL_RESET"
exit 0
fi
}
echo
echo

echo -e "$COL_GREEN Extracting Squid from tar archive. . . !! $COL_RESET"
sleep 3
tar zxvf LUSCA_HEAD-r14942.tar.gz
cd LUSCA_HEAD-r14942/
mkdir /etc/squid

echo -e "$COL_GREEN Executing $squidlabel Compiler [jz] . . . !! $COL_RESET"
echo
cd /tmp/LUSCA_HEAD-r14942
./configure --prefix=/usr --exec_prefix=/usr --bindir=/usr/sbin --sbindir=/usr/sbin --libexecdir=/usr/lib/squid --sysconfdir=/etc/squid --localstatedir=/var/spool/squid --datadir=/usr/share/squid --enable-async-io=24 --with-aufs-threads=24 --with-pthreads --enable-storeio=aufs --enable-linux-netfilter --enable-arp-acl --enable-epoll --enable-removal-policies=heap --with-aio --with-dl --enable-snmp --enable-delay-pools --enable-htcp --enable-cache-digests --disable-unlinkd --enable-large-cache-files --with-large-files --enable-err-languages=English --enable-default-err-language=English --enable-referer-log --with-maxfd=65536
echo
echo -e "$COL_GREEN Executing MAKE and MAKE INSTALL commands . . . !! $COL_RESET"
sleep 3
make
make install
echo
echo
echo -e "$COL_GREEN Creating SQUID LOGS folder and assiging permissions . . . !! $COL_RESET"
sleep 3

# Checking if log folder is previously present or not . . .
{
if [ -d "/var/log/squid" ]; then
echo
echo
echo -e "$COL_GREEN LOGS folder found. No need to create, proceeding Further . . . $COL_RESET"
else
echo
echo
echo -e "$COL_GREEN Creating LOG Folder in /var/log/squid and setting permissions accordingly (to user proxy) $COL_RESET"
mkdir /var/log/squid
fi
}
chown proxy:proxy /var/log/squid
## ** DOWNLOAD SQUID.CONF
echo
echo
echo -e "$COL_GREEN Downloading SQUID.CONF file from $URL and copy it to $SQUID_DIR. . . !! $COL_RESET"
sleep 3

# Checking IF SQUID.CONF File have been ALREADY downloaded in /tmp to avoid duplication! [[ JZ .. . .]]
{
if [ -f /tmp/squid.conf ]; then
rm -fr /tmp/squid.conf
fi
}

cd /tmp
wget $URL/squid.conf

# Checking IF SQUID.CONF file have been downloaded. if YEs continue further , otherwise EXIT the script with ERROR ! [[ JZ .. . .]]
{
if [ ! -f /tmp/squid.conf ]; then
echo
echo
echo -e "$COL_RED ERROR: SQUID.CONF File could not be download or not found in /tmp/ !! $COL_RESET"
exit 0
fi
}
cp -fr squid.conf $SQUID_DIR

## ** DOWNLOAD SQUID.CONF
echo
echo
echo -e "$COL_GREEN Downloading STOREURL.PL file from $URL and copy it to $SQUID_DIR. . . !! $COL_RESET"
sleep 3
cd /tmp

{
if [ -f /tmp/storeurl.txt ]; then
rm -fr /tmp/storeurl.txt
fi
}

wget $URL/storeurl.txt

{
if [ -f /tmp/storeurl.pl ]; then
rm -fr /tmp/storeurl.pl
fi
}

mv storeurl.txt storeurl.pl

# Checking IF STOREURL.PL file have been downloaded. if YEs continue further , otherwise EXIT the script with ERROR ! [[ JZ .. . .]]
{
if [ ! -f /tmp/storeurl.pl ]; then
echo
echo
echo -e "$COL_RED ERROR: STOREURL.PL File could not be download or not found in /tmp/ !! $COL_RESET"
exit 0
fi
}
cp -fr storeurl.pl $SQUID_DIR

echo
echo
echo -e "$COL_GREEN Setting EXECUTE permission for storeurl.pl . . . !! $COL_RESET"
chmod +x $SQUID_DIR/storeurl.pl

# Creating CACHE folders
echo
echo
echo -e "$COL_GREEN Creating CACHE directory in $CACHE_DIR , in this example,I used 5GB for cache for test ,Adjust it accordingly  . . . !! $COL_RESET"
sleep 3

# Checking if /cache-1 folder exist  . . .
{
if [ ! -d "$CACHE_DIR" ]; then
echo
echo
echo -e "$COL_GREEN Creating cache folder in $CACHE_DIR , Default size is 5GB, you should set it accordingly to your requirements  . . . $COL_RESET"
mkdir $CACHE_DIR
chown proxy:proxy $CACHE_DIR
chmod 777 -R $CACHE_DIR
squid -z
else
echo
echo -e "$COL_RED $CACHE_DIR folder already exists , Clearing it before proceeding. . . $COL_RESET"
rm -fr $CACHE_DIR/*
chown proxy:proxy $CACHE_DIR
echo -e "$COL_GREEN $CACHE_DIR Initializing Cache Directories as per the config  . . . $COL_RESET"
echo
squid -z
chmod 777 -R $CACHE_DIR
fi
}

echo
echo
echo -e "$COL_GREEN Adding squid in /etc/rc.local for auto startup . . . !! $COL_RESET"
sed -i '/exit/d' /etc/rc.local
sed -i '/[/usr\/sbin\/squid]/d' /etc/rc.local
echo /usr/sbin/squid >> /etc/rc.local
echo exit 0 >> /etc/rc.local
echo
echo -e "$COL_GREEN Starting SQUID (and adding 10 seconds Pause for proper initialization). . . !! $COL_RESET"
squid
sleep 5

# Checking SQUID status via PID [zaib]
#if [ "$pid" == "" ]; then
#echo
#echo -e "$COL_RED ERROR: UNABLE to start SQUID, try to run with -d1N syntax and see where its showing error !! $COL_RESET"
#else
ps aux |grep squid
echo
echo -e "$COL_GREEN $squidlabel is Running OK with PID number "$pid", no further action required, EXITING  . . .$COL_RESET"
echo
echo To view squid web access activity log, use command
echo -e "$COL_GREEN tail -f /var/log/squid/access.log $COL_RESET"
echo OR
echo -e "$COL_GREEN tail -f /var/log/squid/access.log |ccze $COL_RESET"
echo
echo -e "$COL_GREEN Regard's / Syed Jahanzaib . . . !! $COL_RESET"
echo
