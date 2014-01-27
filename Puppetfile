# -*- mode: ruby -*-
# vi: set ft=ruby :
#
#  ▒█████   ██▀███   ▄████▄   ▄▄▄         ▄▄▄█████▓ ▄▄▄       ███▄ ▄███▓▓█████  ██▀███  
# ▒██▒  ██▒▓██ ▒ ██▒▒██▀ ▀█  ▒████▄       ▓  ██▒ ▓▒▒████▄    ▓██▒▀█▀ ██▒▓█   ▀ ▓██ ▒ ██▒
# ▒██░  ██▒▓██ ░▄█ ▒▒▓█    ▄ ▒██  ▀█▄     ▒ ▓██░ ▒░▒██  ▀█▄  ▓██    ▓██░▒███   ▓██ ░▄█ ▒
# ▒██   ██░▒██▀▀█▄  ▒▓▓▄ ▄██▒░██▄▄▄▄██    ░ ▓██▓ ░ ░██▄▄▄▄██ ▒██    ▒██ ▒▓█  ▄ ▒██▀▀█▄  
# ░ ████▓▒░░██▓ ▒██▒▒ ▓███▀ ░ ▓█   ▓██▒     ▒██▒ ░  ▓█   ▓██▒▒██▒   ░██▒░▒████▒░██▓ ▒██▒
# ░ ▒░▒░▒░ ░ ▒▓ ░▒▓░░ ░▒ ▒  ░ ▒▒   ▓▒█░     ▒ ░░    ▒▒   ▓▒█░░ ▒░   ░  ░░░ ▒░ ░░ ▒▓ ░▒▓░
#   ░ ▒ ▒░   ░▒ ░ ▒░  ░  ▒     ▒   ▒▒ ░       ░      ▒   ▒▒ ░░  ░      ░ ░ ░  ░  ░▒ ░ ▒░
# ░ ░ ░ ▒    ░░   ░ ░          ░   ▒        ░        ░   ▒   ░      ░      ░     ░░   ░ 
#     ░ ░     ░     ░ ░            ░  ░                  ░  ░       ░      ░  ░   ░     
#                   ░                                                                   
#
# ======================================================================================
#
#                 MODERN PUPPET INFRASTRUCTURE ON GENTOO WITH STYLE
#
# ======================================================================================
#

forge "http://forge.puppetlabs.com"

modulefile

# managing gentoo with their module makes sense
mod "gentoo/portage"
# ccache makes compiles a tiny bit faster
mod "purplehazech/ccache"
# every machine needs a well configured syslogger
mod "purplehazech/syslogng"
# my dev boxes usually have mysql involved at some point
mod "example42/mysql"
# we need nginx for some webserver needs
mod "example42/nginx"

# system under development (this is currently being worked on)
mod "zabbix",
  :git => "git://github.com/purplehazech/puppet-zabbix.git",
  :ref => "feature/gentoo-cleanup"
