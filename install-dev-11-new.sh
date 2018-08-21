#!/bin/bash

#--------------------------------------------------
# Update Server
#--------------------------------------------------
echo -e "\n---- Update Server ----"
apt-get update && sudo apt-get dist-upgrade -y && sudo apt-get autoremove -y
apt-get install default-jre -y
add-apt-repository -y ppa:webupd8team/java
apt-get install default-jdk -y
apt-get update
apt-get install oracle-java8-installer -y
add-apt-repository -y ppa:mystic-mirage/pycharm
apt-get update

echo -e "\n---- Install Virtualbox Guest Utils ----"
sudo apt-get install virtualbox-guest-x11-hwe -y



echo "Installazione Database Postgresql"
sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
apt-get update
apt-get upgrade -y
apt-get install -y postgresql-9.6 postgresql-server-dev-9.6 pgadmin3 pgadmin4

echo -e "\n---- Install tool packages ----"
apt-get install wget subversion git bzr bzrtools python-pip python3-pip gdebi-core -y

apt-get install -y libsasl2-dev python-dev libldap2-dev libssl-dev python3-dev libxml2-dev libxslt1-dev zlib1g-dev python3-pip python3-wheel python3-setuptools python3-babel python3-bs4 python3-cffi-backend python3-cryptography python3-dateutil python3-docutils python3-feedparser python3-funcsigs python3-gevent python3-greenlet python3-html2text python3-html5lib python3-jinja2 python3-lxml python3-mako python3-markupsafe python3-mock python3-ofxparse python3-openssl python3-passlib python3-pbr python3-pil python3-psutil python3-psycopg2 python3-pydot python3-pygments python3-pyparsing python3-pypdf2 python3-renderpm python3-reportlab python3-reportlab-accel python3-roman python3-serial python3-stdnum python3-suds python3-tz python3-usb python3-vatnumber python3-werkzeug python3-xlsxwriter python3-yaml
/usr/local/bin/pip3.4 install --upgrade -r https://raw.githubusercontent.com/odoo/odoo/11.0/requirements.txt

wget https://downloads.wkhtmltopdf.org/0.12/0.12.5/wkhtmltox_0.12.5-1.xenial_amd64.deb
gdebi --n wkhtmltox_0.12.5-1.xenial_amd64.deb

echo -e "\n---- Install python libraries ----"
# This is for compatibility with Ubuntu 16.04. Will work on 14.04, 15.04 and 16.04
apt-get install python3-suds -y

echo -e "\n--- Install other required packages"
apt-get install node-clean-css node-less python-gevent -y

#echo -e "\n--- Create symlink for node"
#sudo ln -s /usr/bin/nodejs /usr/bin/node

/usr/local/bin/pip3.4 install num2words ofxparse
apt-get install nodejs npm node-less -y
#sudo npm install -g less
#sudo npm install -g less-plugin-clean-css	

	
	
echo "Installazione Odoo 11.0"
sudo -u postgres createuser -s odoo
sudo -u postgres psql -c "ALTER USER odoo WITH PASSWORD 'odoo';"
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'odoo';"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/OCB.git /home/odoo/odoodev11/server"
su - odoo -c "mkdir -p /home/odoo/odoodev11/addons"
su - odoo -c "git clone -b 11.0 https://github.com/OCA/reporting-engine /home/odoo/odoodev11/source/OCA/reporting-engine"
/usr/local/bin/pip3.4 install --upgrade -r /home/odoo/odoodev11/source/OCA/reporting-engine/requirements.txt

sudo chown -R odoo:odoo /home/odoo/odoodev11/server
sudo chown -R odoo:odoo /home/odoo/odoodev11
/usr/local/bin/pip3.4 install geojson

echo "Installazione pyxb"
/usr/local/bin/pip3.4 install pyxb==1.2.5

echo "Installazione codicefiscale"
/usr/local/bin/pip3.4 install codicefiscale

echo "Installazione simplejson"
/usr/local/bin/pip3.4 install simplejson

echo "Installazione unidecode"
/usr/local/bin/pip3.4 install unidecode

echo "Installazione phonenumbers"
/usr/local/bin/pip3.4 install phonenumbers

echo "Installazione numpy"
/usr/local/bin/pip3.4 install numpy

echo "Installazione cachetools"
/usr/local/bin/pip3.4 install cachetools


su - odoo -c "/home/odoo/odoodev11/server/odoo-bin --stop-after-init -s -c /home/odoo/odoodev11/odoodev11/odoo_serverrc --db_host=localhost --db_user=odoo --db_password=odoo --addons-path=/home/odoo/odoodev11/odoodev11/server/odoo/addons,/home/odoo/odoodev11/odoo11/server/addons,/home/odoo/odoodev11/odoodev11/addons"

echo -e "* Create init file"
su - odoo -c "mkdir bin"
su - odoo -c "cat <<EOF > ~/bin/o11
#!/bin/sh
/home/odoo/odoodev11/odoodev11/server/odoo-bin -c /home/odoo/odoodev11/odoodev11/odoo_derverrc
EOF"
su - odoo -c "chmod 755 ~/bin/o11"

echo "Installazione Aeroo"
mkdir /opt/aeroo
echo '#!/bin/sh' > /etc/init.d/office
echo '' >> /etc/init.d/office
echo '/usr/bin/soffice --nologo --nofirststartwizard --headless --norestore --invisible "--accept=socket,host=localhost,port=8100,tcpNoDelay=1;urp;" &'  >> /etc/init.d/office
chmod +x /etc/init.d/office
update-rc.d office defaults
/etc/init.d/office
/usr/local/bin/pip3.4 install jsonrpc2 daemonize
git clone https://github.com/aeroo/aeroo_docs.git /opt/aeroo/aeroo_docs
cd /opt/aeroo/aeroo_docs/
echo "Y" | python3 /opt/aeroo/aeroo_docs/aeroo-docs start -c /etc/aeroo-docs.conf
ln -s /opt/aeroo/aeroo_docs/aeroo-docs /etc/init.d/aeroo-docs
update-rc.d aeroo-docs defaults

su - odoo -c "git clone -b 11.0 https://github.com/ingadhoc/aeroo_reports.git /home/odoo/odoodev11/source/ingadhoc/aeroo_reports"
/usr/local/bin/pip3.4 install --upgrade -r /home/odoo/odoodev11/source/ingadhoc/aeroo_reports/requirements.txt
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/server-tools  /home/odoo/odoodev11/source/OCA/server-tools"
/usr/local/bin/pip3.4 install -r /home/odoo/odoodev11/source/OCA/server-tools/requirements.txt
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/server-ux  /home/odoo/odoodev11/source/OCA/server-ux"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/partner-contact  /home/odoo/odoodev11/source/OCA/partner-contact"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/l10n-italy  /home/odoo/odoodev11/source/OCA/l10n-italy"
su - odoo -c "git clone -b 11.0-mig-tax_kind --single-branch https://github.com/fcoach66/l10n-italy  /home/odoo/odoodev11/source/fcoach66/11.0-mig-tax_kind-l10n-italy"
su - odoo -c "git clone -b 11.0-mig-l10n_it_ipa --single-branch https://github.com/fcoach66/l10n-italy  /home/odoo/odoodev11/source/fcoach66/11.0-mig-l10n_it_ipa-l10n-italy"
su - odoo -c "git clone -b 11.0-mig-l10n_it_rea --single-branch https://github.com/fcoach66/l10n-italy  /home/odoo/odoodev11/source/fcoach66/11.0-mig-l10n_it_rea-l10n-italy"
su - odoo -c "git clone -b 11.0-mig-fatturapa --single-branch https://github.com/fcoach66/l10n-italy  /home/odoo/odoodev11/source/fcoach66/11.0-mig-fatturapa-l10n-italy"
su - odoo -c "git clone -b 11.0-mig-l10n_it_split_payment --single-branch https://github.com/jackjack82/l10n-italy /home/odoo/odoodev11/source/jackjack82/11.0-mig-l10n_it_split_payment"
su - odoo -c "git clone -b 11.0-mig-l10n_it_reverse_charge --single-branch https://github.com/jackjack82/l10n-italy /home/odoo/odoodev11/source/jackjack82/11.0-mig-l10n_it_reverse_charge"
su - odoo -c "git clone -b 11.0-mig-l10n_it_withholding_tax --single-branch https://github.com/alessandrocamilli/l10n-italy /home/odoo/odoodev11/source/alessandrocamilli/11.0-mig-l10n_it_withholding_tax"
su - odoo -c "git clone -b 11.0-mig-l10n_it_ddt --single-branch https://github.com/SilvioGregorini/l10n-italy /home/odoo/odoodev11/source/SilvioGregorini/11.0-mig-l10n_it_ddt"
su - odoo -c "git clone -b 11.0-mig-account_vat_period_end_statement --single-branch https://github.com/jackjack82/l10n-italy /home/odoo/odoodev11/source/jackjack82/11.0-mig-account_vat_period_end_statement"
su - odoo -c "git clone -b 11.0-mig-l10n_it_ricevute_bancarie --single-branch https://github.com/jackjack82/l10n-italy /home/odoo/odoodev11/source/jackjack82/11.0-mig-l10n_it_ricevute_bancarie"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/ingadhoc/miscellaneous  /home/odoo/odoodev11/source/ingadhoc/miscellaneous"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/ingadhoc/odoo-argentina  /home/odoo/odoodev11/source/ingadhoc/odoo-argentina"
/usr/local/bin/pip3.4 install -r /home/odoo/odoodev11/source/ingadhoc/odoo-argentina/requirements.txt
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/ingadhoc/argentina-sale  /home/odoo/odoodev11/source/ingadhoc/argentina-sale"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/ingadhoc/argentina-reporting  /home/odoo/odoodev11/source/ingadhoc/argentina-reporting"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/ingadhoc/account-financial-tools  /home/odoo/odoodev11/source/ingadhoc/account-financial-tools"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/ingadhoc/reporting-engine  /home/odoo/odoodev11/source/ingadhoc/reporting-engine"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/ingadhoc/account-payment  /home/odoo/odoodev11/source/ingadhoc/account-payment"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/ingadhoc/partner  /home/odoo/odoodev11/source/ingadhoc/partner"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/ingadhoc/sale  /home/odoo/odoodev11/source/ingadhoc/sale"
/usr/local/bin/pip3.4 install -r /home/odoo/odoodev11/source/ingadhoc/sale/requirements.txt
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/ingadhoc/account-invoicing  /home/odoo/odoodev11/source/ingadhoc/account-invoicing"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/ingadhoc/product  /home/odoo/odoodev11/source/ingadhoc/product"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/account-payment  /home/odoo/odoodev11/source/OCA/account-payment"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/account-financial-reporting  /home/odoo/odoodev11/source/OCA/account-financial-reporting"
/usr/local/bin/pip3.4 install -r /home/odoo/odoodev11/source/OCA/account-financial-reporting/requirements.txt
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/account-financial-tools  /home/odoo/odoodev11/source/OCA/account-financial-tools"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/account-closing  /home/odoo/odoodev11/source/OCA/account-closing"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/account-analytic  /home/odoo/odoodev11/source/OCA/account-analytic"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/account-invoicing  /home/odoo/odoodev11/source/OCA/account-invoicing"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/account-invoice-reporting  /home/odoo/odoodev11/source/OCA/account-invoice-reporting"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/account-budgeting /home/odoo/odoodev11/source/OCA/account-budgeting"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/account-consolidation /home/odoo/odoodev11/source/OCA/account-consolidation"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/bank-payment  /home/odoo/odoodev11/source/OCA/bank-payment"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/bank-statement-reconcile  /home/odoo/odoodev11/source/OCA/bank-statement-reconcile"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/bank-statement-import  /home/odoo/odoodev11/source/OCA/bank-statement-import"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/product-attribute  /home/odoo/odoodev11/source/OCA/product-attribute"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/product-variant /home/odoo/odoodev11/source/OCA/product-variant"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/stock-logistics-warehouse  /home/odoo/odoodev11/source/OCA/stock-logistics-warehouse"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/stock-logistics-tracking  /home/odoo/odoodev11/source/OCA/stock-logistics-tracking"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/stock-logistics-barcode  /home/odoo/odoodev11/source/OCA/stock-logistics-barcode"
/usr/local/bin/pip3.4 install -r /home/odoo/odoodev11/source/OCA/stock-logistics-barcode/requirements.txt
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/stock-logistics-workflow  /home/odoo/odoodev11/source/OCA/stock-logistics-workflow"
su - odoo -c "git clone -b 11.0-mig-stock_picking_package_preparation --single-branch https://github.com/dcorio/stock-logistics-workflow  /home/odoo/odoodev11/source/dcorio/11.0-mig-stock_picking_package_preparation"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/stock-logistics-transport  /home/odoo/odoodev11/source/OCA/stock-logistics-transport"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/sale-workflow  /home/odoo/odoodev11/source/OCA/sale-workflow"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/sale-financial /home/odoo/odoodev11/source/OCA/sale-financial"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/sale-reporting /home/odoo/odoodev11/source/OCA/sale-reporting"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/web  /home/odoo/odoodev11/source/OCA/web"
/usr/local/bin/pip3.4 install -r /home/odoo/odoodev11/source/OCA/web/requirements.txt
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/website  /home/odoo/odoodev11/source/OCA/website"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/event /home/odoo/odoodev11/source/OCA/event"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/survey /home/odoo/odoodev11/source/OCA/survey"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/social  /home/odoo/odoodev11/source/OCA/social"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/e-commerce  /home/odoo/odoodev11/source/OCA/e-commerce"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/commission /home/odoo/odoodev11/source/OCA/commission"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/margin-analysis  /home/odoo/odoodev11/source/OCA/margin-analysis"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/contract  /home/odoo/odoodev11/source/OCA/contract"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/rma  /home/odoo/odoodev11/source/OCA/rma"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/crm  /home/odoo/odoodev11/source/OCA/crm"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/project-service  /home/odoo/odoodev11/source/OCA/project-service"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/carrier-delivery  /home/odoo/odoodev11/source/OCA/carrier-delivery"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/stock-logistics-reporting /home/odoo/odoodev11/source/OCA/stock-logistics-reporting"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/hr-timesheet  /home/odoo/odoodev11/source/OCA/hr-timesheet"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/hr  /home/odoo/odoodev11/source/OCA/hr"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/management-system  /home/odoo/odoodev11/source/OCA/management-system"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/report-print-send  /home/odoo/odoodev11/source/OCA/report-print-send"
/usr/local/bin/pip3.4 install -r /home/odoo/odoodev11/source/OCA/report-print-send/requirements.txt 
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/purchase-reporting  /home/odoo/odoodev11/source/OCA/purchase-reporting"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/purchase-workflow  /home/odoo/odoodev11/source/OCA/purchase-workflow"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/manufacture-reporting  /home/odoo/odoodev11/source/OCA/manufacture-reporting"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/knowledge  /home/odoo/odoodev11/source/OCA/knowledge"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/project-reporting  /home/odoo/odoodev11/source/OCA/project-reporting"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/project  /home/odoo/odoodev11/source/OCA/project"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/it-projects-llc/misc-addons  /home/odoo/odoodev11/source/it-projects-llc/misc-addons"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/it-projects-llc/access-addons  /home/odoo/odoodev11/source/it-projects-llc/access-addons"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/it-projects-llc/pos-addons  /home/odoo/odoodev11/source/it-projects-llc/pos-addons"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/it-projects-llc/website-addons  /home/odoo/odoodev11/source/it-projects-llc/website-addons"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/it-projects-llc/mail-addons  /home/odoo/odoodev11/source/it-projects-llc/mail-addons"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/vauxoo/addons-vauxoo /home/odoo/odoodev11/source/vauxoo/addons-vauxoo"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/onesteinbv/addons-onestein  /home/odoo/odoodev11/source/onesteinbv/addons-onestein"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/connector /home/odoo/odoodev11/source/OCA/connector"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/queue /home/odoo/odoodev11/source/OCA/queue"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/multi-company  /home/odoo/odoodev11/source/OCA/multi-company"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/pos  /home/odoo/odoodev11/source/OCA/pos"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/fcoach66/odoo-italy-extra  /home/odoo/odoodev11/source/fcoach66/odoo-italy-extra"

su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/community-data-files  /home/odoo/odoodev11/source/OCA/community-data-files"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/geospatial  /home/odoo/odoodev11/source/OCA/geospatial"
su - odoo -c "git clone -b 11.0 --single-branch https://github.com/OCA/vertical-isp  /home/odoo/odoodev11/source/OCA/vertical-isp"


su - odoo -c "git clone -b 11.0-mig-invoice_comment_template --single-branch https://github.com/QubiQ/account-invoice-reporting /home/odoo/odoodev11/source/1-QubiQ/account-invoice-reporting"

su - odoo -c "find . -type d -name .git -exec sh -c "cd \"{}\"/../ && pwd && git pull" \;"
su - odoo -c "for d in $( ls ); do  find $(pwd)/$d -mindepth 2 -maxdepth 2 -type d -exec sh -c "ln -sfn \"{}\" $(pwd)/../addons" \;; done"


/usr/local/bin/pip3.4 install -r /home/odoo/odoodev11/source/ingadhoc/product/requirements.txt
/usr/local/bin/pip3.4 install -r /home/odoo/odoodev11/source/ingadhoc/account-invoicing/requirements.txt
/usr/local/bin/pip3.4 install -r /home/odoo/odoodev11/source/ingadhoc/reporting-engine/requirements.txt
/usr/local/bin/pip3.4 install -r /home/odoo/odoodev11/source/ingadhoc/partner/requirements.txt
/usr/local/bin/pip3.4 install -r /home/odoo/odoodev11/source/ingadhoc/sale/requirements.txt
/usr/local/bin/pip3.4 install -r /home/odoo/odoodev11/source/OCA/stock-logistics-barcode/requirements.txt
/usr/local/bin/pip3.4 install -r /home/odoo/odoodev11/source/OCA/server-tools/requirements.txt
/usr/local/bin/pip3.4 install -r /home/odoo/odoodev11/source/OCA/account-financial-tools/requirements.txt
/usr/local/bin/pip3.4 install -r /home/odoo/odoodev11/source/OCA/web/requirements.txt
/usr/local/bin/pip3.4 install -r /home/odoo/odoodev11/source/OCA/account-financial-reporting/requirements.txt
/usr/local/bin/pip3.4 install -r /home/odoo/odoodev11/source/OCA/reporting-engine/requirements.txt
/usr/local/bin/pip3.4 install -r /home/odoo/odoodev11/source/OCA/report-print-send/requirements.txt
/usr/local/bin/pip3.4 install -r /home/odoo/odoodev11/source/vauxoo/addons-vauxoo/requirements.txt
/usr/local/bin/pip3.4 install -r /home/odoo/odoodev11/source/it-projects-llc/misc-addons/requirements.txt
/usr/local/bin/pip3.4 install -r /home/odoo/odoodev11/source/it-projects-llc/website-addons/requirements.txt




