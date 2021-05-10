#!/bin/bash

set -u
set -x

# Raspberry Pi 3

# Keyboard Setup
# sudo dpkg-reconfigure keyboard-configuration

# Non-Graphical Boot
# sudo systemctl set-default multi-user.target

# All Systems

update_secureboot_policy_() {
    sudo fuser -v -k /var/cache/debconf/config.dat
    sudo /usr/bin/perl -w /usr/share/debconf/frontend /usr/sbin/update-secureboot-policy --enroll-key
}

reboot_to_uefi_() {
    systemctl reboot --firmware-setup
}

drop_motd_() {
    for f in 85-fwupd 90-updates-available 91-release-upgrade 92-unattended-upgrades 95-hwe-eol; do
        sudo chmod -v -x /etc/update-motd.d/$f
    done
}

# https://developer.android.com/studio#command-tools

fetch_android_tools() {
    pushd ~/Downloads
    if [ "$?" -eq "0" ]; then
        wget https://dl.google.com/android/repository/commandlinetools-linux-7302050_latest.zip
        sudo unzip -d /opt commandlinetools-linux-7302050_latest.zip
        popd
    fi
}

main_() {
    # Disable Unattended Upgrades
    sudo dpkg-reconfigure unattended-upgrades

    # Disable Ondemand CPU Governor
    # https://askubuntu.com/questions/1021748/set-cpu-governor-to-performance-in-18-04
    # sudo systemctl disable ondemand
    # reboot
    # cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

    # Remove Stuff I Don't Need / Stupid Beacons
    sudo apt remove \
        apport \
        avahi-daemon \
        cups cups-browsed cups-daemon \
        firefox \
        irqbalance \
        kerneloops \
        modemmanager \
        popularity-contest \
        switcheroo-control \
        unattended-upgrades update-notifier update-notifier-common \
        whoopsie

    # Leave cron stuff for now
    # anacron at cron
}

# The following packages were automatically installed and are no longer required:
#   cups-server-common gir1.2-dbusmenu-glib-0.4 gir1.2-dee-1.0 gir1.2-unity-5.0 hplip-data libavahi-core7 libhpmud0 libimagequant0
#   libmbim-glib4 libmbim-proxy libqmi-glib5 libqmi-proxy libsane-hpaio printer-driver-postscript-hp python3-debconf python3-debian
#   python3-olefile python3-pexpect python3-pil python3-ptyprocess python3-renderpm python3-reportlab python3-reportlab-accel
#   ssl-cert usb-modeswitch usb-modeswitch-data
# Use 'sudo apt autoremove' to remove them.
# The following packages will be REMOVED:
#   avahi-daemon avahi-utils bluez-cups cups cups-browsed cups-core-drivers cups-daemon firefox hplip irqbalance kerneloops
#   libnss-mdns modemmanager popularity-contest printer-driver-hpcups printer-driver-splix switcheroo-control ubuntu-desktop
#   ubuntu-desktop-minimal ubuntu-release-upgrader-gtk ubuntu-standard unattended-upgrades update-manager update-notifier
#   update-notifier-common whoopsie
# 0 upgraded, 0 newly installed, 26 to remove and 0 not upgraded.
# After this operation, 240 MB disk space will be freed.
