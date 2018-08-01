#!/bin/bash

#--------------------------------------------------
# Update Server
#--------------------------------------------------
echo -e "\n---- Update Server ----"
sudo apt-get update && sudo apt-get dist-upgrade -y && sudo apt-get autoremove -y
sudo apt-get install default-jre -y
sudo add-apt-repository -y ppa:webupd8team/java
sudo apt-get install default-jdk -y
sudo apt-get update
sudo apt-get install oracle-java8-installer -y
sudo add-apt-repository -y ppa:mystic-mirage/pycharm
sudo apt-get update

echo -e "\n---- Install Virtualbox Guest Utils ----"
sudo apt-get install virtualbox-guest-x11-hwe -y



echo "Installazione Database Postgresql"
sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
apt-get update
apt-get upgrade -y
apt-get install -y postgresql-9.6 postgresql-server-dev-9.6 pgadmin3 pgadmin4

echo -e "\n---- Install tool packages ----"
sudo apt-get install wget subversion git bzr bzrtools python-pip python3-pip gdebi-core -y

sudo apt-get install -y libsasl2-dev python-dev libldap2-dev libssl-dev python3-dev libxml2-dev libxslt1-dev zlib1g-dev python3-pip python3-wheel python3-setuptools python3-babel python3-bs4 python3-cffi-backend python3-cryptography python3-dateutil python3-docutils python3-feedparser python3-funcsigs python3-gevent python3-greenlet python3-html2text python3-html5lib python3-jinja2 python3-lxml python3-mako python3-markupsafe python3-mock python3-ofxparse python3-openssl python3-passlib python3-pbr python3-pil python3-psutil python3-psycopg2 python3-pydot python3-pygments python3-pyparsing python3-pypdf2 python3-renderpm python3-reportlab python3-reportlab-accel python3-roman python3-serial python3-stdnum python3-suds python3-tz python3-usb python3-vatnumber python3-werkzeug python3-xlsxwriter python3-yaml
sudo -H pip3 install --upgrade -r https://raw.githubusercontent.com/odoo/odoo/11.0/requirements.txt

wget https://downloads.wkhtmltopdf.org/0.12/0.12.5/wkhtmltox_0.12.5-1.xenial_amd64.deb
gdebi --n wkhtmltox_0.12.5-1.xenial_amd64.deb

echo -e "\n---- Install python libraries ----"
# This is for compatibility with Ubuntu 16.04. Will work on 14.04, 15.04 and 16.04
sudo apt-get install python3-suds -y

echo -e "\n--- Install other required packages"
sudo apt-get install node-clean-css node-less python-gevent -y

#echo -e "\n--- Create symlink for node"
#sudo ln -s /usr/bin/nodejs /usr/bin/node

sudo pip3 install num2words ofxparse
sudo apt-get install nodejs npm node-less -y
#sudo npm install -g less
#sudo npm install -g less-plugin-clean-css	

	
	
echo "Installazione Odoo 11.0"
sudo -u postgres createuser -s odoo
sudo -u postgres psql -c "ALTER USER odoo WITH PASSWORD 'odoo';"
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'odoo';"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/OCB.git /home/odoo/server"
su - odoo -c "mkdir -p /home/odoo/addons"
su - odoo -c "mkdir -p /home/odoo/source/OCA"
su - odoo -c "git clone -b 11.0 https://github.com/OCA/reporting-engine /home/odoo/source/OCA/reporting-engine"
pip3 install --upgrade -r /home/odoo/source/OCA/reporting-engine/requirements.txt
su - odoo -c "ln -sfn /home/odoo/source/OCA/reporting-engine/report_fillpdf /home/odoo/addons/report_fillpdf"
su - odoo -c "ln -sfn /home/odoo/source/OCA/reporting-engine/report_qweb_parameter /home/odoo/addons/report_qweb_parameter"
su - odoo -c "ln -sfn /home/odoo/source/OCA/reporting-engine/report_wkhtmltopdf_param /home/odoo/addons/report_wkhtmltopdf_param"
su - odoo -c "ln -sfn /home/odoo/source/OCA/reporting-engine/report_xlsx /home/odoo/addons/report_xlsx"
su - odoo -c "ln -sfn /home/odoo/source/OCA/reporting-engine/report_xml /home/odoo/addons/report_xml"

sudo chown -R odoo:odoo /home/odoo/server
sudo chown -R odoo:odoo /opt/odoo
pip3 install geojson

echo "Installazione pyxb"
pip3 install pyxb==1.2.5

echo "Installazione codicefiscale"
pip3 install codicefiscale

echo "Installazione simplejson"
pip3 install simplejson

su - odoo -c "/home/odoo/server/odoo-bin --stop-after-init -s -c /home/odoo/odoo.conf --db_host=localhost --db_user=odoo --db_password=odoo --addons-path=/home/odoo/server/odoo/addons,/home/odoo/server/addons,/home/odoo/addons"

echo -e "* Create init file"
su - odoo -c "mkdir bin"
su - odoo -c "cat <<EOF > ~/bin/odoo
#!/bin/sh
/home/odoo/server/odoo-bin -c /home/odoo/odoo.conf
EOF"
su - odoo -c "chmod 755 ~/bin/odoo"

echo "Installazione Aeroo"
mkdir /opt/aeroo
echo '#!/bin/sh' > /etc/init.d/office
echo '' >> /etc/init.d/office
echo '/usr/bin/soffice --nologo --nofirststartwizard --headless --norestore --invisible "--accept=socket,host=localhost,port=8100,tcpNoDelay=1;urp;" &'  >> /etc/init.d/office
chmod +x /etc/init.d/office
update-rc.d office defaults
/etc/init.d/office
pip3 install jsonrpc2 daemonize
git clone https://github.com/aeroo/aeroo_docs.git /opt/aeroo/aeroo_docs
cd /opt/aeroo/aeroo_docs/
echo "Y" | python3 /opt/aeroo/aeroo_docs/aeroo-docs start -c /etc/aeroo-docs.conf
ln -s /opt/aeroo/aeroo_docs/aeroo-docs /etc/init.d/aeroo-docs
update-rc.d aeroo-docs defaults

su - odoo -c "git clone -b 11.0 https://github.com/ingadhoc/aeroo_reports.git /home/odoo/source/ingadhoc/aeroo_reports"
pip3 install --upgrade -r /home/odoo/source/ingadhoc/aeroo_reports/requirements.txt
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/aeroo_reports/report_aeroo /home/odoo/addons/report_aeroo"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/aeroo_reports/report_aeroo_sample /home/odoo/addons/report_aeroo_sample"

echo "Installazione Odoo 11.0 moduli server-tools"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/server-tools  /home/odoo/source/OCA/server-tools"
pip3 install -r /home/odoo/source/OCA/server-tools/requirements.txt
su - odoo -c "ln -sfn /home/odoo/source/OCA/server-tools/auditlog /home/odoo/addons/auditlog"
su - odoo -c "ln -sfn /home/odoo/source/OCA/server-tools/auto_backup /home/odoo/addons/auto_backup"
su - odoo -c "ln -sfn /home/odoo/source/OCA/server-tools/base_cron_exclusion /home/odoo/addons/base_cron_exclusion"
su - odoo -c "ln -sfn /home/odoo/source/OCA/server-tools/base_exception /home/odoo/addons/base_exception"
su - odoo -c "ln -sfn /home/odoo/source/OCA/server-tools/base_remote /home/odoo/addons/base_remote"
su - odoo -c "ln -sfn /home/odoo/source/OCA/server-tools/base_search_fuzzy /home/odoo/addons/base_search_fuzzy"
su - odoo -c "ln -sfn /home/odoo/source/OCA/server-tools/base_technical_user /home/odoo/addons/base_technical_user"
su - odoo -c "ln -sfn /home/odoo/source/OCA/server-tools/database_cleanup /home/odoo/addons/database_cleanup"
su - odoo -c "ln -sfn /home/odoo/source/OCA/server-tools/datetime_formatter /home/odoo/addons/datetime_formatter"
su - odoo -c "ln -sfn /home/odoo/source/OCA/server-tools/dbfilter_from_header /home/odoo/addons/dbfilter_from_header"
su - odoo -c "ln -sfn /home/odoo/source/OCA/server-tools/fetchmail_notify_error_to_sender /home/odoo/addons/fetchmail_notify_error_to_sender"
su - odoo -c "ln -sfn /home/odoo/source/OCA/server-tools/html_image_url_extractor /home/odoo/addons/html_image_url_extractor"
su - odoo -c "ln -sfn /home/odoo/source/OCA/server-tools/html_text /home/odoo/addons/html_text"
su - odoo -c "ln -sfn /home/odoo/source/OCA/server-tools/letsencrypt /home/odoo/addons/letsencrypt"
su - odoo -c "ln -sfn /home/odoo/source/OCA/server-tools/module_auto_update /home/odoo/addons/module_auto_update"
su - odoo -c "ln -sfn /home/odoo/source/OCA/server-tools/onchange_helper /home/odoo/addons/onchange_helper"
su - odoo -c "ln -sfn /home/odoo/source/OCA/server-tools/sentry /home/odoo/addons/sentry"

echo "Installazione Odoo 10.0 moduli server-ux"
su - odoo -c "mkdir -p /home/odoo/source/OCA"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/server-ux  /home/odoo/source/OCA/server-ux"
su - odoo -c "ln -sfn /home/odoo/source/OCA/server-ux/base_optional_quick_create /home/odoo/addons/base_optional_quick_create"
su - odoo -c "ln -sfn /home/odoo/source/OCA/server-ux/base_technical_features /home/odoo/addons/base_technical_features"
su - odoo -c "ln -sfn /home/odoo/source/OCA/server-ux/base_tier_validation /home/odoo/addons/base_tier_validation"
su - odoo -c "ln -sfn /home/odoo/source/OCA/server-ux/date_range /home/odoo/addons/date_range"
su - odoo -c "ln -sfn /home/odoo/source/OCA/server-ux/easy_switch_user /home/odoo/addons/easy_switch_user"
su - odoo -c "ln -sfn /home/odoo/source/OCA/server-ux/LICENSE /home/odoo/addons/LICENSE"
su - odoo -c "ln -sfn /home/odoo/source/OCA/server-ux/mass_editing /home/odoo/addons/mass_editing"
su - odoo -c "ln -sfn /home/odoo/source/OCA/server-ux/README.md /home/odoo/addons/README.md"
su - odoo -c "ln -sfn /home/odoo/source/OCA/server-ux/sequence_check_digit /home/odoo/addons/sequence_check_digit"
su - odoo -c "ln -sfn /home/odoo/source/OCA/server-ux/sequence_reset_period /home/odoo/addons/sequence_reset_period"

echo "Installazione Odoo 11.0 moduli partner-contact"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/partner-contact  /home/odoo/source/OCA/partner-contact"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/account_partner_merge /home/odoo/addons/account_partner_merge"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/base_continent /home/odoo/addons/base_continent"
su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/base_country_state_translatable /home/odoo/addons/base_country_state_translatable"
su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/base_location /home/odoo/addons/base_location"
su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/base_location_geonames_import /home/odoo/addons/base_location_geonames_import"
su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/base_location_nuts /home/odoo/addons/base_location_nuts"
su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/base_partner_merge /home/odoo/addons/base_partner_merge"
su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/base_partner_sequence /home/odoo/addons/base_partner_sequence"
su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/base_vat_sanitized /home/odoo/addons/base_vat_sanitized"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/firstname_display_name_trigger /home/odoo/addons/firstname_display_name_trigger"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/partner_academic_title /home/odoo/addons/partner_academic_title"
su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/partner_address_street3 /home/odoo/addons/partner_address_street3"
su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/partner_affiliate /home/odoo/addons/partner_affiliate"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/partner_alias /home/odoo/addons/partner_alias"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/partner_auto_salesman /home/odoo/addons/partner_auto_salesman"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/partner_bank_active /home/odoo/addons/partner_bank_active"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/partner_capital /home/odoo/addons/partner_capital"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/partner_changeset /home/odoo/addons/partner_changeset"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/partner_coc /home/odoo/addons/partner_coc"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/partner_company_type /home/odoo/addons/partner_company_type"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/partner_contact_address_detailed /home/odoo/addons/partner_contact_address_detailed"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/partner_contact_birthdate /home/odoo/addons/partner_contact_birthdate"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/partner_contact_birthplace /home/odoo/addons/partner_contact_birthplace"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/partner_contact_configuration /home/odoo/addons/partner_contact_configuration"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/partner_contact_department /home/odoo/addons/partner_contact_department"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/partner_contact_gender /home/odoo/addons/partner_contact_gender"
su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/partner_contact_in_several_companies /home/odoo/addons/partner_contact_in_several_companies"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/partner_contact_job_position /home/odoo/addons/partner_contact_job_position"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/partner_contact_lang /home/odoo/addons/partner_contact_lang"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/partner_contact_nationality /home/odoo/addons/partner_contact_nationality"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/partner_contact_nutrition /home/odoo/addons/partner_contact_nutrition"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/partner_contact_nutrition_activity_level /home/odoo/addons/partner_contact_nutrition_activity_level"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/partner_contact_nutrition_goal /home/odoo/addons/partner_contact_nutrition_goal"
su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/partner_contact_personal_information_page /home/odoo/addons/partner_contact_personal_information_page"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/partner_contact_role /home/odoo/addons/partner_contact_role"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/partner_contact_weight /home/odoo/addons/partner_contact_weight"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/partner_create_by_vat /home/odoo/addons/partner_create_by_vat"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/partner_disable_gravatar /home/odoo/addons/partner_disable_gravatar"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/partner_email_check /home/odoo/addons/partner_email_check"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/partner_employee_quantity /home/odoo/addons/partner_employee_quantity"
su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/partner_external_map /home/odoo/addons/partner_external_map"
su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/partner_fax /home/odoo/addons/partner_fax"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/partner_financial_risk /home/odoo/addons/partner_financial_risk"
su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/partner_firstname /home/odoo/addons/partner_firstname"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/partner_helper /home/odoo/addons/partner_helper"
su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/partner_identification /home/odoo/addons/partner_identification"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/partner_label /home/odoo/addons/partner_label"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/partner_multi_relation /home/odoo/addons/partner_multi_relation"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/partner_password_reset /home/odoo/addons/partner_password_reset"
su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/partner_phonecall_schedule /home/odoo/addons/partner_phonecall_schedule"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/partner_phone_extension /home/odoo/addons/partner_phone_extension"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/partner_risk_insurance /home/odoo/addons/partner_risk_insurance"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/partner_sale_risk /home/odoo/addons/partner_sale_risk"
su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/partner_second_lastname /home/odoo/addons/partner_second_lastname"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/partner_sector /home/odoo/addons/partner_sector"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/partner_stock_risk /home/odoo/addons/partner_stock_risk"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/partner_street_number /home/odoo/addons/partner_street_number"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/partner_vat_unique /home/odoo/addons/partner_vat_unique"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/partner-contact/portal_partner_merge /home/odoo/addons/portal_partner_merge"


echo "Installazione Odoo 10.0 moduli l10n-italy"
su - odoo -c "mkdir -p /home/odoo/source/OCA"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/l10n-italy  /home/odoo/source/OCA/l10n-italy"

#su - odoo -c "ln -sfn /home/odoo/source/OCA/l10n-italy/account_central_journal /home/odoo/addons/account_central_journal"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/l10n-italy/account_invoice_entry_date /home/odoo/addons/account_invoice_entry_date"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/l10n-italy/account_invoice_report_ddt_group /home/odoo/addons/account_invoice_report_ddt_group"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/l10n-italy/account_invoice_sequential_dates /home/odoo/addons/account_invoice_sequential_dates"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/l10n-italy/account_vat_period_end_statement /home/odoo/addons/account_vat_period_end_statement"
su - odoo -c "ln -sfn /home/odoo/source/OCA/l10n-italy/l10n_it_abicab /home/odoo/addons/l10n_it_abicab"
su - odoo -c "ln -sfn /home/odoo/source/OCA/l10n-italy/l10n_it_account /home/odoo/addons/l10n_it_account"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/l10n-italy/l10n_it_account_tax_kind /home/odoo/addons/l10n_it_account_tax_kind"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/l10n-italy/l10n_it_ateco /home/odoo/addons/l10n_it_ateco"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/l10n-italy/l10n_it_base_crm /home/odoo/addons/l10n_it_base_crm"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/l10n-italy/l10n_it_base_location_geonames_import /home/odoo/addons/l10n_it_base_location_geonames_import"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/l10n-italy/l10n_it_bill_of_entry /home/odoo/addons/l10n_it_bill_of_entry"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/l10n-italy/l10n_it_CEE_balance_generic /home/odoo/addons/l10n_it_CEE_balance_generic"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/l10n-italy/l10n_it_central_journal /home/odoo/addons/l10n_it_central_journal"
su - odoo -c "ln -sfn /home/odoo/source/OCA/l10n-italy/l10n_it_codici_carica /home/odoo/addons/l10n_it_codici_carica"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/l10n-italy/l10n_it_corrispettivi /home/odoo/addons/l10n_it_corrispettivi"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/l10n-italy/l10n_it_corrispettivi_sale /home/odoo/addons/l10n_it_corrispettivi_sale"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/l10n-italy/l10n_it_ddt /home/odoo/addons/l10n_it_ddt"
su - odoo -c "ln -sfn /home/odoo/source/OCA/l10n-italy/l10n_it_esigibilita_iva /home/odoo/addons/l10n_it_esigibilita_iva"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/l10n-italy/l10n_it_fatturapa /home/odoo/addons/l10n_it_fatturapa"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/l10n-italy/l10n_it_fatturapa_out /home/odoo/addons/l10n_it_fatturapa_out"
su - odoo -c "ln -sfn /home/odoo/source/OCA/l10n-italy/l10n_it_fiscalcode /home/odoo/addons/l10n_it_fiscalcode"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/l10n-italy/l10n_it_fiscalcode_invoice /home/odoo/addons/l10n_it_fiscalcode_invoice"
su - odoo -c "ln -sfn /home/odoo/source/OCA/l10n-italy/l10n_it_fiscal_document_type /home/odoo/addons/l10n_it_fiscal_document_type"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/l10n-italy/l10n_it_ipa /home/odoo/addons/l10n_it_ipa"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/l10n-italy/l10n_it_partially_deductible_vat /home/odoo/addons/l10n_it_partially_deductible_vat"
su - odoo -c "ln -sfn /home/odoo/source/OCA/l10n-italy/l10n_it_pec /home/odoo/addons/l10n_it_pec"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/l10n-italy/l10n_it_prima_nota_cassa /home/odoo/addons/l10n_it_prima_nota_cassa"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/l10n-italy/l10n_it_rea /home/odoo/addons/l10n_it_rea"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/l10n-italy/l10n_it_reverse_charge /home/odoo/addons/l10n_it_reverse_charge"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/l10n-italy/l10n_it_riba_commission /home/odoo/addons/l10n_it_riba_commission"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/l10n-italy/l10n_it_ricevute_bancarie /home/odoo/addons/l10n_it_ricevute_bancarie"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/l10n-italy/l10n_it_split_payment /home/odoo/addons/l10n_it_split_payment"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/l10n-italy/l10n_it_vat_registries /home/odoo/addons/l10n_it_vat_registries"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/l10n-italy/l10n_it_vat_registries_cash_basis /home/odoo/addons/l10n_it_vat_registries_cash_basis"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/l10n-italy/l10n_it_website_sale_corrispettivi /home/odoo/addons/l10n_it_website_sale_corrispettivi"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/l10n-italy/l10n_it_website_sale_fiscalcode /home/odoo/addons/l10n_it_website_sale_fiscalcode"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/l10n-italy/l10n_it_withholding_tax /home/odoo/addons/l10n_it_withholding_tax"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/l10n-italy/l10n_it_withholding_tax_payment /home/odoo/addons/l10n_it_withholding_tax_payment"

#su - odoo -c "git clone -b 10.0-mig-fatturapa https://github.com/eLBati/l10n-italy /home/odoo/source/eLBati/l10n-italy-10.0-mig-fatturapa"
#su - odoo -c "ln -sfn /home/odoo/source/eLBati/l10n-italy-10.0-mig-fatturapa/l10n_it_fatturapa /home/odoo/addons/l10n_it_fatturapa"
#su - odoo -c "ln -sfn /home/odoo/source/eLBati/l10n-italy-10.0-mig-fatturapa/l10n_it_fatturapa_out /home/odoo/addons/l10n_it_fatturapa_out"
#su - odoo -c "ln -sfn /home/odoo/source/eLBati/l10n-italy-10.0-mig-fatturapa/l10n_it_fiscalcode /home/odoo/addons/l10n_it_fiscalcode"
#su - odoo -c "ln -sfn /home/odoo/source/eLBati/l10n-italy-10.0-mig-fatturapa/l10n_it_ipa /home/odoo/addons/l10n_it_ipa"
#su - odoo -c "ln -sfn /home/odoo/source/eLBati/l10n-italy-10.0-mig-fatturapa/l10n_it_rea /home/odoo/addons/l10n_it_rea"
#su - odoo -c "ln -sfn /home/odoo/source/eLBati/l10n-italy-10.0-mig-fatturapa/l10n_it_split_payment /home/odoo/addons/l10n_it_split_payment"

#su - odoo -c "git clone -b 10.0-mig-withholding_tax https://github.com/alessandrocamilli/l10n-italy /home/odoo/source/alessandrocamilli/l10n-italy-10.0-mig-withholding_tax"
#su - odoo -c "ln -sfn /home/odoo/source/alessandrocamilli/l10n-italy-10.0-mig-withholding_tax/l10n_it_withholding_tax /home/odoo/addons/l10n_it_withholding_tax"
#su - odoo -c "ln -sfn /home/odoo/source/alessandrocamilli/l10n-italy-10.0-mig-withholding_tax/l10n_it_withholding_tax_payment /home/odoo/addons/l10n_it_withholding_tax_payment"

#su - odoo -c "git clone -b 10.0-l10n_it_ddt-fix https://github.com/As400it/l10n-italy /home/odoo/source/As400it/l10n-italy-10.0-l10n_it_ddt-fix"
#su - odoo -c "ln -sfn /home/odoo/source/As400it/l10n-italy-10.0-l10n_it_ddt-fix/l10n_it_ddt /home/odoo/addons/l10n_it_ddt"

#su - odoo -c "git clone -b 10-l10n_it_reverse_charge https://github.com/abstract-open-solutions/l10n-italy /home/odoo/source/abstract-open-solutions/l10n-italy-10-l10n_it_reverse_charge"
#su - odoo -c "ln -sfn /home/odoo/source/abstract-open-solutions/l10n-italy-10-l10n_it_reverse_charge/l10n_it_reverse_charge /home/odoo/addons/l10n_it_reverse_charge"

#su - odoo -c "git clone -b 10.0-mig-account_vat_period_end_statement https://github.com/eLBati/l10n-italy /home/odoo/source/eLBati/10.0-mig-account_vat_period_end_statement-l10n-italy"
#su - odoo -c "ln -sfn /home/odoo/source/eLBati/10.0-mig-account_vat_period_end_statement-l10n-italy/account_vat_period_end_statement /home/odoo/addons/account_vat_period_end_statement"

su - odoo -c "git clone -b 11.0-mig-tax_kind --single-branch https://github.com/fcoach66/l10n-italy  /home/odoo/source/fcoach66/11.0-mig-tax_kind-l10n-italy"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/11.0-mig-tax_kind-l10n-italy/l10n_it_account_tax_kind /home/odoo/addons/l10n_it_account_tax_kind"

su - odoo -c "git clone -b 11.0-mig-l10n_it_ipa --single-branch https://github.com/fcoach66/l10n-italy  /home/odoo/source/fcoach66/11.0-mig-l10n_it_ipa-l10n-italy"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/11.0-mig-l10n_it_ipa-l10n-italy/l10n_it_ipa /home/odoo/addons/l10n_it_ipa"

su - odoo -c "git clone -b 11.0-mig-l10n_it_rea --single-branch https://github.com/fcoach66/l10n-italy  /home/odoo/source/fcoach66/11.0-mig-l10n_it_rea-l10n-italy"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/11.0-mig-l10n_it_rea-l10n-italy/l10n_it_rea /home/odoo/addons/l10n_it_rea"


su - odoo -c "git clone -b 11.0-mig-fatturapa --single-branch https://github.com/fcoach66/l10n-italy  /home/odoo/source/fcoach66/11.0-mig-fatturapa-l10n-italy"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/11.0-mig-fatturapa-l10n-italy/l10n_it_fatturapa /home/odoo/addons/l10n_it_fatturapa"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/11.0-mig-fatturapa-l10n-italy/l10n_it_fatturapa_out /home/odoo/addons/l10n_it_fatturapa_out"


su - odoo -c "git clone -b 11.0-mig-l10n_it_split_payment --single-branch https://github.com/jackjack82/l10n-italy /home/odoo/source/jackjack82/11.0-mig-l10n_it_split_payment"
su - odoo -c "ln -sfn /home/odoo/source/jackjack82/11.0-mig-l10n_it_split_payment/l10n_it_split_payment /home/odoo/addons/l10n_it_split_payment"

su - odoo -c "git clone -b 11.0-mig-l10n_it_reverse_charge --single-branch https://github.com/jackjack82/l10n-italy /home/odoo/source/jackjack82/11.0-mig-l10n_it_reverse_charge"
su - odoo -c "ln -sfn /home/odoo/source/jackjack82/11.0-mig-l10n_it_reverse_charge/l10n_it_reverse_charge /home/odoo/addons/l10n_it_reverse_charge"

su - odoo -c "git clone -b 11.0-mig-l10n_it_withholding_tax --single-branch https://github.com/alessandrocamilli/l10n-italy /home/odoo/source/alessandrocamilli/11.0-mig-l10n_it_withholding_tax"
su - odoo -c "ln -sfn /home/odoo/source/alessandrocamilli/11.0-mig-l10n_it_withholding_tax/l10n_it_withholding_tax /home/odoo/addons/l10n_it_withholding_tax"
su - odoo -c "ln -sfn /home/odoo/source/alessandrocamilli/11.0-mig-l10n_it_withholding_tax/l10n_it_withholding_tax_payment /home/odoo/addons/l10n_it_withholding_tax_payment"

su - odoo -c "git clone -b 11.0-mig-l10n_it_ddt --single-branch https://github.com/SilvioGregorini/l10n-italy /home/odoo/source/SilvioGregorini/11.0-mig-l10n_it_ddt"
su - odoo -c "ln -sfn /home/odoo/source/SilvioGregorini/11.0-mig-l10n_it_ddt/l10n_it_ddt /home/odoo/addons/l10n_it_ddt"

su - odoo -c "git clone -b 11.0-mig-account_vat_period_end_statement --single-branch https://github.com/jackjack82/l10n-italy /home/odoo/source/jackjack82/11.0-mig-account_vat_period_end_statement"
su - odoo -c "ln -sfn /home/odoo/source/jackjack82/11.0-mig-account_vat_period_end_statement/account_vat_period_end_statement /home/odoo/addons/account_vat_period_end_statement"

su - odoo -c "git clone -b 11.0-mig-l10n_it_ricevute_bancarie --single-branch https://github.com/jackjack82/l10n-italy /home/odoo/source/jackjack82/11.0-mig-l10n_it_ricevute_bancarie"
su - odoo -c "ln -sfn /home/odoo/source/jackjack82/11.0-mig-l10n_it_ricevute_bancarie/l10n_it_ricevute_bancarie /home/odoo/addons/l10n_it_ricevute_bancarie"





echo "Installazione Odoo 11.0 moduli ingadhoc"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/ingadhoc/miscellaneous  /home/odoo/source/ingadhoc/miscellaneous"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/miscellaneous/base_ux /home/odoo/addons/base_ux"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/miscellaneous/base_validator /home/odoo/addons/base_validator"


su - odoo -c "git clone -b 11.0 --single-branch https://github.com/ingadhoc/odoo-argentina  /home/odoo/source/ingadhoc/odoo-argentina"
pip3 install -r /home/odoo/source/ingadhoc/odoo-argentina/requirements.txt
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/odoo-argentina/l10n_ar_account /home/odoo/addons/l10n_ar_account"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/odoo-argentina/l10n_ar_account_vat_ledger /home/odoo/addons/l10n_ar_account_vat_ledger"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/odoo-argentina/l10n_ar_account_vat_ledger_citi /home/odoo/addons/l10n_ar_account_vat_ledger_citi"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/odoo-argentina/l10n_ar_account_withholding /home/odoo/addons/l10n_ar_account_withholding"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/odoo-argentina/l10n_ar_afipws /home/odoo/addons/l10n_ar_afipws"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/odoo-argentina/l10n_ar_afipws_fe /home/odoo/addons/l10n_ar_afipws_fe"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/odoo-argentina/l10n_ar_bank /home/odoo/addons/l10n_ar_bank"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/odoo-argentina/l10n_ar_base /home/odoo/addons/l10n_ar_base"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/odoo-argentina/l10n_ar_chart /home/odoo/addons/l10n_ar_chart"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/odoo-argentina/l10n_ar_currency_update /home/odoo/addons/l10n_ar_currency_update"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/odoo-argentina/l10n_ar_demo /home/odoo/addons/l10n_ar_demo"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/odoo-argentina/l10n_ar_partner /home/odoo/addons/l10n_ar_partner"

su - odoo -c "git clone -b 11.0 --single-branch https://github.com/ingadhoc/argentina-sale  /home/odoo/source/ingadhoc/argentina-sale"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/argentina-sale/l10n_ar_sale /home/odoo/addons/l10n_ar_sale"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/argentina-sale/l10n_ar_stock /home/odoo/addons/l10n_ar_stock"

su - odoo -c "git clone -b 11.0 --single-branch https://github.com/ingadhoc/argentina-reporting  /home/odoo/source/ingadhoc/argentina-reporting"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/argentina-reporting/l10n_ar_aeroo_base /home/odoo/addons/l10n_ar_aeroo_base"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/argentina-reporting/l10n_ar_aeroo_einvoice /home/odoo/addons/l10n_ar_aeroo_einvoice"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/argentina-reporting/l10n_ar_aeroo_invoice /home/odoo/addons/l10n_ar_aeroo_invoice"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/argentina-reporting/l10n_ar_aeroo_payment_group /home/odoo/addons/l10n_ar_aeroo_payment_group"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/argentina-reporting/l10n_ar_aeroo_purchase /home/odoo/addons/l10n_ar_aeroo_purchase"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/argentina-reporting/l10n_ar_aeroo_sale /home/odoo/addons/l10n_ar_aeroo_sale"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/argentina-reporting/l10n_ar_aeroo_stock /home/odoo/addons/l10n_ar_aeroo_stock"

su - odoo -c "git clone -b 11.0 --single-branch https://github.com/ingadhoc/account-financial-tools  /home/odoo/source/ingadhoc/account-financial-tools"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/account-financial-tools/account_debt_management /home/odoo/addons/account_debt_management"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/account-financial-tools/account_document /home/odoo/addons/account_document"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/account-financial-tools/account_financial_amount /home/odoo/addons/account_financial_amount"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/account-financial-tools/account_fix /home/odoo/addons/account_fix"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/account-financial-tools/account_interests /home/odoo/addons/account_interests"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/account-financial-tools/account_journal_security /home/odoo/addons/account_journal_security"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/account-financial-tools/account_move_helper /home/odoo/addons/account_move_helper"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/account-financial-tools/account_statement_aeroo_report /home/odoo/addons/account_statement_aeroo_report"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/account-financial-tools/account_statement_move_import /home/odoo/addons/account_statement_move_import"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/account-financial-tools/account_ux /home/odoo/addons/account_ux"

su - odoo -c "git clone -b 11.0 --single-branch https://github.com/ingadhoc/reporting-engine  /home/odoo/source/ingadhoc/reporting-engine"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/reporting-engine/google_cloud_print /home/odoo/addons/google_cloud_print"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/reporting-engine/report_extended /home/odoo/addons/report_extended"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/reporting-engine/report_extended_account /home/odoo/addons/report_extended_account"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/reporting-engine/report_extended_payment_group /home/odoo/addons/report_extended_payment_group"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/reporting-engine/report_extended_purchase /home/odoo/addons/report_extended_purchase"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/reporting-engine/report_extended_sale /home/odoo/addons/report_extended_sale"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/reporting-engine/report_extended_stock /home/odoo/addons/report_extended_stock"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/reporting-engine/report_extended_website_sale /home/odoo/addons/report_extended_website_sale"

su - odoo -c "git clone -b 11.0 --single-branch https://github.com/ingadhoc/account-payment  /home/odoo/source/ingadhoc/account-payment"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/account-payment/account_check /home/odoo/addons/account_check"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/account-payment/account_payment_fix /home/odoo/addons/account_payment_fix"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/account-payment/account_payment_group /home/odoo/addons/account_payment_group"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/account-payment/account_payment_group_document /home/odoo/addons/account_payment_group_document"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/account-payment/account_transfer_unreconcile /home/odoo/addons/account_transfer_unreconcile"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/account-payment/account_withholding /home/odoo/addons/account_withholding"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/account-payment/account_withholding_automatic /home/odoo/addons/account_withholding_automatic"












echo "Installazione Odoo 11.0 moduli odoo-italy-extra"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/fcoach66/odoo-italy-extra  /home/odoo/source/fcoach66/odoo-italy-extra"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-italy-extra/l10n_it_report_extended /home/odoo/addons/	l10n_it_report_extended"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-italy-extra/l10n_it_aeroo_base /home/odoo/addons/l10n_it_aeroo_base"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-italy-extra/l10n_it_aeroo_invoice /home/odoo/addons/l10n_it_aeroo_invoice"
#su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-italy-extra/l10n_it_aeroo_ddt /home/odoo/addons/l10n_it_aeroo_ddt"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-italy-extra/l10n_it_aeroo_sale /home/odoo/addons/l10n_it_aeroo_sale"
#su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-italy-extra/odoo_fcoach66_fix /home/odoo/addons/odoo_fcoach66_fix"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-italy-extra/sale_additional_text_template /home/odoo/addons/sale_additional_text_template"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-italy-extra/sale_mandatory_fields /home/odoo/addons/sale_mandatory_fields"
































  




echo "Installazione Odoo 8.0 moduli account-payment"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/account-payment  /home/odoo/source/OCA/account-payment"
su - odoo -c "ln -sfn /home/odoo/source/OCA/account-payment/account_cash_invoice /home/odoo/addons/account_cash_invoice"
su - odoo -c "ln -sfn /home/odoo/source/OCA/account-payment/account_check_printing_report_base /home/odoo/addons/account_check_printing_report_base"
su - odoo -c "ln -sfn /home/odoo/source/OCA/account-payment/account_check_printing_report_dlt103 /home/odoo/addons/account_check_printing_report_dlt103"
su - odoo -c "ln -sfn /home/odoo/source/OCA/account-payment/account_due_list /home/odoo/addons/account_due_list"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/account-payment/account_due_list_aging_comments /home/odoo/addons/account_due_list_aging_comments"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/account-payment/account_due_list_days_overdue /home/odoo/addons/account_due_list_days_overdue"
su - odoo -c "ln -sfn /home/odoo/source/OCA/account-payment/account_due_list_payment_mode /home/odoo/addons/account_due_list_payment_mode"
su - odoo -c "ln -sfn /home/odoo/source/OCA/account-payment/account_early_payment_discount /home/odoo/addons/account_early_payment_discount"
su - odoo -c "ln -sfn /home/odoo/source/OCA/account-payment/account_partner_reconcile /home/odoo/addons/account_partner_reconcile"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/account-payment/account_payment_batch_process /home/odoo/addons/account_payment_batch_process"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/account-payment/account_payment_credit_card /home/odoo/addons/account_payment_credit_card"
su - odoo -c "ln -sfn /home/odoo/source/OCA/account-payment/account_payment_return /home/odoo/addons/account_payment_return"
su - odoo -c "ln -sfn /home/odoo/source/OCA/account-payment/account_payment_return_import /home/odoo/addons/account_payment_return_import"
su - odoo -c "ln -sfn /home/odoo/source/OCA/account-payment/account_payment_return_import_sepa_pain /home/odoo/addons/account_payment_return_import_sepa_pain"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/account-payment/account_payment_show_invoice /home/odoo/addons/account_payment_show_invoice"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/account-payment/account_vat_on_payment /home/odoo/addons/account_vat_on_payment"


echo "Installazione Odoo 8.0 moduli bank-payment"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/bank-payment  /home/odoo/source/OCA/bank-payment"
su - odoo -c "ln -sfn /home/odoo/source/OCA/bank-payment/account_banking_mandate /home/odoo/addons/account_banking_mandate"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/bank-payment/account_banking_mandate_sale /home/odoo/addons/account_banking_mandate_sale"
su - odoo -c "ln -sfn /home/odoo/source/OCA/bank-payment/account_banking_pain_base /home/odoo/addons/account_banking_pain_base"
su - odoo -c "ln -sfn /home/odoo/source/OCA/bank-payment/account_banking_sepa_credit_transfer /home/odoo/addons/account_banking_sepa_credit_transfer"
su - odoo -c "ln -sfn /home/odoo/source/OCA/bank-payment/account_banking_sepa_direct_debit /home/odoo/addons/account_banking_sepa_direct_debit"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/bank-payment/account_banking_tests /home/odoo/addons/account_banking_tests"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/bank-payment/account_import_line_multicurrency_extension /home/odoo/addons/account_import_line_multicurrency_extension"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/bank-payment/account_payment_blocking /home/odoo/addons/account_payment_blocking"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/bank-payment/account_payment_line_cancel /home/odoo/addons/account_payment_line_cancel"
su - odoo -c "ln -sfn /home/odoo/source/OCA/bank-payment/account_payment_mode /home/odoo/addons/account_payment_mode"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/bank-payment/account_payment_mode_term /home/odoo/addons/account_payment_mode_term"
su - odoo -c "ln -sfn /home/odoo/source/OCA/bank-payment/account_payment_order /home/odoo/addons/account_payment_order"
su - odoo -c "ln -sfn /home/odoo/source/OCA/bank-payment/account_payment_partner /home/odoo/addons/account_payment_partner"
su - odoo -c "ln -sfn /home/odoo/source/OCA/bank-payment/account_payment_sale /home/odoo/addons/account_payment_sale"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/bank-payment/account_voucher_killer /home/odoo/addons/account_voucher_killer"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/bank-payment/bank_statement_instant_voucher /home/odoo/addons/bank_statement_instant_voucher"


echo "Installazione Odoo 8.0 moduli stock-logistics-workflow"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/stock-logistics-workflow  /home/odoo/source/OCA/stock-logistics-workflow"
su - odoo -c "ln -sfn /home/odoo/source/OCA/stock-logistics-workflow/mrp_stock_picking_restrict_cancel /home/odoo/addons/mrp_stock_picking_restrict_cancel"
su - odoo -c "ln -sfn /home/odoo/source/OCA/stock-logistics-workflow/purchase_stock_picking_restrict_cancel /home/odoo/addons/purchase_stock_picking_restrict_cancel"
su - odoo -c "ln -sfn /home/odoo/source/OCA/stock-logistics-workflow/stock_no_negative /home/odoo/addons/stock_no_negative"
su - odoo -c "ln -sfn /home/odoo/source/OCA/stock-logistics-workflow/stock_pack_operation_auto_fill /home/odoo/addons/stock_pack_operation_auto_fill"
su - odoo -c "ln -sfn /home/odoo/source/OCA/stock-logistics-workflow/stock_picking_customer_ref /home/odoo/addons/stock_picking_customer_ref"
su - odoo -c "ln -sfn /home/odoo/source/OCA/stock-logistics-workflow/stock_picking_invoice_link /home/odoo/addons/stock_picking_invoice_link"
su - odoo -c "ln -sfn /home/odoo/source/OCA/stock-logistics-workflow/stock_picking_purchase_propagate /home/odoo/addons/stock_picking_purchase_propagate"
su - odoo -c "ln -sfn /home/odoo/source/OCA/stock-logistics-workflow/stock_picking_restrict_cancel_with_orig_move /home/odoo/addons/stock_picking_restrict_cancel_with_orig_move"
su - odoo -c "ln -sfn /home/odoo/source/OCA/stock-logistics-workflow/stock_picking_show_backorder /home/odoo/addons/stock_picking_show_backorder"
su - odoo -c "ln -sfn /home/odoo/source/OCA/stock-logistics-workflow/stock_picking_show_return /home/odoo/addons/stock_picking_show_return"
su - odoo -c "ln -sfn /home/odoo/source/OCA/stock-logistics-workflow/stock_split_picking /home/odoo/addons/stock_split_picking"

su - odoo -c "git clone -b 11.0-mig-stock_picking_package_preparation --single-branch https://github.com/dcorio/stock-logistics-workflow  /home/odoo/source/dcorio/11.0-mig-stock_picking_package_preparation"
su - odoo -c "ln -sfn /home/odoo/source/dcorio/11.0-mig-stock_picking_package_preparation/stock_picking_package_preparation /home/odoo/addons/stock_picking_package_preparation"
su - odoo -c "ln -sfn /home/odoo/source/dcorio/11.0-mig-stock_picking_package_preparation/stock_picking_package_preparation_line /home/odoo/addons/stock_picking_package_preparation_line"


echo "Installazione Odoo 8.0 moduli product-attribute"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/product-attribute  /home/odoo/source/OCA/product-attribute"
su - odoo -c "ln -sfn /home/odoo/source/OCA/product-attribute/product_brand /home/odoo/addons/product_brand"
su - odoo -c "ln -sfn /home/odoo/source/OCA/product-attribute/product_code_mandatory /home/odoo/addons/product_code_mandatory"
su - odoo -c "ln -sfn /home/odoo/source/OCA/product-attribute/product_code_unique /home/odoo/addons/product_code_unique"
su - odoo -c "ln -sfn /home/odoo/source/OCA/product-attribute/product_end_of_life /home/odoo/addons/product_end_of_life"
su - odoo -c "ln -sfn /home/odoo/source/OCA/product-attribute/product_firmware_version /home/odoo/addons/product_firmware_version"
su - odoo -c "ln -sfn /home/odoo/source/OCA/product-attribute/product_manufacturer /home/odoo/addons/product_manufacturer"
su - odoo -c "ln -sfn /home/odoo/source/OCA/product-attribute/product_multi_category /home/odoo/addons/product_multi_category"
su - odoo -c "ln -sfn /home/odoo/source/OCA/product-attribute/product_priority /home/odoo/addons/product_priority"
su - odoo -c "ln -sfn /home/odoo/source/OCA/product-attribute/product_sequence /home/odoo/addons/product_sequence"
su - odoo -c "ln -sfn /home/odoo/source/OCA/product-attribute/product_state /home/odoo/addons/product_state"
su - odoo -c "ln -sfn /home/odoo/source/OCA/product-attribute/product_supplierinfo_revision /home/odoo/addons/product_supplierinfo_revision"
su - odoo -c "ln -sfn /home/odoo/source/OCA/product-attribute/stock_production_lot_firmware_version /home/odoo/addons/stock_production_lot_firmware_version"


echo "Installazione Odoo 8.0 moduli stock-logistics-warehouse"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/stock-logistics-warehouse  /home/odoo/source/OCA/stock-logistics-warehouse"
su - odoo -c "ln -sfn /home/odoo/source/OCA/stock-logistics-warehouse/stock_available /home/odoo/addons/stock_available"
su - odoo -c "ln -sfn /home/odoo/source/OCA/stock-logistics-warehouse/stock_available_global /home/odoo/addons/stock_available_global"
su - odoo -c "ln -sfn /home/odoo/source/OCA/stock-logistics-warehouse/stock_available_unreserved /home/odoo/addons/stock_available_unreserved"
su - odoo -c "ln -sfn /home/odoo/source/OCA/stock-logistics-warehouse/stock_demand_estimate /home/odoo/addons/stock_demand_estimate"
su - odoo -c "ln -sfn /home/odoo/source/OCA/stock-logistics-warehouse/stock_inventory_chatter /home/odoo/addons/stock_inventory_chatter"
su - odoo -c "ln -sfn /home/odoo/source/OCA/stock-logistics-warehouse/stock_inventory_discrepancy /home/odoo/addons/stock_inventory_discrepancy"
su - odoo -c "ln -sfn /home/odoo/source/OCA/stock-logistics-warehouse/stock_mts_mto_rule /home/odoo/addons/stock_mts_mto_rule"
su - odoo -c "ln -sfn /home/odoo/source/OCA/stock-logistics-warehouse/stock_orderpoint_manual_procurement /home/odoo/addons/stock_orderpoint_manual_procurement"
su - odoo -c "ln -sfn /home/odoo/source/OCA/stock-logistics-warehouse/stock_orderpoint_manual_procurement_uom /home/odoo/addons/stock_orderpoint_manual_procurement_uom"
su - odoo -c "ln -sfn /home/odoo/source/OCA/stock-logistics-warehouse/stock_orderpoint_move_link /home/odoo/addons/stock_orderpoint_move_link"
su - odoo -c "ln -sfn /home/odoo/source/OCA/stock-logistics-warehouse/stock_orderpoint_purchase_link /home/odoo/addons/stock_orderpoint_purchase_link"
su - odoo -c "ln -sfn /home/odoo/source/OCA/stock-logistics-warehouse/stock_orderpoint_uom /home/odoo/addons/stock_orderpoint_uom"
su - odoo -c "ln -sfn /home/odoo/source/OCA/stock-logistics-warehouse/stock_putaway_method /home/odoo/addons/stock_putaway_method"
su - odoo -c "ln -sfn /home/odoo/source/OCA/stock-logistics-warehouse/stock_putaway_product /home/odoo/addons/stock_putaway_product"
su - odoo -c "ln -sfn /home/odoo/source/OCA/stock-logistics-warehouse/stock_putaway_same_location /home/odoo/addons/stock_putaway_same_location"
su - odoo -c "ln -sfn /home/odoo/source/OCA/stock-logistics-warehouse/stock_request /home/odoo/addons/stock_request"
su - odoo -c "ln -sfn /home/odoo/source/OCA/stock-logistics-warehouse/stock_request_kanban /home/odoo/addons/stock_request_kanban"
su - odoo -c "ln -sfn /home/odoo/source/OCA/stock-logistics-warehouse/stock_request_purchase /home/odoo/addons/stock_request_purchase"
su - odoo -c "ln -sfn /home/odoo/source/OCA/stock-logistics-warehouse/stock_warehouse_calendar /home/odoo/addons/stock_warehouse_calendar"
su - odoo -c "ln -sfn /home/odoo/source/OCA/stock-logistics-warehouse/stock_warehouse_orderpoint_stock_info /home/odoo/addons/stock_warehouse_orderpoint_stock_info"
su - odoo -c "ln -sfn /home/odoo/source/OCA/stock-logistics-warehouse/stock_warehouse_orderpoint_stock_info_unreserved /home/odoo/addons/stock_warehouse_orderpoint_stock_info_unreserved"


echo "Installazione Odoo 8.0 moduli stock-logistics-tracking"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/stock-logistics-tracking  /home/odoo/source/OCA/stock-logistics-tracking"


echo "Installazione Odoo 8.0 moduli stock-logistics-barcode"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/stock-logistics-barcode  /home/odoo/source/OCA/stock-logistics-barcode"
pip3 install -r /home/odoo/source/OCA/stock-logistics-barcode/requirements.txt
su - odoo -c "ln -sfn /home/odoo/source/OCA/stock-logistics-barcode/product_multi_ean /home/odoo/addons/product_multi_ean"
su - odoo -c "ln -sfn /home/odoo/source/OCA/stock-logistics-barcode/stock_scanner /home/odoo/addons/stock_scanner"


echo "Installazione Odoo 8.0 moduli web"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/web  /home/odoo/source/OCA/web"
pip3 install -r /home/odoo/source/OCA/web/requirements.txt
su - odoo -c "ln -sfn /home/odoo/source/OCA/web/web_action_conditionable /home/odoo/addons/web_action_conditionable"
su - odoo -c "ln -sfn /home/odoo/source/OCA/web/web_decimal_numpad_dot /home/odoo/addons/web_decimal_numpad_dot"
su - odoo -c "ln -sfn /home/odoo/source/OCA/web/web_dialog_size /home/odoo/addons/web_dialog_size"
su - odoo -c "ln -sfn /home/odoo/source/OCA/web/web_disable_export_group /home/odoo/addons/web_disable_export_group"
su - odoo -c "ln -sfn /home/odoo/source/OCA/web/web_environment_ribbon /home/odoo/addons/web_environment_ribbon"
su - odoo -c "ln -sfn /home/odoo/source/OCA/web/web_favicon /home/odoo/addons/web_favicon"
su - odoo -c "ln -sfn /home/odoo/source/OCA/web/web_group_expand /home/odoo/addons/web_group_expand"
su - odoo -c "ln -sfn /home/odoo/source/OCA/web/web_ir_actions_act_multi /home/odoo/addons/web_ir_actions_act_multi"
su - odoo -c "ln -sfn /home/odoo/source/OCA/web/web_ir_actions_act_view_reload /home/odoo/addons/web_ir_actions_act_view_reload"
su - odoo -c "ln -sfn /home/odoo/source/OCA/web/web_listview_range_select /home/odoo/addons/web_listview_range_select"
su - odoo -c "ln -sfn /home/odoo/source/OCA/web/web_m2x_options /home/odoo/addons/web_m2x_options"
su - odoo -c "ln -sfn /home/odoo/source/OCA/web/web_no_bubble /home/odoo/addons/web_no_bubble"
su - odoo -c "ln -sfn /home/odoo/source/OCA/web/web_notify /home/odoo/addons/web_notify"
su - odoo -c "ln -sfn /home/odoo/source/OCA/web/web_responsive /home/odoo/addons/web_responsive"
su - odoo -c "ln -sfn /home/odoo/source/OCA/web/web_searchbar_full_width /home/odoo/addons/web_searchbar_full_width"
su - odoo -c "ln -sfn /home/odoo/source/OCA/web/web_search_with_and /home/odoo/addons/web_search_with_and"
su - odoo -c "ln -sfn /home/odoo/source/OCA/web/web_sheet_full_width /home/odoo/addons/web_sheet_full_width"
su - odoo -c "ln -sfn /home/odoo/source/OCA/web/web_timeline /home/odoo/addons/web_timeline"
su - odoo -c "ln -sfn /home/odoo/source/OCA/web/web_tree_dynamic_colored_field /home/odoo/addons/web_tree_dynamic_colored_field"
su - odoo -c "ln -sfn /home/odoo/source/OCA/web/web_tree_many2one_clickable /home/odoo/addons/web_tree_many2one_clickable"
su - odoo -c "ln -sfn /home/odoo/source/OCA/web/web_widget_bokeh_chart /home/odoo/addons/web_widget_bokeh_chart"
su - odoo -c "ln -sfn /home/odoo/source/OCA/web/web_widget_color /home/odoo/addons/web_widget_color"
su - odoo -c "ln -sfn /home/odoo/source/OCA/web/web_widget_datepicker_options /home/odoo/addons/web_widget_datepicker_options"
su - odoo -c "ln -sfn /home/odoo/source/OCA/web/web_widget_image_download /home/odoo/addons/web_widget_image_download"
su - odoo -c "ln -sfn /home/odoo/source/OCA/web/web_widget_image_url /home/odoo/addons/web_widget_image_url"
su - odoo -c "ln -sfn /home/odoo/source/OCA/web/web_widget_many2many_tags_multi_selection /home/odoo/addons/web_widget_many2many_tags_multi_selection"
su - odoo -c "ln -sfn /home/odoo/source/OCA/web/web_widget_x2many_2d_matrix /home/odoo/addons/web_widget_x2many_2d_matrix"
su - odoo -c "ln -sfn /home/odoo/source/OCA/web/web_widget_x2many_2d_matrix_example /home/odoo/addons/web_widget_x2many_2d_matrix_example"


echo "Installazione Odoo 8.0 moduli sale-workflow"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/sale-workflow  /home/odoo/source/OCA/sale-workflow"
su - odoo -c "ln -sfn /home/odoo/source/OCA/sale-workflow/partner_prospect /home/odoo/addons/partner_prospect"
su - odoo -c "ln -sfn /home/odoo/source/OCA/sale-workflow/sale_automatic_workflow /home/odoo/addons/sale_automatic_workflow"
su - odoo -c "ln -sfn /home/odoo/source/OCA/sale-workflow/sale_automatic_workflow_payment_mode /home/odoo/addons/sale_automatic_workflow_payment_mode"
su - odoo -c "ln -sfn /home/odoo/source/OCA/sale-workflow/sale_commercial_partner /home/odoo/addons/sale_commercial_partner"
su - odoo -c "ln -sfn /home/odoo/source/OCA/sale-workflow/sale_exception /home/odoo/addons/sale_exception"
su - odoo -c "ln -sfn /home/odoo/source/OCA/sale-workflow/sale_invoice_group_method /home/odoo/addons/sale_invoice_group_method"
su - odoo -c "ln -sfn /home/odoo/source/OCA/sale-workflow/sale_merge_draft_invoice /home/odoo/addons/sale_merge_draft_invoice"
su - odoo -c "ln -sfn /home/odoo/source/OCA/sale-workflow/sale_order_action_invoice_create_hook /home/odoo/addons/sale_order_action_invoice_create_hook"
su - odoo -c "ln -sfn /home/odoo/source/OCA/sale-workflow/sale_order_invoicing_finished_task /home/odoo/addons/sale_order_invoicing_finished_task"
su - odoo -c "ln -sfn /home/odoo/source/OCA/sale-workflow/sale_order_line_date /home/odoo/addons/sale_order_line_date"
su - odoo -c "ln -sfn /home/odoo/source/OCA/sale-workflow/sale_order_line_input /home/odoo/addons/sale_order_line_input"
su - odoo -c "ln -sfn /home/odoo/source/OCA/sale-workflow/sale_order_price_recalculation /home/odoo/addons/sale_order_price_recalculation"
su - odoo -c "ln -sfn /home/odoo/source/OCA/sale-workflow/sale_order_type /home/odoo/addons/sale_order_type"
su - odoo -c "ln -sfn /home/odoo/source/OCA/sale-workflow/sale_product_set /home/odoo/addons/sale_product_set"
su - odoo -c "ln -sfn /home/odoo/source/OCA/sale-workflow/sale_product_set_variant /home/odoo/addons/sale_product_set_variant"


echo "Installazione Odoo 8.0 moduli stock-logistics-transport"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/stock-logistics-transport  /home/odoo/source/OCA/stock-logistics-transport"
su - odoo -c "ln -sfn /home/odoo/source/OCA/stock-logistics-transport/stock_location_address /home/odoo/addons/stock_location_address"
su - odoo -c "ln -sfn /home/odoo/source/OCA/stock-logistics-transport/stock_location_address_purchase /home/odoo/addons/stock_location_address_purchase"


echo "Installazione Odoo 8.0 moduli account-financial-reporting"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/account-financial-reporting  /home/odoo/source/OCA/account-financial-reporting"
pip3 install -r /home/odoo/source/OCA/account-financial-reporting/requirements.txt
#su - odoo -c "ln -sfn /home/odoo/source/OCA/account-financial-reporting/account_chart_report /home/odoo/addons/account_chart_report"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/account-financial-reporting/account_export_csv /home/odoo/addons/account_export_csv"
su - odoo -c "ln -sfn /home/odoo/source/OCA/account-financial-reporting/account_financial_report /home/odoo/addons/account_financial_report"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/account-financial-reporting/account_financial_report_horizontal /home/odoo/addons/account_financial_report_horizontal"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/account-financial-reporting/account_financial_report_qweb /home/odoo/addons/account_financial_report_qweb"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/account-financial-reporting/account_journal_report_xls /home/odoo/addons/account_journal_report_xls"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/account-financial-reporting/account_move_line_report_xls /home/odoo/addons/account_move_line_report_xls"
su - odoo -c "ln -sfn /home/odoo/source/OCA/account-financial-reporting/account_tax_balance /home/odoo/addons/account_tax_balance"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/account-financial-reporting/mis_builder /home/odoo/addons/mis_builder"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/account-financial-reporting/mis_builder_demo /home/odoo/addons/mis_builder_demo"
su - odoo -c "ln -sfn /home/odoo/source/OCA/account-financial-reporting/customer_activity_statement /home/odoo/addons/customer_activity_statement"
su - odoo -c "ln -sfn /home/odoo/source/OCA/account-financial-reporting/customer_outstanding_statement /home/odoo/addons/customer_outstanding_statement"

echo "Installazione Odoo 8.0 moduli account-financial-tools"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/account-financial-tools  /home/odoo/source/OCA/account-financial-tools"
su - odoo -c "ln -sfn /home/odoo/source/OCA/account-financial-tools/account_balance_line /home/odoo/addons/account_balance_line"
su - odoo -c "ln -sfn /home/odoo/source/OCA/account-financial-tools/account_credit_control /home/odoo/addons/account_credit_control"
su - odoo -c "ln -sfn /home/odoo/source/OCA/account-financial-tools/account_credit_control_dunning_fees /home/odoo/addons/account_credit_control_dunning_fees"
su - odoo -c "ln -sfn /home/odoo/source/OCA/account-financial-tools/account_fiscal_year /home/odoo/addons/account_fiscal_year"
su - odoo -c "ln -sfn /home/odoo/source/OCA/account-financial-tools/account_group_menu /home/odoo/addons/account_group_menu"
su - odoo -c "ln -sfn /home/odoo/source/OCA/account-financial-tools/account_invoice_constraint_chronology /home/odoo/addons/account_invoice_constraint_chronology"
su - odoo -c "ln -sfn /home/odoo/source/OCA/account-financial-tools/account_invoice_currency /home/odoo/addons/account_invoice_currency"
su - odoo -c "ln -sfn /home/odoo/source/OCA/account-financial-tools/account_loan /home/odoo/addons/account_loan"
su - odoo -c "ln -sfn /home/odoo/source/OCA/account-financial-tools/account_move_fiscal_year /home/odoo/addons/account_move_fiscal_year"
su - odoo -c "ln -sfn /home/odoo/source/OCA/account-financial-tools/account_move_line_purchase_info /home/odoo/addons/account_move_line_purchase_info"
su - odoo -c "ln -sfn /home/odoo/source/OCA/account-financial-tools/account_move_line_tax_editable /home/odoo/addons/account_move_line_tax_editable"
su - odoo -c "ln -sfn /home/odoo/source/OCA/account-financial-tools/account_partner_required /home/odoo/addons/account_partner_required"
su - odoo -c "ln -sfn /home/odoo/source/OCA/account-financial-tools/account_reversal /home/odoo/addons/account_reversal"
su - odoo -c "ln -sfn /home/odoo/source/OCA/account-financial-tools/account_tag_menu /home/odoo/addons/account_tag_menu"
su - odoo -c "ln -sfn /home/odoo/source/OCA/account-financial-tools/account_type_menu /home/odoo/addons/account_type_menu"






echo "Installazione Odoo 11.0 moduli account-closing"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/account-closing  /home/odoo/source/OCA/account-closing"
su - odoo -c "ln -sfn /home/odoo/source/OCA/account-closing/account_cutoff_accrual_base /home/odoo/addons/account_cutoff_accrual_base"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/account-closing/account_cutoff_accrual_dates /home/odoo/addons/account_cutoff_accrual_dates"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/account-closing/account_cutoff_accrual_picking /home/odoo/addons/account_cutoff_accrual_picking"
su - odoo -c "ln -sfn /home/odoo/source/OCA/account-closing/account_cutoff_base /home/odoo/addons/account_cutoff_base"
su - odoo -c "ln -sfn /home/odoo/source/OCA/account-closing/account_cutoff_prepaid /home/odoo/addons/account_cutoff_prepaid"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/account-closing/account_fiscal_year_closing /home/odoo/addons/account_fiscal_year_closing"
su - odoo -c "ln -sfn /home/odoo/source/OCA/account-closing/account_invoice_start_end_dates /home/odoo/addons/account_invoice_start_end_dates"
su - odoo -c "ln -sfn /home/odoo/source/OCA/account-closing/account_multicurrency_revaluation /home/odoo/addons/account_multicurrency_revaluation"


echo "Installazione Odoo 11.0 moduli bank-statement-reconcile"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/bank-statement-reconcile  /home/odoo/source/OCA/bank-statement-reconcile"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/bank-statement-reconcile/account_invoice_reference /home/odoo/addons/account_invoice_reference"
su - odoo -c "ln -sfn /home/odoo/source/OCA/bank-statement-reconcile/account_mass_reconcile /home/odoo/addons/account_mass_reconcile"
su - odoo -c "ln -sfn /home/odoo/source/OCA/bank-statement-reconcile/account_mass_reconcile_by_purchase_line /home/odoo/addons/account_mass_reconcile_by_purchase_line"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/bank-statement-reconcile/account_mass_reconcile_ref_deep_search /home/odoo/addons/account_mass_reconcile_ref_deep_search"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/bank-statement-reconcile/account_mass_reconcile_transaction_ref /home/odoo/addons/account_mass_reconcile_transaction_ref"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/bank-statement-reconcile/account_move_bankaccount_import /home/odoo/addons/account_move_bankaccount_import"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/bank-statement-reconcile/account_move_base_import /home/odoo/addons/account_move_base_import"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/bank-statement-reconcile/account_move_reconcile_helper /home/odoo/addons/account_move_reconcile_helper"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/bank-statement-reconcile/account_move_so_import /home/odoo/addons/account_move_so_import"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/bank-statement-reconcile/account_move_transactionid_import /home/odoo/addons/account_move_transactionid_import"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/bank-statement-reconcile/account_operation_rule /home/odoo/addons/account_operation_rule"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/bank-statement-reconcile/account_payment_transaction_id /home/odoo/addons/account_payment_transaction_id"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/bank-statement-reconcile/account_reconcile_payment_order /home/odoo/addons/account_reconcile_payment_order"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/bank-statement-reconcile/account_statement_cancel_line /home/odoo/addons/account_statement_cancel_line"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/bank-statement-reconcile/account_statement_completion_label /home/odoo/addons/account_statement_completion_label"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/bank-statement-reconcile/account_statement_completion_voucher /home/odoo/addons/account_statement_completion_voucher"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/bank-statement-reconcile/account_statement_ext /home/odoo/addons/account_statement_ext"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/bank-statement-reconcile/account_statement_ext_point_of_sale /home/odoo/addons/account_statement_ext_point_of_sale"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/bank-statement-reconcile/account_statement_ext_voucher /home/odoo/addons/account_statement_ext_voucher"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/bank-statement-reconcile/account_statement_no_invoice_import /home/odoo/addons/account_statement_no_invoice_import"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/bank-statement-reconcile/account_statement_one_move /home/odoo/addons/account_statement_one_move"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/bank-statement-reconcile/account_statement_operation_multicompany /home/odoo/addons/account_statement_operation_multicompany"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/bank-statement-reconcile/account_statement_regex_account_completion /home/odoo/addons/account_statement_regex_account_completion"
su - odoo -c "ln -sfn /home/odoo/source/OCA/bank-statement-reconcile/bank_statement_foreign_currency /home/odoo/addons/bank_statement_foreign_currency"
su - odoo -c "ln -sfn /home/odoo/source/OCA/bank-statement-reconcile/base_transaction_id /home/odoo/addons/base_transaction_id"


echo "Installazione Odoo 11.0 moduli bank-statement-import"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/bank-statement-import  /home/odoo/source/OCA/bank-statement-import"
su - odoo -c "ln -sfn /home/odoo/source/OCA/bank-statement-import/account_bank_statement_import_camt /home/odoo/addons/account_bank_statement_import_camt"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/bank-statement-import/account_bank_statement_import_camt_details /home/odoo/addons/account_bank_statement_import_camt_details"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/bank-statement-import/account_bank_statement_import_move_line /home/odoo/addons/account_bank_statement_import_move_line"
su - odoo -c "ln -sfn /home/odoo/source/OCA/bank-statement-import/account_bank_statement_import_mt940_base /home/odoo/addons/account_bank_statement_import_mt940_base"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/bank-statement-import/account_bank_statement_import_mt940_nl_ing /home/odoo/addons/account_bank_statement_import_mt940_nl_ing"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/bank-statement-import/account_bank_statement_import_mt940_nl_rabo /home/odoo/addons/account_bank_statement_import_mt940_nl_rabo"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/bank-statement-import/account_bank_statement_import_ofx /home/odoo/addons/account_bank_statement_import_ofx"
su - odoo -c "ln -sfn /home/odoo/source/OCA/bank-statement-import/account_bank_statement_import_qif /home/odoo/addons/account_bank_statement_import_qif"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/bank-statement-import/account_bank_statement_import_save_file /home/odoo/addons/account_bank_statement_import_save_file"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/bank-statement-import/base_bank_account_number_unique /home/odoo/addons/base_bank_account_number_unique"


echo "Installazione Odoo 11.0 moduli commission"
su - odoo -c "mkdir -p /home/odoo/source/OCA"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/commission /home/odoo/source/OCA/commission"
su - odoo -c "ln -sfn /home/odoo/source/OCA/commission/sale_commission /home/odoo/addons/sale_commission"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/commission/sale_commission_areamanager /home/odoo/addons/sale_commission_areamanager"
su - odoo -c "ln -sfn /home/odoo/source/OCA/commission/sale_commission_formula /home/odoo/addons/sale_commission_formula"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/commission/sale_commission_pricelist /home/odoo/addons/sale_commission_pricelist"


echo "Installazione Odoo 11.0 moduli margin-analysis"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/margin-analysis  /home/odoo/source/OCA/margin-analysis"
su - odoo -c "ln -sfn /home/odoo/source/OCA/margin-analysis/sale_margin_security /home/odoo/addons/sale_margin_security"


echo "Installazione Odoo 11.0 moduli sale-financial"
su - odoo -c "mkdir -p /home/odoo/source/OCA"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/sale-financial /home/odoo/source/OCA/sale-financial"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/sale-financial/sale_floor_price /home/odoo/addons/sale_floor_price"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/sale-financial/sale_line_watcher /home/odoo/addons/sale_line_watcher"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/sale-financial/sale_markup /home/odoo/addons/sale_markup"


echo "Installazione Odoo 11.0 moduli sale-reporting"
su - odoo -c "mkdir -p /home/odoo/source/OCA"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/sale-reporting /home/odoo/source/OCA/sale-reporting"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/sale-reporting/html_sale_product_note /home/odoo/addons/html_sale_product_note"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/sale-reporting/sale_comment_template /home/odoo/addons/sale_comment_template"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/sale-reporting/sale_note_flow /home/odoo/addons/sale_note_flow"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/sale-reporting/sale_order_proforma_webkit /home/odoo/addons/sale_order_proforma_webkit"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/sale-reporting/sale_order_webkit /home/odoo/addons/sale_order_webkit"


echo "Installazione Odoo 11.0 moduli contract"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/contract  /home/odoo/source/OCA/contract"
su - odoo -c "ln -sfn /home/odoo/source/OCA/contract/contract /home/odoo/addons/contract"
su - odoo -c "ln -sfn /home/odoo/source/OCA/contract/contract_payment_mode /home/odoo/addons/contract_payment_mode"
su - odoo -c "ln -sfn /home/odoo/source/OCA/contract/contract_sale_invoicing /home/odoo/addons/contract_sale_invoicing"
su - odoo -c "ln -sfn /home/odoo/source/OCA/contract/contract_variable_qty_timesheet /home/odoo/addons/contract_variable_qty_timesheet"
su - odoo -c "ln -sfn /home/odoo/source/OCA/contract/contract_variable_quantity /home/odoo/addons/contract_variable_quantity"


echo "Installazione Odoo 11.0 moduli rma"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/rma  /home/odoo/source/OCA/rma"


echo "Installazione Odoo 11.0 moduli crm"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/crm  /home/odoo/source/OCA/crm"
su - odoo -c "ln -sfn /home/odoo/source/OCA/crm/crm_claim /home/odoo/addons/crm_claim"
su - odoo -c "ln -sfn /home/odoo/source/OCA/crm/crm_deduplicate_acl /home/odoo/addons/crm_deduplicate_acl"
su - odoo -c "ln -sfn /home/odoo/source/OCA/crm/crm_deduplicate_filter /home/odoo/addons/crm_deduplicate_filter"


echo "Installazione Odoo 11.0 moduli project-service"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/project-service  /home/odoo/source/OCA/project-service"
su - odoo -c "ln -sfn /home/odoo/source/OCA/project-service/project_department /home/odoo/addons/project_department"
su - odoo -c "ln -sfn /home/odoo/source/OCA/project-service/project_description /home/odoo/addons/project_description"
su - odoo -c "ln -sfn /home/odoo/source/OCA/project-service/project_key /home/odoo/addons/project_key"
su - odoo -c "ln -sfn /home/odoo/source/OCA/project-service/project_stage_closed /home/odoo/addons/project_stage_closed"
su - odoo -c "ln -sfn /home/odoo/source/OCA/project-service/project_stage_state /home/odoo/addons/project_stage_state"
su - odoo -c "ln -sfn /home/odoo/source/OCA/project-service/project_task_add_very_high /home/odoo/addons/project_task_add_very_high"
su - odoo -c "ln -sfn /home/odoo/source/OCA/project-service/project_task_code /home/odoo/addons/project_task_code"
su - odoo -c "ln -sfn /home/odoo/source/OCA/project-service/project_task_default_stage /home/odoo/addons/project_task_default_stage"
su - odoo -c "ln -sfn /home/odoo/source/OCA/project-service/project_task_dependency /home/odoo/addons/project_task_dependency"
su - odoo -c "ln -sfn /home/odoo/source/OCA/project-service/project_task_material /home/odoo/addons/project_task_material"
su - odoo -c "ln -sfn /home/odoo/source/OCA/project-service/project_timeline /home/odoo/addons/project_timeline"


echo "Installazione Odoo 11.0 moduli account-analytic"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/account-analytic  /home/odoo/source/OCA/account-analytic"
su - odoo -c "ln -sfn /home/odoo/source/OCA/account-analytic/account_analytic_required /home/odoo/addons/account_analytic_required"
su - odoo -c "ln -sfn /home/odoo/source/OCA/account-analytic/analytic_base_department /home/odoo/addons/analytic_base_department"
su - odoo -c "ln -sfn /home/odoo/source/OCA/account-analytic/analytic_tag_dimension_purchase_warning /home/odoo/addons/analytic_tag_dimension_purchase_warning"
su - odoo -c "ln -sfn /home/odoo/source/OCA/account-analytic/analytic_tag_dimension_sale_warning /home/odoo/addons/analytic_tag_dimension_sale_warning"
su - odoo -c "ln -sfn /home/odoo/source/OCA/account-analytic/product_analytic /home/odoo/addons/product_analytic"


echo "Installazione Odoo 11.0 moduli account-invoicing"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/account-invoicing  /home/odoo/source/OCA/account-invoicing"
su - odoo -c "ln -sfn /home/odoo/source/OCA/account-invoicing/account_invoice_check_total /home/odoo/addons/account_invoice_check_total"
su - odoo -c "ln -sfn /home/odoo/source/OCA/account-invoicing/account_invoice_force_number /home/odoo/addons/account_invoice_force_number"
su - odoo -c "ln -sfn /home/odoo/source/OCA/account-invoicing/account_invoice_line_description /home/odoo/addons/account_invoice_line_description"
su - odoo -c "ln -sfn /home/odoo/source/OCA/account-invoicing/account_invoice_refund_link /home/odoo/addons/account_invoice_refund_link"
su - odoo -c "ln -sfn /home/odoo/source/OCA/account-invoicing/account_invoice_reimbursable /home/odoo/addons/account_invoice_reimbursable"
su - odoo -c "ln -sfn /home/odoo/source/OCA/account-invoicing/account_invoice_supplier_ref_reuse /home/odoo/addons/account_invoice_supplier_ref_reuse"
su - odoo -c "ln -sfn /home/odoo/source/OCA/account-invoicing/account_invoice_supplier_ref_unique /home/odoo/addons/account_invoice_supplier_ref_unique"
su - odoo -c "ln -sfn /home/odoo/source/OCA/account-invoicing/account_invoice_supplier_self_invoice /home/odoo/addons/account_invoice_supplier_self_invoice"
su - odoo -c "ln -sfn /home/odoo/source/OCA/account-invoicing/account_invoice_tax_required /home/odoo/addons/account_invoice_tax_required"
su - odoo -c "ln -sfn /home/odoo/source/OCA/account-invoicing/account_invoice_triple_discount /home/odoo/addons/account_invoice_triple_discount"
su - odoo -c "ln -sfn /home/odoo/source/OCA/account-invoicing/account_invoice_view_payment /home/odoo/addons/account_invoice_view_payment"
su - odoo -c "ln -sfn /home/odoo/source/OCA/account-invoicing/account_payment_term_extension /home/odoo/addons/account_payment_term_extension"
su - odoo -c "ln -sfn /home/odoo/source/OCA/account-invoicing/sale_timesheet_invoice_description /home/odoo/addons/sale_timesheet_invoice_description"


echo "Installazione Odoo 11.0 moduli account-invoice-reporting"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/account-invoice-reporting  /home/odoo/source/OCA/account-invoice-reporting"
su - odoo -c "ln -sfn /home/odoo/source/OCA/account-invoice-reporting/account_invoice_line_report /home/odoo/addons/account_invoice_line_report"
su - odoo -c "ln -sfn /home/odoo/source/OCA/account-invoice-reporting/account_invoice_report_grouped_by_picking /home/odoo/addons/account_invoice_report_grouped_by_picking"


echo "Installazione Odoo 11.0 moduli account-budgeting"
su - odoo -c "mkdir -p /home/odoo/source/OCA"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/account-budgeting /home/odoo/source/OCA/account-budgeting"


echo "Installazione Odoo 11.0 moduli account-consolidation"
su - odoo -c "mkdir -p /home/odoo/source/OCA"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/account-consolidation /home/odoo/source/OCA/account-consolidation"
su - odoo -c "ln -sfn /home/odoo/source/OCA/account-consolidation/account_consolidation /home/odoo/addons/account_consolidation"


echo "Installazione Odoo 11.0 moduli event"
su - odoo -c "mkdir -p /home/odoo/source/OCA"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/event /home/odoo/source/OCA/event"
su - odoo -c "ln -sfn /home/odoo/source/OCA/event/partner_event /home/odoo/addons/partner_event"
su - odoo -c "ln -sfn /home/odoo/source/OCA/event/website_event_excerpt_img /home/odoo/addons/website_event_excerpt_img"
su - odoo -c "ln -sfn /home/odoo/source/OCA/event/website_event_filter_selector /home/odoo/addons/website_event_filter_selector"


echo "Installazione Odoo 11.0 moduli survey"
su - odoo -c "mkdir -p /home/odoo/source/OCA"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/survey /home/odoo/source/OCA/survey"


echo "Installazione Odoo 11.0 moduli social"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/social  /home/odoo/source/OCA/social"
su - odoo -c "ln -sfn /home/odoo/source/OCA/social/base_search_mail_content /home/odoo/addons/base_search_mail_content"
su - odoo -c "ln -sfn /home/odoo/source/OCA/social/email_template_qweb /home/odoo/addons/email_template_qweb"
su - odoo -c "ln -sfn /home/odoo/source/OCA/social/mail_attach_existing_attachment /home/odoo/addons/mail_attach_existing_attachment"
su - odoo -c "ln -sfn /home/odoo/source/OCA/social/mail_debrand /home/odoo/addons/mail_debrand"
su - odoo -c "ln -sfn /home/odoo/source/OCA/social/mail_digest /home/odoo/addons/mail_digest"
su - odoo -c "ln -sfn /home/odoo/source/OCA/social/mail_restrict_follower_selection /home/odoo/addons/mail_restrict_follower_selection"
su - odoo -c "ln -sfn /home/odoo/source/OCA/social/mail_tracking /home/odoo/addons/mail_tracking"
su - odoo -c "ln -sfn /home/odoo/source/OCA/social/mail_tracking_mailgun /home/odoo/addons/mail_tracking_mailgun"
su - odoo -c "ln -sfn /home/odoo/source/OCA/social/mass_mailing_custom_unsubscribe /home/odoo/addons/mass_mailing_custom_unsubscribe"
su - odoo -c "ln -sfn /home/odoo/source/OCA/social/mass_mailing_partner /home/odoo/addons/mass_mailing_partner"
su - odoo -c "ln -sfn /home/odoo/source/OCA/social/mass_mailing_unique /home/odoo/addons/mass_mailing_unique"


echo "Installazione Odoo 11.0 moduli e-commerce"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/e-commerce  /home/odoo/source/OCA/e-commerce"
su - odoo -c "ln -sfn /home/odoo/source/OCA/e-commerce/website_sale_default_country /home/odoo/addons/website_sale_default_country"
su - odoo -c "ln -sfn /home/odoo/source/OCA/e-commerce/website_sale_hide_price /home/odoo/addons/website_sale_hide_price"
su - odoo -c "ln -sfn /home/odoo/source/OCA/e-commerce/website_sale_product_brand /home/odoo/addons/website_sale_product_brand"
su - odoo -c "ln -sfn /home/odoo/source/OCA/e-commerce/website_sale_require_legal /home/odoo/addons/website_sale_require_legal"
su - odoo -c "ln -sfn /home/odoo/source/OCA/e-commerce/website_sale_require_login /home/odoo/addons/website_sale_require_login"
su - odoo -c "ln -sfn /home/odoo/source/OCA/e-commerce/website_sale_suggest_create_account /home/odoo/addons/website_sale_suggest_create_account"
su - odoo -c "ln -sfn /home/odoo/source/OCA/e-commerce/website_sale_vat_required /home/odoo/addons/website_sale_vat_required"


echo "Installazione Odoo 11.0 moduli product-variant"
su - odoo -c "mkdir -p /home/odoo/source/OCA"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/product-variant /home/odoo/source/OCA/product-variant"


echo "Installazione Odoo 11.0 moduli carrier-delivery"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/carrier-delivery  /home/odoo/source/OCA/carrier-delivery"
su - odoo -c "ln -sfn /home/odoo/source/OCA/carrier-delivery/base_delivery_carrier_label /home/odoo/addons/base_delivery_carrier_label"


echo "Installazione Odoo 11.0 moduli stock-logistics-reporting"
su - odoo -c "mkdir -p /home/odoo/source/OCA"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/stock-logistics-reporting /home/odoo/source/OCA/stock-logistics-reporting"


echo "Installazione Odoo 11.0 moduli hr-timesheet"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/hr-timesheet  /home/odoo/source/OCA/hr-timesheet"
su - odoo -c "ln -sfn /home/odoo/source/OCA/hr-timesheet/crm_timesheet /home/odoo/addons/crm_timesheet"
su - odoo -c "ln -sfn /home/odoo/source/OCA/hr-timesheet/hr_timesheet_sheet /home/odoo/addons/hr_timesheet_sheet"
su - odoo -c "ln -sfn /home/odoo/source/OCA/hr-timesheet/hr_timesheet_task_required /home/odoo/addons/hr_timesheet_task_required"
su - odoo -c "ln -sfn /home/odoo/source/OCA/hr-timesheet/project_task_stage_allow_timesheet /home/odoo/addons/project_task_stage_allow_timesheet"


echo "Installazione Odoo 11.0 moduli hr"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/hr  /home/odoo/source/OCA/hr"
su - odoo -c "ln -sfn /home/odoo/source/OCA/hr/hr_employee_birth_name /home/odoo/addons/hr_employee_birth_name"
su - odoo -c "ln -sfn /home/odoo/source/OCA/hr/hr_employee_firstname /home/odoo/addons/hr_employee_firstname"
su - odoo -c "ln -sfn /home/odoo/source/OCA/hr/hr_experience /home/odoo/addons/hr_experience"
su - odoo -c "ln -sfn /home/odoo/source/OCA/hr/hr_holidays_imposed_days /home/odoo/addons/hr_holidays_imposed_days"
su - odoo -c "ln -sfn /home/odoo/source/OCA/hr/hr_holidays_leave_auto_approve /home/odoo/addons/hr_holidays_leave_auto_approve"
su - odoo -c "ln -sfn /home/odoo/source/OCA/hr/hr_holidays_notify_employee_manager /home/odoo/addons/hr_holidays_notify_employee_manager"
su - odoo -c "ln -sfn /home/odoo/source/OCA/hr/hr_holidays_settings /home/odoo/addons/hr_holidays_settings"
su - odoo -c "ln -sfn /home/odoo/source/OCA/hr/hr_payroll_cancel /home/odoo/addons/hr_payroll_cancel"
su - odoo -c "ln -sfn /home/odoo/source/OCA/hr/hr_skill /home/odoo/addons/hr_skill"


echo "Installazione Odoo 11.0 moduli management-system"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/management-system  /home/odoo/source/OCA/management-system"
su - odoo -c "ln -sfn /home/odoo/source/OCA/management-system/mgmtsystem /home/odoo/addons/mgmtsystem"


echo "Installazione Odoo 11.0 moduli website"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/website  /home/odoo/source/OCA/website"
su - odoo -c "ln -sfn /home/odoo/source/OCA/website/website_addthis /home/odoo/addons/website_addthis"
su - odoo -c "ln -sfn /home/odoo/source/OCA/website/website_adv_image_optimization /home/odoo/addons/website_adv_image_optimization"
su - odoo -c "ln -sfn /home/odoo/source/OCA/website/website_analytics_piwik /home/odoo/addons/website_analytics_piwik"
su - odoo -c "ln -sfn /home/odoo/source/OCA/website/website_anchor_smooth_scroll /home/odoo/addons/website_anchor_smooth_scroll"
su - odoo -c "ln -sfn /home/odoo/source/OCA/website/website_canonical_url /home/odoo/addons/website_canonical_url"
su - odoo -c "ln -sfn /home/odoo/source/OCA/website/website_cookie_notice /home/odoo/addons/website_cookie_notice"
su - odoo -c "ln -sfn /home/odoo/source/OCA/website/website_crm_privacy_policy /home/odoo/addons/website_crm_privacy_policy"
su - odoo -c "ln -sfn /home/odoo/source/OCA/website/website_crm_recaptcha /home/odoo/addons/website_crm_recaptcha"
su - odoo -c "ln -sfn /home/odoo/source/OCA/website/website_form_builder /home/odoo/addons/website_form_builder"
su - odoo -c "ln -sfn /home/odoo/source/OCA/website/website_form_metadata /home/odoo/addons/website_form_metadata"
su - odoo -c "ln -sfn /home/odoo/source/OCA/website/website_form_recaptcha /home/odoo/addons/website_form_recaptcha"
su - odoo -c "ln -sfn /home/odoo/source/OCA/website/website_img_dimension /home/odoo/addons/website_img_dimension"
su - odoo -c "ln -sfn /home/odoo/source/OCA/website/website_js_below_the_fold /home/odoo/addons/website_js_below_the_fold"
su - odoo -c "ln -sfn /home/odoo/source/OCA/website/website_legal_page /home/odoo/addons/website_legal_page"
su - odoo -c "ln -sfn /home/odoo/source/OCA/website/website_logo /home/odoo/addons/website_logo"
su - odoo -c "ln -sfn /home/odoo/source/OCA/website/website_media_size /home/odoo/addons/website_media_size"
su - odoo -c "ln -sfn /home/odoo/source/OCA/website/website_menu_by_user_status /home/odoo/addons/website_menu_by_user_status"
su - odoo -c "ln -sfn /home/odoo/source/OCA/website/website_multi_theme /home/odoo/addons/website_multi_theme"
su - odoo -c "ln -sfn /home/odoo/source/OCA/website/website_no_crawler /home/odoo/addons/website_no_crawler"
su - odoo -c "ln -sfn /home/odoo/source/OCA/website/website_odoo_debranding /home/odoo/addons/website_odoo_debranding"
su - odoo -c "ln -sfn /home/odoo/source/OCA/website/website_snippet_anchor /home/odoo/addons/website_snippet_anchor"
su - odoo -c "ln -sfn /home/odoo/source/OCA/website/website_snippet_preset /home/odoo/addons/website_snippet_preset"


echo "Installazione Odoo 11.0 moduli report-print-send"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/report-print-send  /home/odoo/source/OCA/report-print-send"
pip install -r /home/odoo/source/OCA/report-print-send/requirements.txt 
su - odoo -c "ln -sfn /home/odoo/source/OCA/report-print-send/base_report_to_printer /home/odoo/addons/base_report_to_printer"
su - odoo -c "ln -sfn /home/odoo/source/OCA/report-print-send/printer_zpl2 /home/odoo/addons/printer_zpl2"


echo "Installazione Odoo 11.0 moduli purchase-reporting"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/purchase-reporting  /home/odoo/source/OCA/purchase-reporting"


echo "Installazione Odoo 11.0 moduli purchase-workflow"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/purchase-workflow  /home/odoo/source/OCA/purchase-workflow"
su - odoo -c "ln -sfn /home/odoo/source/OCA/purchase-workflow/purchase_discount /home/odoo/addons/purchase_discount"
su - odoo -c "ln -sfn /home/odoo/source/OCA/purchase-workflow/purchase_exception /home/odoo/addons/purchase_exception"
su - odoo -c "ln -sfn /home/odoo/source/OCA/purchase-workflow/purchase_line_procurement_group /home/odoo/addons/purchase_line_procurement_group"
su - odoo -c "ln -sfn /home/odoo/source/OCA/purchase-workflow/purchase_minimum_amount /home/odoo/addons/purchase_minimum_amount"
su - odoo -c "ln -sfn /home/odoo/source/OCA/purchase-workflow/purchase_order_approval_block /home/odoo/addons/purchase_order_approval_block"
su - odoo -c "ln -sfn /home/odoo/source/OCA/purchase-workflow/stock_landed_cost_company_percentage /home/odoo/addons/stock_landed_cost_company_percentage"
su - odoo -c "ln -sfn /home/odoo/source/OCA/purchase-workflow/subcontracted_service /home/odoo/addons/subcontracted_service"


echo "Installazione Odoo 11.0 moduli manufacture-reporting"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/manufacture-reporting  /home/odoo/source/OCA/manufacture-reporting"
su - odoo -c "ln -sfn /home/odoo/source/OCA/manufacture-reporting/mrp_bom_current_stock /home/odoo/addons/mrp_bom_current_stock"
su - odoo -c "ln -sfn /home/odoo/source/OCA/manufacture-reporting/mrp_bom_matrix_report /home/odoo/addons/mrp_bom_matrix_report"
su - odoo -c "ln -sfn /home/odoo/source/OCA/manufacture-reporting/mrp_bom_structure_xlsx /home/odoo/addons/mrp_bom_structure_xlsx"
su - odoo -c "ln -sfn /home/odoo/source/OCA/manufacture-reporting/mrp_bom_structure_xlsx_level_1 /home/odoo/addons/mrp_bom_structure_xlsx_level_1"
su - odoo -c "ln -sfn /home/odoo/source/OCA/manufacture-reporting/mrp_order_report_product_barcode /home/odoo/addons/mrp_order_report_product_barcode"
su - odoo -c "ln -sfn /home/odoo/source/OCA/manufacture-reporting/mrp_order_report_stock_location /home/odoo/addons/mrp_order_report_stock_location"


echo "Installazione Odoo 11.0 moduli knowledge"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/knowledge  /home/odoo/source/OCA/knowledge"
su - odoo -c "ln -sfn /home/odoo/source/OCA/knowledge/document_page /home/odoo/addons/document_page"
su - odoo -c "ln -sfn /home/odoo/source/OCA/knowledge/document_page_approval /home/odoo/addons/document_page_approval"
su - odoo -c "ln -sfn /home/odoo/source/OCA/knowledge/document_url /home/odoo/addons/document_url"
su - odoo -c "ln -sfn /home/odoo/source/OCA/knowledge/knowledge /home/odoo/addons/knowledge"


echo "Installazione Odoo 11.0 moduli project-reporting"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/project-reporting  /home/odoo/source/OCA/project-reporting"


echo "Installazione Odoo 11.0 moduli project"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/project  /home/odoo/source/OCA/project"
su - odoo -c "ln -sfn /home/odoo/source/OCA/project/project_department /home/odoo/addons/project_department"
su - odoo -c "ln -sfn /home/odoo/source/OCA/project/project_description /home/odoo/addons/project_description"
su - odoo -c "ln -sfn /home/odoo/source/OCA/project/project_key /home/odoo/addons/project_key"
su - odoo -c "ln -sfn /home/odoo/source/OCA/project/project_stage_closed /home/odoo/addons/project_stage_closed"
su - odoo -c "ln -sfn /home/odoo/source/OCA/project/project_stage_state /home/odoo/addons/project_stage_state"
su - odoo -c "ln -sfn /home/odoo/source/OCA/project/project_task_add_very_high /home/odoo/addons/project_task_add_very_high"
su - odoo -c "ln -sfn /home/odoo/source/OCA/project/project_task_code /home/odoo/addons/project_task_code"
su - odoo -c "ln -sfn /home/odoo/source/OCA/project/project_task_default_stage /home/odoo/addons/project_task_default_stage"
su - odoo -c "ln -sfn /home/odoo/source/OCA/project/project_task_dependency /home/odoo/addons/project_task_dependency"
su - odoo -c "ln -sfn /home/odoo/source/OCA/project/project_task_material /home/odoo/addons/project_task_material"
su - odoo -c "ln -sfn /home/odoo/source/OCA/project/project_timeline /home/odoo/addons/project_timeline"




echo "Installazione Odoo 11.0 moduli ingadhoc partner"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/ingadhoc/partner  /home/odoo/source/ingadhoc/partner"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/partner/partner_internal_code /home/odoo/addons/partner_internal_code"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/partner/partner_state /home/odoo/addons/partner_state"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/partner/partner_tree_first /home/odoo/addons/partner_tree_first"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/partner/partner_user /home/odoo/addons/partner_user"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/partner/partner_views_fields /home/odoo/addons/partner_views_fields"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/partner/portal_partner_fix /home/odoo/addons/portal_partner_fix"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/partner/portal_ux /home/odoo/addons/portal_ux"



echo "Installazione Odoo 10.0 moduli ingadhoc sale"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/ingadhoc/sale  /home/odoo/source/ingadhoc/sale"
pip3 install -r /home/odoo/source/ingadhoc/sale/requirements.txt
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/sale/event_sale_ux /home/odoo/addons/event_sale_ux"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/sale/portal_sale_distributor /home/odoo/addons/portal_sale_distributor"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/sale/portal_sale_distributor_wesbite_quote /home/odoo/addons/portal_sale_distributor_wesbite_quote"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/sale/portal_sale_order_type /home/odoo/addons/portal_sale_order_type"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/sale/sale_delivery_ux /home/odoo/addons/sale_delivery_ux"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/sale/sale_dummy_confirmation /home/odoo/addons/sale_dummy_confirmation"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/sale/sale_exception_credit_limit /home/odoo/addons/sale_exception_credit_limit"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/sale/sale_exception_partner_state /home/odoo/addons/sale_exception_partner_state"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/sale/sale_exception_price_security /home/odoo/addons/sale_exception_price_security"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/sale/sale_exception_print /home/odoo/addons/sale_exception_print"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/sale/sale_exceptions_ignore_approve /home/odoo/addons/sale_exceptions_ignore_approve"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/sale/sale_global_three_discounts /home/odoo/addons/sale_global_three_discounts"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/sale/sale_invoice_operation_line /home/odoo/addons/sale_invoice_operation_line"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/sale/sale_margin_ux /home/odoo/addons/sale_margin_ux"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/sale/sale_order_line_number /home/odoo/addons/sale_order_line_number"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/sale/sale_order_type_automation /home/odoo/addons/sale_order_type_automation"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/sale/sale_order_type_invoice_policy /home/odoo/addons/sale_order_type_invoice_policy"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/sale/sale_order_type_sequence /home/odoo/addons/sale_order_type_sequence"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/sale/sale_order_type_user_default /home/odoo/addons/sale_order_type_user_default"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/sale/sale_order_validity /home/odoo/addons/sale_order_validity"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/sale/sale_quotation_products /home/odoo/addons/sale_quotation_products"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/sale/sale_require_contract /home/odoo/addons/sale_require_contract"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/sale/sale_require_purchase_order_number /home/odoo/addons/sale_require_purchase_order_number"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/sale/sale_require_ref /home/odoo/addons/sale_require_ref"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/sale/sale_restrict_partners /home/odoo/addons/sale_restrict_partners"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/sale/sale_stock_availability /home/odoo/addons/sale_stock_availability"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/sale/sale_stock_ux /home/odoo/addons/sale_stock_ux"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/sale/sale_three_discounts /home/odoo/addons/sale_three_discounts"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/sale/sale_timesheet_ux /home/odoo/addons/sale_timesheet_ux"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/sale/sale_ux /home/odoo/addons/sale_ux"




echo "Installazione Odoo 11.0 moduli account-invoicing"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/ingadhoc/account-invoicing  /home/odoo/source/ingadhoc/account-invoicing"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/account-invoicing/account_clean_cancelled_invoice_number /home/odoo/addons/account_clean_cancelled_invoice_number"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/account-invoicing/account_invoice_commission /home/odoo/addons/account_invoice_commission"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/account-invoicing/account_invoice_control /home/odoo/addons/account_invoice_control"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/account-invoicing/account_invoice_journal_group /home/odoo/addons/account_invoice_journal_group"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/account-invoicing/account_invoice_line_number /home/odoo/addons/account_invoice_line_number"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/account-invoicing/account_invoice_move_currency /home/odoo/addons/account_invoice_move_currency"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/account-invoicing/account_partner_restrict_invoicing /home/odoo/addons/account_partner_restrict_invoicing"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/account-invoicing/account_user_default_journals /home/odoo/addons/account_user_default_journals"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/account-invoicing/website_sale_account_invoice_commission /home/odoo/addons/website_sale_account_invoice_commission"

echo "Installazione Odoo 10.0 moduli ingadhoc product"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/ingadhoc/product  /home/odoo/source/ingadhoc/product"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/product/price_security /home/odoo/addons/price_security"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/product/price_security_planned_price /home/odoo/addons/price_security_planned_price"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/product/product_catalog_aeroo_report /home/odoo/addons/product_catalog_aeroo_report"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/product/product_catalog_aeroo_report_public_categ /home/odoo/addons/product_catalog_aeroo_report_public_categ"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/product/product_currency /home/odoo/addons/product_currency"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/product/product_internal_code /home/odoo/addons/product_internal_code"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/product/product_management_group /home/odoo/addons/product_management_group"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/product/product_pack /home/odoo/addons/product_pack"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/product/product_planned_price /home/odoo/addons/product_planned_price"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/product/product_pricelist /home/odoo/addons/product_pricelist"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/product/product_price_taxes_included /home/odoo/addons/product_price_taxes_included"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/product/product_purchase_uom /home/odoo/addons/product_purchase_uom"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/product/product_reference_required /home/odoo/addons/product_reference_required"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/product/product_replenishment_cost /home/odoo/addons/product_replenishment_cost"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/product/product_salesman_group /home/odoo/addons/product_salesman_group"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/product/product_sale_uom /home/odoo/addons/product_sale_uom"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/product/product_stock_by_location /home/odoo/addons/product_stock_by_location"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/product/product_template_tree_first /home/odoo/addons/product_template_tree_first"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/product/product_unique /home/odoo/addons/product_unique"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/product/product_uom_prices_currency /home/odoo/addons/product_uom_prices_currency"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/product/product_ux /home/odoo/addons/product_ux"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/product/product_variant_o2o /home/odoo/addons/product_variant_o2o"



echo "Installazione Odoo 11.0 moduli misc-addons"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/it-projects-llc/misc-addons  /home/odoo/source/it-projects-llc/misc-addons"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/attachment_large_object /home/odoo/addons/attachment_large_object"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/auth_signup_confirmation /home/odoo/addons/auth_signup_confirmation"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/auth_signup_confirmation_crm /home/odoo/addons/auth_signup_confirmation_crm"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/autostaging_base /home/odoo/addons/autostaging_base"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/autostaging_project_task /home/odoo/addons/autostaging_project_task"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/barcode_widget /home/odoo/addons/barcode_widget"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/base_attendance /home/odoo/addons/base_attendance"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/base_details /home/odoo/addons/base_details"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/base_groupby_extra /home/odoo/addons/base_groupby_extra"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/base_import_map /home/odoo/addons/base_import_map"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/base_session_store_psql /home/odoo/addons/base_session_store_psql"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/booking_calendar /home/odoo/addons/booking_calendar"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/booking_calendar_analytic /home/odoo/addons/booking_calendar_analytic"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/crm_expected_revenue /home/odoo/addons/crm_expected_revenue"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/crm_next_action /home/odoo/addons/crm_next_action"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/currency_rate_update /home/odoo/addons/currency_rate_update"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/customer_marketing /home/odoo/addons/customer_marketing"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/custom_menu_bar /home/odoo/addons/custom_menu_bar"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/delivery_sequence /home/odoo/addons/delivery_sequence"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/delivery_special /home/odoo/addons/delivery_special"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/fleet_odometer_oil /home/odoo/addons/fleet_odometer_oil"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/fleet_odometer_track_changes /home/odoo/addons/fleet_odometer_track_changes"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/gamification_extra /home/odoo/addons/gamification_extra"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/hr_public_holidays_ics_import /home/odoo/addons/hr_public_holidays_ics_import"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/hr_rule_input_compute /home/odoo/addons/hr_rule_input_compute"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/import_csv_fix_field_limit /home/odoo/addons/import_csv_fix_field_limit"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/invoice_sale_order_line_group /home/odoo/addons/invoice_sale_order_line_group"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/ir_actions_todo_repeat /home/odoo/addons/ir_actions_todo_repeat"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/ir_attachment_force_storage /home/odoo/addons/ir_attachment_force_storage"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/ir_attachment_s3 /home/odoo/addons/ir_attachment_s3"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/ir_attachment_url /home/odoo/addons/ir_attachment_url"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/ir_config_parameter_multi_company /home/odoo/addons/ir_config_parameter_multi_company"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/LICENSE /home/odoo/addons/LICENSE"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/oca_dependencies.txt /home/odoo/addons/oca_dependencies.txt"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/pitch_booking /home/odoo/addons/pitch_booking"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/product_category_taxes /home/odoo/addons/product_category_taxes"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/product_details /home/odoo/addons/product_details"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/production_lot_details /home/odoo/addons/production_lot_details"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/product_tags /home/odoo/addons/product_tags"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/project_description /home/odoo/addons/project_description"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/project_gantt8 /home/odoo/addons/project_gantt8"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/project_kanban_customer /home/odoo/addons/project_kanban_customer"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/project_tags /home/odoo/addons/project_tags"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/project_task_auto_staging /home/odoo/addons/project_task_auto_staging"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/project_task_order_kanban_state /home/odoo/addons/project_task_order_kanban_state"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/project_task_search_custom /home/odoo/addons/project_task_search_custom"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/project_task_subtask /home/odoo/addons/project_task_subtask"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/project_timelog /home/odoo/addons/project_timelog"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/README.md /home/odoo/addons/README.md"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/reminder_base /home/odoo/addons/reminder_base"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/reminder_crm_next_action /home/odoo/addons/reminder_crm_next_action"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/reminder_crm_next_action_time /home/odoo/addons/reminder_crm_next_action_time"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/reminder_hr_recruitment /home/odoo/addons/reminder_hr_recruitment"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/reminder_issue_deadline /home/odoo/addons/reminder_issue_deadline"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/reminder_task_deadline /home/odoo/addons/reminder_task_deadline"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/requirements.txt /home/odoo/addons/requirements.txt"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/res_partner_country_code /home/odoo/addons/res_partner_country_code"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/res_partner_phone /home/odoo/addons/res_partner_phone"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/res_partner_skype /home/odoo/addons/res_partner_skype"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/res_users_signature /home/odoo/addons/res_users_signature"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/res_users_signature_hr /home/odoo/addons/res_users_signature_hr"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/sale_order_hide_tax /home/odoo/addons/sale_order_hide_tax"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/sms_sg /home/odoo/addons/sms_sg"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/thecage_data /home/odoo/addons/thecage_data"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/theme_kit /home/odoo/addons/theme_kit"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/web_calendar_quick_navigation /home/odoo/addons/web_calendar_quick_navigation"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/web_calendar_repeat_form /home/odoo/addons/web_calendar_repeat_form"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/web_debranding /home/odoo/addons/web_debranding"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/web_debranding_support /home/odoo/addons/web_debranding_support"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/web_gantt8 /home/odoo/addons/web_gantt8"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/web_iframe /home/odoo/addons/web_iframe"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/web_iframe_pages /home/odoo/addons/web_iframe_pages"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/web_polymorphic_field /home/odoo/addons/web_polymorphic_field"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/web_preview /home/odoo/addons/web_preview"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/web_sessions_management /home/odoo/addons/web_sessions_management"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/web_tour_extra /home/odoo/addons/web_tour_extra"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/misc-addons/web_website /home/odoo/addons/web_website"


echo "Installazione Odoo 11.0 moduli access-addons"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/it-projects-llc/access-addons  /home/odoo/source/it-projects-llc/access-addons"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/access-addons/access_apps /home/odoo/addons/access_apps"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/access-addons/access_apps_website /home/odoo/addons/access_apps_website"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/access-addons/access_base /home/odoo/addons/access_base"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/access-addons/access_limit_records_number /home/odoo/addons/access_limit_records_number"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/access-addons/access_menu_extra_groups /home/odoo/addons/access_menu_extra_groups"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/access-addons/access_restricted /home/odoo/addons/access_restricted"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/access-addons/access_settings_menu /home/odoo/addons/access_settings_menu"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/access-addons/apps /home/odoo/addons/apps"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/access-addons/group_menu_no_access /home/odoo/addons/group_menu_no_access"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/access-addons/hidden_admin /home/odoo/addons/hidden_admin"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/access-addons/ir_rule_protected /home/odoo/addons/ir_rule_protected"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/access-addons/ir_rule_website /home/odoo/addons/ir_rule_website"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/access-addons/res_users_clear_access_rights /home/odoo/addons/res_users_clear_access_rights"


echo "Installazione Odoo 11.0 moduli pos-addons"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/it-projects-llc/pos-addons  /home/odoo/source/it-projects-llc/pos-addons"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/pos-addons/hw_printer_network /home/odoo/addons/hw_printer_network"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/pos-addons/hw_twitter_printing /home/odoo/addons/hw_twitter_printing"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/pos-addons/pos_cashier_select /home/odoo/addons/pos_cashier_select"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/pos-addons/pos_category_multi /home/odoo/addons/pos_category_multi"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/pos-addons/pos_debranding /home/odoo/addons/pos_debranding"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/pos-addons/pos_debt_notebook /home/odoo/addons/pos_debt_notebook"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/pos-addons/pos_debt_notebook_sync /home/odoo/addons/pos_debt_notebook_sync"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/pos-addons/pos_details_custom /home/odoo/addons/pos_details_custom"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/pos-addons/pos_disable_payment /home/odoo/addons/pos_disable_payment"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/pos-addons/pos_disable_restore_orders /home/odoo/addons/pos_disable_restore_orders"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/pos-addons/pos_discount_base /home/odoo/addons/pos_discount_base"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/pos-addons/pos_discount_total /home/odoo/addons/pos_discount_total"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/pos-addons/pos_fiscal_current /home/odoo/addons/pos_fiscal_current"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/pos-addons/pos_fiscal_floor /home/odoo/addons/pos_fiscal_floor"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/pos-addons/pos_invoice_pay /home/odoo/addons/pos_invoice_pay"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/pos-addons/pos_keyboard /home/odoo/addons/pos_keyboard"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/pos-addons/pos_longpolling /home/odoo/addons/pos_longpolling"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/pos-addons/pos_mobile /home/odoo/addons/pos_mobile"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/pos-addons/pos_mobile_restaurant /home/odoo/addons/pos_mobile_restaurant"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/pos-addons/pos_multi_session /home/odoo/addons/pos_multi_session"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/pos-addons/pos_multi_session_restaurant /home/odoo/addons/pos_multi_session_restaurant"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/pos-addons/pos_multi_session_sync /home/odoo/addons/pos_multi_session_sync"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/pos-addons/pos_order_cancel /home/odoo/addons/pos_order_cancel"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/pos-addons/pos_order_cancel_restaurant /home/odoo/addons/pos_order_cancel_restaurant"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/pos-addons/pos_orderline_absolute_discount /home/odoo/addons/pos_orderline_absolute_discount"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/pos-addons/pos_order_note /home/odoo/addons/pos_order_note"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/pos-addons/pos_order_printer_product /home/odoo/addons/pos_order_printer_product"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/pos-addons/pos_pin /home/odoo/addons/pos_pin"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/pos-addons/pos_printer_network /home/odoo/addons/pos_printer_network"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/pos-addons/pos_print_method /home/odoo/addons/pos_print_method"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/pos-addons/pos_product_available /home/odoo/addons/pos_product_available"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/pos-addons/pos_product_available_negative /home/odoo/addons/pos_product_available_negative"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/pos-addons/pos_product_category_discount /home/odoo/addons/pos_product_category_discount"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/pos-addons/pos_product_lot /home/odoo/addons/pos_product_lot"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/pos-addons/pos_restaurant_base /home/odoo/addons/pos_restaurant_base"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/pos-addons/pos_sale_order /home/odoo/addons/pos_sale_order"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/pos-addons/pos_scan_ref /home/odoo/addons/pos_scan_ref"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/pos-addons/product_lot /home/odoo/addons/product_lot"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/pos-addons/product_variant_multi /home/odoo/addons/product_variant_multi"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/pos-addons/to_pos_shared_floor /home/odoo/addons/to_pos_shared_floor"


echo "Installazione Odoo 11.0 moduli website-addons"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/it-projects-llc/website-addons  /home/odoo/source/it-projects-llc/website-addons"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/website-addons/chess /home/odoo/addons/chess"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/website-addons/LICENSE /home/odoo/addons/LICENSE"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/website-addons/oca_dependencies.txt /home/odoo/addons/oca_dependencies.txt"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/website-addons/portal_event_tickets /home/odoo/addons/portal_event_tickets"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/website-addons/README.md /home/odoo/addons/README.md"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/website-addons/requirements.txt /home/odoo/addons/requirements.txt"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/website-addons/stock_picking_barcode /home/odoo/addons/stock_picking_barcode"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/website-addons/web_login_background /home/odoo/addons/web_login_background"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/website-addons/website_booking_calendar /home/odoo/addons/website_booking_calendar"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/website-addons/website_debranding /home/odoo/addons/website_debranding"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/website-addons/website_event_attendee_fields /home/odoo/addons/website_event_attendee_fields"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/website-addons/website_event_attendee_fields_custom /home/odoo/addons/website_event_attendee_fields_custom"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/website-addons/website_event_attendee_signup /home/odoo/addons/website_event_attendee_signup"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/website-addons/website_event_require_login /home/odoo/addons/website_event_require_login"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/website-addons/website_files /home/odoo/addons/website_files"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/website-addons/website_forum_faq_edit /home/odoo/addons/website_forum_faq_edit"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/website-addons/website_login_background /home/odoo/addons/website_login_background"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/website-addons/website_login_hide /home/odoo/addons/website_login_hide"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/website-addons/website_multi_company /home/odoo/addons/website_multi_company"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/website-addons/website_multi_company_blog /home/odoo/addons/website_multi_company_blog"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/website-addons/website_multi_company_demo /home/odoo/addons/website_multi_company_demo"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/website-addons/website_multi_company_portal /home/odoo/addons/website_multi_company_portal"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/website-addons/website_multi_company_sale /home/odoo/addons/website_multi_company_sale"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/website-addons/website_multi_company_sale_delivery /home/odoo/addons/website_multi_company_sale_delivery"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/website-addons/website_proposal /home/odoo/addons/website_proposal"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/website-addons/website_redirect /home/odoo/addons/website_redirect"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/website-addons/website_sale_add_to_cart /home/odoo/addons/website_sale_add_to_cart"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/website-addons/website_sale_add_to_cart_disable /home/odoo/addons/website_sale_add_to_cart_disable"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/website-addons/website_sale_add_to_cart_stock_status /home/odoo/addons/website_sale_add_to_cart_stock_status"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/website-addons/website_sale_available /home/odoo/addons/website_sale_available"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/website-addons/website_sale_birthdate /home/odoo/addons/website_sale_birthdate"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/website-addons/website_sale_buy_now /home/odoo/addons/website_sale_buy_now"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/website-addons/website_sale_cache /home/odoo/addons/website_sale_cache"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/website-addons/website_sale_checkout_store /home/odoo/addons/website_sale_checkout_store"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/website-addons/website_sale_clear_cart /home/odoo/addons/website_sale_clear_cart"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/website-addons/website_sale_order /home/odoo/addons/website_sale_order"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/website-addons/website_sale_product_tags /home/odoo/addons/website_sale_product_tags"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/website-addons/website_sale_quantity_hide /home/odoo/addons/website_sale_quantity_hide"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/website-addons/website_sale_refund /home/odoo/addons/website_sale_refund"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/website-addons/website_sale_search_clear /home/odoo/addons/website_sale_search_clear"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/website-addons/website_sale_search_custom /home/odoo/addons/website_sale_search_custom"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/website-addons/website_sale_search_tags /home/odoo/addons/website_sale_search_tags"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/website-addons/website_sales_team /home/odoo/addons/website_sales_team"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/website-addons/website_sale_stock_status /home/odoo/addons/website_sale_stock_status"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/website-addons/website_seo_url /home/odoo/addons/website_seo_url"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/website-addons/website_seo_url_product /home/odoo/addons/website_seo_url_product"

echo "Installazione Odoo 11.0 moduli mail-addons"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/it-projects-llc/mail-addons  /home/odoo/source/it-projects-llc/mail-addons"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/mail-addons/LICENSE /home/odoo/addons/LICENSE"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/mail-addons/mail_all /home/odoo/addons/mail_all"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/mail-addons/mail_archives /home/odoo/addons/mail_archives"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/mail-addons/mail_attachment_popup /home/odoo/addons/mail_attachment_popup"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/mail-addons/mail_base /home/odoo/addons/mail_base"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/mail-addons/mail_check_immediately /home/odoo/addons/mail_check_immediately"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/mail-addons/mail_fix_553 /home/odoo/addons/mail_fix_553"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/mail-addons/mailgun /home/odoo/addons/mailgun"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/mail-addons/mail_move_message /home/odoo/addons/mail_move_message"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/mail-addons/mail_private /home/odoo/addons/mail_private"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/mail-addons/mail_recovery /home/odoo/addons/mail_recovery"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/mail-addons/mail_reply /home/odoo/addons/mail_reply"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/mail-addons/mail_sent /home/odoo/addons/mail_sent"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/mail-addons/mail_to /home/odoo/addons/mail_to"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/mail-addons/oca_dependencies.txt /home/odoo/addons/oca_dependencies.txt"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/mail-addons/README.md /home/odoo/addons/README.md"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/mail-addons/res_partner_company_messages /home/odoo/addons/res_partner_company_messages"
su - odoo -c "ln -sfn /home/odoo/source/it-projects-llc/mail-addons/res_partner_mails_count /home/odoo/addons/res_partner_mails_count"



echo "Installazione Odoo 11.0 moduli vauxoo addos-vauxoo"
su - odoo -c "mkdir -p /home/odoo/source/vauxoo"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/vauxoo/addons-vauxoo /home/odoo/source/vauxoo/addons-vauxoo"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_amortization /home/odoo/addons/account_amortization"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_analytic_policy /home/odoo/addons/account_analytic_policy"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_anglo_saxon_missing_key /home/odoo/addons/account_anglo_saxon_missing_key"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_anglo_saxon_stock_move /home/odoo/addons/account_anglo_saxon_stock_move"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_anglo_saxon_stock_move_purchase /home/odoo/addons/account_anglo_saxon_stock_move_purchase"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_anglo_saxon_stock_move_sale /home/odoo/addons/account_anglo_saxon_stock_move_sale"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_asset_analytic /home/odoo/addons/account_asset_analytic"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_asset_date /home/odoo/addons/account_asset_date"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_asset_move_check /home/odoo/addons/account_asset_move_check"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_bank_statement_unfucked /home/odoo/addons/account_bank_statement_unfucked"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_bank_statement_vauxoo /home/odoo/addons/account_bank_statement_vauxoo"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_budget_imp /home/odoo/addons/account_budget_imp"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_chart_wiz_dates /home/odoo/addons/account_chart_wiz_dates"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_closure_preparation /home/odoo/addons/account_closure_preparation"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_currency_tools /home/odoo/addons/account_currency_tools"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_entries_report_group_by_ref /home/odoo/addons/account_entries_report_group_by_ref"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_group_auditory /home/odoo/addons/account_group_auditory"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_group_auditory_assets /home/odoo/addons/account_group_auditory_assets"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_invoice_change_currency /home/odoo/addons/account_invoice_change_currency"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_invoice_line_asset_category_required /home/odoo/addons/account_invoice_line_asset_category_required"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_invoice_line_currency /home/odoo/addons/account_invoice_line_currency"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_invoice_number /home/odoo/addons/account_invoice_number"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_invoice_regular_validation /home/odoo/addons/account_invoice_regular_validation"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_invoice_show_by_user /home/odoo/addons/account_invoice_show_by_user"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_invoice_supplier_quantity_attachments /home/odoo/addons/account_invoice_supplier_quantity_attachments"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_invoice_tax /home/odoo/addons/account_invoice_tax"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_ledger_report /home/odoo/addons/account_ledger_report"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_move_cancel /home/odoo/addons/account_move_cancel"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_move_filters /home/odoo/addons/account_move_filters"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_move_folio /home/odoo/addons/account_move_folio"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_move_group /home/odoo/addons/account_move_group"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_move_line_address /home/odoo/addons/account_move_line_address"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_move_line_base_tax /home/odoo/addons/account_move_line_base_tax"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_move_line_dp_product /home/odoo/addons/account_move_line_dp_product"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_move_line_extended /home/odoo/addons/account_move_line_extended"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_move_line_group_analytic /home/odoo/addons/account_move_line_group_analytic"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_move_line_group_by_asset /home/odoo/addons/account_move_line_group_by_asset"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_move_line_group_by_extend /home/odoo/addons/account_move_line_group_by_extend"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_move_line_grouping /home/odoo/addons/account_move_line_grouping"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_move_line_production /home/odoo/addons/account_move_line_production"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_move_nonzero /home/odoo/addons/account_move_nonzero"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_move_report /home/odoo/addons/account_move_report"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_move_sum_all_credits_debits /home/odoo/addons/account_move_sum_all_credits_debits"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_move_validate_multi_wizard /home/odoo/addons/account_move_validate_multi_wizard"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_multicompany_code /home/odoo/addons/account_multicompany_code"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_name_ref_search /home/odoo/addons/account_name_ref_search"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_order_wizard /home/odoo/addons/account_order_wizard"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_payment_approve_invoice /home/odoo/addons/account_payment_approve_invoice"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_reconcile_advance /home/odoo/addons/account_reconcile_advance"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_reconcile_advance_tax /home/odoo/addons/account_reconcile_advance_tax"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_reconcile_grouping /home/odoo/addons/account_reconcile_grouping"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_reconcile_search /home/odoo/addons/account_reconcile_search"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_refund_early_payment /home/odoo/addons/account_refund_early_payment"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_relation_move /home/odoo/addons/account_relation_move"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_remove_account_move_amount_field /home/odoo/addons/account_remove_account_move_amount_field"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_report_general_ledger_no_journal /home/odoo/addons/account_report_general_ledger_no_journal"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_smart_unreconcile /home/odoo/addons/account_smart_unreconcile"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_tax_importation /home/odoo/addons/account_tax_importation"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_update_amount_tax_in_move_lines /home/odoo/addons/account_update_amount_tax_in_move_lines"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_voucher_category /home/odoo/addons/account_voucher_category"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_voucher_department /home/odoo/addons/account_voucher_department"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_voucher_draft /home/odoo/addons/account_voucher_draft"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_voucher_move_id /home/odoo/addons/account_voucher_move_id"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_voucher_no_check_default /home/odoo/addons/account_voucher_no_check_default"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_voucher_requester /home/odoo/addons/account_voucher_requester"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_voucher_tax /home/odoo/addons/account_voucher_tax"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_voucher_tax_sat /home/odoo/addons/account_voucher_tax_sat"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/account_wizard_vouchers_invoice /home/odoo/addons/account_wizard_vouchers_invoice"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/active_journal_period /home/odoo/addons/active_journal_period"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/aging_due_report /home/odoo/addons/aging_due_report"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/analytic_entry_line_group /home/odoo/addons/analytic_entry_line_group"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/analytic_entry_line_journal /home/odoo/addons/analytic_entry_line_journal"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/analytic_entry_line_move /home/odoo/addons/analytic_entry_line_move"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/analytic_entry_line_partner /home/odoo/addons/analytic_entry_line_partner"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/analytic_entry_line_period /home/odoo/addons/analytic_entry_line_period"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/analytic_entry_line_plans /home/odoo/addons/analytic_entry_line_plans"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/analytic_entry_line_taxcode /home/odoo/addons/analytic_entry_line_taxcode"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/analytic_plans_group /home/odoo/addons/analytic_plans_group"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/analytic_split_quantity /home/odoo/addons/analytic_split_quantity"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/bank_iva_report /home/odoo/addons/bank_iva_report"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/base_user_signature_logo /home/odoo/addons/base_user_signature_logo"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/base_vat_country /home/odoo/addons/base_vat_country"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/base_vat_principal_view /home/odoo/addons/base_vat_principal_view"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/bom_inventory_information /home/odoo/addons/bom_inventory_information"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/change_invoice_number /home/odoo/addons/change_invoice_number"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/clean_user_groups /home/odoo/addons/clean_user_groups"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/commission_payment /home/odoo/addons/commission_payment"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/company_description /home/odoo/addons/company_description"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/configure_account_partner /home/odoo/addons/configure_account_partner"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/configure_chart_account /home/odoo/addons/configure_chart_account"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/CONTRIBUTING.md /home/odoo/addons/CONTRIBUTING.md"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/controller_report_xls /home/odoo/addons/controller_report_xls"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/costing_method_settings /home/odoo/addons/costing_method_settings"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/crm_claim_summary_report /home/odoo/addons/crm_claim_summary_report"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/crm_cost_issue /home/odoo/addons/crm_cost_issue"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/crm_profile_reporting /home/odoo/addons/crm_profile_reporting"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/debit_credit_note /home/odoo/addons/debit_credit_note"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/decimal_precision_currency /home/odoo/addons/decimal_precision_currency"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/decimal_precision_tax /home/odoo/addons/decimal_precision_tax"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/default_warehouse_from_sale_team /home/odoo/addons/default_warehouse_from_sale_team"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/deliver_project /home/odoo/addons/deliver_project"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/email_show_only_changes /home/odoo/addons/email_show_only_changes"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/email_template_att_dinamic /home/odoo/addons/email_template_att_dinamic"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/email_template_comment /home/odoo/addons/email_template_comment"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/expired_task_information /home/odoo/addons/expired_task_information"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/forward_mail /home/odoo/addons/forward_mail"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/group_button_wkf_send_rfq /home/odoo/addons/group_button_wkf_send_rfq"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/group_configurations_account /home/odoo/addons/group_configurations_account"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/hr_childrens /home/odoo/addons/hr_childrens"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/hr_expense_analytic /home/odoo/addons/hr_expense_analytic"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/hr_expense_replenishment /home/odoo/addons/hr_expense_replenishment"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/hr_expense_replenishment_cancel /home/odoo/addons/hr_expense_replenishment_cancel"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/hr_expense_replenishment_tax /home/odoo/addons/hr_expense_replenishment_tax"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/hr_job_positions_extended /home/odoo/addons/hr_job_positions_extended"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/hr_lastname /home/odoo/addons/hr_lastname"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/hr_payroll_cancel /home/odoo/addons/hr_payroll_cancel"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/hr_payroll_multicompany /home/odoo/addons/hr_payroll_multicompany"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/hr_payslip_paid /home/odoo/addons/hr_payslip_paid"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/hr_payslip_validation_home_address /home/odoo/addons/hr_payslip_validation_home_address"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/hr_salesman_commission /home/odoo/addons/hr_salesman_commission"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/hr_timesheet_reports /home/odoo/addons/hr_timesheet_reports"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/import_tax_tariff /home/odoo/addons/import_tax_tariff"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/inactive_account_children /home/odoo/addons/inactive_account_children"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/incoterm_delivery_type /home/odoo/addons/incoterm_delivery_type"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/incoterm_ext /home/odoo/addons/incoterm_ext"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/inventory_stock_report /home/odoo/addons/inventory_stock_report"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/invisible_aml_tax /home/odoo/addons/invisible_aml_tax"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/invoice_cancel_islr /home/odoo/addons/invoice_cancel_islr"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/invoice_cancel_iva /home/odoo/addons/invoice_cancel_iva"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/invoice_comment_view_tree /home/odoo/addons/invoice_comment_view_tree"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/invoice_commission /home/odoo/addons/invoice_commission"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/invoice_date_ref /home/odoo/addons/invoice_date_ref"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/invoice_datetime /home/odoo/addons/invoice_datetime"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/invoice_discount /home/odoo/addons/invoice_discount"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/invoice_double_validation /home/odoo/addons/invoice_double_validation"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/invoice_multicompany_report /home/odoo/addons/invoice_multicompany_report"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/invoice_number_view_tree /home/odoo/addons/invoice_number_view_tree"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/invoice_print_multicompany /home/odoo/addons/invoice_print_multicompany"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/invoice_report_multicompany /home/odoo/addons/invoice_report_multicompany"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/invoice_report_per_journal /home/odoo/addons/invoice_report_per_journal"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/invoice_sale_ref /home/odoo/addons/invoice_sale_ref"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/invoice_so /home/odoo/addons/invoice_so"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/ir_actions_report_xml_multicompany /home/odoo/addons/ir_actions_report_xml_multicompany"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/ir_ui_view_filter_arch /home/odoo/addons/ir_ui_view_filter_arch"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/issue_view /home/odoo/addons/issue_view"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/mail_add_followers_multirecord /home/odoo/addons/mail_add_followers_multirecord"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/merge_editing /home/odoo/addons/merge_editing"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/message_post_model /home/odoo/addons/message_post_model"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/message_post_test /home/odoo/addons/message_post_test"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/mrp_bom_constraint /home/odoo/addons/mrp_bom_constraint"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/mrp_bom_standard_price /home/odoo/addons/mrp_bom_standard_price"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/mrp_bom_subproduct_cost /home/odoo/addons/mrp_bom_subproduct_cost"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/mrp_button_box /home/odoo/addons/mrp_button_box"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/mrp_force_responsible /home/odoo/addons/mrp_force_responsible"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/mrp_location_line_production /home/odoo/addons/mrp_location_line_production"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/mrp_location_route /home/odoo/addons/mrp_location_route"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/mrp_partial_production /home/odoo/addons/mrp_partial_production"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/mrp_product_capacity /home/odoo/addons/mrp_product_capacity"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/mrp_production_analytic_acc /home/odoo/addons/mrp_production_analytic_acc"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/mrp_production_bom_related /home/odoo/addons/mrp_production_bom_related"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/mrp_production_filter_date /home/odoo/addons/mrp_production_filter_date"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/mrp_production_filter_product /home/odoo/addons/mrp_production_filter_product"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/mrp_production_procurement_order /home/odoo/addons/mrp_production_procurement_order"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/mrp_production_security_force /home/odoo/addons/mrp_production_security_force"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/mrp_pt_planified /home/odoo/addons/mrp_pt_planified"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/mrp_routing_account_journal /home/odoo/addons/mrp_routing_account_journal"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/mrp_scheduled_onchange_product /home/odoo/addons/mrp_scheduled_onchange_product"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/mrp_subproduction /home/odoo/addons/mrp_subproduction"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/mrp_subproduct_pt_planified /home/odoo/addons/mrp_subproduct_pt_planified"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/mrp_webkit_report_wizard /home/odoo/addons/mrp_webkit_report_wizard"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/mrp_workcenter_account_move /home/odoo/addons/mrp_workcenter_account_move"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/mrp_workcenter_management /home/odoo/addons/mrp_workcenter_management"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/mrp_workcenter_responsible /home/odoo/addons/mrp_workcenter_responsible"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/mrp_workcenter_segmentation /home/odoo/addons/mrp_workcenter_segmentation"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/mrp_workorder_variation /home/odoo/addons/mrp_workorder_variation"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/note_to_task /home/odoo/addons/note_to_task"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/partner_credit_limit /home/odoo/addons/partner_credit_limit"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/partner_effective_sale /home/odoo/addons/partner_effective_sale"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/partner_foreign /home/odoo/addons/partner_foreign"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/partner_invoice_description /home/odoo/addons/partner_invoice_description"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/partner_notification_advance /home/odoo/addons/partner_notification_advance"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/partner_products /home/odoo/addons/partner_products"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/partner_property_accounts /home/odoo/addons/partner_property_accounts"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/partner_ref_search /home/odoo/addons/partner_ref_search"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/partner_required_in_acc_move_line /home/odoo/addons/partner_required_in_acc_move_line"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/partner_search_by_vat /home/odoo/addons/partner_search_by_vat"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/partner_validate_vat /home/odoo/addons/partner_validate_vat"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/payment_term_type /home/odoo/addons/payment_term_type"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/payroll_amount_residual /home/odoo/addons/payroll_amount_residual"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/periodic_inventory_valuation /home/odoo/addons/periodic_inventory_valuation"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/picking_force_availability /home/odoo/addons/picking_force_availability"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/picking_from_invoice /home/odoo/addons/picking_from_invoice"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/picking_verification_report /home/odoo/addons/picking_verification_report"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/point_of_sale_by_month /home/odoo/addons/point_of_sale_by_month"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/point_of_sale_reprint_tree /home/odoo/addons/point_of_sale_reprint_tree"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/portal_project_kanban_fields /home/odoo/addons/portal_project_kanban_fields"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/pos_calculator /home/odoo/addons/pos_calculator"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/pos_delivery_restaurant /home/odoo/addons/pos_delivery_restaurant"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/pos_product_filter /home/odoo/addons/pos_product_filter"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/pr_line_related_po_line /home/odoo/addons/pr_line_related_po_line"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/procurement_cancel /home/odoo/addons/procurement_cancel"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/procurement_so2po_shiping_address /home/odoo/addons/procurement_so2po_shiping_address"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/product_attr_description /home/odoo/addons/product_attr_description"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/product_categ_name_untranslated /home/odoo/addons/product_categ_name_untranslated"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/product_category_attributes /home/odoo/addons/product_category_attributes"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/product_category_multicompany /home/odoo/addons/product_category_multicompany"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/product_context_date /home/odoo/addons/product_context_date"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/product_cost_usd /home/odoo/addons/product_cost_usd"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/product_customer_code /home/odoo/addons/product_customer_code"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/product_customs_rate /home/odoo/addons/product_customs_rate"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/product_do_merge /home/odoo/addons/product_do_merge"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/product_extended_segmentation /home/odoo/addons/product_extended_segmentation"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/product_extended_variants /home/odoo/addons/product_extended_variants"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/product_images_olbs /home/odoo/addons/product_images_olbs"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/production_lot_group_by_name /home/odoo/addons/production_lot_group_by_name"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/product_lifecycle /home/odoo/addons/product_lifecycle"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/product_model_no /home/odoo/addons/product_model_no"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/product_name_untranslated /home/odoo/addons/product_name_untranslated"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/product_pricelist_date /home/odoo/addons/product_pricelist_date"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/product_pricelist_report_qweb /home/odoo/addons/product_pricelist_report_qweb"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/product_price_visible /home/odoo/addons/product_price_visible"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/product_product_multi_link /home/odoo/addons/product_product_multi_link"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/product_properties_by_category /home/odoo/addons/product_properties_by_category"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/product_rfq /home/odoo/addons/product_rfq"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/products_finished_scrap /home/odoo/addons/products_finished_scrap"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/product_unique_default_code /home/odoo/addons/product_unique_default_code"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/product_uom_update /home/odoo/addons/product_uom_update"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/project_complete_name /home/odoo/addons/project_complete_name"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/project_contract_validations /home/odoo/addons/project_contract_validations"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/project_followers_rule /home/odoo/addons/project_followers_rule"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/project_image /home/odoo/addons/project_image"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/project_issue_fix_progress /home/odoo/addons/project_issue_fix_progress"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/project_issue_management /home/odoo/addons/project_issue_management"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/project_issue_report /home/odoo/addons/project_issue_report"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/project_issue_report2 /home/odoo/addons/project_issue_report2"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/project_search_create_uid /home/odoo/addons/project_search_create_uid"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/project_task_work /home/odoo/addons/project_task_work"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/purchase_changeless_move_lines /home/odoo/addons/purchase_changeless_move_lines"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/purchase_incoming_qty /home/odoo/addons/purchase_incoming_qty"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/purchase_multi_report /home/odoo/addons/purchase_multi_report"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/purchase_order_cancel /home/odoo/addons/purchase_order_cancel"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/purchase_order_contract_analyst /home/odoo/addons/purchase_order_contract_analyst"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/purchase_order_department /home/odoo/addons/purchase_order_department"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/purchase_order_description /home/odoo/addons/purchase_order_description"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/purchase_order_line_quantity /home/odoo/addons/purchase_order_line_quantity"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/purchase_order_line_sequence /home/odoo/addons/purchase_order_line_sequence"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/purchase_order_requisitor /home/odoo/addons/purchase_order_requisitor"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/purchase_order_type /home/odoo/addons/purchase_order_type"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/purchase_requisition_contract_analyst /home/odoo/addons/purchase_requisition_contract_analyst"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/purchase_requisition_currency /home/odoo/addons/purchase_requisition_currency"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/purchase_requisition_department /home/odoo/addons/purchase_requisition_department"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/purchase_requisition_for_everybody /home/odoo/addons/purchase_requisition_for_everybody"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/purchase_requisition_incoterms /home/odoo/addons/purchase_requisition_incoterms"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/purchase_requisition_line_analytic /home/odoo/addons/purchase_requisition_line_analytic"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/purchase_requisition_line_description /home/odoo/addons/purchase_requisition_line_description"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/purchase_requisition_line_plan /home/odoo/addons/purchase_requisition_line_plan"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/purchase_requisition_line_price_unit /home/odoo/addons/purchase_requisition_line_price_unit"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/purchase_requisition_line_uom_check /home/odoo/addons/purchase_requisition_line_uom_check"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/purchase_requisition_line_view /home/odoo/addons/purchase_requisition_line_view"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/purchase_requisition_priority /home/odoo/addons/purchase_requisition_priority"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/purchase_requisition_remarks /home/odoo/addons/purchase_requisition_remarks"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/purchase_requisition_supplier_list /home/odoo/addons/purchase_requisition_supplier_list"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/purchase_requisition_type /home/odoo/addons/purchase_requisition_type"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/purchase_supplier /home/odoo/addons/purchase_supplier"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/purchase_test_data_imp /home/odoo/addons/purchase_test_data_imp"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/purchase_third_validation /home/odoo/addons/purchase_third_validation"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/purchase_user_validation /home/odoo/addons/purchase_user_validation"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/README.md /home/odoo/addons/README.md"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/recovery_attachments_bd /home/odoo/addons/recovery_attachments_bd"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/repo_requirements.txt /home/odoo/addons/repo_requirements.txt"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/report_move_voucher /home/odoo/addons/report_move_voucher"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/report_multicompany /home/odoo/addons/report_multicompany"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/report_parser_html /home/odoo/addons/report_parser_html"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/report_process_production /home/odoo/addons/report_process_production"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/requirements.txt /home/odoo/addons/requirements.txt"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/res_bank_menu_payroll /home/odoo/addons/res_bank_menu_payroll"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/res_partner_btree /home/odoo/addons/res_partner_btree"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/sale_block_cancellation /home/odoo/addons/sale_block_cancellation"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/sale_date_confirm /home/odoo/addons/sale_date_confirm"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/sale_double_validation /home/odoo/addons/sale_double_validation"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/sale_line_import /home/odoo/addons/sale_line_import"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/sale_margin_commision /home/odoo/addons/sale_margin_commision"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/sale_margin_percentage /home/odoo/addons/sale_margin_percentage"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/sale_order_copy_line /home/odoo/addons/sale_order_copy_line"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/sale_order_create_task_planned_hours /home/odoo/addons/sale_order_create_task_planned_hours"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/sale_order_customized /home/odoo/addons/sale_order_customized"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/sale_order_dates_max /home/odoo/addons/sale_order_dates_max"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/sale_order_line_quantity /home/odoo/addons/sale_order_line_quantity"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/sale_test_data_imp /home/odoo/addons/sale_test_data_imp"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/sale_uncommitted_product /home/odoo/addons/sale_uncommitted_product"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/sale_uom_group /home/odoo/addons/sale_uom_group"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/sale_website_cleanup /home/odoo/addons/sale_website_cleanup"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/send_author_mail /home/odoo/addons/send_author_mail"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/send_mail_task /home/odoo/addons/send_mail_task"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/set_group_by_department /home/odoo/addons/set_group_by_department"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/seudo_oca_dependencies.txt /home/odoo/addons/seudo_oca_dependencies.txt"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/split_invoice_button /home/odoo/addons/split_invoice_button"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/sprint_kanban /home/odoo/addons/sprint_kanban"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/standard_price_acl /home/odoo/addons/standard_price_acl"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/stock_accrual_report /home/odoo/addons/stock_accrual_report"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/stock_allow_past_date /home/odoo/addons/stock_allow_past_date"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/stock_card /home/odoo/addons/stock_card"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/stock_card_segmentation /home/odoo/addons/stock_card_segmentation"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/stock_deviation_account /home/odoo/addons/stock_deviation_account"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/stock_easy_internal_transfer /home/odoo/addons/stock_easy_internal_transfer"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/stock_hide_set_zero_button /home/odoo/addons/stock_hide_set_zero_button"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/stock_inventory_delete /home/odoo/addons/stock_inventory_delete"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/stock_invoice_state_editable /home/odoo/addons/stock_invoice_state_editable"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/stock_landed_costs_average /home/odoo/addons/stock_landed_costs_average"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/stock_landed_costs_segmentation /home/odoo/addons/stock_landed_costs_segmentation"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/stock_location_acml /home/odoo/addons/stock_location_acml"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/stock_location_code /home/odoo/addons/stock_location_code"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/stock_move_entries /home/odoo/addons/stock_move_entries"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/stock_move_name /home/odoo/addons/stock_move_name"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/stock_move_tracking_number /home/odoo/addons/stock_move_tracking_number"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/stock_picking_invoice_validation /home/odoo/addons/stock_picking_invoice_validation"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/stock_picking_log_message_transfer /home/odoo/addons/stock_picking_log_message_transfer"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/stock_picking_security_force /home/odoo/addons/stock_picking_security_force"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/stock_picking_show_entries_info /home/odoo/addons/stock_picking_show_entries_info"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/stock_picking_validate_past /home/odoo/addons/stock_picking_validate_past"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/stock_purchase_analytic_plans /home/odoo/addons/stock_purchase_analytic_plans"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/stock_purchase_check_fulfillment /home/odoo/addons/stock_purchase_check_fulfillment"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/stock_purchase_expiry /home/odoo/addons/stock_purchase_expiry"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/stock_purchase_requisitor /home/odoo/addons/stock_purchase_requisitor"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/stock_purchase_type /home/odoo/addons/stock_purchase_type"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/stock_quant_cost_segmentation /home/odoo/addons/stock_quant_cost_segmentation"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/stock_quant_menu /home/odoo/addons/stock_quant_menu"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/stock_sale_invoice_line /home/odoo/addons/stock_sale_invoice_line"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/stock_sale_order_line /home/odoo/addons/stock_sale_order_line"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/stock_transfer_avoid_lot_repeated_split /home/odoo/addons/stock_transfer_avoid_lot_repeated_split"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/stock_unfuck /home/odoo/addons/stock_unfuck"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/stock_view_product /home/odoo/addons/stock_view_product"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/supplier_invoice_number_unique /home/odoo/addons/supplier_invoice_number_unique"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/sync_youtube /home/odoo/addons/sync_youtube"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/test_sale_team_warehouse /home/odoo/addons/test_sale_team_warehouse"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/transaction_type /home/odoo/addons/transaction_type"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/update_period /home/odoo/addons/update_period"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/validate_stock_move_product /home/odoo/addons/validate_stock_move_product"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/validate_stock_picking /home/odoo/addons/validate_stock_picking"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/validate_type_line_invoice /home/odoo/addons/validate_type_line_invoice"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/website_authorized_service_centers /home/odoo/addons/website_authorized_service_centers"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/website_blog_rss /home/odoo/addons/website_blog_rss"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/website_comment_approval /home/odoo/addons/website_comment_approval"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/website_customer_also_purchased /home/odoo/addons/website_customer_also_purchased"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/website_hr_social_icons /home/odoo/addons/website_hr_social_icons"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/website_order_confirm /home/odoo/addons/website_order_confirm"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/website_product_availability /home/odoo/addons/website_product_availability"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/website_product_comment_purchased /home/odoo/addons/website_product_comment_purchased"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/website_product_manufacturer_url /home/odoo/addons/website_product_manufacturer_url"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/website_product_rss /home/odoo/addons/website_product_rss"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/website_rate_product /home/odoo/addons/website_rate_product"
su - odoo -c "ln -sfn /home/odoo/source/vauxoo/addons-vauxoo/website_variants_extra /home/odoo/addons/website_variants_extra"


echo "Installazione Odoo 11.0 moduli addons-onestein"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/onesteinbv/addons-onestein  /home/odoo/source/onesteinbv/addons-onestein"
su - odoo -c "ln -sfn /home/odoo/source/onesteinbv/addons-onestein/account_cost_center /home/odoo/addons/account_cost_center"
su - odoo -c "ln -sfn /home/odoo/source/onesteinbv/addons-onestein/account_cost_spread /home/odoo/addons/account_cost_spread"
su - odoo -c "ln -sfn /home/odoo/source/onesteinbv/addons-onestein/account_cost_spread_all /home/odoo/addons/account_cost_spread_all"
su - odoo -c "ln -sfn /home/odoo/source/onesteinbv/addons-onestein/account_fiscal_year_config /home/odoo/addons/account_fiscal_year_config"
su - odoo -c "ln -sfn /home/odoo/source/onesteinbv/addons-onestein/account_invoice_discount_formula /home/odoo/addons/account_invoice_discount_formula"
su - odoo -c "ln -sfn /home/odoo/source/onesteinbv/addons-onestein/base_directory_file_download /home/odoo/addons/base_directory_file_download"
su - odoo -c "ln -sfn /home/odoo/source/onesteinbv/addons-onestein/hr_absenteeism /home/odoo/addons/hr_absenteeism"
su - odoo -c "ln -sfn /home/odoo/source/onesteinbv/addons-onestein/hr_absenteeism_hours /home/odoo/addons/hr_absenteeism_hours"
su - odoo -c "ln -sfn /home/odoo/source/onesteinbv/addons-onestein/hr_holidays_approval_date /home/odoo/addons/hr_holidays_approval_date"
su - odoo -c "ln -sfn /home/odoo/source/onesteinbv/addons-onestein/hr_holidays_expiration /home/odoo/addons/hr_holidays_expiration"
su - odoo -c "ln -sfn /home/odoo/source/onesteinbv/addons-onestein/hr_holidays_leave_overlap /home/odoo/addons/hr_holidays_leave_overlap"
su - odoo -c "ln -sfn /home/odoo/source/onesteinbv/addons-onestein/l10n_nl_postcode /home/odoo/addons/l10n_nl_postcode"
su - odoo -c "ln -sfn /home/odoo/source/onesteinbv/addons-onestein/purchase_order_archive /home/odoo/addons/purchase_order_archive"
su - odoo -c "ln -sfn /home/odoo/source/onesteinbv/addons-onestein/sale_order_archive /home/odoo/addons/sale_order_archive"
su - odoo -c "ln -sfn /home/odoo/source/onesteinbv/addons-onestein/sale_order_discount_formula /home/odoo/addons/sale_order_discount_formula"
su - odoo -c "ln -sfn /home/odoo/source/onesteinbv/addons-onestein/sale_order_mass_confirm /home/odoo/addons/sale_order_mass_confirm"


pip3 install -r /home/odoo/source/ingadhoc/product/requirements.txt
pip3 install -r /home/odoo/source/ingadhoc/account-invoicing/requirements.txt
pip3 install -r /home/odoo/source/ingadhoc/reporting-engine/requirements.txt
pip3 install -r /home/odoo/source/ingadhoc/partner/requirements.txt
pip3 install -r /home/odoo/source/ingadhoc/sale/requirements.txt
pip3 install -r /home/odoo/source/OCA/stock-logistics-barcode/requirements.txt
pip3 install -r /home/odoo/source/OCA/server-tools/requirements.txt
pip3 install -r /home/odoo/source/OCA/account-financial-tools/requirements.txt
pip3 install -r /home/odoo/source/OCA/web/requirements.txt
pip3 install -r /home/odoo/source/OCA/account-financial-reporting/requirements.txt
pip3 install -r /home/odoo/source/OCA/reporting-engine/requirements.txt
pip3 install -r /home/odoo/source/OCA/report-print-send/requirements.txt
pip3 install -r /home/odoo/source/vauxoo/addons-vauxoo/requirements.txt
pip3 install -r /home/odoo/source/it-projects-llc/misc-addons/requirements.txt
pip3 install -r /home/odoo/source/it-projects-llc/website-addons/requirements.txt





FINE











echo "Installazione Odoo 10.0 moduli connector"
su - odoo -c "mkdir -p /home/odoo/source/OCA"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/connector /home/odoo/source/OCA/connector"
su - odoo -c "ln -sfn /home/odoo/source/OCA/connector/component /home/odoo/addons/component"
su - odoo -c "ln -sfn /home/odoo/source/OCA/connector/component_event /home/odoo/addons/component_event"
su - odoo -c "ln -sfn /home/odoo/source/OCA/connector/connector /home/odoo/addons/connector"
su - odoo -c "ln -sfn /home/odoo/source/OCA/connector/connector_base_product /home/odoo/addons/connector_base_product"
su - odoo -c "ln -sfn /home/odoo/source/OCA/connector/test_component /home/odoo/addons/test_component"
su - odoo -c "ln -sfn /home/odoo/source/OCA/connector/test_connector /home/odoo/addons/test_connector"


echo "Installazione Odoo 10.0 moduli queue"
su - odoo -c "mkdir -p /home/odoo/source/OCA"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/queue /home/odoo/source/OCA/queue"
su - odoo -c "ln -sfn /home/odoo/source/OCA/queue/queue_job /home/odoo/addons/queue_job"
su - odoo -c "ln -sfn /home/odoo/source/OCA/queue/queue_job_cron /home/odoo/addons/queue_job_cron"
su - odoo -c "ln -sfn /home/odoo/source/OCA/queue/queue_job_subscribe /home/odoo/addons/queue_job_subscribe"
su - odoo -c "ln -sfn /home/odoo/source/OCA/queue/test_queue_job /home/odoo/addons/test_queue_job"












#su - odoo -c "git clone -b 10.0-mig-sale_commission https://github.com/hurrinico/commission /home/odoo/source/hurrinico/10.0-mig-sale_commission-commission"
#su - odoo -c "ln -sfn /home/odoo/source/hurrinico/10.0-mig-sale_commission-commission/sale_commission /home/odoo/addons/sale_commission"

#su - odoo -c "git clone -b 10.0-mig-sale_commission_formula https://github.com/hurrinico/commission /home/odoo/source/hurrinico/10.0-mig-sale_commission_formula-commission"
#su - odoo -c "ln -sfn /home/odoo/source/hurrinico/10.0-mig-sale_commission_formula-commission/sale_commission_formula /home/odoo/addons/sale_commission_formula"

#su - odoo -c "git clone -b 10.0-add-sale_commission_areamanager https://github.com/hurrinico/commission /home/odoo/source/hurrinico/10.0-add-sale_commission_areamanager-commission"
#su - odoo -c "ln -sfn /home/odoo/source/hurrinico/10.0-add-sale_commission_areamanager-commission/sale_commission_areamanager /home/odoo/addons/sale_commission_areamanager"

<<<<<<< HEAD



su - odoo -c "ln -sfn /home/odoo/source/FreeDoo2018/aeroo_reports/report_aeroo /home/odoo/addons/report_aeroo"
su - odoo -c "ln -sfn /home/odoo/source/FreeDoo2018/aeroo_reports/report_aeroo_sample /home/odoo/addons/report_aeroo_sample"

su - odoo -c "git clone -b 11.0 https://github.com/ingadhoc/aeroo_reports.git /home/odoo/source/ingadhoc/aeroo_reports"
pip3 install --upgrade -r /home/odoo/source/ingadhoc/aeroo_reports/requirements.txt 
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/aeroo_reports/report_aeroo /home/odoo/addons/report_aeroo"
su - odoo -c "ln -sfn /home/odoo/source/ingadhoc/aeroo_reports/report_aeroo_sample /home/odoo/addons/report_aeroo_sample"



<<<<<<< HEAD


#su - odoo -c "git clone -b 10.0-mig-product_replenishment_cost --single-branch https://github.com/fcoach66/margin-analysis  /home/odoo/source/fcoach66/10.0-mig-product_replenishment_cost-margin-analysis"
#su - odoo -c "ln -sfn /home/odoo/source/fcoach66/10.0-mig-product_replenishment_cost-margin-analysis/product_replenishment_cost /home/odoo/addons/product_replenishment_cost"

>>>>>>> origin/master










#echo "Installazione Odoo 10.0 moduli product-kitting"
#su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/product-kitting  /home/odoo/source/OCA/product-kitting"




echo "Installazione Odoo 8.0 moduli multi-company"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/multi-company  /home/odoo/source/OCA/multi-company"
su - odoo -c "ln -sfn /home/odoo/source/OCA/multi-company/account_invoice_inter_company /home/odoo/addons/account_invoice_inter_company"
su - odoo -c "ln -sfn /home/odoo/source/OCA/multi-company/account_type_multi_company /home/odoo/addons/account_type_multi_company"
su - odoo -c "ln -sfn /home/odoo/source/OCA/multi-company/base_multi_company /home/odoo/addons/base_multi_company"
su - odoo -c "ln -sfn /home/odoo/source/OCA/multi-company/LICENSE /home/odoo/addons/LICENSE"
su - odoo -c "ln -sfn /home/odoo/source/OCA/multi-company/oca_dependencies.txt /home/odoo/addons/oca_dependencies.txt"
su - odoo -c "ln -sfn /home/odoo/source/OCA/multi-company/partner_multi_company /home/odoo/addons/partner_multi_company"
su - odoo -c "ln -sfn /home/odoo/source/OCA/multi-company/product_autocompany /home/odoo/addons/product_autocompany"
su - odoo -c "ln -sfn /home/odoo/source/OCA/multi-company/product_multi_company /home/odoo/addons/product_multi_company"
su - odoo -c "ln -sfn /home/odoo/source/OCA/multi-company/product_name_unique_per_company /home/odoo/addons/product_name_unique_per_company"
su - odoo -c "ln -sfn /home/odoo/source/OCA/multi-company/README.md /home/odoo/addons/README.md"
su - odoo -c "ln -sfn /home/odoo/source/OCA/multi-company/sale_layout_multi_company /home/odoo/addons/sale_layout_multi_company"
su - odoo -c "ln -sfn /home/odoo/source/OCA/multi-company/sales_team_multicompany /home/odoo/addons/sales_team_multicompany"
su - odoo -c "ln -sfn /home/odoo/source/OCA/multi-company/setup /home/odoo/addons/setup"
su - odoo -c "ln -sfn /home/odoo/source/OCA/multi-company/stock_production_lot_multi_company /home/odoo/addons/stock_production_lot_multi_company"




echo "Installazione Odoo 8.0 moduli pos"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/pos  /home/odoo/source/OCA/pos"
su - odoo -c "ln -sfn /home/odoo/source/OCA/pos/account_cash_invoice /home/odoo/addons/account_cash_invoice"
su - odoo -c "ln -sfn /home/odoo/source/OCA/pos/oca_dependencies.txt /home/odoo/addons/oca_dependencies.txt"
su - odoo -c "ln -sfn /home/odoo/source/OCA/pos/pos_backend_communication /home/odoo/addons/pos_backend_communication"
su - odoo -c "ln -sfn /home/odoo/source/OCA/pos/pos_backend_partner /home/odoo/addons/pos_backend_partner"
su - odoo -c "ln -sfn /home/odoo/source/OCA/pos/pos_customer_display /home/odoo/addons/pos_customer_display"
su - odoo -c "ln -sfn /home/odoo/source/OCA/pos/pos_default_empty_image /home/odoo/addons/pos_default_empty_image"
su - odoo -c "ln -sfn /home/odoo/source/OCA/pos/pos_default_payment_method /home/odoo/addons/pos_default_payment_method"
su - odoo -c "ln -sfn /home/odoo/source/OCA/pos/pos_fix_search_limit /home/odoo/addons/pos_fix_search_limit"
su - odoo -c "ln -sfn /home/odoo/source/OCA/pos/pos_gift_ticket /home/odoo/addons/pos_gift_ticket"
su - odoo -c "ln -sfn /home/odoo/source/OCA/pos/pos_lot_selection /home/odoo/addons/pos_lot_selection"
su - odoo -c "ln -sfn /home/odoo/source/OCA/pos/pos_loyalty /home/odoo/addons/pos_loyalty"
su - odoo -c "ln -sfn /home/odoo/source/OCA/pos/pos_margin /home/odoo/addons/pos_margin"
su - odoo -c "ln -sfn /home/odoo/source/OCA/pos/pos_order_return /home/odoo/addons/pos_order_return"
su - odoo -c "ln -sfn /home/odoo/source/OCA/pos/pos_payment_terminal /home/odoo/addons/pos_payment_terminal"
su - odoo -c "ln -sfn /home/odoo/source/OCA/pos/pos_pricelist /home/odoo/addons/pos_pricelist"
su - odoo -c "ln -sfn /home/odoo/source/OCA/pos/pos_price_to_weight /home/odoo/addons/pos_price_to_weight"
su - odoo -c "ln -sfn /home/odoo/source/OCA/pos/pos_product_template /home/odoo/addons/pos_product_template"
su - odoo -c "ln -sfn /home/odoo/source/OCA/pos/pos_quick_logout /home/odoo/addons/pos_quick_logout"
su - odoo -c "ln -sfn /home/odoo/source/OCA/pos/pos_remove_pos_category /home/odoo/addons/pos_remove_pos_category"
su - odoo -c "ln -sfn /home/odoo/source/OCA/pos/pos_session_pay_invoice /home/odoo/addons/pos_session_pay_invoice"
su - odoo -c "ln -sfn /home/odoo/source/OCA/pos/pos_stock_picking_invoice_link /home/odoo/addons/pos_stock_picking_invoice_link"
su - odoo -c "ln -sfn /home/odoo/source/OCA/pos/pos_timeout /home/odoo/addons/pos_timeout"
su - odoo -c "ln -sfn /home/odoo/source/OCA/pos/README.md /home/odoo/addons/README.md"
su - odoo -c "ln -sfn /home/odoo/source/OCA/pos/requirements.txt /home/odoo/addons/requirements.txt"
su - odoo -c "ln -sfn /home/odoo/source/OCA/pos/setup /home/odoo/addons/setup"






#su - odoo -c "git clone -b 10-port-purchase_discount --single-branch https://github.com/akretion/purchase-workflow  /home/odoo/source/akretion/10-port-purchase_discount-purchase-workflow"
#su - odoo -c "ln -sfn /home/odoo/source/akretion/10-port-purchase_discount-purchase-workflow/purchase_discount /home/odoo/addons/purchase_discount"





#echo "Installazione Odoo 8.0 moduli community-data-files"
#su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/community-data-files  /home/odoo/source/OCA/community-data-files"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/community-data-files/account_payment_unece /home/odoo/addons/account_payment_unece"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/community-data-files/account_tax_unece /home/odoo/addons/account_tax_unece"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/community-data-files/base_iso3166 /home/odoo/addons/base_iso3166"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/community-data-files/base_unece /home/odoo/addons/base_unece"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/community-data-files/l10n_eu_nace /home/odoo/addons/l10n_eu_nace"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/community-data-files/product_uom_unece /home/odoo/addons/product_uom_unece"


#echo "Installazione Odoo 8.0 moduli geospatial"
#su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/geospatial  /home/odoo/source/OCA/geospatial"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/geospatial/base_geoengine /home/odoo/addons/base_geoengine"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/geospatial/base_geoengine_demo /home/odoo/addons/base_geoengine_demo"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/geospatial/geoengine_base_geolocalize /home/odoo/addons/geoengine_base_geolocalize"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/geospatial/geoengine_geoname_geocoder /home/odoo/addons/geoengine_geoname_geocoder"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/geospatial/geoengine_maplausanne /home/odoo/addons/geoengine_maplausanne"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/geospatial/geoengine_partner /home/odoo/addons/geoengine_partner"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/geospatial/geoengine_project /home/odoo/addons/geoengine_project"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/geospatial/geoengine_sale /home/odoo/addons/geoengine_sale"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/geospatial/geoengine_swisstopo /home/odoo/addons/geoengine_swisstopo"


#echo "Installazione Odoo 8.0 moduli vertical-isp"
#su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/vertical-isp  /home/odoo/source/OCA/vertical-isp"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/vertical-isp/contract_isp /home/odoo/addons/contract_isp"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/vertical-isp/contract_isp_automatic_invoicing /home/odoo/addons/contract_isp_automatic_invoicing"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/vertical-isp/contract_isp_invoice /home/odoo/addons/contract_isp_invoice"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/vertical-isp/contract_isp_package_configurator /home/odoo/addons/contract_isp_package_configurator"
#su - odoo -c "ln -sfn /home/odoo/source/OCA/vertical-isp/product_dependencies /home/odoo/addons/product_dependencies"


















#echo "Installazione Odoo 10.0 modulo l10n-italy l10n_it_withholding_tax"
#su - odoo -c "mkdir -p /home/odoo/source/elbati"
#su - odoo -c "git clone -b porting_withholding_tax_8 --single-branch https://github.com/eLBati/l10n-italy /home/odoo/source/elbati/l10n-italy-withholding_tax"
#su - odoo -c "ln -s /home/odoo/source/elbati/l10n-italy-withholding_tax/l10n_it_withholding_tax /home/odoo/addons/l10n_it_withholding_tax"








#su - odoo -c "git clone -b 10.0-mig-product_replenishment_cost_currency_rule --single-branch https://github.com/fcoach66/product  /home/odoo/source/fcoach66/10.0-mig-product_replenishment_cost_currency_rule-product"
#su - odoo -c "ln -sfn /home/odoo/source/fcoach66/10.0-mig-product_replenishment_cost_currency_rule-product/product_replenishment_cost_currency /home/odoo/addons/product_replenishment_cost_currency"
#su - odoo -c "ln -sfn /home/odoo/source/fcoach66/10.0-mig-product_replenishment_cost_currency_rule-product/product_replenishment_cost_rule /home/odoo/addons/product_replenishment_cost_rule"
#su - odoo -c "ln -sfn /home/odoo/source/fcoach66/10.0-mig-product_replenishment_cost_currency_rule-product/product_sale_price_by_margin /home/odoo/addons/product_sale_price_by_margin"
#su - odoo -c "ln -sfn /home/odoo/source/fcoach66/10.0-mig-product_replenishment_cost_currency_rule-product/product_computed_list_price /home/odoo/addons/product_computed_list_price"







echo "Installazione Odoo 10.0 moduli techreceptives website_recaptcha"
#su - odoo -c "mkdir -p /home/odoo/source/techreceptives"
#su - odoo -c "git clone -b 10.0 --single-branch https://github.com/techreceptives/website_recaptcha /home/odoo/source/techreceptives/website_recaptcha"
#su - odoo -c "ln -s /home/odoo/source/techreceptives/website_recaptcha/website_crm_recaptcha_reloaded /home/odoo/addons/website_crm_recaptcha_reloaded"
#su - odoo -c "ln -s /home/odoo/source/techreceptives/website_recaptcha/website_forum_recaptcha_reloaded /home/odoo/addons/website_forum_recaptcha_reloaded"
#su - odoo -c "ln -s /home/odoo/source/techreceptives/website_recaptcha/website_recaptcha_reloaded /home/odoo/addons/website_recaptcha_reloaded"
#su - odoo -c "ln -s /home/odoo/source/techreceptives/website_recaptcha/website_signup_recaptcha_reloaded /home/odoo/addons/website_signup_recaptcha_reloaded"


echo "Installazione Odoo 10.0 moduli initos openerp-dav"
#su - odoo -c "mkdir -p /home/odoo/source/initos"
#su - odoo -c "git clone -b 10.0 --single-branch https://github.com/initOS/openerp-dav /home/odoo/source/initOS/openerp-dav"
#su - odoo -c "ln -s /home/odoo/source/initOS/openerp-dav/base_vcard /home/odoo/addons/base_vcard"
#su - odoo -c "ln -s /home/odoo/source/initOS/openerp-dav/crm_vcard /home/odoo/addons/crm_vcard"
#su - odoo -c "ln -s /home/odoo/source/initOS/openerp-dav/document_carddav /home/odoo/addons/document_carddav"
#su - odoo -c "ln -s /home/odoo/source/initOS/openerp-dav/document_webdav_fast /home/odoo/addons/document_webdav_fast"





#echo "Installazione Odoo 10.0 moduli abstract l10n_it_prima_nota_cassa"
#su - odoo -c "mkdir -p /home/odoo/source/abstract-open-solutions"
#su - odoo -c "git clone -b 10.0-prima-nota-cassa --single-branch https://github.com/abstract-open-solutions/l10n-italy /home/odoo/source/abstract-open-solutions/l10n-italy-l10n_it_prima_nota_cassa"
#su - odoo -c "ln -s /home/odoo/source/abstract-open-solutions/l10n-italy-l10n_it_prima_nota_cassa/l10n_it_prima_nota_cassa /home/odoo/addons/l10n_it_prima_nota_cassa"

#echo "Installazione Odoo 10.0 moduli abstract intrastat codes"
#su - odoo -c "mkdir -p /home/odoo/source/abstract-open-solutions"
#su - odoo -c "git clone -b 10.0-intrastat-codes --single-branch https://github.com/abstract-open-solutions/l10n-italy /home/odoo/source/abstract-open-solutions/l10n-italy-intrastat-codes"
#su - odoo -c "ln -s /home/odoo/source/abstract-open-solutions/l10n-italy-intrastat-codes/l10n_it_intrastat_codes /home/odoo/addons/l10n_it_intrastat_codes"

#echo "Installazione Odoo 10.0 moduli abstract intrastat review"
#su - odoo -c "mkdir -p /home/odoo/source/abstract-open-solutions"
#su - odoo -c "git clone -b 10.0-intrastat-review --single-branch https://github.com/abstract-open-solutions/l10n-italy /home/odoo/source/abstract-open-solutions/l10n-italy-intrastat-review"
#su - odoo -c "ln -s /home/odoo/source/abstract-open-solutions/l10n-italy-intrastat-review/l10n_it_intrastat /home/odoo/addons/l10n_it_intrastat"



#echo "Installazione Odoo 10.0 moduli zeroincombenze l10n-italy-supplemental"
#su - odoo -c "git clone -b 10.0 --single-branch https://github.com/zeroincombenze/l10n-italy-supplemental /home/odoo/source/zeroincombenze/l10n-italy-supplemental"
#su - odoo -c "ln -sfn /home/odoo/source/zeroincombenze/l10n-italy-supplemental/l10n_it_fiscal /home/odoo/addons/l10n_it_fiscal"
#su - odoo -c "ln -sfn /home/odoo/source/zeroincombenze/l10n-italy-supplemental/l10n_it_spesometro /home/odoo/addons/l10n_it_spesometro"
#su - odoo -c "ln -sfn /home/odoo/source/zeroincombenze/l10n-italy-supplemental/tndb /home/odoo/addons/tndb"

echo "Installazione Odoo 11.0 moduli odoo-italy-extra"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/fcoach66/odoo-italy-extra  /home/odoo/source/fcoach66/odoo-italy-extra"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-italy-extra/l10n_it_report_extended /home/odoo/addons/	l10n_it_report_extended"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-italy-extra/l10n_it_aeroo_base /home/odoo/addons/l10n_it_aeroo_base"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-italy-extra/l10n_it_aeroo_invoice /home/odoo/addons/l10n_it_aeroo_invoice"
#su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-italy-extra/l10n_it_aeroo_ddt /home/odoo/addons/l10n_it_aeroo_ddt"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-italy-extra/l10n_it_aeroo_sale /home/odoo/addons/l10n_it_aeroo_sale"
#su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-italy-extra/odoo_fcoach66_fix /home/odoo/addons/odoo_fcoach66_fix"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-italy-extra/sale_additional_text_template /home/odoo/addons/sale_additional_text_template"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-italy-extra/sale_mandatory_fields /home/odoo/addons/sale_mandatory_fields"


su - odoo -c "git clone -b 10.0 --single-branch https://github.com/fcoach66/odoo-dev  /home/odoo/source/fcoach66/odoo-dev"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-dev/todo_app /home/odoo/addons/todo_app"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-dev/todo_user /home/odoo/addons/todo_user"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-dev/todo_ui /home/odoo/addons/todo_ui"


echo "Installazione Odoo 8.0 moduli odoo-usability"
su - odoo -c "git clone -b 10.0-fcoach66 --single-branch https://github.com/fcoach66/odoo-usability  /home/odoo/source/fcoach66/odoo-usability"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/account_bank_statement_import_fr_hsbc_card /home/odoo/addons/account_bank_statement_import_fr_hsbc_card"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/account_bank_statement_import_usability /home/odoo/addons/account_bank_statement_import_usability"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/account_bank_statement_no_reconcile_guess /home/odoo/addons/account_bank_statement_no_reconcile_guess"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/account_credit_control_usability /home/odoo/addons/account_credit_control_usability"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/account_cutoff_accrual_picking_ods /home/odoo/addons/account_cutoff_accrual_picking_ods"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/account_cutoff_prepaid_ods /home/odoo/addons/account_cutoff_prepaid_ods"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/account_direct_debit_autogenerate /home/odoo/addons/account_direct_debit_autogenerate"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/account_hide_analytic_line /home/odoo/addons/account_hide_analytic_line"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/account_invoice_margin /home/odoo/addons/account_invoice_margin"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/account_invoice_margin_report /home/odoo/addons/account_invoice_margin_report"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/account_invoice_partner_bank_usability /home/odoo/addons/account_invoice_partner_bank_usability"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/account_move_line_filter_wizard /home/odoo/addons/account_move_line_filter_wizard"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/account_move_line_start_end_dates_xls /home/odoo/addons/account_move_line_start_end_dates_xls"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/account_no_analytic_tags /home/odoo/addons/account_no_analytic_tags"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/account_usability /home/odoo/addons/account_usability"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/aeroo_report_to_printer /home/odoo/addons/aeroo_report_to_printer"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/attribute_usability /home/odoo/addons/attribute_usability"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/base_company_extension /home/odoo/addons/base_company_extension"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/base_mail_sender_bcc /home/odoo/addons/base_mail_sender_bcc"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/base_other_report_engines /home/odoo/addons/base_other_report_engines"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/base_partner_one2many_phone /home/odoo/addons/base_partner_one2many_phone"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/base_partner_prospect /home/odoo/addons/base_partner_prospect"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/base_partner_ref /home/odoo/addons/base_partner_ref"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/base_usability /home/odoo/addons/base_usability"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/calendar_default_value /home/odoo/addons/calendar_default_value"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/crm_partner_prospect /home/odoo/addons/crm_partner_prospect"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/crm_usability /home/odoo/addons/crm_usability"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/delivery_no_invoice_shipping /home/odoo/addons/delivery_no_invoice_shipping"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/eradicate_quick_create /home/odoo/addons/eradicate_quick_create"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/hr_expense_private_car /home/odoo/addons/hr_expense_private_car"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/hr_expense_usability /home/odoo/addons/hr_expense_usability"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/hr_expense_usability_dp /home/odoo/addons/hr_expense_usability_dp"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/hr_holidays_usability /home/odoo/addons/hr_holidays_usability"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/hr_usability /home/odoo/addons/hr_usability"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/intrastat_product_type /home/odoo/addons/intrastat_product_type"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/l10n_fr_infogreffe_connector /home/odoo/addons/l10n_fr_infogreffe_connector"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/l10n_fr_intrastat_product_ods /home/odoo/addons/l10n_fr_intrastat_product_ods"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/l10n_fr_usability /home/odoo/addons/l10n_fr_usability"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/mail_usability /home/odoo/addons/mail_usability"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/mrp_average_cost /home/odoo/addons/mrp_average_cost"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/mrp_export_field_profile /home/odoo/addons/mrp_export_field_profile"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/mrp_no_product_template_menu /home/odoo/addons/mrp_no_product_template_menu"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/mrp_usability /home/odoo/addons/mrp_usability"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/partner_aged_open_invoices /home/odoo/addons/partner_aged_open_invoices"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/partner_firstname_first /home/odoo/addons/partner_firstname_first"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/partner_market /home/odoo/addons/partner_market"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/partner_products_shortcut /home/odoo/addons/partner_products_shortcut"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/partner_search /home/odoo/addons/partner_search"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/partner_tree_default /home/odoo/addons/partner_tree_default"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/phone_directory_report /home/odoo/addons/phone_directory_report"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/pos_config_single_user /home/odoo/addons/pos_config_single_user"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/pos_journal_sequence /home/odoo/addons/pos_journal_sequence"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/pos_sale_report /home/odoo/addons/pos_sale_report"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/pos_second_ean13 /home/odoo/addons/pos_second_ean13"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/pos_usability /home/odoo/addons/pos_usability"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/procurement_usability /home/odoo/addons/procurement_usability"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/product_category_tax /home/odoo/addons/product_category_tax"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/product_export_field_profile /home/odoo/addons/product_export_field_profile"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/product_manager_group /home/odoo/addons/product_manager_group"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/product_manager_group_stock /home/odoo/addons/product_manager_group_stock"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/product_search_supplier_code /home/odoo/addons/product_search_supplier_code"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/product_usability /home/odoo/addons/product_usability"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/product_variant_csv_import /home/odoo/addons/product_variant_csv_import"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/project_issue_extension /home/odoo/addons/project_issue_extension"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/purchase_auto_invoice_method /home/odoo/addons/purchase_auto_invoice_method"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/purchase_date_planned_update /home/odoo/addons/purchase_date_planned_update"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/purchase_hide_report_print_menu /home/odoo/addons/purchase_hide_report_print_menu"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/purchase_no_analytic_tags /home/odoo/addons/purchase_no_analytic_tags"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/purchase_usability /home/odoo/addons/purchase_usability"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/sale_confirm_wizard /home/odoo/addons/sale_confirm_wizard"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/sale_crm_usability /home/odoo/addons/sale_crm_usability"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/sale_from_private_stock /home/odoo/addons/sale_from_private_stock"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/sale_layout_category_per_order /home/odoo/addons/sale_layout_category_per_order"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/sale_layout_category_product /home/odoo/addons/sale_layout_category_product"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/sale_margin_no_onchange /home/odoo/addons/sale_margin_no_onchange"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/sale_margin_report /home/odoo/addons/sale_margin_report"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/sale_no_analytic_tags /home/odoo/addons/sale_no_analytic_tags"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/sale_no_filter_myorder /home/odoo/addons/sale_no_filter_myorder"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/sale_order_add_bom /home/odoo/addons/sale_order_add_bom"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/sale_partner_prospect /home/odoo/addons/sale_partner_prospect"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/sale_purchase_no_product_template_menu /home/odoo/addons/sale_purchase_no_product_template_menu"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/sale_quotation_title /home/odoo/addons/sale_quotation_title"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/sale_stock_usability /home/odoo/addons/sale_stock_usability"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/sale_usability /home/odoo/addons/sale_usability"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/sale_usability_b2b /home/odoo/addons/sale_usability_b2b"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/stock_account_usability /home/odoo/addons/stock_account_usability"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/stock_inventory_valuation_ods /home/odoo/addons/stock_inventory_valuation_ods"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/stock_my_operations_filter /home/odoo/addons/stock_my_operations_filter"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/stock_picking_type_default_partner /home/odoo/addons/stock_picking_type_default_partner"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/stock_picking_zip /home/odoo/addons/stock_picking_zip"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/stock_transfer_continue_later /home/odoo/addons/stock_transfer_continue_later"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/stock_usability /home/odoo/addons/stock_usability"
su - odoo -c "ln -sfn /home/odoo/source/fcoach66/odoo-usability/web_eradicate_duplicate /home/odoo/addons/web_eradicate_duplicate"

