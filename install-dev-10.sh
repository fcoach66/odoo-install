#!/bin/bash

echo "Installazione Database Postgresql"
sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
apt-get update -q=2
apt-get upgrade -y -q=2
apt-get install -y -q=2 postgresql-9.4 pgadmin3

echo "Installazione pacchetti deb"
apt-get install -y mc zip unzip htop ntp ghostscript graphviz antiword git libpq-dev poppler-utils python-pip build-essential libfreetype6-dev npm python-magic python-dateutil python-pypdf python-requests \
python-feedparser python-gdata python-ldap python-libxslt1 python-lxml python-mako python-openid python-psycopg2 python-pybabel python-pychart python-pydot python-pyparsing python-reportlab python-simplejson \
python-tz python-vatnumber python-vobject python-webdav python-werkzeug python-xlwt python-yaml python-zsi python-docutils python-psutil python-unittest2 python-mock python-jinja2 python-dev \
python-pdftools python-decorator python-openssl python-babel python-imaging python-reportlab-accel python-paramiko python-cups python-software-properties python-pip python-dev build-essential libpq-dev \
poppler-utils antiword libldap2-dev libsasl2-dev libssl-dev git python-dateutil python-feedparser python-gdata python-ldap python-lxml python-mako python-openid python-psycopg2 python-pychart python-pydot \
python-pyparsing python-reportlab python-tz python-vatnumber python-vobject python-webdav python-xlwt python-yaml python-zsi python-docutils python-unittest2 python-mock python-jinja2 libevent-dev libxslt1-dev \
libfreetype6-dev libjpeg8-dev python-werkzeug wkhtmltopdf libjpeg-dev python-setuptools python-genshi python-cairo python-lxml libreoffice libreoffice-script-provider-python python3-pip nginx munin apache2-utils \
fonts-crosextra-caladea fonts-crosextra-carlito

echo "Installazione pacchetti pip"
pip install passlib beautifulsoup4 evdev reportlab qrcode polib unidecode validate_email pyDNS pysftp python-slugify phonenumbers py-Asterisk codicefiscale unicodecsv ofxparse pytils gevent_psycopg2 psycogreen erppeek PyXB

echo "Installazione pacchetti npm"
npm install -g less less-plugin-clean-css
ln -s /usr/bin/nodejs /usr/bin/node

echo "Installazione Barcodes"
wget --quiet http://www.reportlab.com/ftp/pfbfer.zip
unzip pfbfer.zip -d fonts
mv fonts /usr/lib/python2.7/dist-packages/reportlab/
rm pfbfer.zip

echo "Installazione wkhtmltox 0.12.1"
wget --quiet http://www.openerp24.de/fileadmin/content/dateien/wkhtmltox-0.12.1_linux-trusty-amd64.deb
dpkg -i wkhtmltox-0.12.1_linux-trusty-amd64.deb
rm wkhtmltox-0.12.1_linux-trusty-amd64.deb

echo "Installazione PoS"
pip install pyserial
pip install --pre pyusb

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


echo "Installazione Odoo 9.0"
sudo -u postgres createuser -s odoo
sudo -u postgres psql -c "ALTER USER odoo WITH PASSWORD 'odoo';"
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'odoo';"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/OCB.git /home/odoo/odoodev10/server"
su - odoo -c "mkdir -p /home/odoo/odoodev10/source/2-OCA"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/webkit-tools /home/odoo/odoodev10/source/2-OCA/webkit-tools"
su - odoo -c "mkdir -p /home/odoo/odoodev10/addons"
su - odoo -c "mkdir -p /home/odoo/odoodev10/source/aeroo"

su - odoo -c "git clone -b master https://github.com/Yenthe666/aeroo_reports /home/odoo/odoodev10/source/aeroo/aeroo_reports"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/reporting-engine /home/odoo/odoodev10/source/2-OCA/reporting-engine"
# su - odoo -c "sed -i "s/admin/odoo/g" /home/odoo/odoodev10/server/openerp/tools/config.py"
su - odoo -c "cp /home/odoo/odoodev10/server/addons/web/static/src/img/favicon.ico /home/odoo/odoodev10/" 
#sed -i "s/'auto_install': True/'auto_install': False/" /home/odoo/odoodev10/server/addons/im_odoo_support/__openerp__.py
sudo chown -R odoo:odoo /home/odoo/odoodev10/server
sudo chown -R odoo:odoo /home/odoo/odoodev10
su - odoo -c "mkdir -p /home/odoo/odoodev10/addons"

su - odoo -c 'for d in $( ls odoodev10/source); do  find $(pwd)/odoodev10/source/$d -mindepth 2 -maxdepth 2 -type d -exec sh -c "ln -sfn \"{}\" $(pwd)/odoodev10/addons" \;; done'

su - odoo -c "/home/odoo/odoodev10/server/odoo-bin --stop-after-init -c /home/odoo/odoodev10/odoo_serverrc -s --db_host=localhost --db_user=odoo --db_password=odoo --addons-path=/home/odoo/odoodev10/server/odoo/addons,/home/odoo/odoodev10/server/addons,/home/odoo/odoodev10/addons"

su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/l10n-italy /home/odoo/odoodev10/source/2-OCA/l10n-italy"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/partner-contact /home/odoo/odoodev10/source/2-OCA/partner-contact"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/account-payment /home/odoo/odoodev10/source/2-OCA/account-payment"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/bank-payment /home/odoo/odoodev10/source/2-OCA/bank-payment"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/stock-logistics-workflow /home/odoo/odoodev10/source/2-OCA/stock-logistics-workflow"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/product-attribute /home/odoo/odoodev10/source/2-OCA/product-attribute"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/stock-logistics-warehouse /home/odoo/odoodev10/source/2-OCA/stock-logistics-warehouse"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/stock-logistics-tracking /home/odoo/odoodev10/source/2-OCA/stock-logistics-tracking"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/stock-logistics-barcode /home/odoo/odoodev10/source/2-OCA/stock-logistics-barcode"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/sale-workflow  /home/odoo/odoodev10/source/2-OCA/sale-workflow"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/stock-logistics-transport /home/odoo/odoodev10/source/2-OCA/stock-logistics-transport"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/account-closing /home/odoo/odoodev10/source/2-OCA/account-closing"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/server-tools /home/odoo/odoodev10/source/2-OCA/server-tools"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/account-financial-tools /home/odoo/odoodev10/source/2-OCA/account-financial-tools"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/connector /home/odoo/odoodev10/source/2-OCA/connector"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/account-financial-reporting /home/odoo/odoodev10/source/2-OCA/account-financial-reporting"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/bank-statement-reconcile /home/odoo/odoodev10/source/2-OCA/bank-statement-reconcile"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/bank-statement-import /home/odoo/odoodev10/source/2-OCA/bank-statement-import"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/rma /home/odoo/odoodev10/source/2-OCA/rma"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/crm /home/odoo/odoodev10/source/2-OCA/crm"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/web  /home/odoo/odoodev10/source/2-OCA/web"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/project-service /home/odoo/odoodev10/source/2-OCA/project-service"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/commission /home/odoo/odoodev10/source/2-OCA/commission"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/margin-analysis /home/odoo/odoodev10/source/2-OCA/margin-analysis"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/account-analytic /home/odoo/odoodev10/source/2-OCA/account-analytic"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/account-invoicing /home/odoo/odoodev10/source/2-OCA/account-invoicing"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/account-invoice-reporting /home/odoo/odoodev10/source/2-OCA/account-invoice-reporting"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/account-budgeting /home/odoo/odoodev10/source/2-OCA/account-budgeting"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/account-consolidation /home/odoo/odoodev10/source/2-OCA/account-consolidation"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/sale-financial /home/odoo/odoodev10/source/2-OCA/sale-financial"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/sale-reporting /home/odoo/odoodev10/source/2-OCA/sale-reporting"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/event /home/odoo/odoodev10/source/2-OCA/event"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/survey /home/odoo/odoodev10/source/2-OCA/survey"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/social  /home/odoo/odoodev10/source/2-OCA/social"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/e-commerce /home/odoo/odoodev10/source/2-OCA/e-commerce"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/product-variant /home/odoo/odoodev10/source/2-OCA/product-variant"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/carrier-delivery /home/odoo/odoodev10/source/2-OCA/carrier-delivery"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/stock-logistics-reporting /home/odoo/odoodev10/source/2-OCA/stock-logistics-reporting"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/product-kitting  /home/odoo/odoodev10/source/2-OCA/product-kitting"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/hr-timesheet  /home/odoo/odoodev10/source/2-OCA/hr-timesheet"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/hr  /home/odoo/odoodev10/source/2-OCA/hr"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/department  /home/odoo/odoodev10/source/2-OCA/department"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/multi-company  /home/odoo/odoodev10/source/2-OCA/multi-company"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/manufacture  /home/odoo/odoodev10/source/2-OCA/manufacture"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/manufacture-reporting  /home/odoo/odoodev10/source/2-OCA/manufacture-reporting"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/knowledge  /home/odoo/odoodev10/source/2-OCA/knowledge"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/pos  /home/odoo/odoodev10/source/2-OCA/pos"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/project-reporting  /home/odoo/odoodev10/source/2-OCA/project-reporting"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/project  /home/odoo/odoodev10/source/2-OCA/project"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/contract  /home/odoo/odoodev10/source/2-OCA/contract"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/purchase-reporting  /home/odoo/odoodev10/source/2-OCA/purchase-reporting"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/purchase-workflow  /home/odoo/odoodev10/source/2-OCA/purchase-workflow"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/management-system  /home/odoo/odoodev10/source/2-OCA/management-system"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/website  /home/odoo/odoodev10/source/2-OCA/website"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/report-print-send  /home/odoo/odoodev10/source/2-OCA/report-print-send"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/community-data-files  /home/odoo/odoodev10/source/2-OCA/community-data-files"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/geospatial  /home/odoo/odoodev10/source/2-OCA/geospatial"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/vertical-isp  /home/odoo/odoodev10/source/2-OCA/vertical-isp"


su - odoo -c "git clone -b 10.0 --single-branch  https://github.com/it-projects-llc/misc-addons /home/odoo/odoodev10/source/1-it-projects-llc/misc-addons"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/it-projects-llc/access-addons  /home/odoo/odoodev10/source/1-it-projects-llc/access-addons"
su - odoo -c "git clone -b 10.0 --single-branch  https://github.com/it-projects-llc/pos-addons /home/odoo/odoodev10/source/1-it-projects-llc/pos-addons"
su - odoo -c "git clone -b 10.0 --single-branch  https://github.com/it-projects-llc/website-addons /home/odoo/odoodev10/source/1-it-projects-llc/website-addons"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/it-projects-llc/mail-addons  /home/odoo/odoodev10/source/1-it-projects-llc/mail-addons"

su - odoo -c "git clone -b 10.0 --single-branch https://github.com/ingadhoc/reporting-engine  /home/odoo/odoodev10/source/3-ingadhoc/reporting-engine"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/ingadhoc/account-invoicing  /home/odoo/odoodev10/source/3-ingadhoc/account-invoicing"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/ingadhoc/sale  /home/odoo/odoodev10/source/3-ingadhoc/sale"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/ingadhoc/product  /home/odoo/odoodev10/source/3-ingadhoc/product"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/ingadhoc/partner  /home/odoo/odoodev10/source/3-ingadhoc/partner"

su - odoo -c "git clone -b 10.0 --single-branch https://github.com/initOS/openerp-dav /home/odoo/odoodev10/source/4-initOS/openerp-dav"

su - odoo -c "git clone -b 10.0 --single-branch https://github.com/vauxoo/addons-vauxoo /home/odoo/odoodev10/source/5-vauxoo/addons-vauxoo"

su - odoo -c "git clone -b 10.0 --single-branch https://github.com/onesteinbv/addons-onestein  /home/odoo/odoodev10/source/5-onesteinbv/addons-onestein"

su - odoo -c "git clone -b 10.0 --single-branch https://github.com/efatto/efatto /home/odoo/odoodev10/source/6-efatto/efatto"

su - odoo -c "git clone -b 10.0 --single-branch https://github.com/fcoach66/odoo-italy-extra  /home/odoo/odoodev10/source/7-fcoach66/odoo-italy-extra"

pip install -r /home/odoo/odoodev10/server/requirements.txt
pip install -r /home/odoo/odoodev10/source/1-it-projects-llc/website-addons/requirements.txt
pip install -r /home/odoo/odoodev10/source/1-it-projects-llc/misc-addons/requirements.txt
pip install -r /home/odoo/odoodev10/source/2-OCA/community-data-files/requirements.txt
pip install -r /home/odoo/odoodev10/source/2-OCA/bank-statement-import/requirements.txt
pip install -r /home/odoo/odoodev10/source/2-OCA/partner-contact/requirements.txt
pip install -r /home/odoo/odoodev10/source/2-OCA/stock-logistics-warehouse/requirements.txt
pip install -r /home/odoo/odoodev10/source/2-OCA/reporting-engine/requirements.txt
pip install -r /home/odoo/odoodev10/source/2-OCA/social/requirements.txt
pip install -r /home/odoo/odoodev10/source/2-OCA/server-tools/requirements.txt
pip install -r /home/odoo/odoodev10/source/2-OCA/connector/requirements.txt
pip install -r /home/odoo/odoodev10/source/2-OCA/stock-logistics-barcode/requirements.txt
pip install -r /home/odoo/odoodev10/source/2-OCA/pos/requirements.txt
pip install -r /home/odoo/odoodev10/source/2-OCA/report-print-send/requirements.txt
pip install -r /home/odoo/odoodev10/source/5-vauxoo/addons-vauxoo/requirements.txt
pip install -r /home/odoo/odoodev10/source/3-ingadhoc/product/requirements.txt

su - odoo -c 'for d in $( ls odoodev10/source); do  find $(pwd)/odoodev10/source/$d -mindepth 2 -maxdepth 2 -type d -exec sh -c "ln -sfn \"{}\" $(pwd)/odoodev10/addons" \;; done'