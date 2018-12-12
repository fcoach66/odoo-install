#!/bin/bash
echo "fix duplicate stock quants in database, lot_id 9,10,13"
read -n1 -r -p "Press any key when done..." key

ou11
o11up

~/odoodev11/server/odoo-bin -c ~/odoodev11/odoo_serverrc -d v11-sinfocom -i base_address_city --stop-after-init
~/odoodev11/server/odoo-bin -c ~/odoodev11/odoo_serverrc -d v11-sinfocom -i account_group_menu --stop-after-init
~/odoodev11/server/odoo-bin -c ~/odoodev11/odoo_serverrc -d v11-sinfocom -i web_widget_x2many_2d_matrix --stop-after-init
~/odoodev11/server/odoo-bin -c ~/odoodev11/odoo_serverrc -d v11-sinfocom -i partner_fax --stop-after-init

o11up


odoouninstall.py -d v11-sinfocom --user admin --password Miky969696 marketing_campaign
odoouninstall.py -d v11-sinfocom --user admin --password Miky969696 portal_sale
odoouninstall.py -d v11-sinfocom --user admin --password Miky969696 disable_odoo_online
odoouninstall.py -d v11-sinfocom --user admin --password Miky969696 l10n_it_ateco 
odoouninstall.py -d v11-sinfocom --user admin --password Miky969696 l10n_it_base_location_geonames_import
odoouninstall.py -d v11-sinfocom --user admin --password Miky969696 partner_create_by_vat
odoouninstall.py -d v11-sinfocom --user admin --password Miky969696 users_ldap_populate
odoouninstall.py -d v11-sinfocom --user admin --password Miky969696 account_accountant
odoouninstall.py -d v11-sinfocom --user admin --password Miky969696 account_financial_report_date_range

#odoouninstall.py -d v11-mig --user admin --password Miky969696 edi
#odoouninstall.py -d v11-mig --user admin --password Miky969696 oerp_no_phoning_home
#odoouninstall.py -d v11-mig --user admin --password Miky969696 account_banking_payment_export
#odoouninstall.py -d v11-mig --user admin --password Miky969696 document_page_tags
#odoouninstall.py -d v11-mig --user admin --password Miky969696 hr_timesheet_invoice
#odoouninstall.py -d v11-mig --user admin --password Miky969696 l10n_it_base
#odoouninstall.py -d v11-mig --user admin --password Miky969696 account_voucher_cash_basis
#odoouninstall.py -d v11-mig --user admin --password Miky969696 web_ckeditor4
#odoouninstall.py -d v11-mig --user admin --password Miky969696 document_reindex
#odoouninstall.py -d v11-mig --user admin --password Miky969696 purchase_analytic_distribution
#odoouninstall.py -d v11-mig --user admin --password Miky969696 account_invoice_entry_date
#odoouninstall.py -d v11-mig --user admin --password Miky969696 product_computed_list_price
#odoouninstall.py -d v11-mig --user admin --password Miky969696 account_direct_debit
#odoouninstall.py -d v11-mig --user admin --password Miky969696 web_widget_one2many_tags
#odoouninstall.py -d v11-mig --user admin --password Miky969696 odoo_no_support
#odoouninstall.py -d v11-mig --user admin --password Miky969696 sale_stock_commission
#odoouninstall.py -d v11-mig --user admin --password Miky969696 contract_commission
#odoouninstall.py -d v11-mig --user admin --password Miky969696 portal_partner_merge
#odoouninstall.py -d v11-mig --user admin --password Miky969696 analytic_contract_hr_expense
#odoouninstall.py -d v11-mig --user admin --password Miky969696 hr_commission
#odoouninstall.py -d v11-mig --user admin --password Miky969696 analytic_user_function
#odoouninstall.py -d v11-mig --user admin --password Miky969696 product_sale_price_by_margin
#odoouninstall.py -d v11-mig --user admin --password Miky969696 product_uos
#odoouninstall.py -d v11-mig --user admin --password Miky969696 claim_from_delivery
#odoouninstall.py -d v11-mig --user admin --password Miky969696 report_webkit
#odoouninstall.py -d v11-mig --user admin --password Miky969696 website_crm_claim
#odoouninstall.py -d v11-mig --user admin --password Miky969696 warning
#odoouninstall.py -d v11-mig --user admin --password Miky969696 l10n_it_fiscalcode_invoice
#odoouninstall.py -d v11-mig --user admin --password Miky969696 users_ldap_populate
#odoouninstall.py -d v11-mig --user admin --password Miky969696 l10n_it_riba_commission
#odoouninstall.py -d v11-mig --user admin --password Miky969696 sale_analytic_distribution
#odoouninstall.py -d v11-mig --user admin --password Miky969696 account_payment_purchase
#odoouninstall.py -d v11-mig --user admin --password Miky969696 l10n_it_vat_registries_split_payment


ALTER TABLE "stock_quant" DROP COLUMN "cost" CASCADE;

ALTER TABLE "account_analytic_account" DROP COLUMN "date" CASCADE;

ALTER TABLE "account_analytic_line" DROP COLUMN "is_timesheet" CASCADE;

ALTER TABLE "mrp_workorder" DROP COLUMN "openupgrade_legacy_10_0_cycle" CASCADE;

ALTER TABLE "account_account" DROP COLUMN "openupgrade_legacy_9_0_type" CASCADE;

ALTER TABLE "hr_attendance" DROP COLUMN "sheet_id" CASCADE;
























