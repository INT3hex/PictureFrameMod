#!/system/bin/sh
echo "start"
LOGFILE=/sdcard/FamilyAlbum/local/log.txt
IMAGEDIR=/sdcard/FamilyAlbum/local
MUTEX=/mnt/obb/loop.run
# URL to pictures
URL=http://192.168.178.200/cpf8a1/
SCRIPT=clear.sh
CONFIG=config.txt

echo "$(date) " >> $LOGFILE 
echo "$(date) [$BASHPID] starting /data/user/hack/loop.sh" >> $LOGFILE 

# Mutexsection
if [ -f "$MUTEX" ];
  then
    echo "Mutex $MUTEX is found, loop already running"
    echo "$(date) Mutex $MUTEX is found, loop already running - exit this!" >> $LOGFILE
    exit
  else
    echo "Mutex $MUTEX is not found"
    echo "$(date) Mutex $MUTEX is not found, start loop" >> $LOGFILE
fi
echo "Running Main!   Mutex BASHPID: $BASHPID" > $MUTEX

# block network communication
# check with: ip route oder /data/user/hack/busybox-armv7lv1_31 route
/data/user/hack/busybox-armv7lv1_31 route add -host 52.41.236.57 reject
/data/user/hack/busybox-armv7lv1_31 route add -host 8.211.36.31 reject
/data/user/hack/busybox-armv7lv1_31 route add -host umeng.com reject
/data/user/hack/busybox-armv7lv1_31 route add -host alog-g.umeng.com reject
/data/user/hack/busybox-armv7lv1_31 route add -host oc.umeng.com.gds.alibabadns.com reject
/data/user/hack/busybox-armv7lv1_31 route add -host alibabadns.com reject
/data/user/hack/busybox-armv7lv1_31 route add -host b.yahoo.com reject
/data/user/hack/busybox-armv7lv1_31 route add -host yahoo.com reject
/data/user/hack/busybox-armv7lv1_31 route add -host n.shifen.com reject
/data/user/hack/busybox-armv7lv1_31 route add -host shifen.com reject
/data/user/hack/busybox-armv7lv1_31 route add -host r6.mo.n.shifen.com reject
/data/user/hack/busybox-armv7lv1_31 route add -host ias.tencent-cloud.net reject
/data/user/hack/busybox-armv7lv1_31 route add -host tencent-cloud.net reject
/data/user/hack/busybox-armv7lv1_31 route add -host ec2-52-41-236-57.us-west-2.compute.amazonaws.com reject
/data/user/hack/busybox-armv7lv1_31 route add -host compute.amazonaws.com reject
/data/user/hack/busybox-armv7lv1_31 route add -host fota5.adup.cn reject
/data/user/hack/busybox-armv7lv1_31 route add -host adup.cn reject
/data/user/hack/busybox-armv7lv1_31 route add -host rqd.uu.qq.com reject
/data/user/hack/busybox-armv7lv1_31 route add -host hwfotadown.mayitek.com reject
/data/user/hack/busybox-armv7lv1_31 route add -host newupdater.api.eaglenet.cn reject
echo "$(date) blackhole hosts added..." >> $LOGFILE

  echo "Waiting initial loop..."
  echo "$(date) Waiting initial loop..." >> $LOGFILE
	sleep 60
	am start -n "com.allwinner.digitalphotoframe.showallapp/.MainActivity"
	am start -n "com.allwinner.theatreplayer.album/.ui.GalleryActivity"
	sleep 1
	input keyevent 21
	input keyevent 21
	input keyevent 21
	input keyevent 21
	sleep 1
	input keyevent 22
	input keyevent 22
  input keyevent 20
	input keyevent 23
	
	# NTP Set Time
	echo "$(date) Retreiving time from pool.ntp.org" >> $LOGFILE
	/data/user/hack/busybox-armv7lv1_31 ntpd -d -n -q -p pool.ntp.org
	
	# Download Config
	echo "Retreiving $URL$CONFIG"
	echo "$(date) Retreiving $URL$CONFIG" >> $LOGFILE
  rm $IMAGEDIR/$CONFIG
  /data/user/hack/busybox-armv7lv1_31 wget -P $IMAGEDIR $URL$CONFIG

	# Read Config
	line=""
	TIMEOUT=120
	input=$IMAGEDIR/$CONFIG
	echo "$(date) read $input" >> $LOGFILE
	read -r line < "$input"
	if [ -z "$line" ];
	then
	  TIMEOUT=1200
	else
	  TIMEOUT=$line
	fi
	echo "$(date) Initial finished. Going to loop in $TIMEOUT..." >> $LOGFILE
	
# Loopsection
while [ -f "$MUTEX" ];
do
	echo "$(date) Sleeping for $TIMEOUT"
	echo "$(date) Sleeping for $TIMEOUT" >> $LOGFILE
	sleep $TIMEOUT

	# Download Shell-Skript
	echo "Retreiving $URL$SCRIPT"
	echo "$(date) Retreiving $URL$SCRIPT" >> $LOGFILE
	rm $IMAGEDIR/$SCRIPT
	rm /data/user/hack/$SCRIPT
	/data/user/hack/busybox-armv7lv1_31 wget -P $IMAGEDIR $URL$SCRIPT
  cp $IMAGEDIR/$SCRIPT /data/user/hack/$SCRIPT
  chmod 755 /data/user/hack/$SCRIPT
  if [ -e "/data/user/hack/$SCRIPT" ]; 
  then
  		echo "$(date) Executing copied /data/user/hack/$SCRIPT" >> $LOGFILE
  		sh /data/user/hack/$SCRIPT
  fi  
	
  # Download Index
  # busybox wget (with repaired /etc/resolv.conf for busybox nslookup!!)
  /data/user/hack/busybox-armv7lv1_31 wget -P $IMAGEDIR $URL
  # get hrefs/jpg from index.html and cut everything out
  grep -Eoi '<a href="[^>]+jpg"><img' $IMAGEDIR/index.html | grep -Eoi '"[^>]+jpg"' | busybox tr -d '"' > $IMAGEDIR/imagelist.txt
  rm $IMAGEDIR/index.html 
  
  # Download Images
	line=""
	input=$IMAGEDIR/imagelist.txt
	while IFS= read -r line
		do
		echo "Retreiving $URL$line"
		echo "$(date) Retreiving $URL$line" >> $LOGFILE
  	/data/user/hack/busybox-armv7lv1_31 wget -P $IMAGEDIR $URL$line
	done < "$input"  

	# Reset ActivityManager
	echo "Restarting ActivityManager"
	echo "$(date) Restarting ActivityManager" >> $LOGFILE
	am restart
	sleep 45
	am start -n "com.allwinner.digitalphotoframe.showallapp/.MainActivity"
	am start -n "com.allwinner.theatreplayer.album/.ui.GalleryActivity"
	# check IR/Key-Inputs with getevent -c 2
	sleep 1
	input keyevent 21
	input keyevent 21
	input keyevent 21
	input keyevent 21
	sleep 1
	input keyevent 22
	input keyevent 22
	input keyevent 20
	input keyevent 23

	echo "$(date) SlideShow should be started..." >> $LOGFILE

	PROCESSPID=$(busybox pidof -s dhcpcd)
	if [ -z "$PROCESSPID" ]; 
	then
  	echo "process $PROCESSPID not running"
	else
  	echo "process $PROCESSPID running"
	fi
	echo "$(date) looping loop.sh" >> $LOGFILE 

done
echo "$(date) ending loop.sh - should never come to here..." >> $LOGFILE 
echo "$(date) Manual Mutex-stop signal set. Exiting..." >> $LOGFILE