#!/bin/sh 

if [ $(id -u) -eq 0 ]; then
                pass=$(perl -e 'print crypt($ARGV[0], "password")' ${password})
                useradd -m -p $pass ${username} 2>/dev/null
                echo $?
                if [ $? -eq 0 ] || [ $? -eq 9 ]; then
                  echo "User is in the system!"
                else
                  echo "Failed to add a user!"
                  exit 1
                fi
        		usermod -aG sudo ${username}
                if [ $? -eq 0 ] || [$? -eq 9]; then
                  echo "User's permission saved !"
                else
                  echo "Failed to add a user!"
                  exit 1
                fi
else
        echo "Only root may add a user to the system"
        exit 2
fi