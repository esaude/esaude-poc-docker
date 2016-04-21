FROM httpd:2.4

ADD httpd.conf /usr/local/apache2/conf/httpd.conf
ADD httpd-vhosts.conf /usr/local/apache2/conf/httpd-vhosts.conf

RUN apt-get update && apt-get install -y curl unzip
RUN curl -skL https://bintray.com/artifact/download/esaude/poc/esaude-emr-poc-master.zip -o /tmp/esaude-emr-poc.zip
RUN curl -skL https://deb.nodesource.com/setup_4.x | bash
RUN apt-get install -y nodejs
RUN unzip /tmp/esaude-emr-poc.zip -d /usr/local/apache2/htdocs/
RUN rm -f /tmp/esaude-emr-poc.zip
