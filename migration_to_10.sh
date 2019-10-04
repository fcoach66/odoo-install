#!/bin/bash

psql v9-mig <<EOF
\x
UPDATE product_uom SET category_id=3 WHERE id=5;
EOF


sudo pip install pyXB==1.2.6

echo "rename code on res_country_state column code"
read -n1 -r -p "Press any key when done..." key

ou10

#psql v9-mig <<EOF
#\x
#DELETE FROM ir_ui_view WHERE id = 2369;
#DELETE FROM ir_ui_view WHERE inherit_id = 1007;
#DELETE FROM ir_ui_view WHERE id = 1007;
#DELETE FROM ir_ui_view WHERE id = 2368;
#EOF

psql v9-mig <<EOF
\x
DELETE FROM ir_ui_view WHERE inherit_id is not null;
EOF



o10up

echo "launch o10"
echo "install module account_fiscal_year"
echo "install module partner_firstname"
echo "install module account_tax_balance"
echo "install module l10n_it_fiscal_document_type"
echo "install module l10n_it_fiscal_payment_term"


read -n1 -r -p "Press any key when done..." key

psql v9-mig <<EOF
\x
UPDATE account_chart_template SET currency_id=1 WHERE id=1;
UPDATE account_chart_template SET transfer_account_id=259 WHERE id=1;
EOF

o10up

echo "launch o10"
read -n1 -r -p "Press any key when done..." key

odoouninstall.py -d v9-mig --user admin --password Miky969696 claim_from_delivery
odoouninstall.py -d v9-mig --user admin --password Miky969696 product_uos
odoouninstall.py -d v9-mig --user admin --password Miky969696 hr_commission
odoouninstall.py -d v9-mig --user admin --password Miky969696 sale_stock_commission
odoouninstall.py -d v9-mig --user admin --password Miky969696 warning
odoouninstall.py -d v9-mig --user admin --password Miky969696 website_crm_claim
odoouninstall.py -d v9-mig --user admin --password Miky969696 web_ckeditor4
odoouninstall.py -d v9-mig --user admin --password Miky969696 portal_partner_merge
odoouninstall.py -d v9-mig --user admin --password Miky969696 edi
odoouninstall.py -d v9-mig --user admin --password Miky969696 account_invoice_entry_date
odoouninstall.py -d v9-mig --user admin --password Miky969696 report_webkit
odoouninstall.py -d v9-mig --user admin --password Miky969696 analytic_contract_hr_expense
odoouninstall.py -d v9-mig --user admin --password Miky969696 document_url
odoouninstall.py -d v9-mig --user admin --password Miky969696 web_widget_one2many_tags
odoouninstall.py -d v9-mig --user admin --password Miky969696 analytic_user_function
odoouninstall.py -d v9-mig --user admin --password Miky969696 contract_commission
odoouninstall.py -d v9-mig --user admin --password Miky969696 contract_mandate
odoouninstall.py -d v9-mig --user admin --password Miky969696 l10n_it_base
odoouninstall.py -d v9-mig --user admin --password Miky969696 document_reindex
odoouninstall.py -d v9-mig --user admin --password Miky969696 portal_payment_mode
odoouninstall.py -d v9-mig --user admin --password Miky969696 account_voucher_cash_basis


echo "backup database"
echo "restore on odoo11dev machine"
