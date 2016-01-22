FROM httpd:2.4

ADD httpd.conf /usr/local/apache2/conf/httpd.conf
ADD httpd-vhosts.conf /usr/local/apache2/conf/httpd-vhosts.conf

RUN apt-get update && apt-get install -y curl git; \
    curl -sL https://deb.nodesource.com/setup_4.x | bash; \
    cd /usr/local/apache2/htdocs && git clone https://github.com/esaude/poc-ui-prototype.git && cd poc-ui-prototype; \
    apt-get install -y nodejs bzip2; \
    npm install -g bower grunt grunt-cli; \
    npm install && bower install --allow-root; \
    grunt build; \
    mkdir -p /usr/local/apache2/htdocs/poc-ui-prototype/dist/common/application/resources; \
    cp /usr/local/apache2/htdocs/poc-ui-prototype/app/common/application/resources/* /usr/local/apache2/htdocs/poc-ui-prototype/dist/common/application/resources/
