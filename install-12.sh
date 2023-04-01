#!/bin/bash

#--------------------------------------------------
# Update Server
#--------------------------------------------------
echo -e "\n---- Update Server ----"
apt-get update && sudo apt-get dist-upgrade -y && sudo apt-get autoremove -y
apt-get install default-jre -y
apt-get install -y software-properties-common
add-apt-repository ppa:linuxuprising/java -y
apt-get install default-jdk -y
apt-get update
apt-get install oracle-java12-installer -y
apt-get install oracle-java12-set-default -y


echo "Installazione Database Postgresql"
sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
apt-get update
apt-get upgrade -y
apt-get install -y postgresql-10 postgresql-server-dev-10

echo -e "\n---- Install tool packages ----"
apt-get install wget subversion git bzr bzrtools python3-pip gdebi-core -y

apt-get install -y libsasl2-dev python-dev libldap2-dev libssl-dev python3-dev libxml2-dev libxslt1-dev zlib1g-dev python3-pip python3-wheel python3-setuptools python3-babel python3-bs4 python3-cffi-backend python3-cryptography python3-dateutil python3-docutils python3-feedparser python3-funcsigs python3-gevent python3-greenlet python3-html2text python3-html5lib python3-jinja2 python3-lxml python3-mako python3-markupsafe python3-mock python3-ofxparse python3-openssl python3-passlib python3-pbr python3-pil python3-psutil python3-psycopg2 python3-pydot python3-pygments python3-pyparsing python3-pypdf2 python3-renderpm python3-reportlab python3-reportlab-accel python3-roman python3-serial python3-stdnum python3-suds python3-tz python3-usb python3-vatnumber python3-werkzeug python3-xlsxwriter python3-yaml

apt-get install -y git python3-pip build-essential wget python3-dev python3-venv python3-wheel libxslt-dev libzip-dev libldap2-dev libsasl2-dev python3-setuptools node-less

pip3 install Babel decorator docutils ebaysdk feedparser gevent greenlet html2text Jinja2 lxml Mako MarkupSafe mock num2words ofxparse passlib Pillow psutil psycogreen psycopg2 pydot pyparsing PyPDF2 pyserial python-dateutil python-openid pytz pyusb PyYAML qrcode reportlab requests six suds-jurko vatnumber vobject Werkzeug XlsxWriter xlwt xlrd

apt-get install -y npm

npm install -g less less-plugin-clean-css

apt-get install -y node-less

python3 -m pip install libsass

pip3 install --upgrade -r https://raw.githubusercontent.com/OCA/OCB/12.0/requirements.txt

wget https://builds.wkhtmltopdf.org/0.12.1.3/wkhtmltox_0.12.1.3-1~bionic_amd64.deb
gdebi --n wkhtmltox_0.12.1.3-1~bionic_amd64.deb

echo -e "\n---- Install python libraries ----"
# This is for compatibility with Ubuntu 16.04. Will work on 14.04, 15.04 and 16.04
apt-get install python3-suds -y

echo -e "\n--- Install other required packages"
apt-get install node-clean-css node-less python-gevent -y

#echo -e "\n--- Create symlink for node"
#sudo ln -s /usr/bin/nodejs /usr/bin/node

pip3 install num2words ofxparse
apt-get install nodejs npm node-less -y
#sudo npm install -g less
#sudo npm install -g less-plugin-clean-css	

	
	
echo "Installazione Odoo 12.0"
adduser odoo --system --group --shell /bin/bash --home /opt/odoo
sudo -u postgres createuser -s odoo
sudo -u postgres psql -c "ALTER USER odoo WITH PASSWORD 'odoo';"
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'odoo';"
su - odoo -c "mkdir -p /opt/odoo/addons"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/OCB.git /opt/odoo/server"
su - odoo -c "git clone -b 12.0 https://github.com/OCA/reporting-engine /opt/odoo/source/2-OCA/reporting-engine"
pip3 install --upgrade -r https://raw.githubusercontent.com/OCA/reporting-engine/12.0/requirements.txt

sudo chown -R odoo:odoo /opt/odoo/odoodev11/server
sudo chown -R odoo:odoo /opt/odoo/odoodev11
pip3 install geojson

echo "Installazione pyxb"
pip3 install pyxb==1.2.5

echo "Installazione codicefiscale"
pip3 install codicefiscale

echo "Installazione simplejson"
pip3 install simplejson

echo "Installazione unidecode"
pip3 install unidecode

echo "Installazione phonenumbers"
pip3 install phonenumbers

echo "Installazione numpy"
pip3 install numpy

echo "Installazione cachetools"
pip3 install cachetools

pip3 install ldap

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
pip3 install jsonrpc2 daemonize
git clone https://github.com/aeroo/aeroo_docs.git /opt/aeroo/aeroo_docs
cd /opt/aeroo/aeroo_docs/
echo "Y" | python3 /opt/aeroo/aeroo_docs/aeroo-docs start -c /etc/aeroo-docs.conf



su - odoo -c "git clone -b 12.0 https://github.com/ingadhoc/aeroo_reports.git /opt/odoo/source/3-ingadhoc/aeroo_reports"

su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/server-tools  /opt/odoo/source/2-OCA/server-tools"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/server-ux  /opt/odoo/source/2-OCA/server-ux"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/partner-contact  /opt/odoo/source/2-OCA/partner-contact"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/l10n-italy  /opt/odoo/source/2-OCA/l10n-italy"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/account-payment  /opt/odoo/source/2-OCA/account-payment"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/account-financial-reporting  /opt/odoo/source/2-OCA/account-financial-reporting"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/account-financial-tools  /opt/odoo/source/2-OCA/account-financial-tools"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/account-closing  /opt/odoo/source/2-OCA/account-closing"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/account-analytic  /opt/odoo/source/2-OCA/account-analytic"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/account-invoicing  /opt/odoo/source/2-OCA/account-invoicing"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/account-invoice-reporting  /opt/odoo/source/2-OCA/account-invoice-reporting"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/account-budgeting /opt/odoo/source/2-OCA/account-budgeting"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/account-consolidation /opt/odoo/source/2-OCA/account-consolidation"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/bank-payment  /opt/odoo/source/2-OCA/bank-payment"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/bank-statement-reconcile  /opt/odoo/source/2-OCA/bank-statement-reconcile"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/bank-statement-import  /opt/odoo/source/2-OCA/bank-statement-import"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/product-attribute  /opt/odoo/source/2-OCA/product-attribute"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/product-variant /opt/odoo/source/2-OCA/product-variant"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/stock-logistics-warehouse  /opt/odoo/source/2-OCA/stock-logistics-warehouse"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/stock-logistics-tracking  /opt/odoo/source/2-OCA/stock-logistics-tracking"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/stock-logistics-barcode  /opt/odoo/source/2-OCA/stock-logistics-barcode"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/stock-logistics-workflow  /opt/odoo/source/2-OCA/stock-logistics-workflow"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/stock-logistics-transport  /opt/odoo/source/2-OCA/stock-logistics-transport"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/sale-workflow  /opt/odoo/source/2-OCA/sale-workflow"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/sale-financial /opt/odoo/source/2-OCA/sale-financial"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/sale-reporting /opt/odoo/source/2-OCA/sale-reporting"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/web  /opt/odoo/source/2-OCA/web"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/website  /opt/odoo/source/2-OCA/website"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/event /opt/odoo/source/2-OCA/event"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/survey /opt/odoo/source/2-OCA/survey"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/social  /opt/odoo/source/2-OCA/social"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/e-commerce  /opt/odoo/source/2-OCA/e-commerce"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/commission /opt/odoo/source/2-OCA/commission"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/margin-analysis  /opt/odoo/source/2-OCA/margin-analysis"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/contract  /opt/odoo/source/2-OCA/contract"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/rma  /opt/odoo/source/2-OCA/rma"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/crm  /opt/odoo/source/2-OCA/crm"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/project-service  /opt/odoo/source/2-OCA/project-service"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/carrier-delivery  /opt/odoo/source/2-OCA/carrier-delivery"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/stock-logistics-reporting /opt/odoo/source/2-OCA/stock-logistics-reporting"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/hr-timesheet  /opt/odoo/source/2-OCA/hr-timesheet"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/hr  /opt/odoo/source/2-OCA/hr"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/management-system  /opt/odoo/source/2-OCA/management-system"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/report-print-send  /opt/odoo/source/2-OCA/report-print-send"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/purchase-reporting  /opt/odoo/source/2-OCA/purchase-reporting"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/purchase-workflow  /opt/odoo/source/2-OCA/purchase-workflow"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/manufacture-reporting  /opt/odoo/source/2-OCA/manufacture-reporting"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/knowledge  /opt/odoo/source/2-OCA/knowledge"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/project-reporting  /opt/odoo/source/2-OCA/project-reporting"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/project  /opt/odoo/source/2-OCA/project"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/connector /opt/odoo/source/2-OCA/connector"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/queue /opt/odoo/source/2-OCA/queue"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/multi-company  /opt/odoo/source/2-OCA/multi-company"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/pos  /opt/odoo/source/2-OCA/pos"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/community-data-files  /opt/odoo/source/2-OCA/community-data-files"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/geospatial  /opt/odoo/source/2-OCA/geospatial"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/vertical-isp  /opt/odoo/source/2-OCA/vertical-isp"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/hr-timesheet /opt/odoo/source/2-OCA/hr-timesheet"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/server-auth /opt/odoo/source/2-OCA/server-auth"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/intrastat /opt/odoo/source/2-OCA/intrastat"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/edi /opt/odoo/source/2-OCA/edi"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/account-reconcile /opt/odoo/source/2-OCA/account-reconcile"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/operating-unit /opt/odoo/source/2-OCA/operating-unit"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/currency /opt/odoo/source/2-OCA/currency"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/website-themes /opt/odoo/source/2-OCA/website-themes"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/server-brand  /opt/odoo/source/2-OCA/server-brand"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/server-backend  /opt/odoo/source/2-OCA/server-backend"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/field-service  /opt/odoo/source/2-OCA/field-service"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/website-cms  /opt/odoo/source/2-OCA/website-cms"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/credit-control  /opt/odoo/source/2-OCA/credit-control"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/product-pack  /opt/odoo/source/2-OCA/product-pack"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/timesheet  /opt/odoo/source/2-OCA/timesheet"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/maintenance /opt/odoo/source/2-OCA/maintenance"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/storage /opt/odoo/source/2-OCA/storage"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/connector-ecommerce /opt/odoo/source/2-OCA/connector-ecommerce"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/helpdesk /opt/odoo/source/2-OCA/helpdesk"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/account-fiscal-rule /opt/odoo/source/2-OCA/account-fiscal-rule"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/payroll /opt/odoo/source/2-OCA/payroll"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/server-brand /opt/odoo/source/2-OCA/server-brand"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/search-engine /opt/odoo/source/2-OCA/search-engine"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/product-kitting /opt/odoo/source/2-OCA/product-kitting"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/intrastat-extrastat /opt/odoo/source/2-OCA/intrastat-extrastat"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/data-protection /opt/odoo/source/2-OCA/data-protection"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/brand /opt/odoo/source/2-OCA/brand"

su - odoo -c "git clone -b 12.0 --single-branch https://github.com/ingadhoc/miscellaneous  /opt/odoo/source/3-ingadhoc/miscellaneous"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/ingadhoc/odoo-argentina  /opt/odoo/source/3-ingadhoc/odoo-argentina"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/ingadhoc/argentina-sale  /opt/odoo/source/3-ingadhoc/argentina-sale"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/ingadhoc/argentina-reporting  /opt/odoo/source/3-ingadhoc/argentina-reporting"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/ingadhoc/account-financial-tools  /opt/odoo/source/3-ingadhoc/account-financial-tools"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/ingadhoc/reporting-engine  /opt/odoo/source/3-ingadhoc/reporting-engine"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/ingadhoc/account-payment  /opt/odoo/source/3-ingadhoc/account-payment"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/ingadhoc/partner  /opt/odoo/source/3-ingadhoc/partner"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/ingadhoc/sale  /opt/odoo/source/3-ingadhoc/sale"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/ingadhoc/account-invoicing  /opt/odoo/source/3-ingadhoc/account-invoicing"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/ingadhoc/product  /opt/odoo/source/3-ingadhoc/product"

su - odoo -c "git clone -b 12.0 --single-branch https://github.com/it-projects-llc/misc-addons  /opt/odoo/source/1-it-projects-llc/misc-addons"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/it-projects-llc/access-addons  /opt/odoo/source/1-it-projects-llc/access-addons"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/it-projects-llc/pos-addons  /opt/odoo/source/1-it-projects-llc/pos-addons"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/it-projects-llc/website-addons  /opt/odoo/source/1-it-projects-llc/website-addons"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/it-projects-llc/mail-addons  /opt/odoo/source/1-it-projects-llc/mail-addons"

su - odoo -c "git clone -b 12.0 --single-branch https://github.com/vauxoo/addons-vauxoo /opt/odoo/source/5-vauxoo/addons-vauxoo"

su - odoo -c "git clone -b 12.0 --single-branch https://github.com/onesteinbv/addons-onestein  /opt/odoo/source/6-onesteinbv/addons-onestein"

#su - odoo -c "git clone -b 12.0 --single-branch https://github.com/efatto/efatto /opt/odoo/source/6-efatto/efatto"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/sergiocorato/efatto /opt/odoo/source/6-sergiocorato/efatto"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/sergiocorato/e-efatto /opt/odoo/source/6-sergiocorato/e-efatto"


su - odoo -c "git clone -b 12.0 --single-branch https://github.com/fcoach66/odoo-italy-extra  /opt/odoo/source/7-fcoach66/odoo-italy-extra"

su - odoo -c "git clone -b 12.0 --single-branch https://github.com/fcoach66/odoo-italy-extra  /opt/odoo/source/7-fcoach66/odoo-italy-extra"

su - odoo -c "git clone -b 12.0 --single-branch https://github.com/CybroOdoo/CybroAddons /opt/odoo/source/0-CybroOdoo/CybroAddons"

su - odoo -c "git clone -b 12.0 --single-branch https://github.com/Openworx/backend_theme /opt/odoo/source/0-Openworx/backend_theme"


# su - odoo -c "git clone -b 12.0-mig-l10n_it_ricevute_bancarie https://github.com/scigghia/l10n-italy /opt/odoo/source/0-scigghia/l10n-italy"
# su - odoo -c "git clone -b 12.0_ricevute_bancarie https://github.com/As400it/l10n-italy /opt/odoo/source/0-As400it/l10n-italy"
su - odoo -c "git clone -b 12.0-mig-l10n_it_ricevute_bancarie https://github.com/tafaRU/l10n-italy /opt/odoo/source/0-tafaRU/l10n-italy"

#su - odoo -c "git clone -b 12.0-mig-l10n_it_withholding_tax_payment https://github.com/linkitspa/l10n-italy /opt/odoo/source/0-linkitspa-1/l10n-italy"
su - odoo -c "git clone -b 12.0-mig-letsencrypt --single-branch https://github.com/eLBati/server-tools/ /opt/odoo/source/0-eLBati/l10n-italy"


su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/product-pack  /opt/odoo/source/2-OCA/product-pack"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/timesheet  /opt/odoo/source/2-OCA/timesheet"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/maintenance /opt/odoo/source/2-OCA/maintenance"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/storage /opt/odoo/source/2-OCA/storage"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/connector-ecommerce /opt/odoo/source/2-OCA/connector-ecommerce"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/helpdesk /opt/odoo/source/2-OCA/helpdesk"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/account-fiscal-rule /opt/odoo/source/2-OCA/account-fiscal-rule"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/payroll /opt/odoo/source/2-OCA/payroll"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/server-brand /opt/odoo/source/2-OCA/server-brand"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/search-engine /opt/odoo/source/2-OCA/search-engine"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/product-kitting /opt/odoo/source/2-OCA/product-kitting"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/intrastat-extrastat /opt/odoo/source/2-OCA/intrastat-extrastat"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/data-protection /opt/odoo/source/2-OCA/data-protection"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/brand /opt/odoo/source/2-OCA/brand"

su - odoo -c "git clone -b 12.0-mig-account_bank_statement_import_qif --single-branch https://github.com/erick-tejada/bank-statement-import /opt/odoo/source/0-Numigi/erick-tejada"

su - odoo -c "git clone -b 12.0 --single-branch https://github.com/Numigi/aeroo_reports /opt/odoo/source/7-Numigi/aeroo_reports"

su - odoo -c "git clone -b 12.0 --single-branch https://github.com/dhongu/deltatech /opt/odoo/source/5-dhongu/deltatech"

su - odoo -c "git clone -b 12.0 --single-branch https://github.com/muk-it/muk_misc /opt/odoo/source/5-muk-it/muk_misc"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/muk-it/muk_web /opt/odoo/source/5-muk-it/muk_web"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/muk-it/muk_base /opt/odoo/source/5-muk-it/muk_base"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/muk-it/muk_dms /opt/odoo/source/5-muk-it/muk_dms"


su - odoo -c "git clone -b 12.0 --single-branch https://github.com/CybroOdoo/CybroAddons /opt/odoo/source/5-CybroOdoo/CybroAddons"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/odoomates/odooapps /opt/odoo/source/5-odoomates/odooapps"




su - odoo -c "find . -type d -name .git -exec sh -c "cd \"{}\"/../ && pwd && git pull" \;"
su - odoo -c 'for d in $( ls source); do  find $(pwd)/source/$d -mindepth 2 -maxdepth 2 -type d -exec sh -c "ln -sfn \"{}\" $(pwd)/addons" \;; done'

pip3 install -r /opt/odoo/server/requirements.txt
pip3 install -r /opt/odoo/source/2-OCA/server-tools/requirements.txt
pip3 install -r /opt/odoo/source/2-OCA/server-auth/requirements.txt
pip3 install -r /opt/odoo/source/2-OCA/search-engine/requirements.txt
pip3 install -r /opt/odoo/source/2-OCA/report-print-send/requirements.txt
pip3 install -r /opt/odoo/source/2-OCA/community-data-files/requirements.txt
pip3 install -r /opt/odoo/source/2-OCA/stock-logistics-barcode/requirements.txt
pip3 install -r /opt/odoo/source/2-OCA/field-service/requirements.txt
pip3 install -r /opt/odoo/source/2-OCA/web/requirements.txt
pip3 install -r /opt/odoo/source/2-OCA/reporting-engine/requirements.txt
pip3 install -r /opt/odoo/source/2-OCA/storage/requirements.txt
pip3 install -r /opt/odoo/source/2-OCA/event/requirements.txt
pip3 install -r /opt/odoo/source/0-CybroOdoo/CybroAddons/user_login_alert/requirements.txt
pip3 install -r /opt/odoo/source/3-ingadhoc/account-invoicing/requirements.txt
pip3 install -r /opt/odoo/source/3-ingadhoc/odoo-argentina/requirements.txt
pip3 install -r /opt/odoo/source/3-ingadhoc/sale/requirements.txt
pip3 install -r /opt/odoo/source/3-ingadhoc/partner/requirements.txt
pip3 install -r /opt/odoo/source/3-ingadhoc/product/requirements.txt
pip3 install -r /opt/odoo/source/3-ingadhoc/miscellaneous/requirements.txt
pip3 install -r /opt/odoo/source/3-ingadhoc/aeroo_reports/requirements.txt
pip3 install -r /opt/odoo/source/3-ingadhoc/reporting-engine/requirements.txt
pip3 install -r /opt/odoo/source/3-ingadhoc/account-payment/requirements.txt
pip3 install -r /opt/odoo/source/1-it-projects-llc/misc-addons/requirements.txt
pip3 install -r /opt/odoo/source/1-it-projects-llc/pos-addons/requirements.txt
pip3 install -r /opt/odoo/source/1-it-projects-llc/website-addons/requirements.txt
