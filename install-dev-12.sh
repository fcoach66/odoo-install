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
add-apt-repository -y ppa:ubuntu-desktop/ubuntu-make
apt-get update


echo "Installazione Database Postgresql"
sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
apt-get update
apt-get upgrade -y
apt-get install -y postgresql-9.6 postgresql-server-dev-9.6 pgadmin3 pgadmin4

echo -e "\n---- Install tool packages ----"
apt-get install wget subversion git bzr bzrtools python-pip python3-pip gdebi-core -y

apt-get install -y libsasl2-dev python-dev libldap2-dev libssl-dev python3-dev libxml2-dev libxslt1-dev zlib1g-dev python3-pip python3-wheel python3-setuptools python3-babel python3-bs4 python3-cffi-backend python3-cryptography python3-dateutil python3-docutils python3-feedparser python3-funcsigs python3-gevent python3-greenlet python3-html2text python3-html5lib python3-jinja2 python3-lxml python3-mako python3-markupsafe python3-mock python3-ofxparse python3-openssl python3-passlib python3-pbr python3-pil python3-psutil python3-psycopg2 python3-pydot python3-pygments python3-pyparsing python3-pypdf2 python3-renderpm python3-reportlab python3-reportlab-accel python3-roman python3-serial python3-stdnum python3-suds python3-tz python3-usb python3-vatnumber python3-werkzeug python3-xlsxwriter python3-yaml
pip3 install --upgrade pip
/usr/local/bin/pip3 install --upgrade -r https://raw.githubusercontent.com/odoo/odoo/12.0/requirements.txt

wget https://downloads.wkhtmltopdf.org/0.12/0.12.5/wkhtmltox_0.12.5-1.bionic_amd64.deb
gdebi --n wkhtmltox_0.12.5-1.bionic_amd64.deb

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
sudo -u postgres createuser -s odoo
sudo -u postgres psql -c "ALTER USER odoo WITH PASSWORD 'odoo';"
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'odoo';"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/OCB.git /home/odoo/odoodev12/server"
pip3 install -r /home/odoo/odoodev12/server/requirements.txt
su - odoo -c "mkdir -p /home/odoo/odoodev12/addons"
su - odoo -c "git clone -b 12.0 https://github.com/OCA/reporting-engine /home/odoo/odoodev12/source/2-OCA/reporting-engine"
pip3 install --upgrade -r /home/odoo/odoodev12/source/2-OCA/reporting-engine/requirements.txt

sudo chown -R odoo:odoo /home/odoo/odoodev12/server
sudo chown -R odoo:odoo /home/odoo/odoodev12
pip3 install geojson

echo "Installazione pyxb"
pip3 install pyxb==1.2.6

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

su - odoo -c 'for d in $( ls odoodev12/source); do  find $(pwd)/odoodev12/source/$d -mindepth 2 -maxdepth 2 -type d -exec sh -c "ln -sfn \"{}\" $(pwd)/odoodev12/addons" \;; done'

su - odoo -c "/home/odoo/odoodev12/server/odoo-bin --stop-after-init -s -c /home/odoo/odoodev12/odoo_serverrc --db_host=localhost --db_user=odoo --db_password=odoo --addons-path=/home/odoo/odoodev12/server/odoo/addons,/home/odoo/odoodev12/server/addons,/home/odoo/odoodev12/addons"

echo -e "* Create init file"
su - odoo -c "mkdir bin"
su - odoo -c "cat <<EOF > ~/bin/o12
#!/bin/sh
/home/odoo/odoodev12/server/odoo-bin -c /home/odoo/odoodev12/odoo_serverrc
EOF"
su - odoo -c "chmod 755 ~/bin/o12"

echo "Installazione Aeroo"
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

#su - odoo -c "git clone -b 12.0 https://github.com/ingadhoc/aeroo_reports.git /home/odoo/odoodev12/source/3-ingadhoc/aeroo_reports"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/Numigi/aeroo_reports /home/odoo/odoodev12/source/7-Numigi/aeroo_reports"


su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/server-tools  /home/odoo/odoodev12/source/2-OCA/server-tools"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/server-ux  /home/odoo/odoodev12/source/2-OCA/server-ux"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/partner-contact  /home/odoo/odoodev12/source/2-OCA/partner-contact"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/l10n-italy  /home/odoo/odoodev12/source/2-OCA/l10n-italy"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/account-payment  /home/odoo/odoodev12/source/2-OCA/account-payment"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/account-financial-reporting  /home/odoo/odoodev12/source/2-OCA/account-financial-reporting"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/account-financial-tools  /home/odoo/odoodev12/source/2-OCA/account-financial-tools"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/account-closing  /home/odoo/odoodev12/source/2-OCA/account-closing"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/account-analytic  /home/odoo/odoodev12/source/2-OCA/account-analytic"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/account-invoicing  /home/odoo/odoodev12/source/2-OCA/account-invoicing"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/account-invoice-reporting  /home/odoo/odoodev12/source/2-OCA/account-invoice-reporting"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/account-budgeting /home/odoo/odoodev12/source/2-OCA/account-budgeting"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/account-consolidation /home/odoo/odoodev12/source/2-OCA/account-consolidation"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/bank-payment  /home/odoo/odoodev12/source/2-OCA/bank-payment"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/bank-statement-reconcile  /home/odoo/odoodev12/source/2-OCA/bank-statement-reconcile"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/bank-statement-import  /home/odoo/odoodev12/source/2-OCA/bank-statement-import"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/product-attribute  /home/odoo/odoodev12/source/2-OCA/product-attribute"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/product-variant /home/odoo/odoodev12/source/2-OCA/product-variant"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/stock-logistics-warehouse  /home/odoo/odoodev12/source/2-OCA/stock-logistics-warehouse"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/stock-logistics-tracking  /home/odoo/odoodev12/source/2-OCA/stock-logistics-tracking"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/stock-logistics-barcode  /home/odoo/odoodev12/source/2-OCA/stock-logistics-barcode"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/stock-logistics-workflow  /home/odoo/odoodev12/source/2-OCA/stock-logistics-workflow"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/stock-logistics-transport  /home/odoo/odoodev12/source/2-OCA/stock-logistics-transport"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/sale-workflow  /home/odoo/odoodev12/source/2-OCA/sale-workflow"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/sale-financial /home/odoo/odoodev12/source/2-OCA/sale-financial"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/sale-reporting /home/odoo/odoodev12/source/2-OCA/sale-reporting"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/web  /home/odoo/odoodev12/source/2-OCA/web"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/website  /home/odoo/odoodev12/source/2-OCA/website"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/event /home/odoo/odoodev12/source/2-OCA/event"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/survey /home/odoo/odoodev12/source/2-OCA/survey"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/social  /home/odoo/odoodev12/source/2-OCA/social"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/e-commerce  /home/odoo/odoodev12/source/2-OCA/e-commerce"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/commission /home/odoo/odoodev12/source/2-OCA/commission"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/margin-analysis  /home/odoo/odoodev12/source/2-OCA/margin-analysis"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/contract  /home/odoo/odoodev12/source/2-OCA/contract"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/rma  /home/odoo/odoodev12/source/2-OCA/rma"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/crm  /home/odoo/odoodev12/source/2-OCA/crm"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/project-service  /home/odoo/odoodev12/source/2-OCA/project-service"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/carrier-delivery  /home/odoo/odoodev12/source/2-OCA/carrier-delivery"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/stock-logistics-reporting /home/odoo/odoodev12/source/2-OCA/stock-logistics-reporting"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/hr-timesheet  /home/odoo/odoodev12/source/2-OCA/hr-timesheet"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/hr  /home/odoo/odoodev12/source/2-OCA/hr"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/management-system  /home/odoo/odoodev12/source/2-OCA/management-system"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/report-print-send  /home/odoo/odoodev12/source/2-OCA/report-print-send"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/purchase-reporting  /home/odoo/odoodev12/source/2-OCA/purchase-reporting"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/purchase-workflow  /home/odoo/odoodev12/source/2-OCA/purchase-workflow"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/manufacture-reporting  /home/odoo/odoodev12/source/2-OCA/manufacture-reporting"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/knowledge  /home/odoo/odoodev12/source/2-OCA/knowledge"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/project-reporting  /home/odoo/odoodev12/source/2-OCA/project-reporting"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/project  /home/odoo/odoodev12/source/2-OCA/project"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/connector /home/odoo/odoodev12/source/2-OCA/connector"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/queue /home/odoo/odoodev12/source/2-OCA/queue"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/multi-company  /home/odoo/odoodev12/source/2-OCA/multi-company"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/pos  /home/odoo/odoodev12/source/2-OCA/pos"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/community-data-files  /home/odoo/odoodev12/source/2-OCA/community-data-files"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/geospatial  /home/odoo/odoodev12/source/2-OCA/geospatial"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/vertical-isp  /home/odoo/odoodev12/source/2-OCA/vertical-isp"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/hr-timesheet /home/odoo/odoodev12/source/2-OCA/hr-timesheet"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/server-auth /home/odoo/odoodev12/source/2-OCA/server-auth"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/intrastat /home/odoo/odoodev12/source/2-OCA/intrastat"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/edi /home/odoo/odoodev12/source/2-OCA/edi"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/account-reconcile /home/odoo/odoodev12/source/2-OCA/account-reconcile"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/operating-unit /home/odoo/odoodev12/source/2-OCA/operating-unit"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/currency /home/odoo/odoodev12/source/2-OCA/currency"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/website-themes /home/odoo/odoodev12/source/2-OCA/website-themes"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/server-brand  /home/odoo/odoodev12/source/2-OCA/server-brand"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/server-backend  /home/odoo/odoodev12/source/2-OCA/server-backend"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/field-service  /home/odoo/odoodev12/source/2-OCA/field-service"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/website-cms  /home/odoo/odoodev12/source/2-OCA/website-cms"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/credit-control  /home/odoo/odoodev12/source/2-OCA/credit-control"

su - odoo -c "git clone -b 12.0 --single-branch https://github.com/ingadhoc/miscellaneous  /home/odoo/odoodev12/source/3-ingadhoc/miscellaneous"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/ingadhoc/account-financial-tools  /home/odoo/odoodev12/source/3-ingadhoc/account-financial-tools"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/ingadhoc/account-payment  /home/odoo/odoodev12/source/3-ingadhoc/account-payment"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/ingadhoc/partner  /home/odoo/odoodev12/source/3-ingadhoc/partner"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/ingadhoc/sale  /home/odoo/odoodev12/source/3-ingadhoc/sale"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/ingadhoc/account-invoicing  /home/odoo/odoodev12/source/3-ingadhoc/account-invoicing"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/ingadhoc/product  /home/odoo/odoodev12/source/3-ingadhoc/product"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/ingadhoc/stock  /home/odoo/odoodev12/source/3-ingadhoc/stock"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/ingadhoc/multi-company  /home/odoo/odoodev12/source/3-ingadhoc/multi-company"

#su - odoo -c "git clone -b 12.0 --single-branch https://github.com/it-projects-llc/misc-addons  /home/odoo/odoodev12/source/1-it-projects-llc/misc-addons"
#su - odoo -c "git clone -b 12.0 --single-branch https://github.com/it-projects-llc/access-addons  /home/odoo/odoodev12/source/1-it-projects-llc/access-addons"
#su - odoo -c "git clone -b 12.0 --single-branch https://github.com/it-projects-llc/pos-addons  /home/odoo/odoodev12/source/1-it-projects-llc/pos-addons"
#su - odoo -c "git clone -b 12.0 --single-branch https://github.com/it-projects-llc/website-addons  /home/odoo/odoodev12/source/1-it-projects-llc/website-addons"
#su - odoo -c "git clone -b 12.0 --single-branch https://github.com/it-projects-llc/mail-addons  /home/odoo/odoodev12/source/1-it-projects-llc/mail-addons"

su - odoo -c "git clone -b 12.0 --single-branch https://github.com/itpp-labs/misc-addons  /home/odoo/odoodev12/source/1-itpp-labs/misc-addons"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/itpp-labs/access-addons  /home/odoo/odoodev12/source/1-itpp-labs/access-addons"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/itpp-labs/website-addons  /home/odoo/odoodev12/source/1-itpp-labs/website-addons"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/itpp-labs/mail-addons  /home/odoo/odoodev12/source/1-itpp-labs/mail-addons"

su - odoo -c "git clone -b 12.0 --single-branch https://github.com/vauxoo/addons-vauxoo /home/odoo/odoodev12/source/5-vauxoo/addons-vauxoo"

su - odoo -c "git clone -b 12.0 --single-branch https://github.com/onesteinbv/addons-onestein  /home/odoo/odoodev12/source/6-onesteinbv/addons-onestein"

#su - odoo -c "git clone -b 12.0 --single-branch https://github.com/efatto/efatto /home/odoo/odoodev12/source/6-efatto/efatto"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/sergiocorato/efatto /home/odoo/odoodev12/source/6-sergiocorato/efatto"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/sergiocorato/e-efatto /home/odoo/odoodev12/source/6-sergiocorato/e-efatto"


su - odoo -c "git clone -b 12.0 --single-branch https://github.com/fcoach66/odoo-italy-extra  /home/odoo/odoodev12/source/7-fcoach66/odoo-italy-extra"


#su - odoo -c "git clone -b 12.0-mig-account_analytic_distribution --single-branch https://github.com/Tecnativa/account-analytic/ /home/odoo/odoodev12/source/1-Tecnativa/12.0-mig-account_analytic_distribution-account-analytic"


su - odoo -c "git clone -b 12.0-mig-invoice_comment_template --single-branch https://github.com/QubiQ/account-invoice-reporting /home/odoo/odoodev12/source/1-QubiQ/account-invoice-reporting"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/QubiQ/qu-server-tools /home/odoo/odoodev12/source/1-QubiQ/qu-server-tools"

# su - odoo -c "git clone -b 12.0-mig-l10n_it_split_payment_\(rt\) --single-branch https://github.com/ruben-tonetto/l10n-italy /home/odoo/odoodev12/source/0-ruben-tonetto/12.0-mig-l10n_it_split_payment_\(rt\)"
# su - odoo -c "git clone -b 12.0-porting-l10n_it_vat_registries --single-branch https://github.com/eLBati/l10n-italy/ /home/odoo/odoodev12/source/1-eLBati/12.0-porting-l10n_it_vat_registries-l10n-italy"
# su - odoo -c "git clone -b 12.0-mig-stock_picking_package_preparation --single-branch https://github.com/dcorio/stock-logistics-workflow  /home/odoo/odoodev12/source/1-dcorio/12.0-mig-stock_picking_package_preparation"
# su - odoo -c "git clone -b 12.0-mig-l10n_it_reverse_charge --single-branch https://github.com/jackjack82/l10n-italy /home/odoo/odoodev12/source/1-jackjack82/12.0-mig-l10n_it_reverse_charge"
# su - odoo -c "git clone -b 12.0-mig-l10n_it_ddt --single-branch https://github.com/SimoRubi/l10n-italy /home/odoo/odoodev12/source/1-SimoRubi/12.0-mig-l10n_it_ddt"
# su - odoo -c "git clone -b 12.0-mig-account_vat_period_end_statement --single-branch https://github.com/jackjack82/l10n-italy /home/odoo/odoodev12/source/1-jackjack82/12.0-mig-account_vat_period_end_statement"
# su - odoo -c "git clone -b 12.0-mig-l10n_it_ricevute_bancarie-rt --single-branch https://github.com/ruben-tonetto/l10n-italy /home/odoo/odoodev12/source/0-ruben-tonetto/12.0-mig-l10n_it_ricevute_bancarie-rt"
# su - odoo -c "git clone -b 12.0-mig-l10n_it_fatturapa --single-branch https://github.com/linkitspa/l10n-italy/ /home/odoo/odoodev12/source/0-linkitspa/12.0-mig-l10n_it_fatturapa-l10n-italy"
# su - odoo -c "git clone -b 12.0-mig-l10n_it_fatturapa_out --single-branch https://github.com/linkitspa/l10n-italy/ /home/odoo/odoodev12/source/0-linkitspa/12.0-mig-l10n_it_fatturapa_out-l10n-italy"
# su - odoo -c "git clone -b 12.0-mig-l10n_it_fatturapa_in --single-branch https://github.com/linkitspa/l10n-italy/ /home/odoo/odoodev12/source/0-linkitspa/12.0-mig-l10n_it_fatturapa_in-l10n-italy"
# su - odoo -c "git clone -b 12.0-mig-l10n_it_fatturapa_pec  --single-branch https://github.com/linkitspa/l10n-italy/ /home/odoo/odoodev12/source/0-linkitspa/12.0-mig-l10n_it_fatturapa_pec"
# su - odoo -c "git clone -b 12.0-mig-l10n_it_sdi_channel --single-branch https://github.com/linkitspa/l10n-italy/ /home/odoo/odoodev12/source/0-linkitspa/12.0-mig-l10n_it_sdi_channel"


su - odoo -c "git clone -b feature/12.0-mig-account_fiscal_position_vat_check --single-branch https://github.com/rven/account-financial-tools /home/odoo/odoodev12/source/1-rven/12.0-mig-account_fiscal_position_vat_check-account-financial-tools"

su - odoo -c "git clone -b 12.0 --single-branch https://github.com/fcoach66/odoo-italy-extra  /home/odoo/odoodev12/source/7-fcoach66/odoo-italy-extra"

su - odoo -c "git clone -b 12.0 --single-branch https://github.com/CybroOdoo/CybroAddons /home/odoo/odoodev12/source/0-CybroOdoo/CybroAddons"

su - odoo -c "git clone -b 12.0 --single-branch https://github.com/Openworx/backend_theme /home/odoo/odoodev12/source/0-Openworx/backend_theme"


#su - odoo -c "git clone -b 12.0-mig-l10n_it_ricevute_bancarie https://github.com/scigghia/l10n-italy /home/odoo/odoodev12/source/0-scigghia/l10n-italy"
#su - odoo -c "git clone -b 12.0_ricevute_bancarie https://github.com/As400it/l10n-italy /home/odoo/odoodev12/source/0-As400it/l10n-italy"
#su - odoo -c "git clone -b 12.0-mig-l10n_it_withholding_tax_payment https://github.com/linkitspa/l10n-italy /home/odoo/odoodev12/source/0-linkitspa-1/l10n-italy"
#su - odoo -c "git clone -b 12.0-mig-letsencrypt --single-branch https://github.com/eLBati/server-tools/ /home/odoo/odoodev12/source/0-eLBati/l10n-italy"


su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/product-pack  /home/odoo/odoodev12/source/2-OCA/product-pack"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/timesheet  /home/odoo/odoodev12/source/2-OCA/timesheet"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/maintenance /home/odoo/odoodev12/source/2-OCA/maintenance"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/storage /home/odoo/odoodev12/source/2-OCA/storage"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/connector-ecommerce /home/odoo/odoodev12/source/2-OCA/connector-ecommerce"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/helpdesk /home/odoo/odoodev12/source/2-OCA/helpdesk"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/account-fiscal-rule /home/odoo/odoodev12/source/2-OCA/account-fiscal-rule"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/payroll /home/odoo/odoodev12/source/2-OCA/payroll"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/server-brand /home/odoo/odoodev12/source/2-OCA/server-brand"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/search-engine /home/odoo/odoodev12/source/2-OCA/search-engine"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/product-kitting /home/odoo/odoodev12/source/2-OCA/product-kitting"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/intrastat-extrastat /home/odoo/odoodev12/source/2-OCA/intrastat-extrastat"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/data-protection /home/odoo/odoodev12/source/2-OCA/data-protection"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/brand /home/odoo/odoodev12/source/2-OCA/brand"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/OCA/mis-builder /home/odoo/odoodev12/source/2-OCA/mis-builder"


su - odoo -c "git clone -b 12.0-mig-account_bank_statement_import_qif --single-branch https://github.com/erick-tejada/bank-statement-import 0-Numigi/erick-tejada"

su - odoo -c "git clone -b 12.0 --single-branch https://github.com/dhongu/deltatech /home//odoo/odoodev12/source/5-dhongu/deltatech"

su - odoo -c "git clone -b 12.0 --single-branch https://github.com/muk-it/muk_misc /home//odoo/odoodev12/source/5-muk-it/muk_misc"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/muk-it/muk_web /home//odoo/odoodev12/source/5-muk-it/muk_web"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/muk-it/muk_base /home//odoo/odoodev12/source/5-muk-it/muk_base"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/muk-it/muk_dms /home//odoo/odoodev12/source/5-muk-it/muk_dms"


su - odoo -c "git clone -b 12.0 --single-branch https://github.com/CybroOdoo/CybroAddons /home//odoo/odoodev12/source/5-CybroOdoo/CybroAddons"
su - odoo -c "git clone -b 12.0 --single-branch https://github.com/fcoach66/CybroAddons /home//odoo/odoodev12/source/7-fcoach66/CybroAddons"

su - odoo -c "git clone -b 12.0 --single-branch https://github.com/odoomates/odooapps /home//odoo/odoodev12/source/5-odoomates/odooapps"

su - odoo -c "git clone -b 12.0 --single-branch https://github.com/Smile-SA/odoo_addons /home//odoo/odoodev12/source/5-Smile-SA/odoo_addons"




su - odoo -c "find . -type d -name .git -exec sh -c "cd \"{}\"/../ && pwd && git pull" \;"
su - odoo -c 'for d in $( ls odoodev12/source); do  find $(pwd)/odoodev12/source/$d -mindepth 2 -maxdepth 2 -type d -exec sh -c "ln -sfn \"{}\" $(pwd)/odoodev12/addons" \;; done'


pip3 install -r /home/odoo/odoodev12/server/requirements.txt
pip3 install -r /home/odoo/odoodev12/source/2-OCA/server-tools/requirements.txt
pip3 install -r /home/odoo/odoodev12/source/2-OCA/server-auth/requirements.txt
pip3 install -r /home/odoo/odoodev12/source/2-OCA/report-print-send/requirements.txt
pip3 install -r /home/odoo/odoodev12/source/2-OCA/community-data-files/requirements.txt
pip3 install -r /home/odoo/odoodev12/source/2-OCA/stock-logistics-barcode/requirements.txt
pip3 install -r /home/odoo/odoodev12/source/2-OCA/field-service/requirements.txt
pip3 install -r /home/odoo/odoodev12/source/2-OCA/web/requirements.txt
pip3 install -r /home/odoo/odoodev12/source/2-OCA/reporting-engine/requirements.txt
pip3 install -r /home/odoo/odoodev12/source/2-OCA/connector/requirements.txt
pip3 install -r /home/odoo/odoodev12/source/2-OCA/event/requirements.txt
pip3 install -r /home/odoo/odoodev12/source/3-ingadhoc/account-invoicing/requirements.txt
pip3 install -r /home/odoo/odoodev12/source/3-ingadhoc/odoo-argentina/requirements.txt
pip3 install -r /home/odoo/odoodev12/source/3-ingadhoc/sale/requirements.txt
pip3 install -r /home/odoo/odoodev12/source/3-ingadhoc/argentina-reporting/requirements.txt
pip3 install -r /home/odoo/odoodev12/source/3-ingadhoc/partner/requirements.txt
pip3 install -r /home/odoo/odoodev12/source/3-ingadhoc/product/requirements.txt
pip3 install -r /home/odoo/odoodev12/source/3-ingadhoc/miscellaneous/requirements.txt
pip3 install -r /home/odoo/odoodev12/source/3-ingadhoc/aeroo_reports/requirements.txt
pip3 install -r /home/odoo/odoodev12/source/3-ingadhoc/reporting-engine/requirements.txt
pip3 install -r /home/odoo/odoodev12/source/3-ingadhoc/argentina-sale/requirements.txt
pip3 install -r /home/odoo/odoodev12/source/3-ingadhoc/account-payment/requirements.txt
pip3 install -r /home/odoo/odoodev12/source/1-itpp-labs/misc-addons/requirements.txt
pip3 install -r /home/odoo/odoodev12/source/1-itpp-labs/pos-addons/requirements.txt
pip3 install -r /home/odoo/odoodev12/source/1-itpp-labs/website-addons/requirements.txt
