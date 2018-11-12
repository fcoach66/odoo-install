#!/bin/bash
#sudo /usr/bin/pip install pyXB==1.2.4

echo "launch o8"
read -n1 -r -p "Press any key when done..." key

odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 fcoach66_accounting_report_configuration_page
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 fcoach66_asset_account
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 fcoach66_liablity_account
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 fcoach66_balance_sheet_aeroo_report
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 fcoach66_trial_balance_aeroo_report
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 l10n_it_aeroo_base
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 l10n_it_report_extended_account
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 l10n_it_report_extended_sale
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 l10n_it_report_extended
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 l10n_it_intrastat_codes
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 product_catalog_aeroo_report
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 product_catalog_aeroo_report_public_categ
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 report_aeroo
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 report_aeroo_controller
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 web_linkedin
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 web_debranding
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 website_debranding
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 base_vcard
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 crm_vcard
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 odoo_no_support
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 oerp_no_phoning_home
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 mail_delete_sent_by_footer
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 oerp_no_website_info
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 newsletter
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 attachment_edit 
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 mail_tracking
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 mail_delete_access_link
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 report_custom_filename
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 account_bank_statement_import_ofx
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 base_user_signature_logo
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 hr_payroll_cancel
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 bom_inventory_information
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 access_base
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 is_employee
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 res_users_clear_access_rights
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 attachment_preview
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 product_sale_price_by_margin
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 product_replenishment_cost_currency
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 sale_payment_term_interest
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 account_clean_cancelled_invoice_number
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 product_computed_list_price
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 account_analytic_plans
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 document_page
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 account_credit_control
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 website


odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 sale_additional_text_template
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 sale_mandatory_fields
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 stock_picking_package_preparation_line
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 stock_picking_package_preparation





psql v8-sinfocom-full <<EOF
\x
UPDATE product_uom SET category_id=1 WHERE id=5;
DELETE FROM ir_ui_view WHERE inherit_id IS NOT NULL;
DELETE FROM res_groups WHERE id = 251;
EOF

psql v8-sinfocom-full <<EOF
\x
DELETE from ir_model_relation WHERE module = 1609;
DELETE from ir_model_constraint WHERE module = 1579;
DELETE from ir_model_relation WHERE module = 1579;
EOF

psql v8-sinfocom-full <<EOF
\x
delete from wkf_instance where res_id=613 and res_type='ir.module.module';
delete from ir_module_module where id IN (613);
delete from wkf_instance where res_id=46851 and res_type='ir.model.data';
delete from ir_model_data where id IN (46851);
EOF

echo "delete purchase_order_line_sequence from web interface"
echo "duplicate on v9-mig"
read -n1 -r -p "Press any key when done..." key

psql v9-mig <<EOF
\x
UPDATE product_uom SET category_id=1 WHERE id=5;
DELETE FROM ir_ui_view WHERE inherit_id IS NOT NULL;
DELETE FROM res_groups WHERE id = 251;
EOF

psql v9-mig <<EOF
\x
DELETE from ir_model_relation WHERE module = 1609;
DELETE from ir_model_constraint WHERE module = 1579;
DELETE from ir_model_relation WHERE module = 1579;
EOF

psql v9-mig <<EOF
\x
delete from wkf_instance where res_id=613 and res_type='ir.module.module';
delete from ir_module_module where id IN (613);
delete from wkf_instance where res_id=46851 and res_type='ir.model.data';
delete from ir_model_data where id IN (46851);
EOF


echo "launch ou9"
echo "launch ~/odoodev9/server/openerp-server -c ~/odoodev9/openerp_serverrc -d v9-mig -i account_payment_partner --stop-after-init"
read -n1 -r -p "Press any key when done..." key

psql v9-mig <<EOF
\x
DELETE FROM ir_ui_view WHERE inherit_id IS NOT NULL;
EOF

echo "and then o9up"


