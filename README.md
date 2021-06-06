# PictureFrameMod
Modding of the Xoro Digital Picture Frame CPF8A (https://www.xoro.de/produkte/details/xoro-cpf-8a1/)

Der CPF8A ist ein digitaler Bilderrahmen mit Wifi und Cloudanbindung. 
Ein günstiger eBay-Kauf war die Grundlage für die Idee darüber einfach Urlaubsbilder den Großeltern bereitzustellen.
Da die Cloudfunktion ohnehin nur noch eingeschränkt funktioniert (Facebook, Twitter Funktion mittlerweile abgeschaltet, lediglich Foto Partner Cloud) und ich die Bilder gerne selbst unter Kontrolle habe, war klar das Teil zu rooten und entsprechend zu modden:

* Funktionen:  Wifi, USB, SD, Bewegungsmelder, IR-Fernbedienung, Sound
* Android Debug Port (5555) offen
```shell
platform-tools\adb kill-server
platform-tools\adb start-server
platform-tools\adb connect <LocalIP>
platform-tools\adb devices -l
platform-tools\adb shell
```

List of devices attached
192.168.178.53:5555    device product:astar_ococci model:XORO_CPF8A1 device:astar-ococci transport_id:1


* [Firmware](http://hwfotadown.mayitek.com/ota/root_data02_2/bozztek/bozztekA33_4.4/XORO%20CPF8A1/en/other/CPF8A1_20190928-0952/2019092811245887921.zip) von `http://hwfotadown.mayitek.com/ota/root_data02_2/bozztek/bozztekA33_4.4/XORO CPF8A1/en/other/CPF8A1_20190928-0952/2019092811245887921.zip`
* findet sich in /data/data/com.adups.fota/files/firmware.txt
* wird ausgeführt aus /data/data/com.adups.fota/update.zip bzw. /storage/emulated/0/adupsfota/update.zip

### Boot init-skripte
```
init.rc
import /init.environ.rc
import /init.usb.rc
import /init.${ro.hardware}.rc
import /init.trace.rc
import init.sun8i.usb.rc
```

### potentielle Hack-Ansätze
```
/system/xbin/usb_modeswitch.sh
/system/etc/dhcpcd/dhcpcd-hooks/95-configured
/system/bin/lights_leds.sh

### Einstiegspunkt in /system/bin/lights_leds.sh
sh /data/user/hack/loop.sh &

### Mutex für loop.sh
/mnt/obb/loop.run

### Netzwerkkonfig
/data/user/0/com.allwinner.theatreplayer.album/shared_prefs/album.xml
/data/misc/wifi/wpa_supplicant.conf

### Busybox muss noch aktualisiert werden
### DNS-Resolver muss aktualisiert werden
### Android intents
### logcat without XmppManager:    adb logcat XmppManager:S dalvikvm:S ActivityManager:V ContextImpl:S *:V
### IR-Keyboardhandler https://stackoverflow.com/questions/40635790/how-to-write-event-handler-for-buttons-in-adb-shell (Thanks Diego)
```

### Patching - Hooking into lights_leds.sh
Ansatz für den Hack ist das lights_leds.sh-Skript. Dort wird ein eigenes Shell-Skript (loop.sh) gestartet.

```
adb shell mount -t ext4 -o remount,rw /dev/block/by-name/system /system
adb push lights_leds.sh /system/bin/lights_leds.sh
adb shell chmod 755 /system/bin/lights_leds.sh

adb push resolv.conf /etc/resolv.conf

adb push busybox-armv7lv1_31 /data/user/hack/busybox-armv7lv1_31
adb shell chmod 755 /data/user/hack/busybox-armv7lv1_31

adb push loop.sh /data/user/hack/loop.sh
adb shell chmod 755 /data/user/hack/loop.sh
adb shell sync
``` 

