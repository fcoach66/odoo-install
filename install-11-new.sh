#!/bin/bash

#--------------------------------------------------
# Update Server
#--------------------------------------------------
echo -e "\n---- Update Server ----"
apt-get update && sudo apt-get dist-upgrade -y && sudo apt-get autoremove -y
apt-get install default-jre -y
apt install -y software-properties-common
add-apt-repository -y ppa:webupd8team/java
apt-get install default-jdk -y
apt-get update
apt-get install oracle-java8-installer -y


echo "Installazione Database Postgresql"
sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
apt-get update
apt-get upgrade -y
apt-get install -y postgresql-10 postgresql-server-dev-10

echo -e "\n---- Install tool packages ----"
apt-get install wget subversion git bzr bzrtools python-pip python3-pip gdebi-core -y

apt-get install -y libsasl2-dev python-dev libldap2-dev libssl-dev python3-dev libxml2-dev libxslt1-dev zlib1g-dev python3-pip python3-wheel python3-setuptools python3-babel python3-bs4 python3-cffi-backend python3-cryptography python3-dateutil python3-docutils python3-feedparser python3-funcsigs python3-gevent python3-greenlet python3-html2text python3-html5lib python3-jinja2 python3-lxml python3-mako python3-markupsafe python3-mock python3-ofxparse python3-openssl python3-passlib python3-pbr python3-pil python3-psutil python3-psycopg2 python3-pydot python3-pygments python3-pyparsing python3-pypdf2 python3-renderpm python3-reportlab python3-reportlab-accel python3-roman python3-serial python3-stdnum python3-suds python3-tz python3-usb python3-vatnumber python3-werkzeug python3-xlsxwriter python3-yaml
pip3 install --upgrade pip
/usr/local/bin/pip3 install --upgrade -r https://raw.githubusercontent.com/OCA/OCB/11.0/requirements.txt

wget https://downloads.wkhtmltopdf.org/0.12/0.12.5/wkhtmltox_0.12.5-1.bionic_amd64.deb
gdebi --n wkhtmltox_0.12.5-1.bionic_amd64.deb

echo -e "\n---- Install python libraries ----"
# This is for compatibility with Ubuntu 16.04. Will work on 14.04, 15.04 and 16.04
apt-get install python3-suds -y

echo -e "\n--- Install other required packages"
apt-get install node-clean-css node-less python-gevent -y

#echo -e "\n--- Create symlink for node"
#sudo ln -s /usr/bin/nodejs /usr/bin/node

/usr/local/bin/pip3 install num2words ofxparse
apt-get install nodejs npm node-less -y
#sudo npm install -g less
#sudo npm install -g less-plugin-clean-css	

	
	
echo "Installazione Odoo 11.0"
adduser odoo --system --group --shell /bin/bash --home /opt/odoo
sudo -u postgres createuser -s odoo
sudo -u postgres psql -c "ALTER USER odoo WITH PASSWORD 'odoo';"
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'odoo';"
su - odoo -c "mkdir -p /opt/odoo/addons"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/OCB.git /opt/odoo/server"
su - odoo -c "git clone -b 11.0 https://github.com/OCA/reporting-engine /opt/odoo/source/2-OCA/reporting-engine"
/usr/local/bin/pip3 install --upgrade -r https://raw.githubusercontent.com/OCA/reporting-engine/11.0/requirements.txt

sudo chown -R odoo:odoo /opt/odoo/odoodev11/server
sudo chown -R odoo:odoo /opt/odoo/odoodev11
/usr/local/bin/pip3 install geojson

echo "Installazione pyxb"
/usr/local/bin/pip3 install pyxb==1.2.5

echo "Installazione codicefiscale"
/usr/local/bin/pip3 install codicefiscale

echo "Installazione simplejson"
/usr/local/bin/pip3 install simplejson

echo "Installazione unidecode"
/usr/local/bin/pip3 install unidecode

echo "Installazione phonenumbers"
/usr/local/bin/pip3 install phonenumbers

echo "Installazione numpy"
/usr/local/bin/pip3 install numpy

echo "Installazione cachetools"
/usr/local/bin/pip3 install cachetools

/usr/local/bin/pip3 install ldap

su - odoo -c 'for d in $( ls source); do  find $(pwd)/source/$d -mindepth 2 -maxdepth 2 -type d -exec sh -c "ln -sfn \"{}\" $(pwd)/addons" \;; done'

su - odoo -c "/opt/odoo/server/odoo-bin --stop-after-init -s -c /opt/odoo/odoo_serverrc --db_host=localhost --db_user=odoo --db_password=odoo --addons-path=/opt/odoo/server/odoo/addons,/opt/odoo/server/addons,/opt/odoo/addons"

mv /opt/odoo/odoo_serverrc /etc/odoo-server.conf
chown odoo:odoo /etc/odoo-server.conf
sed -i "s/db_password = False/db_password = odoo/g" /etc/odoo-server.conf
wget https://raw.githubusercontent.com/fcoach66/odoo-install/master/logrotate -O /etc/logrotate.d/odoo-server
chmod 755 /etc/logrotate.d/odoo-server
wget https://raw.githubusercontent.com/fcoach66/odoo-install/master/odoo10.init.d -O /etc/init.d/odoo-server
sudo chmod +x /etc/init.d/odoo-server
sudo update-rc.d odoo-server defaults

# Install ngnx apache-utils
apt-get install -y nginx apache2-utils
wget https://raw.githubusercontent.com/fcoach66/odoo-install/master/odoo.nginx -O /etc/nginx/sites-available/odoo.nginx
rm /etc/nginx/sites-enabled/default 
ln -s /etc/nginx/sites-available/odoo.nginx /etc/nginx/sites-enabled/odoo.nginx
mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.old
wget https://raw.githubusercontent.com/fcoach66/odoo-install/master/nginx.conf -O /etc/nginx/nginx.conf
htpasswd -cb /etc/nginx/htpasswd odoo odoo
mkdir -p /etc/nginx/ssl
openssl req -new -x509 -days 3650 -nodes -out /etc/nginx/ssl/cert.pem -keyout /etc/nginx/ssl/private.key

echo "Installazione Aeroo"
apt-get install -y libreoffice libreoffice-script-provider-python
mkdir /opt/aeroo
echo '#!/bin/sh' > /etc/init.d/office
echo '' >> /etc/init.d/office
echo '/usr/bin/soffice --nologo --nofirststartwizard --headless --norestore --invisible "--accept=socket,host=localhost,port=8100,tcpNoDelay=1;urp;" &'  >> /etc/init.d/office
chmod +x /etc/init.d/office
update-rc.d office defaults
/etc/init.d/office
/usr/local/bin/pip3 install jsonrpc2 daemonize
git clone https://github.com/aeroo/aeroo_docs.git /opt/aeroo/aeroo_docs
cd /opt/aeroo/aeroo_docs/
echo "Y" | python3 /opt/aeroo/aeroo_docs/aeroo-docs start -c /etc/aeroo-docs.conf
ln -s /opt/aeroo/aeroo_docs/aeroo-docs /etc/init.d/aeroo-docs
update-rc.d aeroo-docs defaults




su - odoo -c "git clone -b 11.0 https://github.com/ingadhoc/aeroo_reports.git /opt/odoo/source/3-ingadhoc/aeroo_reports"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/server-tools  /opt/odoo/source/2-OCA/server-tools"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/server-ux  /opt/odoo/source/2-OCA/server-ux"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/partner-contact  /opt/odoo/source/2-OCA/partner-contact"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/l10n-italy  /opt/odoo/source/2-OCA/l10n-italy"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/ingadhoc/miscellaneous  /opt/odoo/source/3-ingadhoc/miscellaneous"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/ingadhoc/odoo-argentina  /opt/odoo/source/3-ingadhoc/odoo-argentina"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/ingadhoc/argentina-sale  /opt/odoo/source/3-ingadhoc/argentina-sale"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/ingadhoc/argentina-reporting  /opt/odoo/source/3-ingadhoc/argentina-reporting"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/ingadhoc/account-financial-tools  /opt/odoo/source/3-ingadhoc/account-financial-tools"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/ingadhoc/reporting-engine  /opt/odoo/source/3-ingadhoc/reporting-engine"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/ingadhoc/account-payment  /opt/odoo/source/3-ingadhoc/account-payment"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/ingadhoc/partner  /opt/odoo/source/3-ingadhoc/partner"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/ingadhoc/sale  /opt/odoo/source/3-ingadhoc/sale"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/ingadhoc/account-invoicing  /opt/odoo/source/3-ingadhoc/account-invoicing"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/ingadhoc/product  /opt/odoo/source/3-ingadhoc/product"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/account-payment  /opt/odoo/source/2-OCA/account-payment"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/account-financial-reporting  /opt/odoo/source/2-OCA/account-financial-reporting"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/account-financial-tools  /opt/odoo/source/2-OCA/account-financial-tools"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/account-closing  /opt/odoo/source/2-OCA/account-closing"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/account-analytic  /opt/odoo/source/2-OCA/account-analytic"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/account-invoicing  /opt/odoo/source/2-OCA/account-invoicing"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/account-invoice-reporting  /opt/odoo/source/2-OCA/account-invoice-reporting"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/account-budgeting /opt/odoo/source/2-OCA/account-budgeting"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/account-consolidation /opt/odoo/source/2-OCA/account-consolidation"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/bank-payment  /opt/odoo/source/2-OCA/bank-payment"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/bank-statement-reconcile  /opt/odoo/source/2-OCA/bank-statement-reconcile"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/bank-statement-import  /opt/odoo/source/2-OCA/bank-statement-import"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/product-attribute  /opt/odoo/source/2-OCA/product-attribute"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/product-variant /opt/odoo/source/2-OCA/product-variant"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/stock-logistics-warehouse  /opt/odoo/source/2-OCA/stock-logistics-warehouse"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/stock-logistics-tracking  /opt/odoo/source/2-OCA/stock-logistics-tracking"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/stock-logistics-barcode  /opt/odoo/source/2-OCA/stock-logistics-barcode"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/stock-logistics-workflow  /opt/odoo/source/2-OCA/stock-logistics-workflow"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/stock-logistics-transport  /opt/odoo/source/2-OCA/stock-logistics-transport"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/sale-workflow  /opt/odoo/source/2-OCA/sale-workflow"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/sale-financial /opt/odoo/source/2-OCA/sale-financial"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/sale-reporting /opt/odoo/source/2-OCA/sale-reporting"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/web  /opt/odoo/source/2-OCA/web"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/website  /opt/odoo/source/2-OCA/website"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/event /opt/odoo/source/2-OCA/event"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/survey /opt/odoo/source/2-OCA/survey"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/social  /opt/odoo/source/2-OCA/social"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/e-commerce  /opt/odoo/source/2-OCA/e-commerce"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/commission /opt/odoo/source/2-OCA/commission"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/margin-analysis  /opt/odoo/source/2-OCA/margin-analysis"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/contract  /opt/odoo/source/2-OCA/contract"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/rma  /opt/odoo/source/2-OCA/rma"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/crm  /opt/odoo/source/2-OCA/crm"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/project-service  /opt/odoo/source/2-OCA/project-service"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/carrier-delivery  /opt/odoo/source/2-OCA/carrier-delivery"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/stock-logistics-reporting /opt/odoo/source/2-OCA/stock-logistics-reporting"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/hr-timesheet  /opt/odoo/source/2-OCA/hr-timesheet"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/hr  /opt/odoo/source/2-OCA/hr"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/management-system  /opt/odoo/source/2-OCA/management-system"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/report-print-send  /opt/odoo/source/2-OCA/report-print-send"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/purchase-reporting  /opt/odoo/source/2-OCA/purchase-reporting"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/purchase-workflow  /opt/odoo/source/2-OCA/purchase-workflow"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/manufacture-reporting  /opt/odoo/source/2-OCA/manufacture-reporting"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/knowledge  /opt/odoo/source/2-OCA/knowledge"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/project-reporting  /opt/odoo/source/2-OCA/project-reporting"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/project  /opt/odoo/source/2-OCA/project"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/connector /opt/odoo/source/2-OCA/connector"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/queue /opt/odoo/source/2-OCA/queue"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/multi-company  /opt/odoo/source/2-OCA/multi-company"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/pos  /opt/odoo/source/2-OCA/pos"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/community-data-files  /opt/odoo/source/2-OCA/community-data-files"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/geospatial  /opt/odoo/source/2-OCA/geospatial"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/vertical-isp  /opt/odoo/source/2-OCA/vertical-isp"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/hr-timesheet /opt/odoo/source/2-OCA/hr-timesheet"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/server-auth /opt/odoo/source/2-OCA/server-auth"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/intrastat /opt/odoo/source/2-OCA/intrastat"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/edi /opt/odoo/source/2-OCA/edi"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/account-reconcile /opt/odoo/source/2-OCA/account-reconcile"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/operating-unit /opt/odoo/source/2-OCA/operating-unit"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/currency /opt/odoo/source/2-OCA/currency"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/website-themes /opt/odoo/source/2-OCA/website-themes"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/server-brand  /opt/odoo/source/2-OCA/server-brand"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/server-backend  /opt/odoo/source/2-OCA/server-backend"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/field-service  /opt/odoo/source/2-OCA/field-service"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/website-cms  /opt/odoo/source/2-OCA/website-cms"


su - odoo -c "git clone -b 11.0 --single-branch https://github.com/it-projects-llc/misc-addons  /opt/odoo/source/1-it-projects-llc/misc-addons"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/it-projects-llc/access-addons  /opt/odoo/source/1-it-projects-llc/access-addons"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/it-projects-llc/pos-addons  /opt/odoo/source/1-it-projects-llc/pos-addons"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/it-projects-llc/website-addons  /opt/odoo/source/1-it-projects-llc/website-addons"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/it-projects-llc/mail-addons  /opt/odoo/source/1-it-projects-llc/mail-addons"

su - odoo -c "git clone -b 11.0 --single-branch https://github.com/vauxoo/addons-vauxoo /opt/odoo/source/5-vauxoo/addons-vauxoo"

su - odoo -c "git clone -b 11.0 --single-branch https://github.com/onesteinbv/addons-onestein  /opt/odoo/source/6-onesteinbv/addons-onestein"



#su - odoo -c "git clone -b 11.0-mig-account_analytic_distribution --single-branch https://github.com/Tecnativa/account-analytic/ /opt/odoo/source/1-Tecnativa/11.0-mig-account_analytic_distribution-account-analytic"


su - odoo -c "git clone -b 11.0-mig-invoice_comment_template --single-branch https://github.com/QubiQ/account-invoice-reporting /opt/odoo/source/1-QubiQ/account-invoice-reporting"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/QubiQ/qu-server-tools /opt/odoo/source/1-QubiQ/qu-server-tools"

#su - odoo -c "git clone -b 11.0-mig-l10n_it_split_payment_\(rt\) --single-branch https://github.com/ruben-tonetto/l10n-italy /opt/odoo/source/0-ruben-tonetto/11.0-mig-l10n_it_split_payment_\(rt\)"
su - odoo -c "git clone -b 11.0-porting-l10n_it_vat_registries --single-branch https://github.com/eLBati/l10n-italy/ /opt/odoo/source/1-eLBati/11.0-porting-l10n_it_vat_registries-l10n-italy"
su - odoo -c "git clone -b 11.0-mig-stock_picking_package_preparation --single-branch https://github.com/dcorio/stock-logistics-workflow  /opt/odoo/source/1-dcorio/11.0-mig-stock_picking_package_preparation"
su - odoo -c "git clone -b 11.0-mig-l10n_it_reverse_charge --single-branch https://github.com/jackjack82/l10n-italy /opt/odoo/source/1-jackjack82/11.0-mig-l10n_it_reverse_charge"
su - odoo -c "git clone -b 11.0-mig-l10n_it_ddt --single-branch https://github.com/SimoRubi/l10n-italy /opt/odoo/source/1-SimoRubi/11.0-mig-l10n_it_ddt"
su - odoo -c "git clone -b 11.0-mig-account_vat_period_end_statement --single-branch https://github.com/jackjack82/l10n-italy /opt/odoo/source/1-jackjack82/11.0-mig-account_vat_period_end_statement"
su - odoo -c "git clone -b 11.0-mig-l10n_it_ricevute_bancarie --single-branch https://github.com/jackjack82/l10n-italy /opt/odoo/source/1-jackjack82/11.0-mig-l10n_it_ricevute_bancarie"
su - odoo -c "git clone -b 11.0-mig-l10n_it_fatturapa --single-branch https://github.com/linkitspa/l10n-italy/ /opt/odoo/source/0-linkitspa/11.0-mig-l10n_it_fatturapa-l10n-italy"
su - odoo -c "git clone -b 11.0-mig-l10n_it_fatturapa_out --single-branch https://github.com/linkitspa/l10n-italy/ /opt/odoo/source/0-linkitspa/11.0-mig-l10n_it_fatturapa_out-l10n-italy"
su - odoo -c "git clone -b 11.0-mig-l10n_it_fatturapa_in --single-branch https://github.com/linkitspa/l10n-italy/ /opt/odoo/source/0-linkitspa/11.0-mig-l10n_it_fatturapa_in-l10n-italy"

su - odoo -c "git clone -b feature/11.0-mig-account_fiscal_position_vat_check --single-branch https://github.com/rven/account-financial-tools /opt/odoo/source/1-rven/11.0-mig-account_fiscal_position_vat_check-account-financial-tools"

su - odoo -c "git clone -b 11.0 --single-branch https://github.com/fcoach66/odoo-italy-extra  /opt/odoo/source/7-fcoach66/odoo-italy-extra"

su - odoo -c "git clone -b 11.0 --single-branch https://github.com/CybroOdoo/CybroAddons /opt/odoo/source/0-CybroOdoo/CybroAddons"

su - odoo -c "git clone -b 11.0 --single-branch https://github.com/Openworx/backend_theme /opt/odoo/source/0-Openworx/backend_theme"

su - odoo -c "find . -type d -name .git -exec sh -c "cd \"{}\"/../ && pwd && git pull" \;"

su - odoo -c 'for d in $( ls source); do  find $(pwd)/source/$d -mindepth 2 -maxdepth 2 -type d -exec sh -c "ln -sfn \"{}\" $(pwd)/addons" \;; done'


/usr/local/bin/pip3 install --upgrade -r /opt/odoo/source/3-ingadhoc/aeroo_reports/requirements.txt
/usr/local/bin/pip3 install -r /opt/odoo/source/3-ingadhoc/product/requirements.txt
/usr/local/bin/pip3 install -r /opt/odoo/source/3-ingadhoc/account-invoicing/requirements.txt
/usr/local/bin/pip3 install -r /opt/odoo/source/3-ingadhoc/reporting-engine/requirements.txt
/usr/local/bin/pip3 install -r /opt/odoo/source/3-ingadhoc/partner/requirements.txt
/usr/local/bin/pip3 install -r /opt/odoo/source/3-ingadhoc/sale/requirements.txt
/usr/local/bin/pip3 install -r /opt/odoo/source/3-ingadhoc/odoo-argentina/requirements.txt
/usr/local/bin/pip3 install -r /opt/odoo/source/3-ingadhoc/argentina-sale/requirements.txt
/usr/local/bin/pip3 install -r /opt/odoo/source/3-ingadhoc/account-payment/requirements.txt
/usr/local/bin/pip3 install -r /opt/odoo/source/3-ingadhoc/miscellaneous/requirements.txt
/usr/local/bin/pip3 install -r /opt/odoo/source/3-ingadhoc/argentina-reporting/requirements.txt

/usr/local/bin/pip3 install -r /opt/odoo/source/2-OCA/stock-logistics-barcode/requirements.txt
/usr/local/bin/pip3 install -r /opt/odoo/source/2-OCA/server-tools/requirements.txt
/usr/local/bin/pip3 install -r /opt/odoo/source/2-OCA/account-financial-tools/requirements.txt
/usr/local/bin/pip3 install -r /opt/odoo/source/2-OCA/web/requirements.txt
/usr/local/bin/pip3 install -r /opt/odoo/source/2-OCA/account-financial-reporting/requirements.txt
/usr/local/bin/pip3 install -r /opt/odoo/source/2-OCA/reporting-engine/requirements.txt
/usr/local/bin/pip3 install -r /opt/odoo/source/2-OCA/report-print-send/requirements.txt
/usr/local/bin/pip3 install -r /opt/odoo/source/2-OCA/account-financial-reporting/requirements.txt
/usr/local/bin/pip3 install -r /opt/odoo/source/2-OCA/stock-logistics-barcode/requirements.txt
/usr/local/bin/pip3 install -r /opt/odoo/source/2-OCA/web/requirements.txt
/usr/local/bin/pip3 install -r /opt/odoo/source/2-OCA/report-print-send/requirements.txt 
/usr/local/bin/pip3 install -r /opt/odoo/source/2-OCA/server-tools/requirements.txt
/usr/local/bin/pip3 install -r /opt/odoo/source/2-OCA/community-data-files/requirements.txt
/usr/local/bin/pip3 install -r /opt/odoo/source/2-OCA/server-auth/requirements.txt
/usr/local/bin/pip3 install -r /opt/odoo/source/2-OCA/connector/requirements.txt

/usr/local/bin/pip3 install -r /opt/odoo/source/5-vauxoo/addons-vauxoo/requirements.txt

/usr/local/bin/pip3 install -r /opt/odoo/source/1-it-projects-llc/misc-addons/requirements.txt
/usr/local/bin/pip3 install -r /opt/odoo/source/1-it-projects-llc/website-addons/requirements.txt
/usr/local/bin/pip3 install -r /opt/odoo/source/1-it-projects-llc/pos-addons/requirements.txt

/usr/local/bin/pip3 install email_validator

/usr/local/bin/pip3 install -r /opt/odoo/source/1-rven/11.0-mig-account_fiscal_position_vat_check-account-financial-tools/requirements.txt
