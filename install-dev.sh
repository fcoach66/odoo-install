#!/bin/bash

sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
apt-get update -q=2
apt-get upgrade -y -q=2
apt-get install -y -q=2 postgresql-9.6 pgadmin3

apt-get install -y openssh-server mc zip unzip htop ntp ghostscript graphviz antiword git libpq-dev poppler-utils python-pip build-essential libfreetype6-dev npm python-magic python-dateutil python-pypdf python-requests python-feedparser python-gdata python-ldap python-libxslt1 python-lxml python-mako python-openid python-psycopg2 python-pybabel python-pychart python-pydot python-pyparsing python-reportlab python-simplejson python-tz python-vatnumber python-vobject python-webdav python-werkzeug python-xlwt python-yaml python-zsi python-docutils python-psutil python-unittest2 python-mock python-jinja2 python-dev python-pdftools python-decorator python-openssl python-babel python-imaging python-reportlab-accel python-paramiko python-cups python-software-properties python-pip python-dev build-essential libpq-dev poppler-utils antiword libldap2-dev libsasl2-dev libssl-dev git python-dateutil python-feedparser python-gdata python-ldap python-lxml python-mako python-openid python-psycopg2 python-pychart python-pydot python-pyparsing python-reportlab python-tz python-vatnumber python-vobject python-webdav python-xlwt python-yaml python-zsi python-docutils python-unittest2 python-mock python-jinja2 libevent-dev libxslt1-dev libfreetype6-dev libjpeg8-dev python-werkzeug libjpeg-dev python-setuptools python-genshi python-cairo python-lxml libreoffice libreoffice-script-provider-python python3-pip nginx munin apache2-utils fonts-crosextra-caladea fonts-crosextra-carlito git xfonts-75dpi python-pip libxml2-dev libcups2-dev libsasl2-dev python-dev libldap2-dev libssl-dev libtiff5-dev libjpeg8-dev zlib1g-dev libfreetype6-dev liblcms2-dev libwebp-dev tcl8.6-dev tk8.6-dev python-tk libxslt-dev 

pip install --upgrade pip

/usr/local/bin/pip install passlib beautifulsoup4 evdev reportlab qrcode polib unidecode validate_email pyDNS pysftp python-slugify phonenumbers py-Asterisk codicefiscale unicodecsv ofxparse pytils gevent_psycopg2 psycogreen erppeek PyXB

echo "Installazione pacchetti npm"
npm install -g less less-plugin-clean-css
ln -s /usr/bin/nodejs /usr/bin/node

wget --quiet http://www.reportlab.com/ftp/pfbfer.zip
unzip pfbfer.zip -d fonts
mv fonts /usr/lib/python2.7/dist-packages/reportlab/
rm pfbfer.zip

wget --quiet https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.xenial_amd64.deb
dpkg -i wkhtmltox_0.12.5-1.xenial_amd64.deb
rm wkhtmltox_0.12.5-1.xenial_amd64.deb


/usr/local/bin/pip install pyserial
/usr/local/bin/pip install --pre pyusb

echo "Ottimizzazione configurazione database"
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


sudo -u postgres createuser -s odoo
sudo -u postgres psql -c "ALTER USER odoo WITH PASSWORD 'odoo';"
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'odoo';"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/OCB.git /home/odoo/odoodev8/server"
su - odoo -c "mkdir -p /home/odoo/odoodev8/source/OCA"
su - odoo -c "git clone -b 8.0 https://github.com/OCA/webkit-tools /home/odoo/odoodev8/source/2-OCA/webkit-tools"
su - odoo -c "mkdir -p /home/odoo/odoodev8/addons"
su - odoo -c "mkdir -p /home/odoo/odoodev8/source/aeroo"
su - odoo -c "git clone -b 8.0 https://github.com/ingadhoc/aeroo_reports.git /home/odoo/odoodev8/source/aeroo/aeroo_reports"
su - odoo -c "git clone -b 8.0 https://github.com/OCA/reporting-engine /home/odoo/odoodev8/source/2-OCA/reporting-engine"
# su - odoo -c "sed -i "s/admin/odoo/g" /home/odoo/odoodev8/server/openerp/tools/config.py"
su - odoo -c "cp /home/odoo/odoodev8/server/addons/web/static/src/img/favicon.ico /home/odoo/odoodev8/" 
#sed -i "s/'auto_install': True/'auto_install': False/" /home/odoo/odoodev8/server/addons/im_odoo_support/__openerp__.py

su - odoo -c 'for d in $( ls odoodev8/source); do  find $(pwd)/odoodev8/source/$d -mindepth 2 -maxdepth 2 -type d -exec sh -c "ln -sfn \"{}\" $(pwd)/odoodev8/addons" \;; done'

sudo chown -R odoo:odoo /home/odoo/odoodev8/server
sudo chown -R odoo:odoo /home/odoo/odoodev8
su - odoo -c "mkdir -p /home/odoo/odoodev8/addons"

/usr/local/bin/pip install simplejson
/usr/local/bin/pip install python-dateutil
/usr/local/bin/pip install nltk
/usr/local/bin/pip install distribute
apt-get install -y python-psycopg2
apt-get install -y python-openid
/usr/local/bin/pip install jsonrpc2
/usr/local/bin/pip install werkzeug
/usr/local/bin/pip install unittest
/usr/local/bin/pip install reportlab
/usr/local/bin/pip install requests
/usr/local/bin/pip install pyPdf
/usr/local/bin/pip install webdav
/usr/local/bin/pip install caldav
/usr/local/bin/pip install pywebdav
/usr/local/bin/pip install pyxb==1.2.5
/usr/local/bin/pip install codicefiscale

/usr/local/bin/pip install -r /home/odoo/odoodev8/server/doc/requirements.txt
/usr/local/bin/pip install -r /home/odoo/odoodev8/server/requirements.txt
/usr/local/bin/pip install -r /home/odoo/odoodev8/source/aeroo/aeroo_reports/requirements.txt

su - odoo -c "/home/odoo/odoodev8/server/odoo.py --stop-after-init -c /home/odoo/odoodev8/odoo_serverrc -s --db_host=localhost --db_user=odoo --db_password=odoo --addons-path=/home/odoo/odoodev8/server/openerp/addons,/home/odoo/odoodev8/server/addons,/home/odoo/odoodev8/addons"

su - odoo -c "mkdir bin"
su - odoo -c "cat <<EOF > ~/bin/o8
#!/bin/sh
/home/odoo/odoodev8/server/odoo.py -c /home/odoo/odoodev8/odoo_serverrc
EOF"
su - odoo -c "chmod 755 ~/bin/o8"

su - odoo -c "mkdir -p /home/odoo/odoodev8/source"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/l10n-italy /home/odoo/odoodev8/source/2-OCA/l10n-italy"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/partner-contact /home/odoo/odoodev8/source/2-OCA/partner-contact"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/account-payment /home/odoo/odoodev8/source/2-OCA/account-payment"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/bank-payment /home/odoo/odoodev8/source/2-OCA/bank-payment"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/stock-logistics-workflow /home/odoo/odoodev8/source/2-OCA/stock-logistics-workflow"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/product-attribute /home/odoo/odoodev8/source/2-OCA/product-attribute"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/stock-logistics-warehouse /home/odoo/odoodev8/source/2-OCA/stock-logistics-warehouse"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/stock-logistics-tracking /home/odoo/odoodev8/source/2-OCA/stock-logistics-tracking"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/stock-logistics-barcode /home/odoo/odoodev8/source/2-OCA/stock-logistics-barcode"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/margin-analysis /home/odoo/odoodev8/source/2-OCA/margin-analysis"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/account-analytic /home/odoo/odoodev8/source/2-OCA/account-analytic"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/account-invoicing /home/odoo/odoodev8/source/2-OCA/account-invoicing"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/account-invoice-reporting /home/odoo/odoodev8/source/2-OCA/account-invoice-reporting"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/account-budgeting /home/odoo/odoodev8/source/2-OCA/account-budgeting"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/account-consolidation /home/odoo/odoodev8/source/2-OCA/account-consolidation"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/sale-financial /home/odoo/odoodev8/source/2-OCA/sale-financial"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/sale-reporting /home/odoo/odoodev8/source/2-OCA/sale-reporting"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/event /home/odoo/odoodev8/source/2-OCA/event"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/survey /home/odoo/odoodev8/source/2-OCA/survey"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/social  /home/odoo/odoodev8/source/2-OCA/social"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/e-commerce /home/odoo/odoodev8/source/2-OCA/e-commerce"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/product-variant /home/odoo/odoodev8/source/2-OCA/product-variant"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/carrier-delivery /home/odoo/odoodev8/source/2-OCA/carrier-delivery"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/stock-logistics-reporting /home/odoo/odoodev8/source/2-OCA/stock-logistics-reporting"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/product-kitting  /home/odoo/odoodev8/source/2-OCA/product-kitting"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/hr-timesheet  /home/odoo/odoodev8/source/2-OCA/hr-timesheet"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/hr  /home/odoo/odoodev8/source/2-OCA/hr"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/department  /home/odoo/odoodev8/source/2-OCA/department"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/multi-company  /home/odoo/odoodev8/source/2-OCA/multi-company"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/manufacture  /home/odoo/odoodev8/source/2-OCA/manufacture"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/manufacture-reporting  /home/odoo/odoodev8/source/2-OCA/manufacture-reporting"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/knowledge  /home/odoo/odoodev8/source/2-OCA/knowledge"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/pos  /home/odoo/odoodev8/source/2-OCA/pos"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/project-reporting  /home/odoo/odoodev8/source/2-OCA/project-reporting"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/project  /home/odoo/odoodev8/source/2-OCA/project"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/contract  /home/odoo/odoodev8/source/2-OCA/contract"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/purchase-reporting  /home/odoo/odoodev8/source/2-OCA/purchase-reporting"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/purchase-workflow  /home/odoo/odoodev8/source/2-OCA/purchase-workflow"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/management-system  /home/odoo/odoodev8/source/2-OCA/management-system"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/website  /home/odoo/odoodev8/source/2-OCA/website"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/report-print-send  /home/odoo/odoodev8/source/2-OCA/report-print-send"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/community-data-files  /home/odoo/odoodev8/source/2-OCA/community-data-files"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/geospatial  /home/odoo/odoodev8/source/2-OCA/geospatial"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/vertical-isp  /home/odoo/odoodev8/source/2-OCA/vertical-isp"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/sale-workflow  /home/odoo/odoodev8/source/2-OCA/sale-workflow"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/stock-logistics-transport /home/odoo/odoodev8/source/2-OCA/stock-logistics-transport"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/account-closing /home/odoo/odoodev8/source/2-OCA/account-closing"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/server-tools /home/odoo/odoodev8/source/2-OCA/server-tools"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/account-financial-tools /home/odoo/odoodev8/source/2-OCA/account-financial-tools"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/connector /home/odoo/odoodev8/source/2-OCA/connector"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/account-financial-reporting /home/odoo/odoodev8/source/2-OCA/account-financial-reporting"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/bank-statement-reconcile /home/odoo/odoodev8/source/2-OCA/bank-statement-reconcile"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/bank-statement-import /home/odoo/odoodev8/source/2-OCA/bank-statement-import"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/rma /home/odoo/odoodev8/source/2-OCA/rma"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/crm /home/odoo/odoodev8/source/2-OCA/crm"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/web  /home/odoo/odoodev8/source/2-OCA/web"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/project-service /home/odoo/odoodev8/source/2-OCA/project-service"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/commission /home/odoo/odoodev8/source/2-OCA/commission"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/OCA/intrastat  /home/odoo/odoodev8/source/2-OCA/intrastat"

su - odoo -c "git clone -b 8.0 --single-branch https://github.com/it-projects-llc/misc-addons  /home/odoo/odoodev8/source/1-it-projects-llc/misc-addons"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/it-projects-llc/access-addons  /home/odoo/odoodev8/source/1-it-projects-llc/access-addons"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/it-projects-llc/pos-addons  /home/odoo/odoodev8/source/1-it-projects-llc/pos-addons"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/it-projects-llc/website-addons  /home/odoo/odoodev8/source/1-it-projects-llc/website-addons"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/it-projects-llc/mail-addons  /home/odoo/odoodev8/source/1-it-projects-llc/mail-addons"

#su - odoo -c "git clone -b 8.0-abstract-merges --single-branch https://github.com/abstract-open-solutions/l10n-italy /home/odoo/odoodev8/source/abstract-open-solutions/l10n-italy-abstract-merges"

su - odoo -c "git clone -b 8.0 --single-branch https://github.com/ingadhoc/miscellaneous  /home/odoo/odoodev8/source/3-ingadhoc/miscellaneous"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/ingadhoc/odoo-argentina  /home/odoo/odoodev8/source/3-ingadhoc/odoo-argentina"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/ingadhoc/argentina-sale  /home/odoo/odoodev8/source/3-ingadhoc/argentina-sale"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/ingadhoc/argentina-reporting  /home/odoo/odoodev8/source/3-ingadhoc/argentina-reporting"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/ingadhoc/account-financial-tools  /home/odoo/odoodev8/source/3-ingadhoc/account-financial-tools"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/ingadhoc/reporting-engine  /home/odoo/odoodev8/source/3-ingadhoc/reporting-engine"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/ingadhoc/account-payment  /home/odoo/odoodev8/source/3-ingadhoc/account-payment"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/ingadhoc/partner  /home/odoo/odoodev8/source/3-ingadhoc/partner"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/ingadhoc/sale  /home/odoo/odoodev8/source/3-ingadhoc/sale"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/ingadhoc/account-invoicing  /home/odoo/odoodev8/source/3-ingadhoc/account-invoicing"
su - odoo -c "git clone -b 8.0 --single-branch https://github.com/ingadhoc/product  /home/odoo/odoodev8/source/3-ingadhoc/product"

#su - odoo -c "git clone -b 8.0 --single-branch https://github.com/techreceptives/website_recaptcha /home/odoo/odoodev8/source/techreceptives/website_recaptcha"

su - odoo -c "git clone -b 8.0 --single-branch https://github.com/initOS/openerp-dav /home/odoo/odoodev8/source/5-initOS/openerp-dav"

su - odoo -c "git clone -b 8.0-product_do_merge_imp --single-branch https://github.com/Eficent/addons-vauxoo /home/odoo/odoodev8/source/5-Eficent/addons-vauxoo"

su - odoo -c "git clone -b 8.0-prima-nota-cassa --single-branch https://github.com/abstract-open-solutions/l10n-italy /home/odoo/odoodev8/source/0-abstract-open-solutions/l10n-italy-l10n_it_prima_nota_cassa"
su - odoo -c "git clone -b 8.0-intrastat-codes --single-branch https://github.com/abstract-open-solutions/l10n-italy /home/odoo/odoodev8/source/0-abstract-open-solutions/l10n-italy-intrastat-codes"
su - odoo -c "git clone -b 8.0-intrastat-review --single-branch https://github.com/abstract-open-solutions/l10n-italy /home/odoo/odoodev8/source/0-abstract-open-solutions/l10n-italy-intrastat-review"

su - odoo -c "git clone -b 8.0 --single-branch https://github.com/onesteinbv/addons-onestein  /home/odoo/odoodev8/source/6-onesteinbv/addons-onestein"

su - odoo -c "git clone -b 8.0 --single-branch https://github.com/zeroincombenze/l10n-italy-supplemental /home/odoo/odoodev8/source/6-zeroincombenze/l10n-italy-supplemental"

su - odoo -c "git clone -b 8.0 --single-branch https://github.com/fcoach66/odoo-italy-extra  /home/odoo/odoodev8/source/fcoach66/7-odoo-italy-extra"

su - odoo -c "git clone -b 8.0 --single-branch https://github.com/Elico-Corp/odoo-addons /home/odoo/odoodev8/source/1-Elico-Corp/odoo-addons"

su - odoo -c "git clone -b 8.0-backporting-l10n_it_fatturapa_in --single-branch https://github.com/jado95/l10n-italy /home/odoo/odoodev8/source/0-jado95/8.0-backporting-l10n_it_fatturapa_in"

su - odoo -c "git clone -b 8.0 --single-branch  https://github.com/luc-demeyer/noviat-apps /home/odoo/odoodev8/source/0-luc-demever/noviat-apps"


/usr/local/bin/pip install -r /home/odoo/odoodev8/source/1-it-projects-llc/website-addons/requirements.txt
/usr/local/bin/pip install -r /home/odoo/odoodev8/source/1-it-projects-llc/misc-addons/requirements.txt
/usr/local/bin/pip install -r /home/odoo/odoodev8/source/6-zeroincombenze/l10n-italy-supplemental/requirements.txt
/usr/local/bin/pip install -r /home/odoo/odoodev8/source/2-OCA/community-data-files/requirements.txt
/usr/local/bin/pip install -r /home/odoo/odoodev8/source/2-OCA/reporting-engine/requirements.txt
/usr/local/bin/pip install -r /home/odoo/odoodev8/source/2-OCA/report-print-send/requirements.txt
/usr/local/bin/pip install -r /home/odoo/odoodev8/source/2-OCA/server-tools/requirements.txt
/usr/local/bin/pip install -r /home/odoo/odoodev8/source/2-OCA/partner-contact/requirements.txt
/usr/local/bin/pip install -r /home/odoo/odoodev8/source/2-OCA/pos/requirements.txt
/usr/local/bin/pip install -r /home/odoo/odoodev8/source/3-ingadhoc/reporting-engine/requirements.txt
/usr/local/bin/pip install -r /home/odoo/odoodev8/source/3-ingadhoc/partner/requirements.txt
/usr/local/bin/pip install -r /home/odoo/odoodev8/source/3-ingadhoc/miscellaneous/requirements.txt
/usr/local/bin/pip install -r /home/odoo/odoodev8/source/3-ingadhoc/account-payment/requirements.txt
/usr/local/bin/pip install -r /home/odoo/odoodev8/source/3-ingadhoc/odoo-argentina/requirements.txt
/usr/local/bin/pip install -r /home/odoo/odoodev8/source/3-ingadhoc/sale/requirements.txt
/usr/local/bin/pip install -r /home/odoo/odoodev8/source/3-ingadhoc/product/requirements.txt
/usr/local/bin/pip install -r /home/odoo/odoodev8/source/3-ingadhoc/account-invoicing/requirements.txt
/usr/local/bin/pip install -r /home/odoo/odoodev8/source/5-Eficent/addons-vauxoo/requirements.txt


su - odoo -c 'for d in $( ls odoodev8/source); do  find $(pwd)/odoodev8/source/$d -mindepth 2 -maxdepth 2 -type d -exec sh -c "ln -sfn \"{}\" $(pwd)/odoodev8/addons" \;; done'
