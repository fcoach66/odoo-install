#!/bin/bash

echo "Aggiornamento Sistema Operativo"
apt-get update -q=2 && apt-get dist-upgrade -y -q=2 && apt-get autoremove -y -q=2

echo "Installazione Database Postgresql"
sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
apt-get update -q=2
apt-get upgrade -y -q=2
apt-get install -y -q=2 postgresql-9.6 pgadmin3

echo "Installazione pacchetti deb"
apt-get install -y python-setuptools sudo mc zip unzip htop ntp ghostscript graphviz antiword libpq-dev poppler-utils build-essential libfreetype6-dev npm build-essential libpq-dev poppler-utils antiword libldap2-dev libsasl2-dev libssl-dev git nginx munin apache2-utils fonts-crosextra-caladea fonts-crosextra-carlito node-less python-dev python3-dev libxml2-dev libxslt1-dev default-jre ure libreoffice-java-common libreoffice-writer vim node-clean-css node-less python3-pip

wget https://downloads.wkhtmltopdf.org/0.12/0.12.1/wkhtmltox-0.12.1_linux-trusty-amd64.deb
gdebi --n wkhtmltox-0.12.1_linux-trusty-amd64.deb

ln -s /usr/local/bin/wkhtmltopdf /usr/bin
ln -s /usr/local/bin/wkhtmltoimage /usr/bin
  
echo "Installazione pacchetti py3o"
pip install py3o.template
pip install py3o.formats
pip install py3o.fusion
pip install service-identity
pip install py3o.renderserver

echo '#!/bin/sh' > /etc/init.d/py3o.renderserver
echo '' >> /etc/init.d/py3o.renderserver
echo '/usr/local/bin/start-py3o-renderserver --java=/usr/lib/jvm/default-java/jre/lib/amd64/server/libjvm.so --ure=/usr/share --office=/usr/lib/libreoffice --driver=juno --sofficeport=8997 &'  >> /etc/init.d/py3o.renderserver
chmod +x /etc/init.d/py3o.renderserver
update-rc.d py3o.renderserver defaults
/etc/init.d/py3o.renderserver

echo '#!/bin/sh' > /etc/init.d/py3o.fusion
echo '' >> /etc/init.d/py3o.fusion
echo '/usr/local/bin/start-py3o-fusion -s localhost &'  >> /etc/init.d/py3o.fusion
chmod +x /etc/init.d/py3o.fusion
update-rc.d py3o.fusion defaults
/etc/init.d/py3o.fusion

echo "Installazione pyxb"
pip3 install pyxb==1.2.5

echo "Installazione codicefiscale"
pip3 install codicefiscale

pip3 install simplejson

echo "Installazione Odoo 11.0"
adduser odoo --system --group --shell /bin/bash --home /opt/odoo
sudo -u postgres createuser -s odoo
sudo -u postgres psql -c "ALTER USER odoo WITH PASSWORD 'odoo';"
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'odoo';"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/OCB.git /opt/odoo/server"
pip install -r /opt/odoo/server/requirements.txt
pip install -r /opt/odoo/source/OCA/reporting-engine/requirements.txt
su - odoo -c "mkdir -p /opt/odoo/addons"
su - odoo -c "mkdir -p /opt/odoo/source/OCA"
su - odoo -c "git clone -b 11.0 https://github.com/OCA/reporting-engine /opt/odoo/source/OCA/reporting-engine"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/reporting-engine/report_fillpdf /opt/odoo/addons/report_fillpdf"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/reporting-engine/report_qweb_parameter /opt/odoo/addons/report_qweb_parameter"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/reporting-engine/report_wkhtmltopdf_param /opt/odoo/addons/report_wkhtmltopdf_param"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/reporting-engine/report_xlsx /opt/odoo/addons/report_xlsx"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/reporting-engine/report_xml /opt/odoo/addons/report_xml"

su - odoo -c "cp /opt/odoo/server/addons/web/static/src/img/favicon.ico /opt/odoo/" 
sed -i "s/'auto_install': True/'auto_install': False/" /opt/odoo/server/addons/im_odoo_support/__openerp__.py
sudo chown -R odoo:odoo /opt/odoo/server
sudo chown -R odoo:odoo /opt/odoo
mkdir /var/log/odoo
chown odoo:odoo /var/log/odoo
wget https://raw.githubusercontent.com/fcoach66/odoo-install/master/logrotate -O /etc/logrotate.d/odoo-server
chmod 755 /etc/logrotate.d/odoo-server
wget https://raw.githubusercontent.com/fcoach66/odoo-install/master/odoo10.init.d -O /etc/init.d/odoo-server
sudo chmod +x /etc/init.d/odoo-server
sudo update-rc.d odoo-server defaults
pip install geojson
pip install queue_job

su - odoo -c "/opt/odoo/server/odoo-bin --stop-after-init -s -c /opt/odoo/odoo.conf --db_host=localhost --db_user=odoo --db_password=False --workers=9 --addons-path=/opt/odoo/server/odoo/addons,/opt/odoo/server/addons,/opt/odoo/addons --logfile=/var/log/odoo/odoo-server.log"
mv /opt/odoo/odoo.conf /etc/odoo-server.conf
chown odoo:odoo /etc/odoo-server.conf
sed -i "s/db_password = False/db_password = odoo/g" /etc/odoo-server.conf
wget https://raw.githubusercontent.com/fcoach66/odoo-install/master/odoo.nginx -O /etc/nginx/sites-available/odoo.nginx
rm /etc/nginx/sites-enabled/default 
ln -s /etc/nginx/sites-available/odoo.nginx /etc/nginx/sites-enabled/odoo.nginx
# old1="xmlrpc_interface = "
# new1="xmlrpc_interface = 127.0.0.1"
# old2="netrpc_interface = "
# new2="netrpc_interface = 127.0.0.1"
# sed -i "s/$old1/$new1/g" /etc/odoo-server.conf
# sed -i "s/$old2/$new2/g" /etc/odoo-server.conf
mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.old
wget https://raw.githubusercontent.com/fcoach66/odoo-install/master/nginx.conf -O /etc/nginx/nginx.conf
htpasswd -cb /etc/nginx/htpasswd odoo odoo

echo "Installazione Odoo 11.0 moduli server-tools"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/server-tools  /opt/odoo/source/OCA/server-tools"
pip3 install -r /opt/odoo/source/OCA/server-tools/requirements.txt
su - odoo -c "ln -sfn /opt/odoo/source/OCA/server-tools/auditlog /opt/odoo/addons/auditlog"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/server-tools/auto_backup /opt/odoo/addons/auto_backup"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/server-tools/base_cron_exclusion /opt/odoo/addons/base_cron_exclusion"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/server-tools/base_exception /opt/odoo/addons/base_exception"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/server-tools/base_remote /opt/odoo/addons/base_remote"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/server-tools/base_search_fuzzy /opt/odoo/addons/base_search_fuzzy"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/server-tools/base_technical_user /opt/odoo/addons/base_technical_user"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/server-tools/database_cleanup /opt/odoo/addons/database_cleanup"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/server-tools/datetime_formatter /opt/odoo/addons/datetime_formatter"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/server-tools/dbfilter_from_header /opt/odoo/addons/dbfilter_from_header"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/server-tools/fetchmail_notify_error_to_sender /opt/odoo/addons/fetchmail_notify_error_to_sender"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/server-tools/html_image_url_extractor /opt/odoo/addons/html_image_url_extractor"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/server-tools/html_text /opt/odoo/addons/html_text"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/server-tools/letsencrypt /opt/odoo/addons/letsencrypt"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/server-tools/module_auto_update /opt/odoo/addons/module_auto_update"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/server-tools/onchange_helper /opt/odoo/addons/onchange_helper"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/server-tools/sentry /opt/odoo/addons/sentry"


su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/server-tools  /opt/odoo/source/OCA/10.0-server-tools"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/10.0-server-tools/date_range /opt/odoo/addons/date_range"


pip3 install pyxb==1.2.5
pip3 install codicefiscale

echo "Installazione Odoo 10.0 moduli server-ux"
su - odoo -c "mkdir -p /opt/odoo/source/OCA"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/server-ux  /opt/odoo/source/OCA/server-ux"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/server-ux/base_optional_quick_create /opt/odoo/addons/base_optional_quick_create"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/server-ux/base_technical_features /opt/odoo/addons/base_technical_features"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/server-ux/base_tier_validation /opt/odoo/addons/base_tier_validation"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/server-ux/date_range /opt/odoo/addons/date_range"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/server-ux/easy_switch_user /opt/odoo/addons/easy_switch_user"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/server-ux/LICENSE /opt/odoo/addons/LICENSE"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/server-ux/mass_editing /opt/odoo/addons/mass_editing"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/server-ux/README.md /opt/odoo/addons/README.md"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/server-ux/sequence_check_digit /opt/odoo/addons/sequence_check_digit"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/server-ux/sequence_reset_period /opt/odoo/addons/sequence_reset_period"




echo "Installazione Odoo 10.0 moduli l10n-italy"
su - odoo -c "mkdir -p /opt/odoo/source/OCA"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/l10n-italy  /opt/odoo/source/OCA/l10n-italy"

#su - odoo -c "ln -sfn /opt/odoo/source/OCA/l10n-italy/account_central_journal /opt/odoo/addons/account_central_journal"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/l10n-italy/account_invoice_entry_date /opt/odoo/addons/account_invoice_entry_date"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/l10n-italy/account_invoice_report_ddt_group /opt/odoo/addons/account_invoice_report_ddt_group"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/l10n-italy/account_invoice_sequential_dates /opt/odoo/addons/account_invoice_sequential_dates"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/l10n-italy/account_vat_period_end_statement /opt/odoo/addons/account_vat_period_end_statement"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/l10n-italy/l10n_it_abicab /opt/odoo/addons/l10n_it_abicab"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/l10n-italy/l10n_it_account /opt/odoo/addons/l10n_it_account"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/l10n-italy/l10n_it_account_tax_kind /opt/odoo/addons/l10n_it_account_tax_kind"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/l10n-italy/l10n_it_ateco /opt/odoo/addons/l10n_it_ateco"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/l10n-italy/l10n_it_base_crm /opt/odoo/addons/l10n_it_base_crm"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/l10n-italy/l10n_it_base_location_geonames_import /opt/odoo/addons/l10n_it_base_location_geonames_import"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/l10n-italy/l10n_it_bill_of_entry /opt/odoo/addons/l10n_it_bill_of_entry"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/l10n-italy/l10n_it_CEE_balance_generic /opt/odoo/addons/l10n_it_CEE_balance_generic"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/l10n-italy/l10n_it_central_journal /opt/odoo/addons/l10n_it_central_journal"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/l10n-italy/l10n_it_codici_carica /opt/odoo/addons/l10n_it_codici_carica"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/l10n-italy/l10n_it_corrispettivi /opt/odoo/addons/l10n_it_corrispettivi"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/l10n-italy/l10n_it_corrispettivi_sale /opt/odoo/addons/l10n_it_corrispettivi_sale"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/l10n-italy/l10n_it_ddt /opt/odoo/addons/l10n_it_ddt"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/l10n-italy/l10n_it_esigibilita_iva /opt/odoo/addons/l10n_it_esigibilita_iva"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/l10n-italy/l10n_it_fatturapa /opt/odoo/addons/l10n_it_fatturapa"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/l10n-italy/l10n_it_fatturapa_out /opt/odoo/addons/l10n_it_fatturapa_out"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/l10n-italy/l10n_it_fiscalcode /opt/odoo/addons/l10n_it_fiscalcode"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/l10n-italy/l10n_it_fiscalcode_invoice /opt/odoo/addons/l10n_it_fiscalcode_invoice"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/l10n-italy/l10n_it_fiscal_document_type /opt/odoo/addons/l10n_it_fiscal_document_type"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/l10n-italy/l10n_it_ipa /opt/odoo/addons/l10n_it_ipa"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/l10n-italy/l10n_it_partially_deductible_vat /opt/odoo/addons/l10n_it_partially_deductible_vat"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/l10n-italy/l10n_it_pec /opt/odoo/addons/l10n_it_pec"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/l10n-italy/l10n_it_prima_nota_cassa /opt/odoo/addons/l10n_it_prima_nota_cassa"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/l10n-italy/l10n_it_rea /opt/odoo/addons/l10n_it_rea"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/l10n-italy/l10n_it_reverse_charge /opt/odoo/addons/l10n_it_reverse_charge"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/l10n-italy/l10n_it_riba_commission /opt/odoo/addons/l10n_it_riba_commission"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/l10n-italy/l10n_it_ricevute_bancarie /opt/odoo/addons/l10n_it_ricevute_bancarie"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/l10n-italy/l10n_it_split_payment /opt/odoo/addons/l10n_it_split_payment"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/l10n-italy/l10n_it_vat_registries /opt/odoo/addons/l10n_it_vat_registries"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/l10n-italy/l10n_it_vat_registries_cash_basis /opt/odoo/addons/l10n_it_vat_registries_cash_basis"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/l10n-italy/l10n_it_website_sale_corrispettivi /opt/odoo/addons/l10n_it_website_sale_corrispettivi"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/l10n-italy/l10n_it_website_sale_fiscalcode /opt/odoo/addons/l10n_it_website_sale_fiscalcode"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/l10n-italy/l10n_it_withholding_tax /opt/odoo/addons/l10n_it_withholding_tax"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/l10n-italy/l10n_it_withholding_tax_payment /opt/odoo/addons/l10n_it_withholding_tax_payment"

#su - odoo -c "git clone -b 10.0-mig-fatturapa https://github.com/eLBati/l10n-italy /opt/odoo/source/eLBati/l10n-italy-10.0-mig-fatturapa"
#su - odoo -c "ln -sfn /opt/odoo/source/eLBati/l10n-italy-10.0-mig-fatturapa/l10n_it_fatturapa /opt/odoo/addons/l10n_it_fatturapa"
#su - odoo -c "ln -sfn /opt/odoo/source/eLBati/l10n-italy-10.0-mig-fatturapa/l10n_it_fatturapa_out /opt/odoo/addons/l10n_it_fatturapa_out"
#su - odoo -c "ln -sfn /opt/odoo/source/eLBati/l10n-italy-10.0-mig-fatturapa/l10n_it_fiscalcode /opt/odoo/addons/l10n_it_fiscalcode"
#su - odoo -c "ln -sfn /opt/odoo/source/eLBati/l10n-italy-10.0-mig-fatturapa/l10n_it_ipa /opt/odoo/addons/l10n_it_ipa"
#su - odoo -c "ln -sfn /opt/odoo/source/eLBati/l10n-italy-10.0-mig-fatturapa/l10n_it_rea /opt/odoo/addons/l10n_it_rea"
#su - odoo -c "ln -sfn /opt/odoo/source/eLBati/l10n-italy-10.0-mig-fatturapa/l10n_it_split_payment /opt/odoo/addons/l10n_it_split_payment"

#su - odoo -c "git clone -b 10.0-mig-withholding_tax https://github.com/alessandrocamilli/l10n-italy /opt/odoo/source/alessandrocamilli/l10n-italy-10.0-mig-withholding_tax"
#su - odoo -c "ln -sfn /opt/odoo/source/alessandrocamilli/l10n-italy-10.0-mig-withholding_tax/l10n_it_withholding_tax /opt/odoo/addons/l10n_it_withholding_tax"
#su - odoo -c "ln -sfn /opt/odoo/source/alessandrocamilli/l10n-italy-10.0-mig-withholding_tax/l10n_it_withholding_tax_payment /opt/odoo/addons/l10n_it_withholding_tax_payment"

#su - odoo -c "git clone -b 10.0-l10n_it_ddt-fix https://github.com/As400it/l10n-italy /opt/odoo/source/As400it/l10n-italy-10.0-l10n_it_ddt-fix"
#su - odoo -c "ln -sfn /opt/odoo/source/As400it/l10n-italy-10.0-l10n_it_ddt-fix/l10n_it_ddt /opt/odoo/addons/l10n_it_ddt"

#su - odoo -c "git clone -b 10-l10n_it_reverse_charge https://github.com/abstract-open-solutions/l10n-italy /opt/odoo/source/abstract-open-solutions/l10n-italy-10-l10n_it_reverse_charge"
#su - odoo -c "ln -sfn /opt/odoo/source/abstract-open-solutions/l10n-italy-10-l10n_it_reverse_charge/l10n_it_reverse_charge /opt/odoo/addons/l10n_it_reverse_charge"

#su - odoo -c "git clone -b 10.0-mig-account_vat_period_end_statement https://github.com/eLBati/l10n-italy /opt/odoo/source/eLBati/10.0-mig-account_vat_period_end_statement-l10n-italy"
#su - odoo -c "ln -sfn /opt/odoo/source/eLBati/10.0-mig-account_vat_period_end_statement-l10n-italy/account_vat_period_end_statement /opt/odoo/addons/account_vat_period_end_statement"

su - odoo -c "git clone -b 11.0-mig-fatturapa --single-branch https://github.com/fcoach66/l10n-italy  /opt/odoo/source/fcoach66/11.0-mig-fatturapa-l10n-italy"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/11.0-mig-fatturapa-l10n-italy/l10n_it_fatturapa /opt/odoo/addons/l10n_it_fatturapa"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/11.0-mig-fatturapa-l10n-italy/l10n_it_fatturapa_out /opt/odoo/addons/l10n_it_fatturapa_out"


su - odoo -c "git clone -b 11.0-mig-l10n_it_split_payment --single-branch https://github.com/jackjack82/l10n-italy /opt/odoo/source/jackjack82/11.0-mig-l10n_it_split_payment"
su - odoo -c "ln -sfn /opt/odoo/source/jackjack82/11.0-mig-l10n_it_split_payment/l10n_it_split_payment /opt/odoo/addons/l10n_it_split_payment"

su - odoo -c "git clone -b 11.0-mig-l10n_it_reverse_charge --single-branch https://github.com/jackjack82/l10n-italy /opt/odoo/source/jackjack82/11.0-mig-l10n_it_reverse_charge"
su - odoo -c "ln -sfn /opt/odoo/source/jackjack82/11.0-mig-l10n_it_reverse_charge/l10n_it_reverse_charge /opt/odoo/addons/l10n_it_reverse_charge"

su - odoo -c "git clone -b 11.0-mig-l10n_it_withholding_tax --single-branch https://github.com/alessandrocamilli/l10n-italy /opt/odoo/source/alessandrocamilli/11.0-mig-l10n_it_withholding_tax"
su - odoo -c "ln -sfn /opt/odoo/source/alessandrocamilli/11.0-mig-l10n_it_withholding_tax/l10n_it_withholding_tax /opt/odoo/addons/l10n_it_withholding_tax"
su - odoo -c "ln -sfn /opt/odoo/source/alessandrocamilli/11.0-mig-l10n_it_withholding_tax/l10n_it_withholding_tax_payment /opt/odoo/addons/l10n_it_withholding_tax_payment"

su - odoo -c "git clone -b 11.0-mig-l10n_it_ddt --single-branch https://github.com/SilvioGregorini/l10n-italy /opt/odoo/source/SilvioGregorini/11.0-mig-l10n_it_ddt"
su - odoo -c "ln -sfn /opt/odoo/source/SilvioGregorini/11.0-mig-l10n_it_ddt/l10n_it_ddt /opt/odoo/addons/l10n_it_ddt"

su - odoo -c "git clone -b 11.0-mig-account_vat_period_end_statement --single-branch https://github.com/jackjack82/l10n-italy /opt/odoo/source/jackjack82/11.0-mig-account_vat_period_end_statement"
su - odoo -c "ln -sfn /opt/odoo/source/jackjack82/11.0-mig-account_vat_period_end_statement/account_vat_period_end_statement /opt/odoo/addons/account_vat_period_end_statement"

su - odoo -c "git clone -b 11.0-mig-l10n_it_ricevute_bancarie --single-branch https://github.com/jackjack82/l10n-italy /opt/odoo/source/jackjack82/11.0-mig-l10n_it_ricevute_bancarie"
su - odoo -c "ln -sfn /opt/odoo/source/jackjack82/11.0-mig-l10n_it_ricevute_bancarie/l10n_it_ricevute_bancarie /opt/odoo/addons/l10n_it_ricevute_bancarie"







echo "Installazione Odoo 8.0 moduli partner-contact"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/partner-contact  /opt/odoo/source/OCA/partner-contact"
pip install -r /opt/odoo/source/OCA/partner-contact/requirements.txt 
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/account_partner_merge /opt/odoo/addons/account_partner_merge"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/base_continent /opt/odoo/addons/base_continent"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/base_country_state_translatable /opt/odoo/addons/base_country_state_translatable"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/base_location /opt/odoo/addons/base_location"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/base_location_geonames_import /opt/odoo/addons/base_location_geonames_import"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/base_location_nuts /opt/odoo/addons/base_location_nuts"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/base_partner_merge /opt/odoo/addons/base_partner_merge"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/base_partner_sequence /opt/odoo/addons/base_partner_sequence"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/base_vat_sanitized /opt/odoo/addons/base_vat_sanitized"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/firstname_display_name_trigger /opt/odoo/addons/firstname_display_name_trigger"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/partner_academic_title /opt/odoo/addons/partner_academic_title"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/partner_address_street3 /opt/odoo/addons/partner_address_street3"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/partner_affiliate /opt/odoo/addons/partner_affiliate"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/partner_alias /opt/odoo/addons/partner_alias"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/partner_auto_salesman /opt/odoo/addons/partner_auto_salesman"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/partner_bank_active /opt/odoo/addons/partner_bank_active"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/partner_capital /opt/odoo/addons/partner_capital"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/partner_changeset /opt/odoo/addons/partner_changeset"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/partner_coc /opt/odoo/addons/partner_coc"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/partner_company_type /opt/odoo/addons/partner_company_type"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/partner_contact_address_detailed /opt/odoo/addons/partner_contact_address_detailed"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/partner_contact_birthdate /opt/odoo/addons/partner_contact_birthdate"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/partner_contact_birthplace /opt/odoo/addons/partner_contact_birthplace"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/partner_contact_configuration /opt/odoo/addons/partner_contact_configuration"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/partner_contact_department /opt/odoo/addons/partner_contact_department"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/partner_contact_gender /opt/odoo/addons/partner_contact_gender"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/partner_contact_in_several_companies /opt/odoo/addons/partner_contact_in_several_companies"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/partner_contact_job_position /opt/odoo/addons/partner_contact_job_position"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/partner_contact_lang /opt/odoo/addons/partner_contact_lang"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/partner_contact_nationality /opt/odoo/addons/partner_contact_nationality"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/partner_contact_nutrition /opt/odoo/addons/partner_contact_nutrition"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/partner_contact_nutrition_activity_level /opt/odoo/addons/partner_contact_nutrition_activity_level"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/partner_contact_nutrition_goal /opt/odoo/addons/partner_contact_nutrition_goal"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/partner_contact_personal_information_page /opt/odoo/addons/partner_contact_personal_information_page"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/partner_contact_role /opt/odoo/addons/partner_contact_role"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/partner_contact_weight /opt/odoo/addons/partner_contact_weight"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/partner_create_by_vat /opt/odoo/addons/partner_create_by_vat"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/partner_disable_gravatar /opt/odoo/addons/partner_disable_gravatar"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/partner_email_check /opt/odoo/addons/partner_email_check"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/partner_employee_quantity /opt/odoo/addons/partner_employee_quantity"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/partner_external_map /opt/odoo/addons/partner_external_map"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/partner_fax /opt/odoo/addons/partner_fax"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/partner_financial_risk /opt/odoo/addons/partner_financial_risk"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/partner_firstname /opt/odoo/addons/partner_firstname"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/partner_helper /opt/odoo/addons/partner_helper"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/partner_identification /opt/odoo/addons/partner_identification"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/partner_label /opt/odoo/addons/partner_label"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/partner_multi_relation /opt/odoo/addons/partner_multi_relation"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/partner_password_reset /opt/odoo/addons/partner_password_reset"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/partner_phonecall_schedule /opt/odoo/addons/partner_phonecall_schedule"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/partner_phone_extension /opt/odoo/addons/partner_phone_extension"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/partner_risk_insurance /opt/odoo/addons/partner_risk_insurance"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/partner_sale_risk /opt/odoo/addons/partner_sale_risk"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/partner_second_lastname /opt/odoo/addons/partner_second_lastname"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/partner_sector /opt/odoo/addons/partner_sector"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/partner_stock_risk /opt/odoo/addons/partner_stock_risk"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/partner_street_number /opt/odoo/addons/partner_street_number"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/partner_vat_unique /opt/odoo/addons/partner_vat_unique"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/partner-contact/portal_partner_merge /opt/odoo/addons/portal_partner_merge"


echo "Installazione Odoo 8.0 moduli account-payment"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/account-payment  /opt/odoo/source/OCA/account-payment"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-payment/account_cash_invoice /opt/odoo/addons/account_cash_invoice"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-payment/account_check_printing_report_base /opt/odoo/addons/account_check_printing_report_base"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-payment/account_check_printing_report_dlt103 /opt/odoo/addons/account_check_printing_report_dlt103"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-payment/account_due_list /opt/odoo/addons/account_due_list"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-payment/account_due_list_aging_comments /opt/odoo/addons/account_due_list_aging_comments"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-payment/account_due_list_days_overdue /opt/odoo/addons/account_due_list_days_overdue"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-payment/account_due_list_payment_mode /opt/odoo/addons/account_due_list_payment_mode"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-payment/account_early_payment_discount /opt/odoo/addons/account_early_payment_discount"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-payment/account_partner_reconcile /opt/odoo/addons/account_partner_reconcile"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-payment/account_payment_batch_process /opt/odoo/addons/account_payment_batch_process"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-payment/account_payment_credit_card /opt/odoo/addons/account_payment_credit_card"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-payment/account_payment_return /opt/odoo/addons/account_payment_return"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-payment/account_payment_return_import /opt/odoo/addons/account_payment_return_import"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-payment/account_payment_return_import_sepa_pain /opt/odoo/addons/account_payment_return_import_sepa_pain"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-payment/account_payment_show_invoice /opt/odoo/addons/account_payment_show_invoice"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-payment/account_vat_on_payment /opt/odoo/addons/account_vat_on_payment"


echo "Installazione Odoo 8.0 moduli bank-payment"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/bank-payment  /opt/odoo/source/OCA/bank-payment"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/bank-payment/account_banking_mandate /opt/odoo/addons/account_banking_mandate"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/bank-payment/account_banking_mandate_sale /opt/odoo/addons/account_banking_mandate_sale"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/bank-payment/account_banking_pain_base /opt/odoo/addons/account_banking_pain_base"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/bank-payment/account_banking_sepa_credit_transfer /opt/odoo/addons/account_banking_sepa_credit_transfer"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/bank-payment/account_banking_sepa_direct_debit /opt/odoo/addons/account_banking_sepa_direct_debit"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/bank-payment/account_banking_tests /opt/odoo/addons/account_banking_tests"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/bank-payment/account_import_line_multicurrency_extension /opt/odoo/addons/account_import_line_multicurrency_extension"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/bank-payment/account_payment_blocking /opt/odoo/addons/account_payment_blocking"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/bank-payment/account_payment_line_cancel /opt/odoo/addons/account_payment_line_cancel"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/bank-payment/account_payment_mode /opt/odoo/addons/account_payment_mode"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/bank-payment/account_payment_mode_term /opt/odoo/addons/account_payment_mode_term"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/bank-payment/account_payment_order /opt/odoo/addons/account_payment_order"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/bank-payment/account_payment_partner /opt/odoo/addons/account_payment_partner"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/bank-payment/account_payment_sale /opt/odoo/addons/account_payment_sale"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/bank-payment/account_voucher_killer /opt/odoo/addons/account_voucher_killer"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/bank-payment/bank_statement_instant_voucher /opt/odoo/addons/bank_statement_instant_voucher"


echo "Installazione Odoo 8.0 moduli stock-logistics-workflow"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/stock-logistics-workflow  /opt/odoo/source/OCA/stock-logistics-workflow"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/stock-logistics-workflow/mrp_stock_picking_restrict_cancel /opt/odoo/addons/mrp_stock_picking_restrict_cancel"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/stock-logistics-workflow/purchase_stock_picking_restrict_cancel /opt/odoo/addons/purchase_stock_picking_restrict_cancel"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/stock-logistics-workflow/stock_no_negative /opt/odoo/addons/stock_no_negative"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/stock-logistics-workflow/stock_pack_operation_auto_fill /opt/odoo/addons/stock_pack_operation_auto_fill"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/stock-logistics-workflow/stock_picking_customer_ref /opt/odoo/addons/stock_picking_customer_ref"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/stock-logistics-workflow/stock_picking_invoice_link /opt/odoo/addons/stock_picking_invoice_link"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/stock-logistics-workflow/stock_picking_purchase_propagate /opt/odoo/addons/stock_picking_purchase_propagate"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/stock-logistics-workflow/stock_picking_restrict_cancel_with_orig_move /opt/odoo/addons/stock_picking_restrict_cancel_with_orig_move"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/stock-logistics-workflow/stock_picking_show_backorder /opt/odoo/addons/stock_picking_show_backorder"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/stock-logistics-workflow/stock_picking_show_return /opt/odoo/addons/stock_picking_show_return"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/stock-logistics-workflow/stock_split_picking /opt/odoo/addons/stock_split_picking"

su - odoo -c "git clone -b 11.0-mig-stock_picking_package_preparation --single-branch https://github.com/dcorio/stock-logistics-workflow  /opt/odoo/source/dcorio/11.0-mig-stock_picking_package_preparation"
su - odoo -c "ln -sfn /opt/odoo/source/dcorio/11.0-mig-stock_picking_package_preparation/stock_picking_package_preparation /opt/odoo/addons/stock_picking_package_preparation"
su - odoo -c "ln -sfn /opt/odoo/source/dcorio/11.0-mig-stock_picking_package_preparation/stock_picking_package_preparation_line /opt/odoo/addons/stock_picking_package_preparation_line"


echo "Installazione Odoo 8.0 moduli product-attribute"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/product-attribute  /opt/odoo/source/OCA/product-attribute"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/product-attribute/product_brand /opt/odoo/addons/product_brand"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/product-attribute/product_code_mandatory /opt/odoo/addons/product_code_mandatory"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/product-attribute/product_code_unique /opt/odoo/addons/product_code_unique"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/product-attribute/product_end_of_life /opt/odoo/addons/product_end_of_life"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/product-attribute/product_firmware_version /opt/odoo/addons/product_firmware_version"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/product-attribute/product_manufacturer /opt/odoo/addons/product_manufacturer"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/product-attribute/product_multi_category /opt/odoo/addons/product_multi_category"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/product-attribute/product_priority /opt/odoo/addons/product_priority"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/product-attribute/product_sequence /opt/odoo/addons/product_sequence"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/product-attribute/product_state /opt/odoo/addons/product_state"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/product-attribute/product_supplierinfo_revision /opt/odoo/addons/product_supplierinfo_revision"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/product-attribute/stock_production_lot_firmware_version /opt/odoo/addons/stock_production_lot_firmware_version"


echo "Installazione Odoo 8.0 moduli stock-logistics-warehouse"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/stock-logistics-warehouse  /opt/odoo/source/OCA/stock-logistics-warehouse"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/stock-logistics-warehouse/stock_available /opt/odoo/addons/stock_available"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/stock-logistics-warehouse/stock_available_global /opt/odoo/addons/stock_available_global"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/stock-logistics-warehouse/stock_available_unreserved /opt/odoo/addons/stock_available_unreserved"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/stock-logistics-warehouse/stock_demand_estimate /opt/odoo/addons/stock_demand_estimate"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/stock-logistics-warehouse/stock_inventory_chatter /opt/odoo/addons/stock_inventory_chatter"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/stock-logistics-warehouse/stock_inventory_discrepancy /opt/odoo/addons/stock_inventory_discrepancy"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/stock-logistics-warehouse/stock_mts_mto_rule /opt/odoo/addons/stock_mts_mto_rule"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/stock-logistics-warehouse/stock_orderpoint_manual_procurement /opt/odoo/addons/stock_orderpoint_manual_procurement"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/stock-logistics-warehouse/stock_orderpoint_manual_procurement_uom /opt/odoo/addons/stock_orderpoint_manual_procurement_uom"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/stock-logistics-warehouse/stock_orderpoint_move_link /opt/odoo/addons/stock_orderpoint_move_link"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/stock-logistics-warehouse/stock_orderpoint_purchase_link /opt/odoo/addons/stock_orderpoint_purchase_link"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/stock-logistics-warehouse/stock_orderpoint_uom /opt/odoo/addons/stock_orderpoint_uom"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/stock-logistics-warehouse/stock_putaway_method /opt/odoo/addons/stock_putaway_method"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/stock-logistics-warehouse/stock_putaway_product /opt/odoo/addons/stock_putaway_product"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/stock-logistics-warehouse/stock_putaway_same_location /opt/odoo/addons/stock_putaway_same_location"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/stock-logistics-warehouse/stock_request /opt/odoo/addons/stock_request"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/stock-logistics-warehouse/stock_request_kanban /opt/odoo/addons/stock_request_kanban"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/stock-logistics-warehouse/stock_request_purchase /opt/odoo/addons/stock_request_purchase"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/stock-logistics-warehouse/stock_warehouse_calendar /opt/odoo/addons/stock_warehouse_calendar"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/stock-logistics-warehouse/stock_warehouse_orderpoint_stock_info /opt/odoo/addons/stock_warehouse_orderpoint_stock_info"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/stock-logistics-warehouse/stock_warehouse_orderpoint_stock_info_unreserved /opt/odoo/addons/stock_warehouse_orderpoint_stock_info_unreserved"


echo "Installazione Odoo 8.0 moduli stock-logistics-tracking"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/stock-logistics-tracking  /opt/odoo/source/OCA/stock-logistics-tracking"


echo "Installazione Odoo 8.0 moduli stock-logistics-barcode"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/stock-logistics-barcode  /opt/odoo/source/OCA/stock-logistics-barcode"
pip3 install -r /opt/odoo/source/OCA/stock-logistics-barcode/requirements.txt
su - odoo -c "ln -sfn /opt/odoo/source/OCA/stock-logistics-barcode/product_multi_ean /opt/odoo/addons/product_multi_ean"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/stock-logistics-barcode/stock_scanner /opt/odoo/addons/stock_scanner"


echo "Installazione Odoo 8.0 moduli web"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/web  /opt/odoo/source/OCA/web"
pip3 install -r /opt/odoo/source/OCA/web/requirements.txt
su - odoo -c "ln -sfn /opt/odoo/source/OCA/web/web_action_conditionable /opt/odoo/addons/web_action_conditionable"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/web/web_decimal_numpad_dot /opt/odoo/addons/web_decimal_numpad_dot"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/web/web_dialog_size /opt/odoo/addons/web_dialog_size"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/web/web_disable_export_group /opt/odoo/addons/web_disable_export_group"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/web/web_environment_ribbon /opt/odoo/addons/web_environment_ribbon"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/web/web_favicon /opt/odoo/addons/web_favicon"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/web/web_group_expand /opt/odoo/addons/web_group_expand"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/web/web_ir_actions_act_multi /opt/odoo/addons/web_ir_actions_act_multi"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/web/web_ir_actions_act_view_reload /opt/odoo/addons/web_ir_actions_act_view_reload"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/web/web_listview_range_select /opt/odoo/addons/web_listview_range_select"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/web/web_m2x_options /opt/odoo/addons/web_m2x_options"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/web/web_no_bubble /opt/odoo/addons/web_no_bubble"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/web/web_notify /opt/odoo/addons/web_notify"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/web/web_responsive /opt/odoo/addons/web_responsive"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/web/web_searchbar_full_width /opt/odoo/addons/web_searchbar_full_width"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/web/web_search_with_and /opt/odoo/addons/web_search_with_and"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/web/web_sheet_full_width /opt/odoo/addons/web_sheet_full_width"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/web/web_timeline /opt/odoo/addons/web_timeline"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/web/web_tree_dynamic_colored_field /opt/odoo/addons/web_tree_dynamic_colored_field"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/web/web_tree_many2one_clickable /opt/odoo/addons/web_tree_many2one_clickable"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/web/web_widget_bokeh_chart /opt/odoo/addons/web_widget_bokeh_chart"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/web/web_widget_color /opt/odoo/addons/web_widget_color"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/web/web_widget_datepicker_options /opt/odoo/addons/web_widget_datepicker_options"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/web/web_widget_image_download /opt/odoo/addons/web_widget_image_download"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/web/web_widget_image_url /opt/odoo/addons/web_widget_image_url"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/web/web_widget_many2many_tags_multi_selection /opt/odoo/addons/web_widget_many2many_tags_multi_selection"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/web/web_widget_x2many_2d_matrix /opt/odoo/addons/web_widget_x2many_2d_matrix"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/web/web_widget_x2many_2d_matrix_example /opt/odoo/addons/web_widget_x2many_2d_matrix_example"


echo "Installazione Odoo 8.0 moduli sale-workflow"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/sale-workflow  /opt/odoo/source/OCA/sale-workflow"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/sale-workflow/partner_prospect /opt/odoo/addons/partner_prospect"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/sale-workflow/sale_automatic_workflow /opt/odoo/addons/sale_automatic_workflow"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/sale-workflow/sale_automatic_workflow_payment_mode /opt/odoo/addons/sale_automatic_workflow_payment_mode"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/sale-workflow/sale_commercial_partner /opt/odoo/addons/sale_commercial_partner"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/sale-workflow/sale_exception /opt/odoo/addons/sale_exception"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/sale-workflow/sale_invoice_group_method /opt/odoo/addons/sale_invoice_group_method"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/sale-workflow/sale_merge_draft_invoice /opt/odoo/addons/sale_merge_draft_invoice"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/sale-workflow/sale_order_action_invoice_create_hook /opt/odoo/addons/sale_order_action_invoice_create_hook"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/sale-workflow/sale_order_invoicing_finished_task /opt/odoo/addons/sale_order_invoicing_finished_task"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/sale-workflow/sale_order_line_date /opt/odoo/addons/sale_order_line_date"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/sale-workflow/sale_order_line_input /opt/odoo/addons/sale_order_line_input"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/sale-workflow/sale_order_price_recalculation /opt/odoo/addons/sale_order_price_recalculation"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/sale-workflow/sale_order_type /opt/odoo/addons/sale_order_type"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/sale-workflow/sale_product_set /opt/odoo/addons/sale_product_set"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/sale-workflow/sale_product_set_variant /opt/odoo/addons/sale_product_set_variant"


echo "Installazione Odoo 8.0 moduli stock-logistics-transport"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/stock-logistics-transport  /opt/odoo/source/OCA/stock-logistics-transport"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/stock-logistics-transport/stock_location_address /opt/odoo/addons/stock_location_address"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/stock-logistics-transport/stock_location_address_purchase /opt/odoo/addons/stock_location_address_purchase"


echo "Installazione Odoo 8.0 moduli account-financial-reporting"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/account-financial-reporting  /opt/odoo/source/OCA/account-financial-reporting"
pip3 install -r /opt/odoo/source/OCA/account-financial-reporting/requirements.txt
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-financial-reporting/account_chart_report /opt/odoo/addons/account_chart_report"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-financial-reporting/account_export_csv /opt/odoo/addons/account_export_csv"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-financial-reporting/account_financial_report /opt/odoo/addons/account_financial_report"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-financial-reporting/account_financial_report_horizontal /opt/odoo/addons/account_financial_report_horizontal"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-financial-reporting/account_financial_report_qweb /opt/odoo/addons/account_financial_report_qweb"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-financial-reporting/account_journal_report_xls /opt/odoo/addons/account_journal_report_xls"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-financial-reporting/account_move_line_report_xls /opt/odoo/addons/account_move_line_report_xls"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-financial-reporting/account_tax_balance /opt/odoo/addons/account_tax_balance"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-financial-reporting/mis_builder /opt/odoo/addons/mis_builder"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-financial-reporting/mis_builder_demo /opt/odoo/addons/mis_builder_demo"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-financial-reporting/customer_activity_statement /opt/odoo/addons/customer_activity_statement"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-financial-reporting/customer_outstanding_statement /opt/odoo/addons/customer_outstanding_statement"

echo "Installazione Odoo 8.0 moduli account-financial-tools"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/account-financial-tools  /opt/odoo/source/OCA/account-financial-tools"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-financial-tools/account_balance_line /opt/odoo/addons/account_balance_line"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-financial-tools/account_credit_control /opt/odoo/addons/account_credit_control"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-financial-tools/account_credit_control_dunning_fees /opt/odoo/addons/account_credit_control_dunning_fees"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-financial-tools/account_fiscal_year /opt/odoo/addons/account_fiscal_year"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-financial-tools/account_group_menu /opt/odoo/addons/account_group_menu"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-financial-tools/account_invoice_constraint_chronology /opt/odoo/addons/account_invoice_constraint_chronology"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-financial-tools/account_invoice_currency /opt/odoo/addons/account_invoice_currency"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-financial-tools/account_loan /opt/odoo/addons/account_loan"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-financial-tools/account_move_fiscal_year /opt/odoo/addons/account_move_fiscal_year"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-financial-tools/account_move_line_purchase_info /opt/odoo/addons/account_move_line_purchase_info"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-financial-tools/account_move_line_tax_editable /opt/odoo/addons/account_move_line_tax_editable"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-financial-tools/account_partner_required /opt/odoo/addons/account_partner_required"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-financial-tools/account_reversal /opt/odoo/addons/account_reversal"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-financial-tools/account_tag_menu /opt/odoo/addons/account_tag_menu"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-financial-tools/account_type_menu /opt/odoo/addons/account_type_menu"






echo "Installazione Odoo 11.0 moduli account-closing"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/account-closing  /opt/odoo/source/OCA/account-closing"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-closing/account_cutoff_accrual_base /opt/odoo/addons/account_cutoff_accrual_base"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-closing/account_cutoff_accrual_dates /opt/odoo/addons/account_cutoff_accrual_dates"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-closing/account_cutoff_accrual_picking /opt/odoo/addons/account_cutoff_accrual_picking"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-closing/account_cutoff_base /opt/odoo/addons/account_cutoff_base"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-closing/account_cutoff_prepaid /opt/odoo/addons/account_cutoff_prepaid"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-closing/account_fiscal_year_closing /opt/odoo/addons/account_fiscal_year_closing"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-closing/account_invoice_start_end_dates /opt/odoo/addons/account_invoice_start_end_dates"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-closing/account_multicurrency_revaluation /opt/odoo/addons/account_multicurrency_revaluation"


echo "Installazione Odoo 11.0 moduli bank-statement-reconcile"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/bank-statement-reconcile  /opt/odoo/source/OCA/bank-statement-reconcile"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/bank-statement-reconcile/account_invoice_reference /opt/odoo/addons/account_invoice_reference"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/bank-statement-reconcile/account_mass_reconcile /opt/odoo/addons/account_mass_reconcile"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/bank-statement-reconcile/account_mass_reconcile_by_purchase_line /opt/odoo/addons/account_mass_reconcile_by_purchase_line"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/bank-statement-reconcile/account_mass_reconcile_ref_deep_search /opt/odoo/addons/account_mass_reconcile_ref_deep_search"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/bank-statement-reconcile/account_mass_reconcile_transaction_ref /opt/odoo/addons/account_mass_reconcile_transaction_ref"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/bank-statement-reconcile/account_move_bankaccount_import /opt/odoo/addons/account_move_bankaccount_import"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/bank-statement-reconcile/account_move_base_import /opt/odoo/addons/account_move_base_import"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/bank-statement-reconcile/account_move_reconcile_helper /opt/odoo/addons/account_move_reconcile_helper"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/bank-statement-reconcile/account_move_so_import /opt/odoo/addons/account_move_so_import"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/bank-statement-reconcile/account_move_transactionid_import /opt/odoo/addons/account_move_transactionid_import"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/bank-statement-reconcile/account_operation_rule /opt/odoo/addons/account_operation_rule"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/bank-statement-reconcile/account_payment_transaction_id /opt/odoo/addons/account_payment_transaction_id"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/bank-statement-reconcile/account_reconcile_payment_order /opt/odoo/addons/account_reconcile_payment_order"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/bank-statement-reconcile/account_statement_cancel_line /opt/odoo/addons/account_statement_cancel_line"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/bank-statement-reconcile/account_statement_completion_label /opt/odoo/addons/account_statement_completion_label"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/bank-statement-reconcile/account_statement_completion_voucher /opt/odoo/addons/account_statement_completion_voucher"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/bank-statement-reconcile/account_statement_ext /opt/odoo/addons/account_statement_ext"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/bank-statement-reconcile/account_statement_ext_point_of_sale /opt/odoo/addons/account_statement_ext_point_of_sale"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/bank-statement-reconcile/account_statement_ext_voucher /opt/odoo/addons/account_statement_ext_voucher"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/bank-statement-reconcile/account_statement_no_invoice_import /opt/odoo/addons/account_statement_no_invoice_import"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/bank-statement-reconcile/account_statement_one_move /opt/odoo/addons/account_statement_one_move"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/bank-statement-reconcile/account_statement_operation_multicompany /opt/odoo/addons/account_statement_operation_multicompany"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/bank-statement-reconcile/account_statement_regex_account_completion /opt/odoo/addons/account_statement_regex_account_completion"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/bank-statement-reconcile/bank_statement_foreign_currency /opt/odoo/addons/bank_statement_foreign_currency"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/bank-statement-reconcile/base_transaction_id /opt/odoo/addons/base_transaction_id"


echo "Installazione Odoo 11.0 moduli bank-statement-import"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/bank-statement-import  /opt/odoo/source/OCA/bank-statement-import"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/bank-statement-import/account_bank_statement_import_camt /opt/odoo/addons/account_bank_statement_import_camt"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/bank-statement-import/account_bank_statement_import_camt_details /opt/odoo/addons/account_bank_statement_import_camt_details"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/bank-statement-import/account_bank_statement_import_move_line /opt/odoo/addons/account_bank_statement_import_move_line"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/bank-statement-import/account_bank_statement_import_mt940_base /opt/odoo/addons/account_bank_statement_import_mt940_base"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/bank-statement-import/account_bank_statement_import_mt940_nl_ing /opt/odoo/addons/account_bank_statement_import_mt940_nl_ing"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/bank-statement-import/account_bank_statement_import_mt940_nl_rabo /opt/odoo/addons/account_bank_statement_import_mt940_nl_rabo"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/bank-statement-import/account_bank_statement_import_ofx /opt/odoo/addons/account_bank_statement_import_ofx"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/bank-statement-import/account_bank_statement_import_qif /opt/odoo/addons/account_bank_statement_import_qif"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/bank-statement-import/account_bank_statement_import_save_file /opt/odoo/addons/account_bank_statement_import_save_file"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/bank-statement-import/base_bank_account_number_unique /opt/odoo/addons/base_bank_account_number_unique"


echo "Installazione Odoo 11.0 moduli commission"
su - odoo -c "mkdir -p /opt/odoo/source/OCA"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/commission /opt/odoo/source/OCA/commission"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/commission/sale_commission /opt/odoo/addons/sale_commission"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/commission/sale_commission_areamanager /opt/odoo/addons/sale_commission_areamanager"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/commission/sale_commission_formula /opt/odoo/addons/sale_commission_formula"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/commission/sale_commission_pricelist /opt/odoo/addons/sale_commission_pricelist"


echo "Installazione Odoo 11.0 moduli margin-analysis"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/margin-analysis  /opt/odoo/source/OCA/margin-analysis"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/margin-analysis/sale_margin_security /opt/odoo/addons/sale_margin_security"


echo "Installazione Odoo 11.0 moduli sale-financial"
su - odoo -c "mkdir -p /opt/odoo/source/OCA"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/sale-financial /opt/odoo/source/OCA/sale-financial"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/sale-financial/sale_floor_price /opt/odoo/addons/sale_floor_price"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/sale-financial/sale_line_watcher /opt/odoo/addons/sale_line_watcher"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/sale-financial/sale_markup /opt/odoo/addons/sale_markup"


echo "Installazione Odoo 11.0 moduli sale-reporting"
su - odoo -c "mkdir -p /opt/odoo/source/OCA"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/sale-reporting /opt/odoo/source/OCA/sale-reporting"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/sale-reporting/html_sale_product_note /opt/odoo/addons/html_sale_product_note"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/sale-reporting/sale_comment_template /opt/odoo/addons/sale_comment_template"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/sale-reporting/sale_note_flow /opt/odoo/addons/sale_note_flow"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/sale-reporting/sale_order_proforma_webkit /opt/odoo/addons/sale_order_proforma_webkit"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/sale-reporting/sale_order_webkit /opt/odoo/addons/sale_order_webkit"


echo "Installazione Odoo 11.0 moduli contract"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/contract  /opt/odoo/source/OCA/contract"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/contract/contract /opt/odoo/addons/contract"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/contract/contract_payment_mode /opt/odoo/addons/contract_payment_mode"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/contract/contract_sale_invoicing /opt/odoo/addons/contract_sale_invoicing"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/contract/contract_variable_qty_timesheet /opt/odoo/addons/contract_variable_qty_timesheet"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/contract/contract_variable_quantity /opt/odoo/addons/contract_variable_quantity"


echo "Installazione Odoo 11.0 moduli rma"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/rma  /opt/odoo/source/OCA/rma"


echo "Installazione Odoo 11.0 moduli crm"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/crm  /opt/odoo/source/OCA/crm"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/crm/crm_claim /opt/odoo/addons/crm_claim"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/crm/crm_deduplicate_acl /opt/odoo/addons/crm_deduplicate_acl"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/crm/crm_deduplicate_filter /opt/odoo/addons/crm_deduplicate_filter"


echo "Installazione Odoo 11.0 moduli project-service"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/project-service  /opt/odoo/source/OCA/project-service"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/project-service/project_department /opt/odoo/addons/project_department"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/project-service/project_description /opt/odoo/addons/project_description"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/project-service/project_key /opt/odoo/addons/project_key"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/project-service/project_stage_closed /opt/odoo/addons/project_stage_closed"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/project-service/project_stage_state /opt/odoo/addons/project_stage_state"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/project-service/project_task_add_very_high /opt/odoo/addons/project_task_add_very_high"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/project-service/project_task_code /opt/odoo/addons/project_task_code"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/project-service/project_task_default_stage /opt/odoo/addons/project_task_default_stage"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/project-service/project_task_dependency /opt/odoo/addons/project_task_dependency"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/project-service/project_task_material /opt/odoo/addons/project_task_material"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/project-service/project_timeline /opt/odoo/addons/project_timeline"


echo "Installazione Odoo 11.0 moduli account-analytic"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/account-analytic  /opt/odoo/source/OCA/account-analytic"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-analytic/account_analytic_required /opt/odoo/addons/account_analytic_required"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-analytic/analytic_base_department /opt/odoo/addons/analytic_base_department"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-analytic/analytic_tag_dimension_purchase_warning /opt/odoo/addons/analytic_tag_dimension_purchase_warning"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-analytic/analytic_tag_dimension_sale_warning /opt/odoo/addons/analytic_tag_dimension_sale_warning"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-analytic/product_analytic /opt/odoo/addons/product_analytic"


echo "Installazione Odoo 11.0 moduli account-invoicing"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/account-invoicing  /opt/odoo/source/OCA/account-invoicing"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-invoicing/account_invoice_check_total /opt/odoo/addons/account_invoice_check_total"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-invoicing/account_invoice_force_number /opt/odoo/addons/account_invoice_force_number"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-invoicing/account_invoice_line_description /opt/odoo/addons/account_invoice_line_description"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-invoicing/account_invoice_refund_link /opt/odoo/addons/account_invoice_refund_link"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-invoicing/account_invoice_reimbursable /opt/odoo/addons/account_invoice_reimbursable"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-invoicing/account_invoice_supplier_ref_reuse /opt/odoo/addons/account_invoice_supplier_ref_reuse"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-invoicing/account_invoice_supplier_ref_unique /opt/odoo/addons/account_invoice_supplier_ref_unique"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-invoicing/account_invoice_supplier_self_invoice /opt/odoo/addons/account_invoice_supplier_self_invoice"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-invoicing/account_invoice_tax_required /opt/odoo/addons/account_invoice_tax_required"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-invoicing/account_invoice_triple_discount /opt/odoo/addons/account_invoice_triple_discount"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-invoicing/account_invoice_view_payment /opt/odoo/addons/account_invoice_view_payment"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-invoicing/account_payment_term_extension /opt/odoo/addons/account_payment_term_extension"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-invoicing/sale_timesheet_invoice_description /opt/odoo/addons/sale_timesheet_invoice_description"


echo "Installazione Odoo 11.0 moduli account-invoice-reporting"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/account-invoice-reporting  /opt/odoo/source/OCA/account-invoice-reporting"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-invoice-reporting/account_invoice_line_report /opt/odoo/addons/account_invoice_line_report"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-invoice-reporting/account_invoice_report_grouped_by_picking /opt/odoo/addons/account_invoice_report_grouped_by_picking"


echo "Installazione Odoo 11.0 moduli account-budgeting"
su - odoo -c "mkdir -p /opt/odoo/source/OCA"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/account-budgeting /opt/odoo/source/OCA/account-budgeting"


echo "Installazione Odoo 11.0 moduli account-consolidation"
su - odoo -c "mkdir -p /opt/odoo/source/OCA"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/account-consolidation /opt/odoo/source/OCA/account-consolidation"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/account-consolidation/account_consolidation /opt/odoo/addons/account_consolidation"


echo "Installazione Odoo 11.0 moduli event"
su - odoo -c "mkdir -p /opt/odoo/source/OCA"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/event /opt/odoo/source/OCA/event"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/event/partner_event /opt/odoo/addons/partner_event"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/event/website_event_excerpt_img /opt/odoo/addons/website_event_excerpt_img"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/event/website_event_filter_selector /opt/odoo/addons/website_event_filter_selector"


echo "Installazione Odoo 11.0 moduli survey"
su - odoo -c "mkdir -p /opt/odoo/source/OCA"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/survey /opt/odoo/source/OCA/survey"


echo "Installazione Odoo 11.0 moduli social"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/social  /opt/odoo/source/OCA/social"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/social/base_search_mail_content /opt/odoo/addons/base_search_mail_content"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/social/email_template_qweb /opt/odoo/addons/email_template_qweb"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/social/mail_attach_existing_attachment /opt/odoo/addons/mail_attach_existing_attachment"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/social/mail_debrand /opt/odoo/addons/mail_debrand"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/social/mail_digest /opt/odoo/addons/mail_digest"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/social/mail_restrict_follower_selection /opt/odoo/addons/mail_restrict_follower_selection"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/social/mail_tracking /opt/odoo/addons/mail_tracking"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/social/mail_tracking_mailgun /opt/odoo/addons/mail_tracking_mailgun"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/social/mass_mailing_custom_unsubscribe /opt/odoo/addons/mass_mailing_custom_unsubscribe"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/social/mass_mailing_partner /opt/odoo/addons/mass_mailing_partner"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/social/mass_mailing_unique /opt/odoo/addons/mass_mailing_unique"


echo "Installazione Odoo 11.0 moduli e-commerce"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/e-commerce  /opt/odoo/source/OCA/e-commerce"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/e-commerce/website_sale_default_country /opt/odoo/addons/website_sale_default_country"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/e-commerce/website_sale_hide_price /opt/odoo/addons/website_sale_hide_price"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/e-commerce/website_sale_product_brand /opt/odoo/addons/website_sale_product_brand"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/e-commerce/website_sale_require_legal /opt/odoo/addons/website_sale_require_legal"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/e-commerce/website_sale_require_login /opt/odoo/addons/website_sale_require_login"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/e-commerce/website_sale_suggest_create_account /opt/odoo/addons/website_sale_suggest_create_account"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/e-commerce/website_sale_vat_required /opt/odoo/addons/website_sale_vat_required"


echo "Installazione Odoo 11.0 moduli product-variant"
su - odoo -c "mkdir -p /opt/odoo/source/OCA"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/product-variant /opt/odoo/source/OCA/product-variant"


echo "Installazione Odoo 11.0 moduli carrier-delivery"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/carrier-delivery  /opt/odoo/source/OCA/carrier-delivery"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/carrier-delivery/base_delivery_carrier_label /opt/odoo/addons/base_delivery_carrier_label"


echo "Installazione Odoo 11.0 moduli stock-logistics-reporting"
su - odoo -c "mkdir -p /opt/odoo/source/OCA"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/stock-logistics-reporting /opt/odoo/source/OCA/stock-logistics-reporting"


echo "Installazione Odoo 11.0 moduli hr-timesheet"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/hr-timesheet  /opt/odoo/source/OCA/hr-timesheet"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/hr-timesheet/crm_timesheet /opt/odoo/addons/crm_timesheet"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/hr-timesheet/hr_timesheet_sheet /opt/odoo/addons/hr_timesheet_sheet"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/hr-timesheet/hr_timesheet_task_required /opt/odoo/addons/hr_timesheet_task_required"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/hr-timesheet/project_task_stage_allow_timesheet /opt/odoo/addons/project_task_stage_allow_timesheet"


echo "Installazione Odoo 11.0 moduli hr"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/hr  /opt/odoo/source/OCA/hr"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/hr/hr_employee_birth_name /opt/odoo/addons/hr_employee_birth_name"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/hr/hr_employee_firstname /opt/odoo/addons/hr_employee_firstname"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/hr/hr_experience /opt/odoo/addons/hr_experience"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/hr/hr_holidays_imposed_days /opt/odoo/addons/hr_holidays_imposed_days"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/hr/hr_holidays_leave_auto_approve /opt/odoo/addons/hr_holidays_leave_auto_approve"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/hr/hr_holidays_notify_employee_manager /opt/odoo/addons/hr_holidays_notify_employee_manager"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/hr/hr_holidays_settings /opt/odoo/addons/hr_holidays_settings"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/hr/hr_payroll_cancel /opt/odoo/addons/hr_payroll_cancel"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/hr/hr_skill /opt/odoo/addons/hr_skill"


echo "Installazione Odoo 11.0 moduli management-system"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/management-system  /opt/odoo/source/OCA/management-system"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/management-system/mgmtsystem /opt/odoo/addons/mgmtsystem"


echo "Installazione Odoo 11.0 moduli website"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/website  /opt/odoo/source/OCA/website"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/website/website_addthis /opt/odoo/addons/website_addthis"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/website/website_adv_image_optimization /opt/odoo/addons/website_adv_image_optimization"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/website/website_analytics_piwik /opt/odoo/addons/website_analytics_piwik"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/website/website_anchor_smooth_scroll /opt/odoo/addons/website_anchor_smooth_scroll"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/website/website_canonical_url /opt/odoo/addons/website_canonical_url"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/website/website_cookie_notice /opt/odoo/addons/website_cookie_notice"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/website/website_crm_privacy_policy /opt/odoo/addons/website_crm_privacy_policy"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/website/website_crm_recaptcha /opt/odoo/addons/website_crm_recaptcha"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/website/website_form_builder /opt/odoo/addons/website_form_builder"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/website/website_form_metadata /opt/odoo/addons/website_form_metadata"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/website/website_form_recaptcha /opt/odoo/addons/website_form_recaptcha"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/website/website_img_dimension /opt/odoo/addons/website_img_dimension"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/website/website_js_below_the_fold /opt/odoo/addons/website_js_below_the_fold"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/website/website_legal_page /opt/odoo/addons/website_legal_page"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/website/website_logo /opt/odoo/addons/website_logo"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/website/website_media_size /opt/odoo/addons/website_media_size"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/website/website_menu_by_user_status /opt/odoo/addons/website_menu_by_user_status"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/website/website_multi_theme /opt/odoo/addons/website_multi_theme"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/website/website_no_crawler /opt/odoo/addons/website_no_crawler"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/website/website_odoo_debranding /opt/odoo/addons/website_odoo_debranding"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/website/website_snippet_anchor /opt/odoo/addons/website_snippet_anchor"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/website/website_snippet_preset /opt/odoo/addons/website_snippet_preset"


echo "Installazione Odoo 11.0 moduli report-print-send"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/report-print-send  /opt/odoo/source/OCA/report-print-send"
pip install -r /opt/odoo/source/OCA/report-print-send/requirements.txt 
su - odoo -c "ln -sfn /opt/odoo/source/OCA/report-print-send/base_report_to_printer /opt/odoo/addons/base_report_to_printer"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/report-print-send/printer_zpl2 /opt/odoo/addons/printer_zpl2"


echo "Installazione Odoo 11.0 moduli purchase-reporting"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/purchase-reporting  /opt/odoo/source/OCA/purchase-reporting"


echo "Installazione Odoo 11.0 moduli purchase-workflow"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/purchase-workflow  /opt/odoo/source/OCA/purchase-workflow"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/purchase-workflow/purchase_discount /opt/odoo/addons/purchase_discount"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/purchase-workflow/purchase_exception /opt/odoo/addons/purchase_exception"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/purchase-workflow/purchase_line_procurement_group /opt/odoo/addons/purchase_line_procurement_group"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/purchase-workflow/purchase_minimum_amount /opt/odoo/addons/purchase_minimum_amount"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/purchase-workflow/purchase_order_approval_block /opt/odoo/addons/purchase_order_approval_block"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/purchase-workflow/stock_landed_cost_company_percentage /opt/odoo/addons/stock_landed_cost_company_percentage"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/purchase-workflow/subcontracted_service /opt/odoo/addons/subcontracted_service"


echo "Installazione Odoo 11.0 moduli manufacture-reporting"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/manufacture-reporting  /opt/odoo/source/OCA/manufacture-reporting"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/manufacture-reporting/mrp_bom_current_stock /opt/odoo/addons/mrp_bom_current_stock"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/manufacture-reporting/mrp_bom_matrix_report /opt/odoo/addons/mrp_bom_matrix_report"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/manufacture-reporting/mrp_bom_structure_xlsx /opt/odoo/addons/mrp_bom_structure_xlsx"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/manufacture-reporting/mrp_bom_structure_xlsx_level_1 /opt/odoo/addons/mrp_bom_structure_xlsx_level_1"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/manufacture-reporting/mrp_order_report_product_barcode /opt/odoo/addons/mrp_order_report_product_barcode"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/manufacture-reporting/mrp_order_report_stock_location /opt/odoo/addons/mrp_order_report_stock_location"


echo "Installazione Odoo 11.0 moduli knowledge"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/knowledge  /opt/odoo/source/OCA/knowledge"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/knowledge/document_page /opt/odoo/addons/document_page"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/knowledge/document_page_approval /opt/odoo/addons/document_page_approval"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/knowledge/document_url /opt/odoo/addons/document_url"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/knowledge/knowledge /opt/odoo/addons/knowledge"


echo "Installazione Odoo 11.0 moduli project-reporting"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/project-reporting  /opt/odoo/source/OCA/project-reporting"


echo "Installazione Odoo 11.0 moduli project"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/project  /opt/odoo/source/OCA/project"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/project/project_department /opt/odoo/addons/project_department"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/project/project_description /opt/odoo/addons/project_description"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/project/project_key /opt/odoo/addons/project_key"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/project/project_stage_closed /opt/odoo/addons/project_stage_closed"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/project/project_stage_state /opt/odoo/addons/project_stage_state"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/project/project_task_add_very_high /opt/odoo/addons/project_task_add_very_high"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/project/project_task_code /opt/odoo/addons/project_task_code"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/project/project_task_default_stage /opt/odoo/addons/project_task_default_stage"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/project/project_task_dependency /opt/odoo/addons/project_task_dependency"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/project/project_task_material /opt/odoo/addons/project_task_material"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/project/project_timeline /opt/odoo/addons/project_timeline"




echo "Installazione Odoo 11.0 moduli ingadhoc partner"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/ingadhoc/partner  /opt/odoo/source/ingadhoc/partner"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/partner/partner_internal_code /opt/odoo/addons/partner_internal_code"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/partner/partner_state /opt/odoo/addons/partner_state"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/partner/partner_tree_first /opt/odoo/addons/partner_tree_first"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/partner/partner_user /opt/odoo/addons/partner_user"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/partner/partner_views_fields /opt/odoo/addons/partner_views_fields"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/partner/portal_partner_fix /opt/odoo/addons/portal_partner_fix"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/partner/portal_ux /opt/odoo/addons/portal_ux"



echo "Installazione Odoo 10.0 moduli ingadhoc sale"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/ingadhoc/sale  /opt/odoo/source/ingadhoc/sale"
pip3 install -r /opt/odoo/source/ingadhoc/sale/requirements.txt
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/sale/event_sale_ux /opt/odoo/addons/event_sale_ux"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/sale/portal_sale_distributor /opt/odoo/addons/portal_sale_distributor"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/sale/portal_sale_distributor_wesbite_quote /opt/odoo/addons/portal_sale_distributor_wesbite_quote"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/sale/portal_sale_order_type /opt/odoo/addons/portal_sale_order_type"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/sale/sale_delivery_ux /opt/odoo/addons/sale_delivery_ux"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/sale/sale_dummy_confirmation /opt/odoo/addons/sale_dummy_confirmation"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/sale/sale_exception_credit_limit /opt/odoo/addons/sale_exception_credit_limit"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/sale/sale_exception_partner_state /opt/odoo/addons/sale_exception_partner_state"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/sale/sale_exception_price_security /opt/odoo/addons/sale_exception_price_security"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/sale/sale_exception_print /opt/odoo/addons/sale_exception_print"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/sale/sale_exceptions_ignore_approve /opt/odoo/addons/sale_exceptions_ignore_approve"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/sale/sale_global_three_discounts /opt/odoo/addons/sale_global_three_discounts"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/sale/sale_invoice_operation_line /opt/odoo/addons/sale_invoice_operation_line"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/sale/sale_margin_ux /opt/odoo/addons/sale_margin_ux"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/sale/sale_order_line_number /opt/odoo/addons/sale_order_line_number"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/sale/sale_order_type_automation /opt/odoo/addons/sale_order_type_automation"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/sale/sale_order_type_invoice_policy /opt/odoo/addons/sale_order_type_invoice_policy"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/sale/sale_order_type_sequence /opt/odoo/addons/sale_order_type_sequence"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/sale/sale_order_type_user_default /opt/odoo/addons/sale_order_type_user_default"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/sale/sale_order_validity /opt/odoo/addons/sale_order_validity"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/sale/sale_quotation_products /opt/odoo/addons/sale_quotation_products"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/sale/sale_require_contract /opt/odoo/addons/sale_require_contract"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/sale/sale_require_purchase_order_number /opt/odoo/addons/sale_require_purchase_order_number"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/sale/sale_require_ref /opt/odoo/addons/sale_require_ref"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/sale/sale_restrict_partners /opt/odoo/addons/sale_restrict_partners"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/sale/sale_stock_availability /opt/odoo/addons/sale_stock_availability"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/sale/sale_stock_ux /opt/odoo/addons/sale_stock_ux"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/sale/sale_three_discounts /opt/odoo/addons/sale_three_discounts"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/sale/sale_timesheet_ux /opt/odoo/addons/sale_timesheet_ux"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/sale/sale_ux /opt/odoo/addons/sale_ux"


echo "Installazione Odoo 11.0 moduli reporting-engine"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/ingadhoc/reporting-engine  /opt/odoo/source/ingadhoc/reporting-engine"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/reporting-engine/google_cloud_print /opt/odoo/addons/google_cloud_print"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/reporting-engine/report_extended /opt/odoo/addons/report_extended"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/reporting-engine/report_extended_account /opt/odoo/addons/report_extended_account"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/reporting-engine/report_extended_payment_group /opt/odoo/addons/report_extended_payment_group"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/reporting-engine/report_extended_purchase /opt/odoo/addons/report_extended_purchase"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/reporting-engine/report_extended_sale /opt/odoo/addons/report_extended_sale"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/reporting-engine/report_extended_stock /opt/odoo/addons/report_extended_stock"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/reporting-engine/report_extended_website_sale /opt/odoo/addons/report_extended_website_sale"


echo "Installazione Odoo 11.0 moduli account-invoicing"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/ingadhoc/account-invoicing  /opt/odoo/source/ingadhoc/account-invoicing"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/account-invoicing/account_clean_cancelled_invoice_number /opt/odoo/addons/account_clean_cancelled_invoice_number"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/account-invoicing/account_invoice_commission /opt/odoo/addons/account_invoice_commission"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/account-invoicing/account_invoice_control /opt/odoo/addons/account_invoice_control"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/account-invoicing/account_invoice_journal_group /opt/odoo/addons/account_invoice_journal_group"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/account-invoicing/account_invoice_line_number /opt/odoo/addons/account_invoice_line_number"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/account-invoicing/account_invoice_move_currency /opt/odoo/addons/account_invoice_move_currency"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/account-invoicing/account_partner_restrict_invoicing /opt/odoo/addons/account_partner_restrict_invoicing"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/account-invoicing/account_user_default_journals /opt/odoo/addons/account_user_default_journals"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/account-invoicing/website_sale_account_invoice_commission /opt/odoo/addons/website_sale_account_invoice_commission"

echo "Installazione Odoo 10.0 moduli ingadhoc product"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/ingadhoc/product  /opt/odoo/source/ingadhoc/product"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/product/price_security /opt/odoo/addons/price_security"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/product/price_security_planned_price /opt/odoo/addons/price_security_planned_price"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/product/product_catalog_aeroo_report /opt/odoo/addons/product_catalog_aeroo_report"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/product/product_catalog_aeroo_report_public_categ /opt/odoo/addons/product_catalog_aeroo_report_public_categ"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/product/product_currency /opt/odoo/addons/product_currency"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/product/product_internal_code /opt/odoo/addons/product_internal_code"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/product/product_management_group /opt/odoo/addons/product_management_group"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/product/product_pack /opt/odoo/addons/product_pack"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/product/product_planned_price /opt/odoo/addons/product_planned_price"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/product/product_pricelist /opt/odoo/addons/product_pricelist"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/product/product_price_taxes_included /opt/odoo/addons/product_price_taxes_included"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/product/product_purchase_uom /opt/odoo/addons/product_purchase_uom"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/product/product_reference_required /opt/odoo/addons/product_reference_required"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/product/product_replenishment_cost /opt/odoo/addons/product_replenishment_cost"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/product/product_salesman_group /opt/odoo/addons/product_salesman_group"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/product/product_sale_uom /opt/odoo/addons/product_sale_uom"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/product/product_stock_by_location /opt/odoo/addons/product_stock_by_location"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/product/product_template_tree_first /opt/odoo/addons/product_template_tree_first"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/product/product_unique /opt/odoo/addons/product_unique"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/product/product_uom_prices_currency /opt/odoo/addons/product_uom_prices_currency"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/product/product_ux /opt/odoo/addons/product_ux"
su - odoo -c "ln -sfn /opt/odoo/source/ingadhoc/product/product_variant_o2o /opt/odoo/addons/product_variant_o2o"



echo "Installazione Odoo 11.0 moduli misc-addons"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/it-projects-llc/misc-addons  /opt/odoo/source/it-projects-llc/misc-addons"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/attachment_large_object /opt/odoo/addons/attachment_large_object"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/auth_signup_confirmation /opt/odoo/addons/auth_signup_confirmation"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/auth_signup_confirmation_crm /opt/odoo/addons/auth_signup_confirmation_crm"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/autostaging_base /opt/odoo/addons/autostaging_base"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/autostaging_project_task /opt/odoo/addons/autostaging_project_task"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/barcode_widget /opt/odoo/addons/barcode_widget"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/base_attendance /opt/odoo/addons/base_attendance"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/base_details /opt/odoo/addons/base_details"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/base_groupby_extra /opt/odoo/addons/base_groupby_extra"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/base_import_map /opt/odoo/addons/base_import_map"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/base_session_store_psql /opt/odoo/addons/base_session_store_psql"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/booking_calendar /opt/odoo/addons/booking_calendar"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/booking_calendar_analytic /opt/odoo/addons/booking_calendar_analytic"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/crm_expected_revenue /opt/odoo/addons/crm_expected_revenue"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/crm_next_action /opt/odoo/addons/crm_next_action"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/currency_rate_update /opt/odoo/addons/currency_rate_update"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/customer_marketing /opt/odoo/addons/customer_marketing"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/custom_menu_bar /opt/odoo/addons/custom_menu_bar"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/delivery_sequence /opt/odoo/addons/delivery_sequence"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/delivery_special /opt/odoo/addons/delivery_special"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/fleet_odometer_oil /opt/odoo/addons/fleet_odometer_oil"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/fleet_odometer_track_changes /opt/odoo/addons/fleet_odometer_track_changes"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/gamification_extra /opt/odoo/addons/gamification_extra"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/hr_public_holidays_ics_import /opt/odoo/addons/hr_public_holidays_ics_import"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/hr_rule_input_compute /opt/odoo/addons/hr_rule_input_compute"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/import_csv_fix_field_limit /opt/odoo/addons/import_csv_fix_field_limit"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/invoice_sale_order_line_group /opt/odoo/addons/invoice_sale_order_line_group"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/ir_actions_todo_repeat /opt/odoo/addons/ir_actions_todo_repeat"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/ir_attachment_force_storage /opt/odoo/addons/ir_attachment_force_storage"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/ir_attachment_s3 /opt/odoo/addons/ir_attachment_s3"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/ir_attachment_url /opt/odoo/addons/ir_attachment_url"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/ir_config_parameter_multi_company /opt/odoo/addons/ir_config_parameter_multi_company"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/LICENSE /opt/odoo/addons/LICENSE"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/oca_dependencies.txt /opt/odoo/addons/oca_dependencies.txt"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/pitch_booking /opt/odoo/addons/pitch_booking"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/product_category_taxes /opt/odoo/addons/product_category_taxes"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/product_details /opt/odoo/addons/product_details"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/production_lot_details /opt/odoo/addons/production_lot_details"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/product_tags /opt/odoo/addons/product_tags"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/project_description /opt/odoo/addons/project_description"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/project_gantt8 /opt/odoo/addons/project_gantt8"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/project_kanban_customer /opt/odoo/addons/project_kanban_customer"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/project_tags /opt/odoo/addons/project_tags"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/project_task_auto_staging /opt/odoo/addons/project_task_auto_staging"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/project_task_order_kanban_state /opt/odoo/addons/project_task_order_kanban_state"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/project_task_search_custom /opt/odoo/addons/project_task_search_custom"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/project_task_subtask /opt/odoo/addons/project_task_subtask"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/project_timelog /opt/odoo/addons/project_timelog"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/README.md /opt/odoo/addons/README.md"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/reminder_base /opt/odoo/addons/reminder_base"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/reminder_crm_next_action /opt/odoo/addons/reminder_crm_next_action"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/reminder_crm_next_action_time /opt/odoo/addons/reminder_crm_next_action_time"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/reminder_hr_recruitment /opt/odoo/addons/reminder_hr_recruitment"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/reminder_issue_deadline /opt/odoo/addons/reminder_issue_deadline"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/reminder_task_deadline /opt/odoo/addons/reminder_task_deadline"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/requirements.txt /opt/odoo/addons/requirements.txt"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/res_partner_country_code /opt/odoo/addons/res_partner_country_code"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/res_partner_phone /opt/odoo/addons/res_partner_phone"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/res_partner_skype /opt/odoo/addons/res_partner_skype"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/res_users_signature /opt/odoo/addons/res_users_signature"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/res_users_signature_hr /opt/odoo/addons/res_users_signature_hr"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/sale_order_hide_tax /opt/odoo/addons/sale_order_hide_tax"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/sms_sg /opt/odoo/addons/sms_sg"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/thecage_data /opt/odoo/addons/thecage_data"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/theme_kit /opt/odoo/addons/theme_kit"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/web_calendar_quick_navigation /opt/odoo/addons/web_calendar_quick_navigation"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/web_calendar_repeat_form /opt/odoo/addons/web_calendar_repeat_form"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/web_debranding /opt/odoo/addons/web_debranding"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/web_debranding_support /opt/odoo/addons/web_debranding_support"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/web_gantt8 /opt/odoo/addons/web_gantt8"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/web_iframe /opt/odoo/addons/web_iframe"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/web_iframe_pages /opt/odoo/addons/web_iframe_pages"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/web_polymorphic_field /opt/odoo/addons/web_polymorphic_field"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/web_preview /opt/odoo/addons/web_preview"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/web_sessions_management /opt/odoo/addons/web_sessions_management"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/web_tour_extra /opt/odoo/addons/web_tour_extra"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/misc-addons/web_website /opt/odoo/addons/web_website"


echo "Installazione Odoo 11.0 moduli access-addons"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/it-projects-llc/access-addons  /opt/odoo/source/it-projects-llc/access-addons"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/access-addons/access_apps /opt/odoo/addons/access_apps"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/access-addons/access_apps_website /opt/odoo/addons/access_apps_website"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/access-addons/access_base /opt/odoo/addons/access_base"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/access-addons/access_limit_records_number /opt/odoo/addons/access_limit_records_number"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/access-addons/access_menu_extra_groups /opt/odoo/addons/access_menu_extra_groups"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/access-addons/access_restricted /opt/odoo/addons/access_restricted"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/access-addons/access_settings_menu /opt/odoo/addons/access_settings_menu"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/access-addons/apps /opt/odoo/addons/apps"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/access-addons/group_menu_no_access /opt/odoo/addons/group_menu_no_access"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/access-addons/hidden_admin /opt/odoo/addons/hidden_admin"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/access-addons/ir_rule_protected /opt/odoo/addons/ir_rule_protected"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/access-addons/ir_rule_website /opt/odoo/addons/ir_rule_website"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/access-addons/res_users_clear_access_rights /opt/odoo/addons/res_users_clear_access_rights"


echo "Installazione Odoo 11.0 moduli pos-addons"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/it-projects-llc/pos-addons  /opt/odoo/source/it-projects-llc/pos-addons"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/pos-addons/hw_printer_network /opt/odoo/addons/hw_printer_network"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/pos-addons/hw_twitter_printing /opt/odoo/addons/hw_twitter_printing"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/pos-addons/pos_cashier_select /opt/odoo/addons/pos_cashier_select"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/pos-addons/pos_category_multi /opt/odoo/addons/pos_category_multi"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/pos-addons/pos_debranding /opt/odoo/addons/pos_debranding"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/pos-addons/pos_debt_notebook /opt/odoo/addons/pos_debt_notebook"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/pos-addons/pos_debt_notebook_sync /opt/odoo/addons/pos_debt_notebook_sync"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/pos-addons/pos_details_custom /opt/odoo/addons/pos_details_custom"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/pos-addons/pos_disable_payment /opt/odoo/addons/pos_disable_payment"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/pos-addons/pos_disable_restore_orders /opt/odoo/addons/pos_disable_restore_orders"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/pos-addons/pos_discount_base /opt/odoo/addons/pos_discount_base"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/pos-addons/pos_discount_total /opt/odoo/addons/pos_discount_total"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/pos-addons/pos_fiscal_current /opt/odoo/addons/pos_fiscal_current"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/pos-addons/pos_fiscal_floor /opt/odoo/addons/pos_fiscal_floor"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/pos-addons/pos_invoice_pay /opt/odoo/addons/pos_invoice_pay"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/pos-addons/pos_keyboard /opt/odoo/addons/pos_keyboard"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/pos-addons/pos_longpolling /opt/odoo/addons/pos_longpolling"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/pos-addons/pos_mobile /opt/odoo/addons/pos_mobile"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/pos-addons/pos_mobile_restaurant /opt/odoo/addons/pos_mobile_restaurant"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/pos-addons/pos_multi_session /opt/odoo/addons/pos_multi_session"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/pos-addons/pos_multi_session_restaurant /opt/odoo/addons/pos_multi_session_restaurant"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/pos-addons/pos_multi_session_sync /opt/odoo/addons/pos_multi_session_sync"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/pos-addons/pos_order_cancel /opt/odoo/addons/pos_order_cancel"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/pos-addons/pos_order_cancel_restaurant /opt/odoo/addons/pos_order_cancel_restaurant"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/pos-addons/pos_orderline_absolute_discount /opt/odoo/addons/pos_orderline_absolute_discount"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/pos-addons/pos_order_note /opt/odoo/addons/pos_order_note"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/pos-addons/pos_order_printer_product /opt/odoo/addons/pos_order_printer_product"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/pos-addons/pos_pin /opt/odoo/addons/pos_pin"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/pos-addons/pos_printer_network /opt/odoo/addons/pos_printer_network"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/pos-addons/pos_print_method /opt/odoo/addons/pos_print_method"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/pos-addons/pos_product_available /opt/odoo/addons/pos_product_available"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/pos-addons/pos_product_available_negative /opt/odoo/addons/pos_product_available_negative"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/pos-addons/pos_product_category_discount /opt/odoo/addons/pos_product_category_discount"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/pos-addons/pos_product_lot /opt/odoo/addons/pos_product_lot"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/pos-addons/pos_restaurant_base /opt/odoo/addons/pos_restaurant_base"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/pos-addons/pos_sale_order /opt/odoo/addons/pos_sale_order"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/pos-addons/pos_scan_ref /opt/odoo/addons/pos_scan_ref"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/pos-addons/product_lot /opt/odoo/addons/product_lot"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/pos-addons/product_variant_multi /opt/odoo/addons/product_variant_multi"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/pos-addons/to_pos_shared_floor /opt/odoo/addons/to_pos_shared_floor"


echo "Installazione Odoo 11.0 moduli website-addons"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/it-projects-llc/website-addons  /opt/odoo/source/it-projects-llc/website-addons"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/website-addons/chess /opt/odoo/addons/chess"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/website-addons/LICENSE /opt/odoo/addons/LICENSE"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/website-addons/oca_dependencies.txt /opt/odoo/addons/oca_dependencies.txt"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/website-addons/portal_event_tickets /opt/odoo/addons/portal_event_tickets"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/website-addons/README.md /opt/odoo/addons/README.md"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/website-addons/requirements.txt /opt/odoo/addons/requirements.txt"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/website-addons/stock_picking_barcode /opt/odoo/addons/stock_picking_barcode"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/website-addons/web_login_background /opt/odoo/addons/web_login_background"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/website-addons/website_booking_calendar /opt/odoo/addons/website_booking_calendar"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/website-addons/website_debranding /opt/odoo/addons/website_debranding"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/website-addons/website_event_attendee_fields /opt/odoo/addons/website_event_attendee_fields"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/website-addons/website_event_attendee_fields_custom /opt/odoo/addons/website_event_attendee_fields_custom"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/website-addons/website_event_attendee_signup /opt/odoo/addons/website_event_attendee_signup"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/website-addons/website_event_require_login /opt/odoo/addons/website_event_require_login"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/website-addons/website_files /opt/odoo/addons/website_files"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/website-addons/website_forum_faq_edit /opt/odoo/addons/website_forum_faq_edit"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/website-addons/website_login_background /opt/odoo/addons/website_login_background"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/website-addons/website_login_hide /opt/odoo/addons/website_login_hide"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/website-addons/website_multi_company /opt/odoo/addons/website_multi_company"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/website-addons/website_multi_company_blog /opt/odoo/addons/website_multi_company_blog"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/website-addons/website_multi_company_demo /opt/odoo/addons/website_multi_company_demo"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/website-addons/website_multi_company_portal /opt/odoo/addons/website_multi_company_portal"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/website-addons/website_multi_company_sale /opt/odoo/addons/website_multi_company_sale"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/website-addons/website_multi_company_sale_delivery /opt/odoo/addons/website_multi_company_sale_delivery"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/website-addons/website_proposal /opt/odoo/addons/website_proposal"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/website-addons/website_redirect /opt/odoo/addons/website_redirect"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/website-addons/website_sale_add_to_cart /opt/odoo/addons/website_sale_add_to_cart"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/website-addons/website_sale_add_to_cart_disable /opt/odoo/addons/website_sale_add_to_cart_disable"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/website-addons/website_sale_add_to_cart_stock_status /opt/odoo/addons/website_sale_add_to_cart_stock_status"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/website-addons/website_sale_available /opt/odoo/addons/website_sale_available"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/website-addons/website_sale_birthdate /opt/odoo/addons/website_sale_birthdate"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/website-addons/website_sale_buy_now /opt/odoo/addons/website_sale_buy_now"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/website-addons/website_sale_cache /opt/odoo/addons/website_sale_cache"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/website-addons/website_sale_checkout_store /opt/odoo/addons/website_sale_checkout_store"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/website-addons/website_sale_clear_cart /opt/odoo/addons/website_sale_clear_cart"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/website-addons/website_sale_order /opt/odoo/addons/website_sale_order"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/website-addons/website_sale_product_tags /opt/odoo/addons/website_sale_product_tags"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/website-addons/website_sale_quantity_hide /opt/odoo/addons/website_sale_quantity_hide"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/website-addons/website_sale_refund /opt/odoo/addons/website_sale_refund"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/website-addons/website_sale_search_clear /opt/odoo/addons/website_sale_search_clear"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/website-addons/website_sale_search_custom /opt/odoo/addons/website_sale_search_custom"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/website-addons/website_sale_search_tags /opt/odoo/addons/website_sale_search_tags"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/website-addons/website_sales_team /opt/odoo/addons/website_sales_team"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/website-addons/website_sale_stock_status /opt/odoo/addons/website_sale_stock_status"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/website-addons/website_seo_url /opt/odoo/addons/website_seo_url"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/website-addons/website_seo_url_product /opt/odoo/addons/website_seo_url_product"

echo "Installazione Odoo 11.0 moduli mail-addons"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/it-projects-llc/mail-addons  /opt/odoo/source/it-projects-llc/mail-addons"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/mail-addons/LICENSE /opt/odoo/addons/LICENSE"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/mail-addons/mail_all /opt/odoo/addons/mail_all"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/mail-addons/mail_archives /opt/odoo/addons/mail_archives"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/mail-addons/mail_attachment_popup /opt/odoo/addons/mail_attachment_popup"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/mail-addons/mail_base /opt/odoo/addons/mail_base"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/mail-addons/mail_check_immediately /opt/odoo/addons/mail_check_immediately"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/mail-addons/mail_fix_553 /opt/odoo/addons/mail_fix_553"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/mail-addons/mailgun /opt/odoo/addons/mailgun"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/mail-addons/mail_move_message /opt/odoo/addons/mail_move_message"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/mail-addons/mail_private /opt/odoo/addons/mail_private"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/mail-addons/mail_recovery /opt/odoo/addons/mail_recovery"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/mail-addons/mail_reply /opt/odoo/addons/mail_reply"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/mail-addons/mail_sent /opt/odoo/addons/mail_sent"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/mail-addons/mail_to /opt/odoo/addons/mail_to"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/mail-addons/oca_dependencies.txt /opt/odoo/addons/oca_dependencies.txt"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/mail-addons/README.md /opt/odoo/addons/README.md"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/mail-addons/res_partner_company_messages /opt/odoo/addons/res_partner_company_messages"
su - odoo -c "ln -sfn /opt/odoo/source/it-projects-llc/mail-addons/res_partner_mails_count /opt/odoo/addons/res_partner_mails_count"



echo "Installazione Odoo 11.0 moduli vauxoo addos-vauxoo"
su - odoo -c "mkdir -p /opt/odoo/source/vauxoo"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/vauxoo/addons-vauxoo /opt/odoo/source/vauxoo/addons-vauxoo"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_amortization /opt/odoo/addons/account_amortization"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_analytic_policy /opt/odoo/addons/account_analytic_policy"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_anglo_saxon_missing_key /opt/odoo/addons/account_anglo_saxon_missing_key"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_anglo_saxon_stock_move /opt/odoo/addons/account_anglo_saxon_stock_move"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_anglo_saxon_stock_move_purchase /opt/odoo/addons/account_anglo_saxon_stock_move_purchase"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_anglo_saxon_stock_move_sale /opt/odoo/addons/account_anglo_saxon_stock_move_sale"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_asset_analytic /opt/odoo/addons/account_asset_analytic"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_asset_date /opt/odoo/addons/account_asset_date"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_asset_move_check /opt/odoo/addons/account_asset_move_check"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_bank_statement_unfucked /opt/odoo/addons/account_bank_statement_unfucked"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_bank_statement_vauxoo /opt/odoo/addons/account_bank_statement_vauxoo"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_budget_imp /opt/odoo/addons/account_budget_imp"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_chart_wiz_dates /opt/odoo/addons/account_chart_wiz_dates"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_closure_preparation /opt/odoo/addons/account_closure_preparation"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_currency_tools /opt/odoo/addons/account_currency_tools"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_entries_report_group_by_ref /opt/odoo/addons/account_entries_report_group_by_ref"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_group_auditory /opt/odoo/addons/account_group_auditory"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_group_auditory_assets /opt/odoo/addons/account_group_auditory_assets"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_invoice_change_currency /opt/odoo/addons/account_invoice_change_currency"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_invoice_line_asset_category_required /opt/odoo/addons/account_invoice_line_asset_category_required"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_invoice_line_currency /opt/odoo/addons/account_invoice_line_currency"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_invoice_number /opt/odoo/addons/account_invoice_number"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_invoice_regular_validation /opt/odoo/addons/account_invoice_regular_validation"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_invoice_show_by_user /opt/odoo/addons/account_invoice_show_by_user"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_invoice_supplier_quantity_attachments /opt/odoo/addons/account_invoice_supplier_quantity_attachments"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_invoice_tax /opt/odoo/addons/account_invoice_tax"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_ledger_report /opt/odoo/addons/account_ledger_report"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_move_cancel /opt/odoo/addons/account_move_cancel"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_move_filters /opt/odoo/addons/account_move_filters"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_move_folio /opt/odoo/addons/account_move_folio"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_move_group /opt/odoo/addons/account_move_group"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_move_line_address /opt/odoo/addons/account_move_line_address"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_move_line_base_tax /opt/odoo/addons/account_move_line_base_tax"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_move_line_dp_product /opt/odoo/addons/account_move_line_dp_product"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_move_line_extended /opt/odoo/addons/account_move_line_extended"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_move_line_group_analytic /opt/odoo/addons/account_move_line_group_analytic"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_move_line_group_by_asset /opt/odoo/addons/account_move_line_group_by_asset"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_move_line_group_by_extend /opt/odoo/addons/account_move_line_group_by_extend"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_move_line_grouping /opt/odoo/addons/account_move_line_grouping"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_move_line_production /opt/odoo/addons/account_move_line_production"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_move_nonzero /opt/odoo/addons/account_move_nonzero"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_move_report /opt/odoo/addons/account_move_report"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_move_sum_all_credits_debits /opt/odoo/addons/account_move_sum_all_credits_debits"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_move_validate_multi_wizard /opt/odoo/addons/account_move_validate_multi_wizard"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_multicompany_code /opt/odoo/addons/account_multicompany_code"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_name_ref_search /opt/odoo/addons/account_name_ref_search"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_order_wizard /opt/odoo/addons/account_order_wizard"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_payment_approve_invoice /opt/odoo/addons/account_payment_approve_invoice"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_reconcile_advance /opt/odoo/addons/account_reconcile_advance"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_reconcile_advance_tax /opt/odoo/addons/account_reconcile_advance_tax"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_reconcile_grouping /opt/odoo/addons/account_reconcile_grouping"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_reconcile_search /opt/odoo/addons/account_reconcile_search"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_refund_early_payment /opt/odoo/addons/account_refund_early_payment"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_relation_move /opt/odoo/addons/account_relation_move"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_remove_account_move_amount_field /opt/odoo/addons/account_remove_account_move_amount_field"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_report_general_ledger_no_journal /opt/odoo/addons/account_report_general_ledger_no_journal"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_smart_unreconcile /opt/odoo/addons/account_smart_unreconcile"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_tax_importation /opt/odoo/addons/account_tax_importation"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_update_amount_tax_in_move_lines /opt/odoo/addons/account_update_amount_tax_in_move_lines"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_voucher_category /opt/odoo/addons/account_voucher_category"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_voucher_department /opt/odoo/addons/account_voucher_department"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_voucher_draft /opt/odoo/addons/account_voucher_draft"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_voucher_move_id /opt/odoo/addons/account_voucher_move_id"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_voucher_no_check_default /opt/odoo/addons/account_voucher_no_check_default"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_voucher_requester /opt/odoo/addons/account_voucher_requester"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_voucher_tax /opt/odoo/addons/account_voucher_tax"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_voucher_tax_sat /opt/odoo/addons/account_voucher_tax_sat"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/account_wizard_vouchers_invoice /opt/odoo/addons/account_wizard_vouchers_invoice"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/active_journal_period /opt/odoo/addons/active_journal_period"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/aging_due_report /opt/odoo/addons/aging_due_report"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/analytic_entry_line_group /opt/odoo/addons/analytic_entry_line_group"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/analytic_entry_line_journal /opt/odoo/addons/analytic_entry_line_journal"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/analytic_entry_line_move /opt/odoo/addons/analytic_entry_line_move"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/analytic_entry_line_partner /opt/odoo/addons/analytic_entry_line_partner"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/analytic_entry_line_period /opt/odoo/addons/analytic_entry_line_period"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/analytic_entry_line_plans /opt/odoo/addons/analytic_entry_line_plans"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/analytic_entry_line_taxcode /opt/odoo/addons/analytic_entry_line_taxcode"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/analytic_plans_group /opt/odoo/addons/analytic_plans_group"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/analytic_split_quantity /opt/odoo/addons/analytic_split_quantity"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/bank_iva_report /opt/odoo/addons/bank_iva_report"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/base_user_signature_logo /opt/odoo/addons/base_user_signature_logo"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/base_vat_country /opt/odoo/addons/base_vat_country"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/base_vat_principal_view /opt/odoo/addons/base_vat_principal_view"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/bom_inventory_information /opt/odoo/addons/bom_inventory_information"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/change_invoice_number /opt/odoo/addons/change_invoice_number"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/clean_user_groups /opt/odoo/addons/clean_user_groups"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/commission_payment /opt/odoo/addons/commission_payment"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/company_description /opt/odoo/addons/company_description"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/configure_account_partner /opt/odoo/addons/configure_account_partner"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/configure_chart_account /opt/odoo/addons/configure_chart_account"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/CONTRIBUTING.md /opt/odoo/addons/CONTRIBUTING.md"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/controller_report_xls /opt/odoo/addons/controller_report_xls"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/costing_method_settings /opt/odoo/addons/costing_method_settings"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/crm_claim_summary_report /opt/odoo/addons/crm_claim_summary_report"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/crm_cost_issue /opt/odoo/addons/crm_cost_issue"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/crm_profile_reporting /opt/odoo/addons/crm_profile_reporting"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/debit_credit_note /opt/odoo/addons/debit_credit_note"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/decimal_precision_currency /opt/odoo/addons/decimal_precision_currency"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/decimal_precision_tax /opt/odoo/addons/decimal_precision_tax"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/default_warehouse_from_sale_team /opt/odoo/addons/default_warehouse_from_sale_team"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/deliver_project /opt/odoo/addons/deliver_project"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/email_show_only_changes /opt/odoo/addons/email_show_only_changes"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/email_template_att_dinamic /opt/odoo/addons/email_template_att_dinamic"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/email_template_comment /opt/odoo/addons/email_template_comment"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/expired_task_information /opt/odoo/addons/expired_task_information"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/forward_mail /opt/odoo/addons/forward_mail"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/group_button_wkf_send_rfq /opt/odoo/addons/group_button_wkf_send_rfq"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/group_configurations_account /opt/odoo/addons/group_configurations_account"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/hr_childrens /opt/odoo/addons/hr_childrens"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/hr_expense_analytic /opt/odoo/addons/hr_expense_analytic"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/hr_expense_replenishment /opt/odoo/addons/hr_expense_replenishment"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/hr_expense_replenishment_cancel /opt/odoo/addons/hr_expense_replenishment_cancel"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/hr_expense_replenishment_tax /opt/odoo/addons/hr_expense_replenishment_tax"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/hr_job_positions_extended /opt/odoo/addons/hr_job_positions_extended"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/hr_lastname /opt/odoo/addons/hr_lastname"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/hr_payroll_cancel /opt/odoo/addons/hr_payroll_cancel"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/hr_payroll_multicompany /opt/odoo/addons/hr_payroll_multicompany"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/hr_payslip_paid /opt/odoo/addons/hr_payslip_paid"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/hr_payslip_validation_home_address /opt/odoo/addons/hr_payslip_validation_home_address"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/hr_salesman_commission /opt/odoo/addons/hr_salesman_commission"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/hr_timesheet_reports /opt/odoo/addons/hr_timesheet_reports"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/import_tax_tariff /opt/odoo/addons/import_tax_tariff"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/inactive_account_children /opt/odoo/addons/inactive_account_children"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/incoterm_delivery_type /opt/odoo/addons/incoterm_delivery_type"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/incoterm_ext /opt/odoo/addons/incoterm_ext"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/inventory_stock_report /opt/odoo/addons/inventory_stock_report"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/invisible_aml_tax /opt/odoo/addons/invisible_aml_tax"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/invoice_cancel_islr /opt/odoo/addons/invoice_cancel_islr"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/invoice_cancel_iva /opt/odoo/addons/invoice_cancel_iva"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/invoice_comment_view_tree /opt/odoo/addons/invoice_comment_view_tree"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/invoice_commission /opt/odoo/addons/invoice_commission"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/invoice_date_ref /opt/odoo/addons/invoice_date_ref"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/invoice_datetime /opt/odoo/addons/invoice_datetime"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/invoice_discount /opt/odoo/addons/invoice_discount"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/invoice_double_validation /opt/odoo/addons/invoice_double_validation"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/invoice_multicompany_report /opt/odoo/addons/invoice_multicompany_report"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/invoice_number_view_tree /opt/odoo/addons/invoice_number_view_tree"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/invoice_print_multicompany /opt/odoo/addons/invoice_print_multicompany"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/invoice_report_multicompany /opt/odoo/addons/invoice_report_multicompany"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/invoice_report_per_journal /opt/odoo/addons/invoice_report_per_journal"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/invoice_sale_ref /opt/odoo/addons/invoice_sale_ref"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/invoice_so /opt/odoo/addons/invoice_so"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/ir_actions_report_xml_multicompany /opt/odoo/addons/ir_actions_report_xml_multicompany"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/ir_ui_view_filter_arch /opt/odoo/addons/ir_ui_view_filter_arch"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/issue_view /opt/odoo/addons/issue_view"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/mail_add_followers_multirecord /opt/odoo/addons/mail_add_followers_multirecord"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/merge_editing /opt/odoo/addons/merge_editing"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/message_post_model /opt/odoo/addons/message_post_model"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/message_post_test /opt/odoo/addons/message_post_test"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/mrp_bom_constraint /opt/odoo/addons/mrp_bom_constraint"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/mrp_bom_standard_price /opt/odoo/addons/mrp_bom_standard_price"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/mrp_bom_subproduct_cost /opt/odoo/addons/mrp_bom_subproduct_cost"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/mrp_button_box /opt/odoo/addons/mrp_button_box"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/mrp_force_responsible /opt/odoo/addons/mrp_force_responsible"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/mrp_location_line_production /opt/odoo/addons/mrp_location_line_production"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/mrp_location_route /opt/odoo/addons/mrp_location_route"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/mrp_partial_production /opt/odoo/addons/mrp_partial_production"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/mrp_product_capacity /opt/odoo/addons/mrp_product_capacity"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/mrp_production_analytic_acc /opt/odoo/addons/mrp_production_analytic_acc"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/mrp_production_bom_related /opt/odoo/addons/mrp_production_bom_related"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/mrp_production_filter_date /opt/odoo/addons/mrp_production_filter_date"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/mrp_production_filter_product /opt/odoo/addons/mrp_production_filter_product"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/mrp_production_procurement_order /opt/odoo/addons/mrp_production_procurement_order"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/mrp_production_security_force /opt/odoo/addons/mrp_production_security_force"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/mrp_pt_planified /opt/odoo/addons/mrp_pt_planified"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/mrp_routing_account_journal /opt/odoo/addons/mrp_routing_account_journal"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/mrp_scheduled_onchange_product /opt/odoo/addons/mrp_scheduled_onchange_product"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/mrp_subproduction /opt/odoo/addons/mrp_subproduction"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/mrp_subproduct_pt_planified /opt/odoo/addons/mrp_subproduct_pt_planified"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/mrp_webkit_report_wizard /opt/odoo/addons/mrp_webkit_report_wizard"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/mrp_workcenter_account_move /opt/odoo/addons/mrp_workcenter_account_move"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/mrp_workcenter_management /opt/odoo/addons/mrp_workcenter_management"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/mrp_workcenter_responsible /opt/odoo/addons/mrp_workcenter_responsible"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/mrp_workcenter_segmentation /opt/odoo/addons/mrp_workcenter_segmentation"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/mrp_workorder_variation /opt/odoo/addons/mrp_workorder_variation"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/note_to_task /opt/odoo/addons/note_to_task"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/partner_credit_limit /opt/odoo/addons/partner_credit_limit"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/partner_effective_sale /opt/odoo/addons/partner_effective_sale"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/partner_foreign /opt/odoo/addons/partner_foreign"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/partner_invoice_description /opt/odoo/addons/partner_invoice_description"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/partner_notification_advance /opt/odoo/addons/partner_notification_advance"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/partner_products /opt/odoo/addons/partner_products"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/partner_property_accounts /opt/odoo/addons/partner_property_accounts"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/partner_ref_search /opt/odoo/addons/partner_ref_search"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/partner_required_in_acc_move_line /opt/odoo/addons/partner_required_in_acc_move_line"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/partner_search_by_vat /opt/odoo/addons/partner_search_by_vat"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/partner_validate_vat /opt/odoo/addons/partner_validate_vat"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/payment_term_type /opt/odoo/addons/payment_term_type"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/payroll_amount_residual /opt/odoo/addons/payroll_amount_residual"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/periodic_inventory_valuation /opt/odoo/addons/periodic_inventory_valuation"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/picking_force_availability /opt/odoo/addons/picking_force_availability"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/picking_from_invoice /opt/odoo/addons/picking_from_invoice"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/picking_verification_report /opt/odoo/addons/picking_verification_report"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/point_of_sale_by_month /opt/odoo/addons/point_of_sale_by_month"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/point_of_sale_reprint_tree /opt/odoo/addons/point_of_sale_reprint_tree"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/portal_project_kanban_fields /opt/odoo/addons/portal_project_kanban_fields"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/pos_calculator /opt/odoo/addons/pos_calculator"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/pos_delivery_restaurant /opt/odoo/addons/pos_delivery_restaurant"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/pos_product_filter /opt/odoo/addons/pos_product_filter"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/pr_line_related_po_line /opt/odoo/addons/pr_line_related_po_line"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/procurement_cancel /opt/odoo/addons/procurement_cancel"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/procurement_so2po_shiping_address /opt/odoo/addons/procurement_so2po_shiping_address"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/product_attr_description /opt/odoo/addons/product_attr_description"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/product_categ_name_untranslated /opt/odoo/addons/product_categ_name_untranslated"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/product_category_attributes /opt/odoo/addons/product_category_attributes"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/product_category_multicompany /opt/odoo/addons/product_category_multicompany"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/product_context_date /opt/odoo/addons/product_context_date"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/product_cost_usd /opt/odoo/addons/product_cost_usd"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/product_customer_code /opt/odoo/addons/product_customer_code"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/product_customs_rate /opt/odoo/addons/product_customs_rate"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/product_do_merge /opt/odoo/addons/product_do_merge"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/product_extended_segmentation /opt/odoo/addons/product_extended_segmentation"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/product_extended_variants /opt/odoo/addons/product_extended_variants"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/product_images_olbs /opt/odoo/addons/product_images_olbs"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/production_lot_group_by_name /opt/odoo/addons/production_lot_group_by_name"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/product_lifecycle /opt/odoo/addons/product_lifecycle"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/product_model_no /opt/odoo/addons/product_model_no"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/product_name_untranslated /opt/odoo/addons/product_name_untranslated"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/product_pricelist_date /opt/odoo/addons/product_pricelist_date"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/product_pricelist_report_qweb /opt/odoo/addons/product_pricelist_report_qweb"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/product_price_visible /opt/odoo/addons/product_price_visible"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/product_product_multi_link /opt/odoo/addons/product_product_multi_link"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/product_properties_by_category /opt/odoo/addons/product_properties_by_category"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/product_rfq /opt/odoo/addons/product_rfq"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/products_finished_scrap /opt/odoo/addons/products_finished_scrap"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/product_unique_default_code /opt/odoo/addons/product_unique_default_code"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/product_uom_update /opt/odoo/addons/product_uom_update"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/project_complete_name /opt/odoo/addons/project_complete_name"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/project_contract_validations /opt/odoo/addons/project_contract_validations"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/project_followers_rule /opt/odoo/addons/project_followers_rule"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/project_image /opt/odoo/addons/project_image"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/project_issue_fix_progress /opt/odoo/addons/project_issue_fix_progress"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/project_issue_management /opt/odoo/addons/project_issue_management"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/project_issue_report /opt/odoo/addons/project_issue_report"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/project_issue_report2 /opt/odoo/addons/project_issue_report2"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/project_search_create_uid /opt/odoo/addons/project_search_create_uid"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/project_task_work /opt/odoo/addons/project_task_work"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/purchase_changeless_move_lines /opt/odoo/addons/purchase_changeless_move_lines"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/purchase_incoming_qty /opt/odoo/addons/purchase_incoming_qty"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/purchase_multi_report /opt/odoo/addons/purchase_multi_report"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/purchase_order_cancel /opt/odoo/addons/purchase_order_cancel"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/purchase_order_contract_analyst /opt/odoo/addons/purchase_order_contract_analyst"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/purchase_order_department /opt/odoo/addons/purchase_order_department"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/purchase_order_description /opt/odoo/addons/purchase_order_description"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/purchase_order_line_quantity /opt/odoo/addons/purchase_order_line_quantity"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/purchase_order_line_sequence /opt/odoo/addons/purchase_order_line_sequence"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/purchase_order_requisitor /opt/odoo/addons/purchase_order_requisitor"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/purchase_order_type /opt/odoo/addons/purchase_order_type"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/purchase_requisition_contract_analyst /opt/odoo/addons/purchase_requisition_contract_analyst"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/purchase_requisition_currency /opt/odoo/addons/purchase_requisition_currency"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/purchase_requisition_department /opt/odoo/addons/purchase_requisition_department"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/purchase_requisition_for_everybody /opt/odoo/addons/purchase_requisition_for_everybody"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/purchase_requisition_incoterms /opt/odoo/addons/purchase_requisition_incoterms"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/purchase_requisition_line_analytic /opt/odoo/addons/purchase_requisition_line_analytic"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/purchase_requisition_line_description /opt/odoo/addons/purchase_requisition_line_description"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/purchase_requisition_line_plan /opt/odoo/addons/purchase_requisition_line_plan"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/purchase_requisition_line_price_unit /opt/odoo/addons/purchase_requisition_line_price_unit"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/purchase_requisition_line_uom_check /opt/odoo/addons/purchase_requisition_line_uom_check"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/purchase_requisition_line_view /opt/odoo/addons/purchase_requisition_line_view"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/purchase_requisition_priority /opt/odoo/addons/purchase_requisition_priority"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/purchase_requisition_remarks /opt/odoo/addons/purchase_requisition_remarks"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/purchase_requisition_supplier_list /opt/odoo/addons/purchase_requisition_supplier_list"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/purchase_requisition_type /opt/odoo/addons/purchase_requisition_type"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/purchase_supplier /opt/odoo/addons/purchase_supplier"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/purchase_test_data_imp /opt/odoo/addons/purchase_test_data_imp"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/purchase_third_validation /opt/odoo/addons/purchase_third_validation"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/purchase_user_validation /opt/odoo/addons/purchase_user_validation"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/README.md /opt/odoo/addons/README.md"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/recovery_attachments_bd /opt/odoo/addons/recovery_attachments_bd"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/repo_requirements.txt /opt/odoo/addons/repo_requirements.txt"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/report_move_voucher /opt/odoo/addons/report_move_voucher"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/report_multicompany /opt/odoo/addons/report_multicompany"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/report_parser_html /opt/odoo/addons/report_parser_html"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/report_process_production /opt/odoo/addons/report_process_production"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/requirements.txt /opt/odoo/addons/requirements.txt"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/res_bank_menu_payroll /opt/odoo/addons/res_bank_menu_payroll"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/res_partner_btree /opt/odoo/addons/res_partner_btree"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/sale_block_cancellation /opt/odoo/addons/sale_block_cancellation"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/sale_date_confirm /opt/odoo/addons/sale_date_confirm"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/sale_double_validation /opt/odoo/addons/sale_double_validation"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/sale_line_import /opt/odoo/addons/sale_line_import"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/sale_margin_commision /opt/odoo/addons/sale_margin_commision"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/sale_margin_percentage /opt/odoo/addons/sale_margin_percentage"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/sale_order_copy_line /opt/odoo/addons/sale_order_copy_line"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/sale_order_create_task_planned_hours /opt/odoo/addons/sale_order_create_task_planned_hours"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/sale_order_customized /opt/odoo/addons/sale_order_customized"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/sale_order_dates_max /opt/odoo/addons/sale_order_dates_max"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/sale_order_line_quantity /opt/odoo/addons/sale_order_line_quantity"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/sale_test_data_imp /opt/odoo/addons/sale_test_data_imp"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/sale_uncommitted_product /opt/odoo/addons/sale_uncommitted_product"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/sale_uom_group /opt/odoo/addons/sale_uom_group"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/sale_website_cleanup /opt/odoo/addons/sale_website_cleanup"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/send_author_mail /opt/odoo/addons/send_author_mail"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/send_mail_task /opt/odoo/addons/send_mail_task"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/set_group_by_department /opt/odoo/addons/set_group_by_department"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/seudo_oca_dependencies.txt /opt/odoo/addons/seudo_oca_dependencies.txt"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/split_invoice_button /opt/odoo/addons/split_invoice_button"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/sprint_kanban /opt/odoo/addons/sprint_kanban"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/standard_price_acl /opt/odoo/addons/standard_price_acl"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/stock_accrual_report /opt/odoo/addons/stock_accrual_report"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/stock_allow_past_date /opt/odoo/addons/stock_allow_past_date"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/stock_card /opt/odoo/addons/stock_card"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/stock_card_segmentation /opt/odoo/addons/stock_card_segmentation"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/stock_deviation_account /opt/odoo/addons/stock_deviation_account"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/stock_easy_internal_transfer /opt/odoo/addons/stock_easy_internal_transfer"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/stock_hide_set_zero_button /opt/odoo/addons/stock_hide_set_zero_button"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/stock_inventory_delete /opt/odoo/addons/stock_inventory_delete"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/stock_invoice_state_editable /opt/odoo/addons/stock_invoice_state_editable"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/stock_landed_costs_average /opt/odoo/addons/stock_landed_costs_average"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/stock_landed_costs_segmentation /opt/odoo/addons/stock_landed_costs_segmentation"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/stock_location_acml /opt/odoo/addons/stock_location_acml"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/stock_location_code /opt/odoo/addons/stock_location_code"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/stock_move_entries /opt/odoo/addons/stock_move_entries"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/stock_move_name /opt/odoo/addons/stock_move_name"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/stock_move_tracking_number /opt/odoo/addons/stock_move_tracking_number"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/stock_picking_invoice_validation /opt/odoo/addons/stock_picking_invoice_validation"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/stock_picking_log_message_transfer /opt/odoo/addons/stock_picking_log_message_transfer"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/stock_picking_security_force /opt/odoo/addons/stock_picking_security_force"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/stock_picking_show_entries_info /opt/odoo/addons/stock_picking_show_entries_info"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/stock_picking_validate_past /opt/odoo/addons/stock_picking_validate_past"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/stock_purchase_analytic_plans /opt/odoo/addons/stock_purchase_analytic_plans"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/stock_purchase_check_fulfillment /opt/odoo/addons/stock_purchase_check_fulfillment"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/stock_purchase_expiry /opt/odoo/addons/stock_purchase_expiry"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/stock_purchase_requisitor /opt/odoo/addons/stock_purchase_requisitor"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/stock_purchase_type /opt/odoo/addons/stock_purchase_type"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/stock_quant_cost_segmentation /opt/odoo/addons/stock_quant_cost_segmentation"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/stock_quant_menu /opt/odoo/addons/stock_quant_menu"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/stock_sale_invoice_line /opt/odoo/addons/stock_sale_invoice_line"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/stock_sale_order_line /opt/odoo/addons/stock_sale_order_line"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/stock_transfer_avoid_lot_repeated_split /opt/odoo/addons/stock_transfer_avoid_lot_repeated_split"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/stock_unfuck /opt/odoo/addons/stock_unfuck"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/stock_view_product /opt/odoo/addons/stock_view_product"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/supplier_invoice_number_unique /opt/odoo/addons/supplier_invoice_number_unique"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/sync_youtube /opt/odoo/addons/sync_youtube"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/test_sale_team_warehouse /opt/odoo/addons/test_sale_team_warehouse"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/transaction_type /opt/odoo/addons/transaction_type"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/update_period /opt/odoo/addons/update_period"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/validate_stock_move_product /opt/odoo/addons/validate_stock_move_product"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/validate_stock_picking /opt/odoo/addons/validate_stock_picking"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/validate_type_line_invoice /opt/odoo/addons/validate_type_line_invoice"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/website_authorized_service_centers /opt/odoo/addons/website_authorized_service_centers"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/website_blog_rss /opt/odoo/addons/website_blog_rss"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/website_comment_approval /opt/odoo/addons/website_comment_approval"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/website_customer_also_purchased /opt/odoo/addons/website_customer_also_purchased"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/website_hr_social_icons /opt/odoo/addons/website_hr_social_icons"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/website_order_confirm /opt/odoo/addons/website_order_confirm"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/website_product_availability /opt/odoo/addons/website_product_availability"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/website_product_comment_purchased /opt/odoo/addons/website_product_comment_purchased"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/website_product_manufacturer_url /opt/odoo/addons/website_product_manufacturer_url"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/website_product_rss /opt/odoo/addons/website_product_rss"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/website_rate_product /opt/odoo/addons/website_rate_product"
su - odoo -c "ln -sfn /opt/odoo/source/vauxoo/addons-vauxoo/website_variants_extra /opt/odoo/addons/website_variants_extra"


echo "Installazione Odoo 11.0 moduli addons-onestein"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/onesteinbv/addons-onestein  /opt/odoo/source/onesteinbv/addons-onestein"
su - odoo -c "ln -sfn /opt/odoo/source/onesteinbv/addons-onestein/account_cost_center /opt/odoo/addons/account_cost_center"
su - odoo -c "ln -sfn /opt/odoo/source/onesteinbv/addons-onestein/account_cost_spread /opt/odoo/addons/account_cost_spread"
su - odoo -c "ln -sfn /opt/odoo/source/onesteinbv/addons-onestein/account_cost_spread_all /opt/odoo/addons/account_cost_spread_all"
su - odoo -c "ln -sfn /opt/odoo/source/onesteinbv/addons-onestein/account_fiscal_year_config /opt/odoo/addons/account_fiscal_year_config"
su - odoo -c "ln -sfn /opt/odoo/source/onesteinbv/addons-onestein/account_invoice_discount_formula /opt/odoo/addons/account_invoice_discount_formula"
su - odoo -c "ln -sfn /opt/odoo/source/onesteinbv/addons-onestein/base_directory_file_download /opt/odoo/addons/base_directory_file_download"
su - odoo -c "ln -sfn /opt/odoo/source/onesteinbv/addons-onestein/hr_absenteeism /opt/odoo/addons/hr_absenteeism"
su - odoo -c "ln -sfn /opt/odoo/source/onesteinbv/addons-onestein/hr_absenteeism_hours /opt/odoo/addons/hr_absenteeism_hours"
su - odoo -c "ln -sfn /opt/odoo/source/onesteinbv/addons-onestein/hr_holidays_approval_date /opt/odoo/addons/hr_holidays_approval_date"
su - odoo -c "ln -sfn /opt/odoo/source/onesteinbv/addons-onestein/hr_holidays_expiration /opt/odoo/addons/hr_holidays_expiration"
su - odoo -c "ln -sfn /opt/odoo/source/onesteinbv/addons-onestein/hr_holidays_leave_overlap /opt/odoo/addons/hr_holidays_leave_overlap"
su - odoo -c "ln -sfn /opt/odoo/source/onesteinbv/addons-onestein/l10n_nl_postcode /opt/odoo/addons/l10n_nl_postcode"
su - odoo -c "ln -sfn /opt/odoo/source/onesteinbv/addons-onestein/purchase_order_archive /opt/odoo/addons/purchase_order_archive"
su - odoo -c "ln -sfn /opt/odoo/source/onesteinbv/addons-onestein/sale_order_archive /opt/odoo/addons/sale_order_archive"
su - odoo -c "ln -sfn /opt/odoo/source/onesteinbv/addons-onestein/sale_order_discount_formula /opt/odoo/addons/sale_order_discount_formula"
su - odoo -c "ln -sfn /opt/odoo/source/onesteinbv/addons-onestein/sale_order_mass_confirm /opt/odoo/addons/sale_order_mass_confirm"


pip3 install -r /opt/odoo/source/ingadhoc/product/requirements.txt
pip3 install -r /opt/odoo/source/ingadhoc/account-invoicing/requirements.txt
pip3 install -r /opt/odoo/source/ingadhoc/reporting-engine/requirements.txt
pip3 install -r /opt/odoo/source/ingadhoc/partner/requirements.txt
pip3 install -r /opt/odoo/source/ingadhoc/sale/requirements.txt
pip3 install -r /opt/odoo/source/OCA/stock-logistics-barcode/requirements.txt
pip3 install -r /opt/odoo/source/OCA/server-tools/requirements.txt
pip3 install -r /opt/odoo/source/OCA/account-financial-tools/requirements.txt
pip3 install -r /opt/odoo/source/OCA/web/requirements.txt
pip3 install -r /opt/odoo/source/OCA/account-financial-reporting/requirements.txt
pip3 install -r /opt/odoo/source/OCA/reporting-engine/requirements.txt
pip3 install -r /opt/odoo/source/OCA/report-print-send/requirements.txt
pip3 install -r /opt/odoo/source/vauxoo/addons-vauxoo/requirements.txt
pip3 install -r /opt/odoo/source/it-projects-llc/misc-addons/requirements.txt
pip3 install -r /opt/odoo/source/it-projects-llc/website-addons/requirements.txt
pip3 install -r /opt/odoo/source/aeroo/aeroo_reports/requirements.txt





FINE











echo "Installazione Odoo 10.0 moduli connector"
su - odoo -c "mkdir -p /opt/odoo/source/OCA"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/connector /opt/odoo/source/OCA/connector"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/connector/component /opt/odoo/addons/component"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/connector/component_event /opt/odoo/addons/component_event"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/connector/connector /opt/odoo/addons/connector"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/connector/connector_base_product /opt/odoo/addons/connector_base_product"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/connector/test_component /opt/odoo/addons/test_component"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/connector/test_connector /opt/odoo/addons/test_connector"


echo "Installazione Odoo 10.0 moduli queue"
su - odoo -c "mkdir -p /opt/odoo/source/OCA"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/queue /opt/odoo/source/OCA/queue"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/queue/queue_job /opt/odoo/addons/queue_job"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/queue/queue_job_cron /opt/odoo/addons/queue_job_cron"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/queue/queue_job_subscribe /opt/odoo/addons/queue_job_subscribe"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/queue/test_queue_job /opt/odoo/addons/test_queue_job"












#su - odoo -c "git clone -b 10.0-mig-sale_commission https://github.com/hurrinico/commission /opt/odoo/source/hurrinico/10.0-mig-sale_commission-commission"
#su - odoo -c "ln -sfn /opt/odoo/source/hurrinico/10.0-mig-sale_commission-commission/sale_commission /opt/odoo/addons/sale_commission"

#su - odoo -c "git clone -b 10.0-mig-sale_commission_formula https://github.com/hurrinico/commission /opt/odoo/source/hurrinico/10.0-mig-sale_commission_formula-commission"
#su - odoo -c "ln -sfn /opt/odoo/source/hurrinico/10.0-mig-sale_commission_formula-commission/sale_commission_formula /opt/odoo/addons/sale_commission_formula"

#su - odoo -c "git clone -b 10.0-add-sale_commission_areamanager https://github.com/hurrinico/commission /opt/odoo/source/hurrinico/10.0-add-sale_commission_areamanager-commission"
#su - odoo -c "ln -sfn /opt/odoo/source/hurrinico/10.0-add-sale_commission_areamanager-commission/sale_commission_areamanager /opt/odoo/addons/sale_commission_areamanager"

<<<<<<< HEAD
echo "Installazione AerooLib"
mkdir /opt/aeroo
git clone https://github.com/aeroo/aeroolib.git /opt/aeroo/aeroolib
cd /opt/aeroo/aeroolib
python setup.py install
cd
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


su - odoo -c "git clone -b 11.0 https://github.com/aeroo/aeroo_reports.git /opt/odoo/source/aeroo/aeroo_reports"
su - odoo -c "ln -s /opt/odoo/source/aeroo/aeroo_reports/report_aeroo /opt/odoo/addons/report_aeroo"



<<<<<<< HEAD


#su - odoo -c "git clone -b 10.0-mig-product_replenishment_cost --single-branch https://github.com/fcoach66/margin-analysis  /opt/odoo/source/fcoach66/10.0-mig-product_replenishment_cost-margin-analysis"
#su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/10.0-mig-product_replenishment_cost-margin-analysis/product_replenishment_cost /opt/odoo/addons/product_replenishment_cost"

>>>>>>> origin/master










#echo "Installazione Odoo 10.0 moduli product-kitting"
#su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/product-kitting  /opt/odoo/source/OCA/product-kitting"




echo "Installazione Odoo 8.0 moduli multi-company"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/multi-company  /opt/odoo/source/OCA/multi-company"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/multi-company/account_invoice_inter_company /opt/odoo/addons/account_invoice_inter_company"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/multi-company/account_type_multi_company /opt/odoo/addons/account_type_multi_company"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/multi-company/base_multi_company /opt/odoo/addons/base_multi_company"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/multi-company/LICENSE /opt/odoo/addons/LICENSE"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/multi-company/oca_dependencies.txt /opt/odoo/addons/oca_dependencies.txt"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/multi-company/partner_multi_company /opt/odoo/addons/partner_multi_company"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/multi-company/product_autocompany /opt/odoo/addons/product_autocompany"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/multi-company/product_multi_company /opt/odoo/addons/product_multi_company"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/multi-company/product_name_unique_per_company /opt/odoo/addons/product_name_unique_per_company"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/multi-company/README.md /opt/odoo/addons/README.md"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/multi-company/sale_layout_multi_company /opt/odoo/addons/sale_layout_multi_company"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/multi-company/sales_team_multicompany /opt/odoo/addons/sales_team_multicompany"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/multi-company/setup /opt/odoo/addons/setup"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/multi-company/stock_production_lot_multi_company /opt/odoo/addons/stock_production_lot_multi_company"




echo "Installazione Odoo 8.0 moduli pos"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/pos  /opt/odoo/source/OCA/pos"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/pos/account_cash_invoice /opt/odoo/addons/account_cash_invoice"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/pos/oca_dependencies.txt /opt/odoo/addons/oca_dependencies.txt"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/pos/pos_backend_communication /opt/odoo/addons/pos_backend_communication"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/pos/pos_backend_partner /opt/odoo/addons/pos_backend_partner"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/pos/pos_customer_display /opt/odoo/addons/pos_customer_display"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/pos/pos_default_empty_image /opt/odoo/addons/pos_default_empty_image"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/pos/pos_default_payment_method /opt/odoo/addons/pos_default_payment_method"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/pos/pos_fix_search_limit /opt/odoo/addons/pos_fix_search_limit"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/pos/pos_gift_ticket /opt/odoo/addons/pos_gift_ticket"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/pos/pos_lot_selection /opt/odoo/addons/pos_lot_selection"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/pos/pos_loyalty /opt/odoo/addons/pos_loyalty"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/pos/pos_margin /opt/odoo/addons/pos_margin"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/pos/pos_order_return /opt/odoo/addons/pos_order_return"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/pos/pos_payment_terminal /opt/odoo/addons/pos_payment_terminal"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/pos/pos_pricelist /opt/odoo/addons/pos_pricelist"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/pos/pos_price_to_weight /opt/odoo/addons/pos_price_to_weight"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/pos/pos_product_template /opt/odoo/addons/pos_product_template"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/pos/pos_quick_logout /opt/odoo/addons/pos_quick_logout"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/pos/pos_remove_pos_category /opt/odoo/addons/pos_remove_pos_category"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/pos/pos_session_pay_invoice /opt/odoo/addons/pos_session_pay_invoice"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/pos/pos_stock_picking_invoice_link /opt/odoo/addons/pos_stock_picking_invoice_link"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/pos/pos_timeout /opt/odoo/addons/pos_timeout"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/pos/README.md /opt/odoo/addons/README.md"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/pos/requirements.txt /opt/odoo/addons/requirements.txt"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/pos/setup /opt/odoo/addons/setup"






#su - odoo -c "git clone -b 10-port-purchase_discount --single-branch https://github.com/akretion/purchase-workflow  /opt/odoo/source/akretion/10-port-purchase_discount-purchase-workflow"
#su - odoo -c "ln -sfn /opt/odoo/source/akretion/10-port-purchase_discount-purchase-workflow/purchase_discount /opt/odoo/addons/purchase_discount"





#echo "Installazione Odoo 8.0 moduli community-data-files"
#su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/community-data-files  /opt/odoo/source/OCA/community-data-files"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/community-data-files/account_payment_unece /opt/odoo/addons/account_payment_unece"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/community-data-files/account_tax_unece /opt/odoo/addons/account_tax_unece"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/community-data-files/base_iso3166 /opt/odoo/addons/base_iso3166"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/community-data-files/base_unece /opt/odoo/addons/base_unece"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/community-data-files/l10n_eu_nace /opt/odoo/addons/l10n_eu_nace"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/community-data-files/product_uom_unece /opt/odoo/addons/product_uom_unece"


#echo "Installazione Odoo 8.0 moduli geospatial"
#su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/geospatial  /opt/odoo/source/OCA/geospatial"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/geospatial/base_geoengine /opt/odoo/addons/base_geoengine"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/geospatial/base_geoengine_demo /opt/odoo/addons/base_geoengine_demo"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/geospatial/geoengine_base_geolocalize /opt/odoo/addons/geoengine_base_geolocalize"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/geospatial/geoengine_geoname_geocoder /opt/odoo/addons/geoengine_geoname_geocoder"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/geospatial/geoengine_maplausanne /opt/odoo/addons/geoengine_maplausanne"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/geospatial/geoengine_partner /opt/odoo/addons/geoengine_partner"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/geospatial/geoengine_project /opt/odoo/addons/geoengine_project"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/geospatial/geoengine_sale /opt/odoo/addons/geoengine_sale"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/geospatial/geoengine_swisstopo /opt/odoo/addons/geoengine_swisstopo"


#echo "Installazione Odoo 8.0 moduli vertical-isp"
#su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/vertical-isp  /opt/odoo/source/OCA/vertical-isp"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/vertical-isp/contract_isp /opt/odoo/addons/contract_isp"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/vertical-isp/contract_isp_automatic_invoicing /opt/odoo/addons/contract_isp_automatic_invoicing"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/vertical-isp/contract_isp_invoice /opt/odoo/addons/contract_isp_invoice"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/vertical-isp/contract_isp_package_configurator /opt/odoo/addons/contract_isp_package_configurator"
#su - odoo -c "ln -sfn /opt/odoo/source/OCA/vertical-isp/product_dependencies /opt/odoo/addons/product_dependencies"


















#echo "Installazione Odoo 10.0 modulo l10n-italy l10n_it_withholding_tax"
#su - odoo -c "mkdir -p /opt/odoo/source/elbati"
#su - odoo -c "git clone -b porting_withholding_tax_8 --single-branch https://github.com/eLBati/l10n-italy /opt/odoo/source/elbati/l10n-italy-withholding_tax"
#su - odoo -c "ln -s /opt/odoo/source/elbati/l10n-italy-withholding_tax/l10n_it_withholding_tax /opt/odoo/addons/l10n_it_withholding_tax"








#su - odoo -c "git clone -b 10.0-mig-product_replenishment_cost_currency_rule --single-branch https://github.com/fcoach66/product  /opt/odoo/source/fcoach66/10.0-mig-product_replenishment_cost_currency_rule-product"
#su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/10.0-mig-product_replenishment_cost_currency_rule-product/product_replenishment_cost_currency /opt/odoo/addons/product_replenishment_cost_currency"
#su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/10.0-mig-product_replenishment_cost_currency_rule-product/product_replenishment_cost_rule /opt/odoo/addons/product_replenishment_cost_rule"
#su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/10.0-mig-product_replenishment_cost_currency_rule-product/product_sale_price_by_margin /opt/odoo/addons/product_sale_price_by_margin"
#su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/10.0-mig-product_replenishment_cost_currency_rule-product/product_computed_list_price /opt/odoo/addons/product_computed_list_price"







echo "Installazione Odoo 10.0 moduli techreceptives website_recaptcha"
#su - odoo -c "mkdir -p /opt/odoo/source/techreceptives"
#su - odoo -c "git clone -b 10.0 --single-branch https://github.com/techreceptives/website_recaptcha /opt/odoo/source/techreceptives/website_recaptcha"
#su - odoo -c "ln -s /opt/odoo/source/techreceptives/website_recaptcha/website_crm_recaptcha_reloaded /opt/odoo/addons/website_crm_recaptcha_reloaded"
#su - odoo -c "ln -s /opt/odoo/source/techreceptives/website_recaptcha/website_forum_recaptcha_reloaded /opt/odoo/addons/website_forum_recaptcha_reloaded"
#su - odoo -c "ln -s /opt/odoo/source/techreceptives/website_recaptcha/website_recaptcha_reloaded /opt/odoo/addons/website_recaptcha_reloaded"
#su - odoo -c "ln -s /opt/odoo/source/techreceptives/website_recaptcha/website_signup_recaptcha_reloaded /opt/odoo/addons/website_signup_recaptcha_reloaded"


echo "Installazione Odoo 10.0 moduli initos openerp-dav"
#su - odoo -c "mkdir -p /opt/odoo/source/initos"
#su - odoo -c "git clone -b 10.0 --single-branch https://github.com/initOS/openerp-dav /opt/odoo/source/initOS/openerp-dav"
#su - odoo -c "ln -s /opt/odoo/source/initOS/openerp-dav/base_vcard /opt/odoo/addons/base_vcard"
#su - odoo -c "ln -s /opt/odoo/source/initOS/openerp-dav/crm_vcard /opt/odoo/addons/crm_vcard"
#su - odoo -c "ln -s /opt/odoo/source/initOS/openerp-dav/document_carddav /opt/odoo/addons/document_carddav"
#su - odoo -c "ln -s /opt/odoo/source/initOS/openerp-dav/document_webdav_fast /opt/odoo/addons/document_webdav_fast"





#echo "Installazione Odoo 10.0 moduli abstract l10n_it_prima_nota_cassa"
#su - odoo -c "mkdir -p /opt/odoo/source/abstract-open-solutions"
#su - odoo -c "git clone -b 10.0-prima-nota-cassa --single-branch https://github.com/abstract-open-solutions/l10n-italy /opt/odoo/source/abstract-open-solutions/l10n-italy-l10n_it_prima_nota_cassa"
#su - odoo -c "ln -s /opt/odoo/source/abstract-open-solutions/l10n-italy-l10n_it_prima_nota_cassa/l10n_it_prima_nota_cassa /opt/odoo/addons/l10n_it_prima_nota_cassa"

#echo "Installazione Odoo 10.0 moduli abstract intrastat codes"
#su - odoo -c "mkdir -p /opt/odoo/source/abstract-open-solutions"
#su - odoo -c "git clone -b 10.0-intrastat-codes --single-branch https://github.com/abstract-open-solutions/l10n-italy /opt/odoo/source/abstract-open-solutions/l10n-italy-intrastat-codes"
#su - odoo -c "ln -s /opt/odoo/source/abstract-open-solutions/l10n-italy-intrastat-codes/l10n_it_intrastat_codes /opt/odoo/addons/l10n_it_intrastat_codes"

#echo "Installazione Odoo 10.0 moduli abstract intrastat review"
#su - odoo -c "mkdir -p /opt/odoo/source/abstract-open-solutions"
#su - odoo -c "git clone -b 10.0-intrastat-review --single-branch https://github.com/abstract-open-solutions/l10n-italy /opt/odoo/source/abstract-open-solutions/l10n-italy-intrastat-review"
#su - odoo -c "ln -s /opt/odoo/source/abstract-open-solutions/l10n-italy-intrastat-review/l10n_it_intrastat /opt/odoo/addons/l10n_it_intrastat"



#echo "Installazione Odoo 10.0 moduli zeroincombenze l10n-italy-supplemental"
#su - odoo -c "git clone -b 10.0 --single-branch https://github.com/zeroincombenze/l10n-italy-supplemental /opt/odoo/source/zeroincombenze/l10n-italy-supplemental"
#su - odoo -c "ln -sfn /opt/odoo/source/zeroincombenze/l10n-italy-supplemental/l10n_it_fiscal /opt/odoo/addons/l10n_it_fiscal"
#su - odoo -c "ln -sfn /opt/odoo/source/zeroincombenze/l10n-italy-supplemental/l10n_it_spesometro /opt/odoo/addons/l10n_it_spesometro"
#su - odoo -c "ln -sfn /opt/odoo/source/zeroincombenze/l10n-italy-supplemental/tndb /opt/odoo/addons/tndb"

echo "Installazione Odoo 11.0 moduli odoo-italy-extra"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/fcoach66/odoo-italy-extra  /opt/odoo/source/fcoach66/odoo-italy-extra"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-italy-extra/l10n_it_report_extended /opt/odoo/addons/	l10n_it_report_extended"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-italy-extra/l10n_it_aeroo_base /opt/odoo/addons/l10n_it_aeroo_base"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-italy-extra/l10n_it_aeroo_invoice /opt/odoo/addons/l10n_it_aeroo_invoice"
#su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-italy-extra/l10n_it_aeroo_ddt /opt/odoo/addons/l10n_it_aeroo_ddt"
#su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-italy-extra/l10n_it_aeroo_sale /opt/odoo/addons/l10n_it_aeroo_sale"
#su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-italy-extra/odoo_fcoach66_fix /opt/odoo/addons/odoo_fcoach66_fix"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-italy-extra/sale_additional_text_template /opt/odoo/addons/sale_additional_text_template"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-italy-extra/sale_mandatory_fields /opt/odoo/addons/sale_mandatory_fields"


su - odoo -c "git clone -b 10.0 --single-branch https://github.com/fcoach66/odoo-dev  /opt/odoo/source/fcoach66/odoo-dev"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-dev/todo_app /opt/odoo/addons/todo_app"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-dev/todo_user /opt/odoo/addons/todo_user"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-dev/todo_ui /opt/odoo/addons/todo_ui"


echo "Installazione Odoo 8.0 moduli odoo-usability"
su - odoo -c "git clone -b 10.0-fcoach66 --single-branch https://github.com/fcoach66/odoo-usability  /opt/odoo/source/fcoach66/odoo-usability"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/account_bank_statement_import_fr_hsbc_card /opt/odoo/addons/account_bank_statement_import_fr_hsbc_card"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/account_bank_statement_import_usability /opt/odoo/addons/account_bank_statement_import_usability"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/account_bank_statement_no_reconcile_guess /opt/odoo/addons/account_bank_statement_no_reconcile_guess"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/account_credit_control_usability /opt/odoo/addons/account_credit_control_usability"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/account_cutoff_accrual_picking_ods /opt/odoo/addons/account_cutoff_accrual_picking_ods"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/account_cutoff_prepaid_ods /opt/odoo/addons/account_cutoff_prepaid_ods"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/account_direct_debit_autogenerate /opt/odoo/addons/account_direct_debit_autogenerate"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/account_hide_analytic_line /opt/odoo/addons/account_hide_analytic_line"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/account_invoice_margin /opt/odoo/addons/account_invoice_margin"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/account_invoice_margin_report /opt/odoo/addons/account_invoice_margin_report"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/account_invoice_partner_bank_usability /opt/odoo/addons/account_invoice_partner_bank_usability"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/account_move_line_filter_wizard /opt/odoo/addons/account_move_line_filter_wizard"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/account_move_line_start_end_dates_xls /opt/odoo/addons/account_move_line_start_end_dates_xls"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/account_no_analytic_tags /opt/odoo/addons/account_no_analytic_tags"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/account_usability /opt/odoo/addons/account_usability"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/aeroo_report_to_printer /opt/odoo/addons/aeroo_report_to_printer"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/attribute_usability /opt/odoo/addons/attribute_usability"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/base_company_extension /opt/odoo/addons/base_company_extension"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/base_mail_sender_bcc /opt/odoo/addons/base_mail_sender_bcc"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/base_other_report_engines /opt/odoo/addons/base_other_report_engines"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/base_partner_one2many_phone /opt/odoo/addons/base_partner_one2many_phone"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/base_partner_prospect /opt/odoo/addons/base_partner_prospect"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/base_partner_ref /opt/odoo/addons/base_partner_ref"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/base_usability /opt/odoo/addons/base_usability"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/calendar_default_value /opt/odoo/addons/calendar_default_value"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/crm_partner_prospect /opt/odoo/addons/crm_partner_prospect"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/crm_usability /opt/odoo/addons/crm_usability"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/delivery_no_invoice_shipping /opt/odoo/addons/delivery_no_invoice_shipping"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/eradicate_quick_create /opt/odoo/addons/eradicate_quick_create"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/hr_expense_private_car /opt/odoo/addons/hr_expense_private_car"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/hr_expense_usability /opt/odoo/addons/hr_expense_usability"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/hr_expense_usability_dp /opt/odoo/addons/hr_expense_usability_dp"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/hr_holidays_usability /opt/odoo/addons/hr_holidays_usability"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/hr_usability /opt/odoo/addons/hr_usability"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/intrastat_product_type /opt/odoo/addons/intrastat_product_type"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/l10n_fr_infogreffe_connector /opt/odoo/addons/l10n_fr_infogreffe_connector"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/l10n_fr_intrastat_product_ods /opt/odoo/addons/l10n_fr_intrastat_product_ods"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/l10n_fr_usability /opt/odoo/addons/l10n_fr_usability"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/mail_usability /opt/odoo/addons/mail_usability"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/mrp_average_cost /opt/odoo/addons/mrp_average_cost"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/mrp_export_field_profile /opt/odoo/addons/mrp_export_field_profile"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/mrp_no_product_template_menu /opt/odoo/addons/mrp_no_product_template_menu"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/mrp_usability /opt/odoo/addons/mrp_usability"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/partner_aged_open_invoices /opt/odoo/addons/partner_aged_open_invoices"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/partner_firstname_first /opt/odoo/addons/partner_firstname_first"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/partner_market /opt/odoo/addons/partner_market"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/partner_products_shortcut /opt/odoo/addons/partner_products_shortcut"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/partner_search /opt/odoo/addons/partner_search"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/partner_tree_default /opt/odoo/addons/partner_tree_default"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/phone_directory_report /opt/odoo/addons/phone_directory_report"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/pos_config_single_user /opt/odoo/addons/pos_config_single_user"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/pos_journal_sequence /opt/odoo/addons/pos_journal_sequence"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/pos_sale_report /opt/odoo/addons/pos_sale_report"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/pos_second_ean13 /opt/odoo/addons/pos_second_ean13"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/pos_usability /opt/odoo/addons/pos_usability"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/procurement_usability /opt/odoo/addons/procurement_usability"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/product_category_tax /opt/odoo/addons/product_category_tax"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/product_export_field_profile /opt/odoo/addons/product_export_field_profile"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/product_manager_group /opt/odoo/addons/product_manager_group"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/product_manager_group_stock /opt/odoo/addons/product_manager_group_stock"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/product_search_supplier_code /opt/odoo/addons/product_search_supplier_code"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/product_usability /opt/odoo/addons/product_usability"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/product_variant_csv_import /opt/odoo/addons/product_variant_csv_import"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/project_issue_extension /opt/odoo/addons/project_issue_extension"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/purchase_auto_invoice_method /opt/odoo/addons/purchase_auto_invoice_method"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/purchase_date_planned_update /opt/odoo/addons/purchase_date_planned_update"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/purchase_hide_report_print_menu /opt/odoo/addons/purchase_hide_report_print_menu"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/purchase_no_analytic_tags /opt/odoo/addons/purchase_no_analytic_tags"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/purchase_usability /opt/odoo/addons/purchase_usability"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/sale_confirm_wizard /opt/odoo/addons/sale_confirm_wizard"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/sale_crm_usability /opt/odoo/addons/sale_crm_usability"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/sale_from_private_stock /opt/odoo/addons/sale_from_private_stock"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/sale_layout_category_per_order /opt/odoo/addons/sale_layout_category_per_order"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/sale_layout_category_product /opt/odoo/addons/sale_layout_category_product"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/sale_margin_no_onchange /opt/odoo/addons/sale_margin_no_onchange"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/sale_margin_report /opt/odoo/addons/sale_margin_report"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/sale_no_analytic_tags /opt/odoo/addons/sale_no_analytic_tags"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/sale_no_filter_myorder /opt/odoo/addons/sale_no_filter_myorder"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/sale_order_add_bom /opt/odoo/addons/sale_order_add_bom"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/sale_partner_prospect /opt/odoo/addons/sale_partner_prospect"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/sale_purchase_no_product_template_menu /opt/odoo/addons/sale_purchase_no_product_template_menu"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/sale_quotation_title /opt/odoo/addons/sale_quotation_title"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/sale_stock_usability /opt/odoo/addons/sale_stock_usability"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/sale_usability /opt/odoo/addons/sale_usability"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/sale_usability_b2b /opt/odoo/addons/sale_usability_b2b"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/stock_account_usability /opt/odoo/addons/stock_account_usability"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/stock_inventory_valuation_ods /opt/odoo/addons/stock_inventory_valuation_ods"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/stock_my_operations_filter /opt/odoo/addons/stock_my_operations_filter"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/stock_picking_type_default_partner /opt/odoo/addons/stock_picking_type_default_partner"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/stock_picking_zip /opt/odoo/addons/stock_picking_zip"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/stock_transfer_continue_later /opt/odoo/addons/stock_transfer_continue_later"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/stock_usability /opt/odoo/addons/stock_usability"
su - odoo -c "ln -sfn /opt/odoo/source/fcoach66/odoo-usability/web_eradicate_duplicate /opt/odoo/addons/web_eradicate_duplicate"


