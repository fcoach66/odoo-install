sudo pip3 install pyXB==1.2.6

for d in $( ls odoodev12/source); do  find $(pwd)/odoodev12/source/$d -mindepth 2 -maxdepth 2 -type d -exec sh -c "ln -sfn \"{}\" $(pwd)/odoodev12/addons" \;; done
rm -f /home/odoo/odoodev12/l10n_ar_*

psql v12-mig <<EOF
\x
ALTER TABLE public.account_asset RENAME CONSTRAINT account_asset_asset_parent_id_fkey TO account_asset_parent_id_fkey;
ALTER TABLE public.account_asset_profile RENAME CONSTRAINT account_asset_category_parent_id_fkey TO account_asset_profile_parent_id_fkey;
update sale_order_line set project_id = NULL where project_id > 62 ;
EOF

ou12

psql v12-mig <<EOF
\x
DELETE FROM ir_ui_view WHERE inherit_id IS NOT NULL;
EOF

o12up

o12



odoouninstall.py -d v12-mig -u admin -w admin account_bank_statement_import_qif           #non presente nella 12
odoouninstall.py -d v12-mig -u admin -w admin account_financial_report_date_range
odoouninstall.py -d v12-mig -u admin -w admin report_intrastat



odoouninstall.py -d v12-mig -u admin -w admin sale_payment_term_interest
odoouninstall.py -d v12-mig -u admin -w admin base_user_signature_logo
odoouninstall.py -d v12-mig -u admin -w admin is_employee
odoouninstall.py -d v12-mig -u admin -w admin bom_inventory_information
odoouninstall.py -d v12-mig -u admin -w admin mail_delete_access_link
odoouninstall.py -d v12-mig -u admin -w admin sale_add_products_wizard
odoouninstall.py -d v12-mig -u admin -w admin edi
odoouninstall.py -d v12-mig -u admin -w admin analytic_user_function
odoouninstall.py -d v12-mig -u admin -w admin document_reindex

