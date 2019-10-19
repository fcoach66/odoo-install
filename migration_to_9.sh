#!/bin/bash
echo "unistall crm,newsletters,all debranding,report_extended_*"

sudo pip install pyXB==1.2.5

odoouninstall.py -d v8-sinfocom-full -u admin -w admin portal_partner_merge
odoouninstall.py -d v8-sinfocom-full -u admin -w admin attachment_preview
odoouninstall.py -d v8-sinfocom-full -u admin -w admin base_manifest_extension
odoouninstall.py -d v8-sinfocom-full -u admin -w admin l10n_it_intrastat_codes
odoouninstall.py -d v8-sinfocom-full -u admin -w admin base_vcard
odoouninstall.py -d v8-sinfocom-full -u admin -w admin account_bank_statement_line_import
odoouninstall.py -d v8-sinfocom-full -u admin -w admin website_debranding
odoouninstall.py -d v8-sinfocom-full -u admin -w admin web_debranding
odoouninstall.py -d v8-sinfocom-full -u admin -w admin crm
odoouninstall.py -d v8-sinfocom-full -u admin -w admin newsletter
odoouninstall.py -d v8-sinfocom-full -u admin -w admin report_extended
odoouninstall.py -d v8-sinfocom-full -u admin -w admin report_aeroo
odoouninstall.py -d v8-sinfocom-full -u admin -w admin sale_mandatory_fields
odoouninstall.py -d v8-sinfocom-full -u admin -w admin website

psql v9-mig <<EOF
\x
delete from ir_module_module where name = 'purchase_order_line_sequence';
delete from ir_model_data where name = 'module_purchase_order_line_sequence';
update product_template set uom_id = '8' where uom_id = '22';
update product_template set uom_po_id = '8' where uom_po_id = '22';
update sale_order_line set product_uom = '8' where product_uom = '22';
delete from product_uom where id = '22';
delete from product_uom where id = '21';
EOF

psql v9-mig <<EOF
\x
UPDATE product_uom SET category_id=1 WHERE id=5;
DELETE FROM ir_ui_view WHERE inherit_id IS NOT NULL;
EOF

rm /home/odoodev9/addons/website_proposal
rm /home/odoodev9/addons/mail_compose_select_lang
rm /home/odoodev9/addons/email_template_template
rm /home/odoodev9/addons/newsletter

ou9

psql v9-mig <<EOF
\x
DELETE FROM ir_ui_view WHERE inherit_id IS NOT NULL;
EOF

o9up

o9


odoouninstall.py -d v9-mig -u admin -w admin sale_payment_term_interest  #non presente già nella 11
odoouninstall.py -d v9-mig -u admin -w admin document_reindex            #non presente già nella 11
odoouninstall.py -d v9-mig -u admin -w admin bom_inventory_information   #non presente nella 12 (Vauxoo)
odoouninstall.py -d v9-mig -u admin -w admin base_user_signature_logo    #non presente nella 12 (Vauxoo)
odoouninstall.py -d v9-mig -u admin -w admin edi                         #non serve più
odoouninstall.py -d v9-mig -u admin -w admin sale_add_products_wizard    #non presente già nella 9 (ingadhoc)
odoouninstall.py -d v9-mig -u admin -w admin analytic_user_function      #non presente già nella 9
odoouninstall.py -d v9-mig -u admin -w admin is_employee                 #modulo simile presente in OCA
odoouninstall.py -d v9-mig -u admin -w admin mail_delete_access_link     #non presente già nella 9
#odoouninstall.py -d v9-mig -u admin -w admin l10n_it_base                #non serve più
#odoouninstall.py -d v9-mig -u admin -w admin account_invoice_entry_date  #non serve più
#odoouninstall.py -d v9-mig -u admin -w admin l10n_it_fatturapa_out_view
#odoouninstall.py -d v9-mig -u admin -w admin account_voucher_cash_basis  #non serve più

odoouninstall.py -d v9-mig -u admin -w admin report_aeroo_controller
odoouninstall.py -d v9-mig -u admin -w admin web_widget_one2many_tags
odoouninstall.py -d v9-mig -u admin -w admin portal_partner_merge
odoouninstall.py -d v9-mig -u admin -w admin mail_delete_sent_by_footer
odoouninstall.py -d v9-mig -u admin -w admin analytic_contract_hr_expense






#update ir_module_module set state = 'uninstalled' where latest_version like '8.%';
