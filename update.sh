#!/bin/bash

su - odoo -c "cd /opt/odoo/source/OCA/account-financial-reporting && git pull && cd ../.."
su - odoo -c "cd /opt/odoo/source/OCA/account-financial-tools && git pull && cd ../.."
su - odoo -c "cd /opt/odoo/source/OCA/account-invoice-reporting && git pull && cd ../.."
su - odoo -c "cd /opt/odoo/source/OCA/account-payment && git pull && cd ../.."
su - odoo -c "cd /opt/odoo/source/OCA/bank-payment && git pull && cd ../.."
su - odoo -c "cd /opt/odoo/source/OCA/bank-statement-import && git pull && cd ../.."
su - odoo -c "cd /opt/odoo/source/OCA/bank-statement-reconcile && git pull && cd ../.."
su - odoo -c "cd /opt/odoo/source/OCA/crm && git pull && cd ../.."
su - odoo -c "cd /opt/odoo/source/OCA/l10n-italy && git pull && cd ../.."
su - odoo -c "cd /opt/odoo/source/OCA/partner-contact && git pull && cd ../.."
su - odoo -c "cd /opt/odoo/source/OCA/product-attribute && git pull && cd ../.."
su - odoo -c "cd /opt/odoo/source/OCA/project-service && git pull && cd ../.."
su - odoo -c "cd /opt/odoo/source/OCA/purchase-workflow && git pull && cd ../.."
su - odoo -c "cd /opt/odoo/source/OCA/reporting-engine && git pull && cd ../.."
su - odoo -c "cd /opt/odoo/source/OCA/rma && git pull && cd ../.."
su - odoo -c "cd /opt/odoo/source/OCA/sale-reporting && git pull && cd ../.."
su - odoo -c "cd /opt/odoo/source/OCA/sale-workflow && git pull && cd ../.."
su - odoo -c "cd /opt/odoo/source/OCA/server-tools && git pull && cd ../.."
su - odoo -c "cd /opt/odoo/source/OCA/stock-logistics-workflow && git pull && cd ../.."
su - odoo -c "cd /opt/odoo/source/OCA/web && git pull && cd ../.."



su - odoo -c "/opt/odoo/server/odoo.py -u all --stop-after-init"

