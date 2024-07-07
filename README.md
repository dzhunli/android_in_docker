# FAST ANDROID EMULATOR
 - Android 13.0
 - Tablet view
 - Preistalled: adb,telegram,viber,whatsapp

![example-usage](.preview/emulators.png)

## Requirements
1. You must have Linux (deb based)
2. You must install some packages for the emulator to work 

tigervnc --> simply command for install
 ```bash
sudo apt update && sudo apt install -y -qqq tigervnc-viewer
```

docker --> please visit https://docs.docker.com/engine/install/ (you don`t need docker desktop ONLY docker engine)
## Install & Usage

- (OPTIONAL) Add the ability to run from anywhere 
 ```bash
    sudo mv shell-emu /usr/local/bin
```
---
### Run & connect to android emulator
 ```bash
    shell-emu -r
```
---
### Delete all android emulators
 ```bash
    shell-emu -d
```
---
### See help
 ```bash
    shell-emu -h 
```
