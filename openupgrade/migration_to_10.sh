#!/bin/bash

psql v9-mig <<EOF
\x
UPDATE product_uom SET category_id=3 WHERE id=5;
EOF


sudo /usr/local/bin/pip install pyXB==1.2.5

echo "rename code on res_country_state column code"
read -n1 -r -p "Press any key when done..." key

ou10

psql v9-mig <<EOF
\x
DELETE FROM ir_ui_view WHERE id = 2369;
DELETE FROM ir_ui_view WHERE inherit_id = 1007;
DELETE FROM ir_ui_view WHERE id = 1007;
DELETE FROM ir_ui_view WHERE id = 2368;
EOF

psql v9-mig <<EOF
\x
DELETE FROM ir_ui_view WHERE id = 3554;
EOF



o10up

echo "launch o10"
echo "backup database"
echo "restore on odoo11dev machine"

