#!/bin/sh


printf "\n Running Hardening & Rebooting \n "
cd /resources
echo ${pwd} | sudo -S bash ubuntu.sh
echo ${pwd} | sudo -S  shutdown -r +1 "Rebooting in 1"

