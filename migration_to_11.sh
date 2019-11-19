#!/bin/bash
echo "fix duplicate stock quants in database, lot_id 9,10,13"

sudo pip3 install pyXB==1.2.5
sudo pip3 install --ignore-installed git+https://github.com/OCA/openupgradelib.git@master

echo "check duplicate stock_quant lot_id on another window and thelete them. Launch:"
echo "select id,lot_id from stock_quant ou where (select count(*) from stock_quant inr where inr.lot_id = ou.lot_id) > 1;"
echo "on database v11-mig with psql"
read -n1 -r -p "Press any key when done..." key


psql v11-mig <<EOF
\x
delete from ir_module_module where name = 'crm_project';
delete from ir_model_data where name = 'module_crm_project';
EOF


ou11

o11

odoouninstall.py -d v11-mig -u admin -w admin account_budget
odoouninstall.py -d v11-mig -u admin -w admin purchase_analytic_distribution
odoouninstall.py -d v11-mig -u admin -w admin sale_analytic_distribution
odoouninstall.py -d v11-mig -u admin -w admin sale_timesheet
odoouninstall.py -d v11-mig -u admin -w admin account_document
odoouninstall.py -d v11-mig -u admin -w admin l10n_it_vat_registries
odoouninstall.py -d v11-mig -u admin -w admin product_template_listprice_zero_default     #ancora non pronta la versione 12
odoouninstall.py -d v11-mig -u admin -w admin web_view_usability                          #ancora non pronta la versione 12
odoouninstall.py -d v11-mig -u admin -w admin product_computed_list_price                 #non presente già nella 11 (ingadhoc)
odoouninstall.py -d v11-mig -u admin -w admin l10n_it_account_stamp_ddt                   #non serve più
odoouninstall.py -d v11-mig -u admin -w admin base_manifest_extension                     #non presente già nella 11
odoouninstall.py -d v11-mig -u admin -w admin partner_create_by_vat                       #modulo simile da installare partner_autocomplete
odoouninstall.py -d v11-mig -u admin -w admin l10n_it_fiscalcode_invoice                  #non serve più
odoouninstall.py -d v11-mig -u admin -w admin l10n_it_fatturapa_out_wt                    #non serve più
odoouninstall.py -d v11-mig -u admin -w admin l10n_it_account_stamp_sale                  #non serve più
odoouninstall.py -d v11-mig -u admin -w admin l10n_it_base_location_geonames_import       #non serve più
odoouninstall.py -d v11-mig -u admin -w admin access_base                                 #ancora non pronta la versione 12
odoouninstall.py -d v11-mig -u admin -w admin sale_analytic_distribution                  #non presente già nella 11
odoouninstall.py -d v11-mig -u admin -w admin web_ckeditor4                               #non serve più
odoouninstall.py -d v11-mig -u admin -w admin document_page_tags                          #non presente già nella 11
odoouninstall.py -d v11-mig -u admin -w admin l10n_it_ateco                               #non presente già nella 11
odoouninstall.py -d v11-mig -u admin -w admin marketing_campaign                          #non serve più
odoouninstall.py -d v11-mig -u admin -w admin users_ldap_populate                         #non presente già nella 11
odoouninstall.py -d v11-mig -u admin -w admin account_accountant                          #non serve più
odoouninstall.py -d v11-mig -u admin -w admin users_ldap_mail                             #non presente già nella 11
odoouninstall.py -d v11-mig -u admin -w admin l10n_it_fatturapa_in_purchase
odoouninstall.py -d v11-mig -u admin -w admin auth_signup_verify_email
odoouninstall.py -d v11-mig -u admin -w admin disable_odoo_online
odoouninstall.py -d v11-mig -u admin -w admin auth_session_timeout
odoouninstall.py -d v11-mig -u admin -w admin res_users_clear_access_rights
odoouninstall.py -d v11-mig -u admin -w admin oerp_no_website_info

echo "duplicate database to v12-mig"
read -n1 -r -p "Press any key when done..." key


















