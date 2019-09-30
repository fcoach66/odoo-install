#!/bin/bash

su - odoo -c "git clone -b 9.0 --single-branch https://github.com/OCA/openupgrade /home/odoo/openupgrade9"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/openupgrade /home/odoo/openupgrade10"

