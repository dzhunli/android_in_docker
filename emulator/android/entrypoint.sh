#!/bin/bash
CHROMEDRIVER_PORT=9515
BOOTSTRAP_PORT=4725
EMULATOR=emulator-5554
APPIUM_ARGS=${APPIUM_ARGS:-""}
EMULATOR_ARGS=${EMULATOR_ARGS:-""}
PORT=6666
DISPLAY_NUM=99
DISPLAY=:99
export DISPLAY=:99
SCREEN_RESOLUTION=${SCREEN_RESOLUTION:-"1280x800x24"}
SKIN=${SKIN:-"1280x720"}
STOP=""
VERBOSE=${VERBOSE:-""}
ENABLE_VNC=true
VNC_PORT=${VNC_PORT:-"5900"}
if [ -z "$VERBOSE" ]; then
    if [ -z "$APPIUM_ARGS" ]; then
        APPIUM_ARGS="--log-level error"
    fi
else
    EMULATOR_ARGS="$EMULATOR_ARGS -verbose"
fi


clean() {
  STOP="yes"
  if [ -n "$APPIUM_PID" ]; then
    kill -TERM "$APPIUM_PID"
  fi
  if [ -n "$EMULATOR_PID" ]; then
    kill -TERM "$EMULATOR_PID"
  fi
  if [ -n "$X11VNC_PID" ]; then
    kill -TERM "$X11VNC_PID"
  fi
  if [ -n "$DEVTOOLS_PID" ]; then
    kill -TERM "$DEVTOOLS_PID"
  fi
  if [ -n "$XVFB_PID" ]; then
    kill -TERM "$XVFB_PID"
  fi
}

trap clean SIGINT SIGTERM

/usr/bin/xvfb-run -e /dev/stdout -l -n "$DISPLAY_NUM" -s "-ac -screen 0 $SCREEN_RESOLUTION -noreset -listen tcp" /usr/bin/fluxbox -display "$DISPLAY" -log /tmp/fluxbox.log 2>/dev/null &
XVFB_PID=$!

retcode=1
until [ $retcode -eq 0 ] || [ -n "$STOP" ]; do
  DISPLAY="$DISPLAY" wmctrl -m >/dev/null 2>&1
  retcode=$?
  if [ $retcode -ne 0 ]; then
    echo Waiting X server...
    sleep 0.1
  fi
done
if [ -n "$STOP" ]; then exit 0; fi

if [ "$ENABLE_VNC" != "true" ] && [ "$ENABLE_VIDEO" != "true" ]; then
    EMULATOR_ARGS="$EMULATOR_ARGS -no-window"
fi
ANDROID_AVD_HOME=/root/.android/avd DISPLAY="$DISPLAY" /opt/android-sdk-linux/emulator/emulator ${EMULATOR_ARGS} -writable-system -no-boot-anim -no-audio -no-jni -avd @AVD_NAME@ -sdcard /sdcard.img -skin "$SKIN" -skindir /opt/android-sdk-linux/platforms/@PLATFORM@/skins/ -gpu guest -grpc -ranchu -qemu -enable-kvm &
EMULATOR_PID=$!

if [ "$ENABLE_VNC" == "true" ]; then
    x11vnc -display "$DISPLAY" -shared -forever -loop500 -rfbport $VNC_PORT -rfbportv6 $VNC_PORT -logfile /tmp/x11vnc.log &
    X11VNC_PID=$!
fi

while [ "$(adb shell getprop sys.boot_completed | tr -d '\r')" != "1" ] && [ -z "$STOP" ] ; do sleep 1; done
if [ -n "$STOP" ]; then exit 0; fi

DEFAULT_CAPABILITIES='"androidNaturalOrientation": true, "deviceName": "android", "platformName": "Android", "noReset": true, "udid":"'$EMULATOR'"'
if [ -n "@CHROME_MOBILE@" ]; then
    while ip addr | grep inet | grep -q tentative > /dev/null; do sleep 0.1; done
    DEFAULT_CAPABILITIES=$DEFAULT_CAPABILITIES', "chromedriverPort": '$CHROMEDRIVER_PORT
    /usr/bin/devtools --android &
    DEVTOOLS_PID=$!
fi

if [ -x "/usr/bin/chromedriver" ]; then
    DEFAULT_CAPABILITIES=$DEFAULT_CAPABILITIES',"chromedriverExecutable": "/usr/bin/chromedriver"'
fi
set -x
adb install -d -r -g /tg.apk
adb install -d -r -g /viber.apk
adb install -d -r -g /whatsapp.apk
set +x
wait

