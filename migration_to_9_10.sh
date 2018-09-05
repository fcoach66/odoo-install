#!/bin/bash
sudo /usr/bin/pip install pyXB==1.2.4
o8up
o8


odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 sale_additional_text_template
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 sale_mandatory_fields
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 website
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 base_user_signature_logo
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 hr_payroll_cancel
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 bom_inventory_information
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 fcoach66_balance_sheet_aeroo_report
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 fcoach66_trial_balance_aeroo_report
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 l10n_it_aeroo_base
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 product_catalog_aeroo_report
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 product_catalog_aeroo_report_public_categ
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 report_aeroo
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 report_aeroo_controller
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 newsletter
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 fcoach66_accounting_report_configuration_page
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 web_linkedin
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 web_debranding
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 attachment_edit 
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 l10n_it_report_extended
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 l10n_it_report_extended_account
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 l10n_it_report_extended_sale
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 sale_additional_text_template
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 sale_mandatory_fields
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 access_base
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 mail_delete_access_link
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 is_employee
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 res_users_clear_access_rights
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 mail_delete_sent_by_footer
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 base_vcard
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 crm_vcard
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 stock_picking_package_preparation
odoouninstall.py -d v8-sinfocom-full --user admin --password Miky969696 stock_picking_package_preparation_line

psql v8-sinfocom-full <<EOF
\x
UPDATE product_uom SET category_id=1 WHERE id=5;
DELETE FROM ir_ui_view WHERE inherit_id = 533;
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

delete purchase_order_line_sequence from web interface


duplicazione su v9-mig-demo





ou9

psql v8-sinfocom-full <<EOF
\x
UPDATE product_uom SET category_id=3 WHERE id=5;
EOF


sudo /usr/local/bin/pip install pyXB==1.2.5

rename code on res_country_state column code 

ou10

DELETE FROM ir_ui_view WHERE id = 2369;
DELETE FROM ir_ui_view WHERE inherit_id = 1007;
DELETE FROM ir_ui_view WHERE id = 1007;
DELETE FROM ir_ui_view WHERE id = 2368;



o10up

o10

backup database
restore su macchina odoo11

ou11
o11up

~/odoodev11/server/odoo-bin -c ~/odoodev11/odoo_serverrc -d v11-mig -i base_address_city --stop-after-init
~/odoodev11/server/odoo-bin -c ~/odoodev11/odoo_serverrc -d v11-mig -i account_group_menu --stop-after-init
~/odoodev11/server/odoo-bin -c ~/odoodev11/odoo_serverrc -d v11-mig -i web_widget_x2many_2d_matrix --stop-after-init
~/odoodev11/server/odoo-bin -c ~/odoodev11/odoo_serverrc -d v11-mig -i partner_fax --stop-after-init

o11up


odoouninstall.py -d v11-mig --user admin --password Miky969696 edi
odoouninstall.py -d v11-mig --user admin --password Miky969696 attachment_preview
odoouninstall.py -d v11-mig --user admin --password Miky969696 account_asset_management
odoouninstall.py -d v11-mig --user admin --password Miky969696 l10n_it_intrastat_codes
odoouninstall.py -d v11-mig --user admin --password Miky969696 product_replenishment_cost_currency
odoouninstall.py -d v11-mig --user admin --password Miky969696  oerp_no_phoning_home
odoouninstall.py -d v11-mig --user admin --password Miky969696  sale_payment_term_interest
odoouninstall.py -d v11-mig --user admin --password Miky969696  account_banking_payment_export
odoouninstall.py -d v11-mig --user admin --password Miky969696  document_page_tags
odoouninstall.py -d v11-mig --user admin --password Miky969696  hr_timesheet_invoice
odoouninstall.py -d v11-mig --user admin --password Miky969696  l10n_it_base
odoouninstall.py -d v11-mig --user admin --password Miky969696  account_voucher_cash_basis
odoouninstall.py -d v11-mig --user admin --password Miky969696  web_ckeditor4
odoouninstall.py -d v11-mig --user admin --password Miky969696  document_reindex
odoouninstall.py -d v11-mig --user admin --password Miky969696  purchase_analytic_distribution
odoouninstall.py -d v11-mig --user admin --password Miky969696  account_invoice_entry_date
odoouninstall.py -d v11-mig --user admin --password Miky969696  product_computed_list_price
odoouninstall.py -d v11-mig --user admin --password Miky969696  account_direct_debit
odoouninstall.py -d v11-mig --user admin --password Miky969696  web_widget_one2many_tags
odoouninstall.py -d v11-mig --user admin --password Miky969696  odoo_no_support
odoouninstall.py -d v11-mig --user admin --password Miky969696  sale_stock_commission
odoouninstall.py -d v11-mig --user admin --password Miky969696  contract_commission
odoouninstall.py -d v11-mig --user admin --password Miky969696  portal_partner_merge
odoouninstall.py -d v11-mig --user admin --password Miky969696  analytic_contract_hr_expense
odoouninstall.py -d v11-mig --user admin --password Miky969696  hr_commission
odoouninstall.py -d v11-mig --user admin --password Miky969696  analytic_user_function
odoouninstall.py -d v11-mig --user admin --password Miky969696  report_custom_filename
odoouninstall.py -d v11-mig --user admin --password Miky969696  product_sale_price_by_margin
odoouninstall.py -d v11-mig --user admin --password Miky969696 product_uos
odoouninstall.py -d v11-mig --user admin --password Miky969696 claim_from_delivery
odoouninstall.py -d v11-mig --user admin --password Miky969696 report_webkit
odoouninstall.py -d v11-mig --user admin --password Miky969696 website_crm_claim
odoouninstall.py -d v11-mig --user admin --password Miky969696 warning
odoouninstall.py -d v11-mig --user admin --password Miky969696 account_bank_statement_import_ofx
odoouninstall.py -d v11-mig --user admin --password Miky969696 portal_sale
odoouninstall.py -d v11-mig --user admin --password Miky969696 l10n_it_base_location_geonames_import
odoouninstall.py -d v11-mig --user admin --password Miky969696 marketing_campaign
odoouninstall.py -d v11-mig --user admin --password Miky969696 disable_odoo_online
odoouninstall.py -d v11-mig --user admin --password Miky969696 partner_create_by_vat
odoouninstall.py -d v11-mig --user admin --password Miky969696 account_accountant
odoouninstall.py -d v11-mig --user admin --password Miky969696 account_financial_report_date_range
odoouninstall.py -d v11-mig --user admin --password Miky969696 l10n_it_fiscalcode_invoice
odoouninstall.py -d v11-mig --user admin --password Miky969696 users_ldap_populate
odoouninstall.py -d v11-mig --user admin --password Miky969696 l10n_it_ateco 
odoouninstall.py -d v11-mig --user admin --password Miky969696 l10n_it_riba_commission
odoouninstall.py -d v11-mig --user admin --password Miky969696 sale_analytic_distribution
odoouninstall.py -d v11-mig --user admin --password Miky969696 account_payment_purchase

ALTER TABLE "stock_quant" DROP COLUMN "cost" CASCADE;

ALTER TABLE "account_analytic_account" DROP COLUMN "date" CASCADE;

ALTER TABLE "account_analytic_line" DROP COLUMN "is_timesheet" CASCADE;

ALTER TABLE "mrp_workorder" DROP COLUMN "openupgrade_legacy_10_0_cycle" CASCADE;

ALTER TABLE "account_account" DROP COLUMN "openupgrade_legacy_9_0_type" CASCADE;

ALTER TABLE "hr_attendance" DROP COLUMN "sheet_id" CASCADE;

