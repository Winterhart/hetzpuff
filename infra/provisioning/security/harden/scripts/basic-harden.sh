#!/bin/sh


remove_hacking_tools() {
    apt-get autoremove --purge john netcat nmap hydra aircrack-ng
    echo "Hacking tools should be removed now"
}

check_no_pass() {
    sed -i s/NOPASSWD:// /etc/sudoers
    echo "Removed any instances of NOPASSWD in sudoers"
}

disable_guest_account() {
    echo 'allow-guest=false' >> /etc/lightdm/lightdm.conf
    echo "Disabled guest account."
    # Prevent dialog in step package
    apt-get install -yq update-notifier-common
}
# run_hardening - Run the hardening
install_hardening() {
    echo 'Running hardening...'
    chmod +x /resources/ubuntu.sh
}

remove_hacking_tools;
check_no_pass;
disable_guest_account;
install_hardening;

