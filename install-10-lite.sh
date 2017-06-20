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
apt-get install -y sudo mc zip unzip htop ntp ghostscript graphviz antiword libpq-dev poppler-utils build-essential libfreetype6-dev npm build-essential libpq-dev poppler-utils antiword libldap2-dev libsasl2-dev libssl-dev git nginx munin apache2-utils fonts-crosextra-caladea fonts-crosextra-carlito node-less python-dev python3-dev libxml2-dev libxslt1-dev default-jre ure libreoffice-java-common libreoffice-writer

echo "Installazione pacchetti deb python"
apt-get install -y python-magic python-dateutil python-pypdf python-requests python-feedparser python-gdata python-ldap python-libxslt1 python-lxml python-mako python-openid python-psycopg2 python-pybabel python-pychart python-pydot python-pyparsing python-reportlab python-simplejson python-tz python-vatnumber python-vobject python-webdav python-werkzeug python-xlwt python-yaml python-zsi python-docutils python-psutil python-unittest2 python-mock python-jinja2 python-dev python-pdftools python-decorator python-openssl python-babel python-imaging python-reportlab-accel python-paramiko python-cups python-software-properties python-dev python-dateutil python-feedparser python-gdata python-ldap python-lxml python-mako python-openid python-psycopg2 python-pychart python-pydot python-pyparsing python-reportlab python-tz python-vatnumber python-vobject python-webdav python-xlwt python-yaml python-zsi python-docutils python-unittest2 python-mock python-jinja2 python-werkzeug python-setuptools python-genshi python-cairo python-lxml

echo "Installazione pacchetti pip"
pip install passlib beautifulsoup4 evdev reportlab qrcode polib unidecode validate_email pyDNS pysftp python-slugify phonenumbers py-Asterisk codicefiscale unicodecsv ofxparse pytils gevent_psycopg2 psycogreen erppeek PyXB

echo "Installazione pacchetti py3o"
pip install py3o.template
pip install py3o.formats
pip install py3o.fusion
pip install service-identity
pip install py3o.renderserver

echo '#!/bin/sh' > /etc/init.d/py3o.fusion
echo '' >> /etc/init.d/py3o.fusion
echo '/usr/local/bin/start-py3o-renderserver -s localhost &'  >> /etc/init.d/py3o.fusion
chmod +x /etc/init.d/py3o.fusion
update-rc.d py3o.fusion defaults
/etc/init.d/py3o.fusion

echo '#!/bin/sh' > /etc/init.d/py3o.renderserver
echo '' >> /etc/init.d/py3o.renderserver
echo '/usr/local/bin/start-py3o-fusion --java=/usr/lib/jvm/default-java/jre/lib/amd64/server/libjvm.so --ure=/usr/share --office=/usr/lib/libreoffice --driver=juno --sofficeport=8997 &'  >> /etc/init.d/py3o.renderserver
chmod +x /etc/init.d/py3o.renderserver
update-rc.d py3o.renderserver defaults
/etc/init.d/py3o.renderserver

#echo "Installazione pacchetti npm"
#npm install -g less less-plugin-clean-css
#ln -s /usr/bin/nodejs /usr/bin/node

#echo "Installazione Barcodes"
#wget --quiet http://www.reportlab.com/ftp/pfbfer.zip
#unzip pfbfer.zip -d fonts
#mv fonts /usr/lib/python2.7/dist-packages/reportlab/
#rm pfbfer.zip

echo "Installazione wkhtmltox 0.12.1"
wget --quiet http://nightly.odoo.com/extra/wkhtmltox-0.12.2.1_linux-jessie-amd64.deb
apt-get remove -y wkhtmltopdf
apt-get install -y xfonts-base xfonts-75dpi
dpkg -i wkhtmltox-0.12.2.1_linux-jessie-amd64.deb
rm wkhtmltox-0.12.2.1_linux-jessie-amd64.deb

echo "Installazione PoS"
pip install pyserial
pip install --pre pyusb

#echo "Ottimizzazione configurazione database"
#pgtune -i /etc/postgresql/9.4/main/postgresql.conf -o /etc/postgresql/9.4/main/postgresql.conf.tuned
#mv /etc/postgresql/9.4/main/postgresql.conf  /etc/postgresql/9.4/main/postgresql.conf.old
#mv /etc/postgresql/9.4/main/postgresql.conf.tuned  /etc/postgresql/9.4/main/postgresql.conf
#/etc/init.d/postgresql stop
#/etc/init.d/postgresql start 
#cat /etc/postgresql/9.4/main/postgresql.conf

echo "Installazione Odoo 10.0"
adduser odoo --system --group --shell /bin/bash --home /opt/odoo
sudo -u postgres createuser -s odoo
sudo -u postgres psql -c "ALTER USER odoo WITH PASSWORD 'odoo';"
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'odoo';"
su - odoo -c "git clone -b 10.0 --single-branch https://github.com/OCA/OCB.git /opt/odoo/server"
su - odoo -c "mkdir -p /opt/odoo/source/OCA"
su - odoo -c "mkdir -p /opt/odoo/addons"
su - odoo -c "git clone -b 10.0 https://github.com/OCA/webkit-tools /opt/odoo/source/OCA/webkit-tools"
su - odoo -c "mkdir -p /opt/odoo/addons"
su - odoo -c "ln -s /opt/odoo/source/OCA/webkit-tools/base_headers_webkit /opt/odoo/addons/base_headers_webkit"
su - odoo -c "ln -s /opt/odoo/source/OCA/webkit-tools/report_webkit_chapter_server /opt/odoo/addons/report_webkit_chapter_server"
su - odoo -c "git clone -b 10.0 https://github.com/OCA/reporting-engine /opt/odoo/source/OCA/reporting-engine"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/reporting-engine/base_report_assembler /opt/odoo/addons/base_report_assembler"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/reporting-engine/bi_view_editor /opt/odoo/addons/bi_view_editor"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/reporting-engine/report_custom_filename /opt/odoo/addons/report_custom_filename"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/reporting-engine/report_qweb_element_page_visibility /opt/odoo/addons/report_qweb_element_page_visibility"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/reporting-engine/report_qweb_signer /opt/odoo/addons/report_qweb_signer"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/reporting-engine/report_xls /opt/odoo/addons/report_xls"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/reporting-engine/report_xlsx /opt/odoo/addons/report_xlsx"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/reporting-engine/report_xml /opt/odoo/addons/report_xml"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/reporting-engine/report_xml_sample /opt/odoo/addons/report_xml_sample"
su - odoo -c "ln -sfn /opt/odoo/source/OCA/reporting-engine/report_py3o /opt/odoo/addons/report_py3o"
# su - odoo -c "sed -i "s/admin/odoo/g" /opt/odoo/server/openerp/tools/config.py"
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
su - odoo -c "mkdir -p /opt/odoo/addons"
pip install -r /opt/odoo/server/requirements.txt

su - odoo -c "/opt/odoo/server/odoo-bin --stop-after-init -s -c /opt/odoo/odoo.conf --db_host=localhost --db_user=odoo --db_password=False --addons-path=/opt/odoo/server/odoo/addons,/opt/odoo/server/addons,/opt/odoo/addons --logfile=/var/log/odoo/odoo-server.log"
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

