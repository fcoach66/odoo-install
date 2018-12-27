#!/bin/bash

echo "Aggiornamento Sistema Operativo"
apt-get update -q=2 && apt-get dist-upgrade -y -q=2 && apt-get autoremove -y -q=2

sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
apt-get update -q=2
apt-get upgrade -y -q=2
apt-get install -y -q=2 postgresql-9.6

apt-get install -y openssh-server mc zip unzip htop ntp ghostscript graphviz antiword git libpq-dev poppler-utils python-pip build-essential libfreetype6-dev npm python-magic python-dateutil python-pypdf python-requests python-feedparser python-gdata python-ldap python-libxslt1 python-lxml python-mako python-openid python-psycopg2 python-pybabel python-pychart python-pydot python-pyparsing python-reportlab python-simplejson python-tz python-vatnumber python-vobject python-webdav python-werkzeug python-xlwt python-yaml python-zsi python-docutils python-psutil python-unittest2 python-mock python-jinja2 python-dev python-pdftools python-decorator python-openssl python-babel python-imaging python-reportlab-accel python-paramiko python-cups python-software-properties python-pip python-dev build-essential libpq-dev poppler-utils antiword libldap2-dev libsasl2-dev libssl-dev git python-dateutil python-feedparser python-gdata python-ldap python-lxml python-mako python-openid python-psycopg2 python-pychart python-pydot python-pyparsing python-reportlab python-tz python-vatnumber python-vobject python-webdav python-xlwt python-yaml python-zsi python-docutils python-unittest2 python-mock python-jinja2 libevent-dev libxslt1-dev libfreetype6-dev libjpeg8-dev python-werkzeug libjpeg-dev python-setuptools python-genshi python-cairo python-lxml libreoffice libreoffice-script-provider-python python3-pip nginx munin apache2-utils fonts-crosextra-caladea fonts-crosextra-carlito git xfonts-75dpi python-pip libxml2-dev libcups2-dev libsasl2-dev python-dev libldap2-dev libssl-dev libtiff5-dev libjpeg8-dev zlib1g-dev libfreetype6-dev liblcms2-dev libwebp-dev tcl8.6-dev tk8.6-dev python-tk libxslt-dev 

pip install passlib beautifulsoup4 evdev reportlab qrcode polib unidecode validate_email pyDNS pysftp python-slugify phonenumbers py-Asterisk codicefiscale unicodecsv ofxparse pytils gevent_psycopg2 psycogreen erppeek PyXB

npm install -g less less-plugin-clean-css
ln -s /usr/bin/nodejs /usr/bin/node

wget --quiet http://www.reportlab.com/ftp/pfbfer.zip
unzip pfbfer.zip -d fonts
mv fonts /usr/lib/python2.7/dist-packages/reportlab/
rm pfbfer.zip

wget --quiet https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.xenial_amd64.deb
dpkg -i wkhtmltox_0.12.5-1.xenial_amd64.deb
rm wkhtmltox_0.12.5-1.xenial_amd64.deb

pip install pyserial
pip install --pre pyusb



#pgtune -i /etc/postgresql/9.4/main/postgresql.conf -o /etc/postgresql/9.4/main/postgresql.conf.tuned
#mv /etc/postgresql/9.4/main/postgresql.conf  /etc/postgresql/9.4/main/postgresql.conf.old
#mv /etc/postgresql/9.4/main/postgresql.conf.tuned  /etc/postgresql/9.4/main/postgresql.conf
#/etc/init.d/postgresql stop
#/etc/init.d/postgresql start 
#cat /etc/postgresql/9.4/main/postgresql.conf

mkdir /opt/aeroo
git clone https://github.com/ingadhoc/aeroolib.git /opt/aeroo/aeroolib
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

adduser odoo --system --group --shell /bin/bash --home /opt/odoo
sudo -u postgres createuser -s odoo
sudo -u postgres psql -c "ALTER USER odoo WITH PASSWORD 'odoo';"
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'odoo';"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/OCB.git /opt/odoo/server"
su - odoo -c "mkdir -p /opt/odoo/source/OCA"
su - odoo -c "git clone -b 8.0 https://github.com/OCA/webkit-tools /opt/odoo/source/2-OCA/webkit-tools"
su - odoo -c "mkdir -p /opt/odoo/addons"
su - odoo -c "mkdir -p /opt/odoo/source/aeroo"
su - odoo -c "git clone -b 8.0 https://github.com/ingadhoc/aeroo_reports.git /opt/odoo/source/aeroo/aeroo_reports"
su - odoo -c "git clone -b 8.0 https://github.com/OCA/reporting-engine /opt/odoo/source/2-OCA/reporting-engine"
# su - odoo -c "sed -i "s/admin/odoo/g" /opt/odoo/server/openerp/tools/config.py"
su - odoo -c "cp /opt/odoo/server/addons/web/static/src/img/favicon.ico /opt/odoo/" 
#sed -i "s/'auto_install': True/'auto_install': False/" /opt/odoo/server/addons/im_odoo_support/__openerp__.py

su - odoo -c 'for d in $( ls odoodev8/source); do  find $(pwd)/odoodev8/source/$d -mindepth 2 -maxdepth 2 -type d -exec sh -c "ln -sfn \"{}\" $(pwd)/odoodev8/addons" \;; done'

sudo chown -R odoo:odoo /opt/odoo/server
sudo chown -R odoo:odoo /opt/odoo
su - odoo -c "mkdir -p /opt/odoo/addons"


mkdir /var/log/odoo
chown odoo:odoo /var/log/odoo
wget https://raw.githubusercontent.com/fcoach66/odoo-install/master/logrotate -O /etc/logrotate.d/odoo-server
chmod 755 /etc/logrotate.d/odoo-server
wget https://raw.githubusercontent.com/fcoach66/odoo-install/master/openerp.init.d -O /etc/init.d/odoo-server
sudo chmod +x /etc/init.d/odoo-server
sudo update-rc.d odoo-server defaults
su - odoo -c "mkdir -p /opt/odoo/addons"

pip install simplejson
pip install python-dateutil
pip install nltk
pip install distribute
apt-get install -y python-psycopg2
apt-get install -y python-openid
pip install jsonrpc2
pip install werkzeug
pip install unittest
pip install reportlab
pip install requests
pip install pyPdf
pip install webdav
pip install caldav
pip install pywebdav
pip install pyxb==1.2.5
pip install codicefiscale
pip install ofxparse
pip install Shapely geojson
pip install pandas

pip install -r /opt/odoo/server/doc/requirements.txt
pip install -r /opt/odoo/server/requirements.txt

su - odoo -c "/opt/odoo/server/odoo.py --stop-after-init -c /opt/odoo/odoo_serverrc -s --db_host=localhost --db_user=odoo --db_password=odoo --addons-path=/opt/odoo/server/openerp/addons,/opt/odoo/server/addons,/opt/odoo/addons"

mv /opt/odoo/odoo_serverrc /etc/odoo-server.conf
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

su - odoo -c "mkdir -p /opt/odoo/source"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/l10n-italy /opt/odoo/source/2-OCA/l10n-italy"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/partner-contact /opt/odoo/source/2-OCA/partner-contact"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/account-payment /opt/odoo/source/2-OCA/account-payment"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/bank-payment /opt/odoo/source/2-OCA/bank-payment"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/stock-logistics-workflow /opt/odoo/source/2-OCA/stock-logistics-workflow"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/product-attribute /opt/odoo/source/2-OCA/product-attribute"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/stock-logistics-warehouse /opt/odoo/source/2-OCA/stock-logistics-warehouse"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/stock-logistics-tracking /opt/odoo/source/2-OCA/stock-logistics-tracking"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/stock-logistics-barcode /opt/odoo/source/2-OCA/stock-logistics-barcode"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/margin-analysis /opt/odoo/source/2-OCA/margin-analysis"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/account-analytic /opt/odoo/source/2-OCA/account-analytic"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/account-invoicing /opt/odoo/source/2-OCA/account-invoicing"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/account-invoice-reporting /opt/odoo/source/2-OCA/account-invoice-reporting"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/account-budgeting /opt/odoo/source/2-OCA/account-budgeting"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/account-consolidation /opt/odoo/source/2-OCA/account-consolidation"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/sale-financial /opt/odoo/source/2-OCA/sale-financial"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/sale-reporting /opt/odoo/source/2-OCA/sale-reporting"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/event /opt/odoo/source/2-OCA/event"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/survey /opt/odoo/source/2-OCA/survey"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/social  /opt/odoo/source/2-OCA/social"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/e-commerce /opt/odoo/source/2-OCA/e-commerce"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/product-variant /opt/odoo/source/2-OCA/product-variant"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/carrier-delivery /opt/odoo/source/2-OCA/carrier-delivery"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/stock-logistics-reporting /opt/odoo/source/2-OCA/stock-logistics-reporting"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/product-kitting  /opt/odoo/source/2-OCA/product-kitting"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/hr-timesheet  /opt/odoo/source/2-OCA/hr-timesheet"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/hr  /opt/odoo/source/2-OCA/hr"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/department  /opt/odoo/source/2-OCA/department"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/multi-company  /opt/odoo/source/2-OCA/multi-company"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/manufacture  /opt/odoo/source/2-OCA/manufacture"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/manufacture-reporting  /opt/odoo/source/2-OCA/manufacture-reporting"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/knowledge  /opt/odoo/source/2-OCA/knowledge"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/pos  /opt/odoo/source/2-OCA/pos"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/project-reporting  /opt/odoo/source/2-OCA/project-reporting"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/project  /opt/odoo/source/2-OCA/project"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/contract  /opt/odoo/source/2-OCA/contract"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/purchase-reporting  /opt/odoo/source/2-OCA/purchase-reporting"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/purchase-workflow  /opt/odoo/source/2-OCA/purchase-workflow"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/management-system  /opt/odoo/source/2-OCA/management-system"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/website  /opt/odoo/source/2-OCA/website"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/report-print-send  /opt/odoo/source/2-OCA/report-print-send"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/community-data-files  /opt/odoo/source/2-OCA/community-data-files"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/geospatial  /opt/odoo/source/2-OCA/geospatial"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/vertical-isp  /opt/odoo/source/2-OCA/vertical-isp"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/sale-workflow  /opt/odoo/source/2-OCA/sale-workflow"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/stock-logistics-transport /opt/odoo/source/2-OCA/stock-logistics-transport"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/account-closing /opt/odoo/source/2-OCA/account-closing"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/server-tools /opt/odoo/source/2-OCA/server-tools"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/account-financial-tools /opt/odoo/source/2-OCA/account-financial-tools"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/connector /opt/odoo/source/2-OCA/connector"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/account-financial-reporting /opt/odoo/source/2-OCA/account-financial-reporting"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/bank-statement-reconcile /opt/odoo/source/2-OCA/bank-statement-reconcile"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/bank-statement-import /opt/odoo/source/2-OCA/bank-statement-import"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/rma /opt/odoo/source/2-OCA/rma"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/crm /opt/odoo/source/2-OCA/crm"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/web  /opt/odoo/source/2-OCA/web"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/project-service /opt/odoo/source/2-OCA/project-service"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/commission /opt/odoo/source/2-OCA/commission"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/intrastat  /opt/odoo/source/2-OCA/intrastat"

su - odoo -c "git clone -b 8.0 --single-branch https://github.com/it-projects-llc/misc-addons  /opt/odoo/source/1-it-projects-llc/misc-addons"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/it-projects-llc/access-addons  /opt/odoo/source/1-it-projects-llc/access-addons"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/it-projects-llc/pos-addons  /opt/odoo/source/1-it-projects-llc/pos-addons"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/it-projects-llc/website-addons  /opt/odoo/source/1-it-projects-llc/website-addons"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/it-projects-llc/mail-addons  /opt/odoo/source/1-it-projects-llc/mail-addons"

#su - odoo -c "git clone -b 8.0-abstract-merges --single-branch https://github.com/abstract-open-solutions/l10n-italy /opt/odoo/source/abstract-open-solutions/l10n-italy-abstract-merges"

su - odoo -c "git clone -b 8.0 --single-branch https://github.com/ingadhoc/miscellaneous  /opt/odoo/source/3-ingadhoc/miscellaneous"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/ingadhoc/odoo-argentina  /opt/odoo/source/3-ingadhoc/odoo-argentina"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/ingadhoc/argentina-sale  /opt/odoo/source/3-ingadhoc/argentina-sale"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/ingadhoc/argentina-reporting  /opt/odoo/source/3-ingadhoc/argentina-reporting"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/ingadhoc/account-financial-tools  /opt/odoo/source/3-ingadhoc/account-financial-tools"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/ingadhoc/reporting-engine  /opt/odoo/source/3-ingadhoc/reporting-engine"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/ingadhoc/account-payment  /opt/odoo/source/3-ingadhoc/account-payment"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/ingadhoc/partner  /opt/odoo/source/3-ingadhoc/partner"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/ingadhoc/sale  /opt/odoo/source/3-ingadhoc/sale"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/ingadhoc/account-invoicing  /opt/odoo/source/3-ingadhoc/account-invoicing"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/ingadhoc/product  /opt/odoo/source/3-ingadhoc/product"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/ingadhoc/stock  /opt/odoo/source/3-ingadhoc/stock"

#su - odoo -c "git clone -b 8.0 --single-branch https://github.com/techreceptives/website_recaptcha /opt/odoo/source/techreceptives/website_recaptcha"

su - odoo -c "git clone -b 8.0 --single-branch https://github.com/initOS/openerp-dav /opt/odoo/source/5-initOS/openerp-dav"

su - odoo -c "git clone -b 8.0-product_do_merge_imp --single-branch https://github.com/Eficent/addons-vauxoo /opt/odoo/source/5-Eficent/addons-vauxoo"

su - odoo -c "git clone -b 8.0-prima-nota-cassa --single-branch https://github.com/abstract-open-solutions/l10n-italy /opt/odoo/source/0-abstract-open-solutions/l10n-italy-l10n_it_prima_nota_cassa"
su - odoo -c "git clone -b 8.0-intrastat-codes --single-branch https://github.com/abstract-open-solutions/l10n-italy /opt/odoo/source/0-abstract-open-solutions/l10n-italy-intrastat-codes"
su - odoo -c "git clone -b 8.0-intrastat-review --single-branch https://github.com/abstract-open-solutions/l10n-italy /opt/odoo/source/0-abstract-open-solutions/l10n-italy-intrastat-review"

su - odoo -c "git clone -b 8.0 --single-branch https://github.com/onesteinbv/addons-onestein  /opt/odoo/source/6-onesteinbv/addons-onestein"

su - odoo -c "git clone -b 8.0 --single-branch https://github.com/zeroincombenze/l10n-italy-supplemental /opt/odoo/source/6-zeroincombenze/l10n-italy-supplemental"

su - odoo -c "git clone -b 8.0 --single-branch https://github.com/efatto/efatto /opt/odoo/source/6-efatto/efatto"

su - odoo -c "git clone -b 8.0 --single-branch https://github.com/fcoach66/odoo-italy-extra  /opt/odoo/source/7-fcoach66/odoo-italy-extra"

su - odoo -c "git clone -b 8.0 --single-branch https://github.com/Elico-Corp/odoo-addons /opt/odoo/source/1-Elico-Corp/odoo-addons"

su - odoo -c "git clone -b 8.0-backporting-l10n_it_fatturapa_in --single-branch https://github.com/jado95/l10n-italy /opt/odoo/source/0-jado95/8.0-backporting-l10n_it_fatturapa_in"

su - odoo -c "git clone -b 8.0 --single-branch  https://github.com/luc-demeyer/noviat-apps /opt/odoo/source/0-luc-demever/noviat-apps"

su - odoo -c "git clone -b 8.0 --single-branch https://github.com/bizzappdev/odoo_apps /opt/odoo/source/1-bizzappdev/odoo_apps"


pip install -r /opt/odoo/source/1-it-projects-llc/website-addons/requirements.txt
pip install -r /opt/odoo/source/1-it-projects-llc/misc-addons/requirements.txt
pip install -r /opt/odoo/source/6-zeroincombenze/l10n-italy-supplemental/requirements.txt
pip install -r /opt/odoo/source/2-OCA/community-data-files/requirements.txt
pip install -r /opt/odoo/source/2-OCA/reporting-engine/requirements.txt
pip install -r /opt/odoo/source/2-OCA/report-print-send/requirements.txt
pip install -r /opt/odoo/source/2-OCA/server-tools/requirements.txt
pip install -r /opt/odoo/source/2-OCA/partner-contact/requirements.txt
pip install -r /opt/odoo/source/2-OCA/pos/requirements.txt
pip install -r /opt/odoo/source/3-ingadhoc/reporting-engine/requirements.txt
pip install -r /opt/odoo/source/3-ingadhoc/partner/requirements.txt
pip install -r /opt/odoo/source/3-ingadhoc/miscellaneous/requirements.txt
pip install -r /opt/odoo/source/3-ingadhoc/account-payment/requirements.txt
pip install -r /opt/odoo/source/3-ingadhoc/odoo-argentina/requirements.txt
pip install -r /opt/odoo/source/3-ingadhoc/sale/requirements.txt
pip install -r /opt/odoo/source/3-ingadhoc/product/requirements.txt
pip install -r /opt/odoo/source/3-ingadhoc/account-invoicing/requirements.txt
pip install -r /opt/odoo/source/5-Eficent/addons-vauxoo/requirements.txt


su - odoo -c 'for d in $( ls odoodev8/source); do  find $(pwd)/odoodev8/source/$d -mindepth 2 -maxdepth 2 -type d -exec sh -c "ln -sfn \"{}\" $(pwd)/odoodev8/addons" \;; done'
