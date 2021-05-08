#!/bin/bash

# Raspberry Pi 3

# Keyboard Setup
# sudo dpkg-reconfigure keyboard-configuration

# Non-Graphical Boot
# sudo systemctl set-default multi-user.target

# All Systems

# Disable Unattended Upgrades
sudo dpkg-reconfigure unattended-upgrades

# Disable Ondemand CPU Governor
# https://askubuntu.com/questions/1021748/set-cpu-governor-to-performance-in-18-04
sudo systemctl disable ondemand
# reboot
# cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

# Remove Stuff I Don't Need / Stupid Beacons
sudo apt remove \
    anacron at avahi-daemon \
    cron cups cups-browsed cups-daemon \
    popularity-contest \
    unattended-upgrades update-notifier update-notifier-common \
    whoopsie
