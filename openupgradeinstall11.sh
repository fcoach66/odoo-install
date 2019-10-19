#!/bin/bash

su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/openupgrade /home/odoo/OpenUpgrade11"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/openupgrade /home/odoo/OpenUpgrade12"

su - odoo -c "mkdir -p /home/odoo/bin"
su - odoo -c "wget -O /home/odoo/bin/o11 https://raw.githubusercontent.com/fcoach66/odoo-install/master/openupgrade/bin/o11"
su - odoo -c "wget -O /home/odoo/bin/o11up https://raw.githubusercontent.com/fcoach66/odoo-install/master/openupgrade/bin/o11up"
su - odoo -c "wget -O /home/odoo/bin/ou11 https://raw.githubusercontent.com/fcoach66/odoo-install/master/openupgrade/bin/ou11"

su - odoo -c "wget -O /home/odoo/bin/o12 https://raw.githubusercontent.com/fcoach66/odoo-install/master/openupgrade/bin/o12"
su - odoo -c "wget -O /home/odoo/bin/o12up https://raw.githubusercontent.com/fcoach66/odoo-install/master/openupgrade/bin/o12up"
su - odoo -c "wget -O /home/odoo/bin/ou12 https://raw.githubusercontent.com/fcoach66/odoo-install/master/openupgrade/bin/ou12"

su - odoo -c "wget -O /home/odoo/openupgrade11_serverrc https://raw.githubusercontent.com/fcoach66/odoo-install/master/openupgrade/openupgrade11_serverrc"
su - odoo -c "wget -O /home/odoo/openupgrade11_no_addons_serverrc https://raw.githubusercontent.com/fcoach66/odoo-install/master/openupgrade/openupgrade11_no_addons_serverrc"

su - odoo -c "wget -O /home/odoo/openupgrade12_serverrc https://raw.githubusercontent.com/fcoach66/odoo-install/master/openupgrade/openupgrade12_serverrc"
su - odoo -c "wget -O /home/odoo/openupgrade12_no_addons_serverrc https://raw.githubusercontent.com/fcoach66/odoo-install/master/openupgrade/openupgrade12_no_addons_serverrc"


su - odoo -c "chmod 755 /home/odoo/bin/*"
