# -*- mode: ruby -*-
# vi: set ft=ruby :
#                                      _                                  
#                                     ( )_                                
#              _    _ __   ___    _ _ | ,_)   _ _   ___ ___     __   _ __ 
#            /'_`\ ( '__)/'___) /'_` )| |   /'_` )/' _ ` _ `\ /'__`\( '__)
#           ( (_) )| |  ( (___ ( (_| || |_ ( (_| || ( ) ( ) |(  ___/| |   
#           `\___/'(_)  `\____)`\__,_)`\__)`\__,_)(_) (_) (_)`\____)(_)   
#
# ======================================================================================
#
#                 MODERN PUPPET INFRASTRUCTURE ON GENTOO WITH STYLE
#
# ======================================================================================
#

forge "http://forge.puppetlabs.com"

modulefile

# puppet roles and profiles
mod "purplehazech/role",
  :git => "https://github.com/purplehazech/purplehazech-orcatamer-role.git",
  :ref => "master"
mod "purplehazech/profile",
  :git => "https://github.com/purplehazech/purplehazech-orcatamer-profile.git",
  :ref => "master"


# managing gentoo with their module makes sense
mod "gentoo/portage",
  :git => "https://github.com/gentoo/puppet-portage.git",
  :ref => "master"
# ccache makes compiles a tiny bit faster
mod "purplehazech/ccache"
# every machine needs a well configured syslogger
mod "purplehazech/syslogng"
# my dev boxes usually have mysql involved at some point
mod "example42/mysql"
# we need nginx for some webserver needs
mod "example42/nginx"
# sudo is needed by layman-add and we will be using it anyhow
mod "saz/sudo"

# system under development (this is currently being worked on)
mod "zabbix",
  :git => "https://github.com/purplehazech/puppet-zabbix.git",
  :ref => "feature/gentoo-cleanup"
