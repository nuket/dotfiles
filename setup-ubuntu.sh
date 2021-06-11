#!/bin/bash

set -ux

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
