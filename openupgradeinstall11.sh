#!/bin/bash

su - odoo -c "git clone -b 9.0 --single-branch https://github.com/OCA/openupgrade /home/odoo/openupgrade9"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/openupgrade /home/odoo/openupgrade10"

su - odoo -c "mkdir -p /home/odoo/bin"
su - odoo -c "wget -O /home/odoo/bin/o8 https://raw.githubusercontent.com/fcoach66/odoo-install/master/openupgrade/bin/o8"
su - odoo -c "wget -O /home/odoo/bin/o8up https://raw.githubusercontent.com/fcoach66/odoo-install/master/openupgrade/bin/o8up"

su - odoo -c "wget -O /home/odoo/bin/o9 https://raw.githubusercontent.com/fcoach66/odoo-install/master/openupgrade/bin/o9"
su - odoo -c "wget -O /home/odoo/bin/o9up https://raw.githubusercontent.com/fcoach66/odoo-install/master/openupgrade/bin/o9up"
su - odoo -c "wget -O /home/odoo/bin/ou9 https://raw.githubusercontent.com/fcoach66/odoo-install/master/openupgrade/bin/ou9"

su - odoo -c "wget -O /home/odoo/bin/o10 https://raw.githubusercontent.com/fcoach66/odoo-install/master/openupgrade/bin/o10"
su - odoo -c "wget -O /home/odoo/bin/o10up https://raw.githubusercontent.com/fcoach66/odoo-install/master/openupgrade/bin/o10up"
su - odoo -c "wget -O /home/odoo/bin/ou10 https://raw.githubusercontent.com/fcoach66/odoo-install/master/openupgrade/bin/ou10"


su - odoo -c "wget -O /home/odoo/openupgrade9_serverrc https://raw.githubusercontent.com/fcoach66/odoo-install/master/openupgrade/openupgrade9_serverrc"
su - odoo -c "wget -O /home/odoo/openupgrade9_no_addons_serverrc https://raw.githubusercontent.com/fcoach66/odoo-install/master/openupgrade/openupgrade9_no_addons_serverrc"
su - odoo -c "wget -O /home/odoo/openupgrade10_serverrc https://raw.githubusercontent.com/fcoach66/odoo-install/master/openupgrade/openupgrade10_serverrc"
su - odoo -c "wget -O /home/odoo/openupgrade10_no_addons_serverrc https://raw.githubusercontent.com/fcoach66/odoo-install/master/openupgrade/openupgrade10_no_addons_serverrc"


su - odoo -c "chmod 755 /home/odoo/bin/*"
