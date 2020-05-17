#!/bin/bash

# shellcheck disable=1090
# shellcheck disable=2009
# shellcheck disable=2034

set -u -o pipefail

if ! ps -p $$ | grep -si bash; then
  echo "Sorry, this script requires bash."
  exit 1
fi

if ! [ -x "$(command -v systemctl)" ]; then
  echo "systemctl required. Exiting."
  exit 1
fi

function main {
  clear

  REQUIREDPROGS='arp w'
  for p in $REQUIREDPROGS; do
    if ! command -v "$p" >/dev/null 2>&1; then
      echo "$p is required."
      exit 1
    fi
  done

  ARPBIN="$(command -v arp)"
  WBIN="$(command -v w)"
  LXC="0"

  if grep -qE 'container=lxc|container=lxd' /proc/1/environ; then
    LXC="1"
  fi

  if grep -s "AUTOFILL='Y'" ./ubuntu.cfg; then
    USERIP="$($WBIN -ih | awk '{print $3}' | head -n1)"

    if [[ "$USERIP" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      ADMINIP="$USERIP"
    else
      ADMINIP=""
    fi

    sed -i "s/FW_ADMIN='/FW_ADMIN='$ADMINIP /" ./ubuntu.cfg
    sed -i "s/SSH_GRPS='/SSH_GRPS='$(id "$($WBIN -ih | awk '{print $1}' | head -n1)" -ng) /" ./ubuntu.cfg
    sed -i "s/CHANGEME=''/CHANGEME='$(date +%s)'/" ./ubuntu.cfg
    sed -i "s/VERBOSE='N'/VERBOSE='Y'/" ./ubuntu.cfg
  fi

  source ./ubuntu.cfg

  readonly ADDUSER
  readonly ARPBIN
  readonly AUDITDCONF
  readonly AUDITD_MODE
  readonly AUDITD_RULES
  readonly AUDITRULES
  readonly AUTOFILL
  readonly CHANGEME
  readonly COMMONACCOUNT
  readonly COMMONAUTH
  readonly COMMONPASSWD
  readonly COREDUMPCONF
  readonly DEFAULTGRUB
  readonly DISABLEFS
  readonly DISABLEMOD
  readonly DISABLENET
  readonly FW_ADMIN
  readonly JOURNALDCONF
  readonly LIMITSCONF
  readonly LOGINDCONF
  readonly LOGINDEFS
  readonly LOGROTATE
  readonly LOGROTATE_CONF
  readonly LXC
  readonly NTPSERVERPOOL
  readonly PAMLOGIN
  readonly RESOLVEDCONF
  readonly RKHUNTERCONF
  readonly SECURITYACCESS
  readonly SSHDFILE
  readonly SSHFILE
  readonly SSH_GRPS
  readonly SSH_PORT
  readonly SYSCTL
  readonly SYSCTL_CONF
  readonly SYSTEMCONF
  readonly TIMEDATECTL
  readonly TIMESYNCD
  readonly UFWDEFAULT
  readonly USERADD
  readonly USERCONF
  readonly VERBOSE
  readonly WBIN

  for s in ./scripts/[0-9_]*; do
    [[ -f $s ]] || break

    source "$s"
  done

  f_pre 
  f_kernel
  f_firewall
  f_disablenet
  f_disablefs
  f_disablemod
  f_systemdconf
  f_resolvedconf
  f_logindconf
  f_journalctl
  f_timesyncd
  f_fstab
  f_prelink
  f_aptget_configure
  f_aptget
  f_hosts
  f_issue
  f_sudo
  f_logindefs
  f_sysctl
  f_limitsconf
  f_adduser
  f_rootaccess
  f_package_install
  f_coredump
  #f_usbguard # Breaking the server
  f_postfix
  f_apport
  f_motdnews
  f_rkhunter
  f_sshconfig
  f_sshdconfig 
  f_password
  f_cron
  f_ctrlaltdel
  f_auditd
  f_aide
  f_rhosts
  f_users
  f_lockroot
  f_package_remove
  f_suid
  f_restrictcompilers
  f_umask
  f_path
  f_aa_enforce
  f_aide_post
  f_aide_timer
  f_aptget_noexec
  f_aptget_clean
  f_systemddelta
  f_post
  f_checkreboot

  echo
}

LOGFILE="hardening-$(hostname --short)-$(date +%y%m%d).log"
echo "[HARDENING LOG - $(hostname --fqdn) - $(LANG=C date)]" >> "$LOGFILE"

main "$@" | tee -a "$LOGFILE"
