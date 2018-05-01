FROM java:7
MAINTAINER Yusuke Saito <ysaito8015@gmail.com>

#system update & install packages
RUN apt-get update && apt-get upgrade -y && apt-get install -y ant build-essential apt-utils

# install tomcat8 & nodejs
#/opt
#RUN cd /opt && wget "http://ftp.jaist.ac.jp/pub/apache/tomcat/tomcat-8/v8.5.23/bin/apache-tomcat-8.5.23.tar.gz"
RUN cd /opt && wget "https://archive.apache.org/dist/tomcat/tomcat-8/v8.5.23/bin/apache-tomcat-8.5.23.tar.gz"
RUN tar axvf /opt/apache-tomcat-8.5.23.tar.gz -C /opt/ && rm /opt/apache-tomcat-8.5.23.tar.gz
RUN mv /opt/apache-tomcat-8.5.23 /opt/tomcat8
RUN cd /opt && wget "https://nodejs.org/dist/v6.11.3/node-v6.11.3-linux-x64.tar.xz"
RUN tar axvf /opt/node-v6.11.3-linux-x64.tar.xz -C /opt/ && rm /opt/node-v6.11.3-linux-x64.tar.xz
RUN ln -s /opt/node-v6.11.3-linux-x64/bin/node /usr/local/bin/node
RUN ln -s /opt/node-v6.11.3-linux-x64/bin/npm /usr/local/bin/npm

# install grant global
RUN npm install grunt bower -g

# install NLPReViz server
RUN git clone https://github.com/NLPReViz/emr-nlp-server.git /opt/emr-nlp-server
#/opt/emr-nlp-server
RUN cd /opt/emr-nlp-server/ && ant resolve && env CATALINA_HOME=/opt/tomcat8 ant deploy

# fetch data.zip
#/opt/tomcat8
RUN cd /opt/tomcat8/ && wget "https://github.com/NLPReViz/emr-nlp-server/releases/download/empirical-study/data.zip"  && unzip ./data.zip && rm ./data.zip
RUN cd /opt/tomcat8/data/libsvm && make

# install NLPReViz views
# /opt/tomcat8/webapps
RUN cd /opt/tomcat8/webapps && git clone https://github.com/NLPReViz/emr-vis-web.git /opt/tomcat8/webapps/emr-vis-web
#/opt/tomcat8/webapps/emr-vis-web
RUN cd /opt/tomcat8/webapps/emr-vis-web/ && npm install && ./node_modules/bower/bin/bower install --allow-root &&  npm start

# port open 8080
EXPOSE 8080
# start tomcat8
CMD /opt/tomcat8/bin/catalina.sh start && /bin/bash
