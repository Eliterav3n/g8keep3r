#!/bin/bash

print_help () {
    echo "Correct Usage:"
    echo "  g8keepr --add <username>"
    echo "  g8keepr --remove <username>"
    exit 14
}

print_error () {
    echo "unknown argument please try again"
    exit 15
}

removing_proc () {
    username="$1"
    echo "removing $username from the watched list"
}

adding_proc () {
    username="$1"
    if  grep -q "$username" $g8dir/watch.list 2>/dev/null; then
        echo "this username is already being watched for"
        echo "to remove a user from the watchlist please use --remove <username>"
        exit 15
    else
        # watchdog_cronfile="$username.g8keepr.parser.schedule"
        echo "$username" >> $g8dir/watch.list
        echo "watching $username"
        sudo -u root crontab -l 2>/dev/null; echo "* * * * * sudo -u root bash $g8dir/parser.sh $username" | crontab -
        # echo "*  *  *  *  *    root    `pwd`/parser.sh $username" >> /etc/crontab
    fi
}

g8dir="$(dirname "$(readlink -f "$0")")"

if [[ $EUID -gt 0 ]]; then
    echo "This script must be run as root"
    exit 12
fi

 ( iptables -V >/dev/null ) || ( echo "iptables is missing" && exit 16)

if [[ $# -lt 2 ]]; then
    echo "this script requires a username as an argument"
    echo "use --help to display this message"
    echo "Correct Usage:"
    echo "  g8keepr --add <username>"
    echo "  g8keepr --remove <username>"
    exit 13
fi

case "${1}" in
	"")         print_help;;
    --add)     adding_proc "$2";;
    --remove)     removing_proc "$2";;
    --help)   print_help;;
    *)          print_error;;
esac


# tail -n 100 /var/log/auth.log | awk '/password|sshd[*.]/{print $3,$11,$6,$9}' | awk '! /message/' | sed -e 's/sshd\[//g' -e 's/\]://g'