FROM tomcat:8.0-jre8
MAINTAINER "F Agagnier <felix.agagnier@polymtl.ca>"

# remove preinstalled webapps 
RUN rm -fr /usr/local/tomcat/webapps/ROOT
RUN rm -fr /usr/local/tomcat/webapps/host-manager
RUN rm -fr /usr/local/tomcat/webapps/manager
RUN rm -fr /usr/local/tomcat/webapps/docs
RUN rm -fr /usr/local/tomcat/webapps/examples

# copy and unzip the application war file
ADD target/weka_rs-0.5.0.war /usr/local/tomcat/webapps/ROOT.war
RUN unzip -d /usr/local/tomcat/webapps/ROOT /usr/local/tomcat/webapps/ROOT.war && rm -f /usr/local/tomcat/webapps/ROOT.war

# add openam certificat to tomcat's cert-store
RUN openssl s_client -showcerts -connect openam.in-silico.ch:443 </dev/null 2>/dev/null|openssl x509 -outform PEM > /usr/local/tomcat/in-silicoch.crt
RUN keytool -keystore /etc/ssl/certs/java/cacerts -keypass changeit -storepass changeit -noprompt -importcert -alias openam.in-silico.ch -file /usr/local/tomcat/in-silicoch.crt

# Create a non-priviledged user to run Tomcat
RUN useradd -u 501 -m -g root tomcat && chown -R tomcat:root /usr/local/tomcat
# Set file permissions for that user.
RUN chown -R tomcat:root /usr/local/tomcat
# run as that user
USER 501

EXPOSE 8080

###### Remvove comments to enable JProfiler
#RUN wget https://download-keycdn.ej-technologies.com/jprofiler/jprofiler_linux_10_1_5.tar.gz -P /tmp/ &&\
# tar -xzf /tmp/jprofiler_linux_10_1_5.tar.gz -C /usr/local/tomcat &&\
# rm /tmp/jprofiler_linux_10_1_5.tar.gz
#ENV CATALINA_OPTS="$CATALINA_OPTS -agentpath:/usr/local/tomcat/jprofiler10.1.5/bin/linux-x64/libjprofilerti.so=port=8849,wait,config=/usr/local/tomcat/jprofiler10.1.5/config.xml"
#EXPOSE 8849
