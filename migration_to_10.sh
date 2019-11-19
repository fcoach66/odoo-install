#!/bin/bash

psql v10-mig <<EOF
\x
UPDATE product_uom SET category_id=3 WHERE id=5;
UPDATE res_country_state SET code = 'PZo' WHERE code = 'PZ';
UPDATE res_country_state SET code = 'BNo' WHERE code = 'BN';
UPDATE res_country_state SET code = 'NAo' WHERE code = 'NA';
UPDATE res_country_state SET code = 'SAo' WHERE code = 'SA';
UPDATE res_country_state SET code = 'BOo' WHERE code = 'BO';
UPDATE res_country_state SET code = 'RAo' WHERE code = 'RA';
UPDATE res_country_state SET code = 'PNo' WHERE code = 'PN';
UPDATE res_country_state SET code = 'BGo' WHERE code = 'BG';
UPDATE res_country_state SET code = 'LCo' WHERE code = 'LC';
UPDATE res_country_state SET code = 'MBo' WHERE code = 'MB';
UPDATE res_country_state SET code = 'MIo' WHERE code = 'MI';
UPDATE res_country_state SET code = 'VAo' WHERE code = 'VA';
UPDATE res_country_state SET code = 'RMo' WHERE code = 'RM';
UPDATE res_country_state SET code = 'MCo' WHERE code = 'MC';
UPDATE res_country_state SET code = 'BIo' WHERE code = 'BI';
UPDATE res_country_state SET code = 'TOo' WHERE code = 'TO';
UPDATE res_country_state SET code = 'BAo' WHERE code = 'BA';
UPDATE res_country_state SET code = 'FGo' WHERE code = 'FG';
UPDATE res_country_state SET code = 'CTo' WHERE code = 'CT';
UPDATE res_country_state SET code = 'ENo' WHERE code = 'EN';
UPDATE res_country_state SET code = 'ARo' WHERE code = 'AR';
UPDATE res_country_state SET code = 'FIo' WHERE code = 'FI';
UPDATE res_country_state SET code = 'LUo' WHERE code = 'LU';
UPDATE res_country_state SET code = 'TNo' WHERE code = 'TN';
UPDATE res_country_state SET code = 'PGo' WHERE code = 'PG';
UPDATE res_country_state SET code = 'TRo' WHERE code = 'TR';
DROP INDEX public.product_attribute_line_product_attribute_value_rel_line_id_index;
DROP INDEX public.product_attribute_line_product_attribute_value_rel_val_id_index;
EOF


sudo pip install pyXB==1.2.6

ou10

psql v10-mig <<EOF
\x
DELETE FROM ir_ui_view WHERE inherit_id IS NOT NULL;
EOF

o10up

o10

odoouninstall.py -d v10-mig -u admin -w admin product_uos                 #non serve più
odoouninstall.py -d v10-mig -u admin -w admin report_custom_filename      #non serve più
odoouninstall.py -d v10-mig -u admin -w admin purchase_analytic_distribution  #non presente già nella 10
odoouninstall.py -d v10-mig -u admin -w admin report_webkit               #non presente già nella 10
odoouninstall.py -d v10-mig -u admin -w admin warning                     #non presente già nella 10

odoouninstall.py -d v10-mig -u admin -w admin product_template_tree_prices
odoouninstall.py -d v10-mig -u admin -w admin portal_sale_order_type
odoouninstall.py -d v10-mig -u admin -w admin report_extended_sale
odoouninstall.py -d v10-mig -u admin -w admin report_extended
odoouninstall.py -d v10-mig -u admin -w admin report_aeroo

odoouninstall.py -d v10-mig -u admin -w admin l10n_it_base                #non serve più
odoouninstall.py -d v10-mig -u admin -w admin account_invoice_entry_date  #non serve più
odoouninstall.py -d v10-mig -u admin -w admin l10n_it_fatturapa_out_view
odoouninstall.py -d v10-mig -u admin -w admin account_voucher_cash_basis  #non serve più


odoouninstall.py -d v10-mig -u admin -w admin document_url
odoouninstall.py -d v10-mig -u admin -w admin account_analytic_required
odoouninstall.py -d v10-mig -u admin -w admin portal_partner_merge
odoouninstall.py -d v10-mig -u admin -w admin report_aeroo_controller
odoouninstall.py -d v10-mig -u admin -w admin product_do_merge
odoouninstall.py -d v10-mig -u admin -w admin hr_payroll_cancel
odoouninstall.py -d v10-mig -u admin -w admin purchase_discount
odoouninstall.py -d v10-mig -u admin -w admin analytic_contract_hr_expense
odoouninstall.py -d v10-mig -u admin -w admin mail_delete_sent_by_footer
odoouninstall.py -d v10-mig -u admin -w admin web_widget_one2many_tags
odoouninstall.py -d v10-mig -u admin -w admin product_replenishment_cost
odoouninstall.py -d v10-mig -u admin -w admin portal_payment_mode
odoouninstall.py -d v10-mig -u admin -w admin account_clean_cancelled_invoice_number
odoouninstall.py -d v10-mig -u admin -w admin product_prices_update
odoouninstall.py -d v10-mig -u admin -w admin contract_mandate
odoouninstall.py -d v10-mig -u admin -w admin portal_payment_mode




echo "install module website and theme plain bootstrap"
echo "backup database"
echo "restore on odoo11dev machine"
