FROM debian
MAINTAINER Thomas Rodenhausen <thomas.rodenhausen@gmail.com>
LABEL Description="This image is created for the purpose of easily running standalone charaparser in a preconfigured environment"

ARG charaparserVersion=0.1.196-SNAPSHOT

USER root

### Apt installations
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -yq mysql-server
RUN apt-get install -yq \
    vim \
    wget \
    git \
    openjdk-8-jdk \
    maven \
    wordnet \
    libdbi-perl \
    libdbd-mysql-perl

### Get Charaparser source
RUN git clone https://github.com/biosemantics/charaparser.git /opt/git/charaparser
COPY configs/edu/arizona/biosemantics/semanticmarkup /opt/git/charaparser/src/main/resources/edu/arizona/biosemantics/semanticmarkup

### Setup MySQL
COPY setupDB.sh /opt/setupDB.sh
RUN chmod +x /opt/setupDB.sh
RUN /opt/setupDB.sh

### Setup remaining charparser requirements
RUN wget http://cpansearch.perl.org/src/GRANTM/Encoding-FixLatin-1.04/lib/Encoding/FixLatin.pm -P /usr/lib/x86_64-linux-gnu/perl5/5.22/Encoding
RUN mkdir -p /root/workspace
RUN mkdir -p /opt/resources/perl
RUN cp -R /opt/git/charaparser/src/main/perl/edu/arizona/biosemantics/semanticmarkup/markupelement/description/ling/learn/lib/perl/* /opt/resources/perl/
RUN mkdir -p /opt/resources/wordnet/wn31/dict
RUN cp -R /opt/git/charaparser/wordnet/wn31/* /opt/resources/wordnet/wn31/
RUN mkdir -p /opt/resources/glossaries
RUN mkdir -p /opt/resources/ontologies
RUN wget --no-check-certificate -P /opt/resources/ontologies http://purl.obolibrary.org/obo/bspo.owl
RUN wget --no-check-certificate -P /opt/resources/ontologies http://purl.obolibrary.org/obo/hao.owl
RUN wget --no-check-certificate -P /opt/resources/ontologies http://purl.obolibrary.org/obo/pato.owl
RUN wget --no-check-certificate -P /opt/resources/ontologies http://purl.obolibrary.org/obo/po.owl
RUN wget --no-check-certificate -P /opt/resources/ontologies http://purl.obolibrary.org/obo/poro.owl
RUN wget --no-check-certificate -P /opt/resources/ontologies http://purl.obolibrary.org/obo/ro.owl
RUN wget --no-check-certificate -P /opt/resources/ontologies http://purl.obolibrary.org/obo/spd.owl

#Build Charaparser steps
RUN mvn -f /opt/git/charaparser/pom.xml package -P learn
RUN mvn -f /opt/git/charaparser/pom.xml package -P markup
RUN cp /opt/git/charaparser/target/semantic-markup-learn-${charaparserVersion}-jar-with-dependencies.jar /opt/learn.jar
RUN cp /opt/git/charaparser/target/semantic-markup-markup-${charaparserVersion}-jar-with-dependencies.jar /opt/markup.jar
RUN echo "java -jar /opt/learn.jar \"\$*\"" >> /root/learn
RUN echo "java -jar /opt/markup.jar \"\$*\"" >> /root/markup
RUN chmod +x /root/learn
RUN chmod +x /root/markup

#Reduce image size
RUN rm -R /opt/git
RUN rm /opt/setupDB.sh
RUN rm -R /tmp/*
RUN rm -R /root/.m2
RUN apt-get remove -yq \
    git \
#    vim \
    wget \
    maven \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

#Define the startup
COPY start.sh /opt/start.sh
RUN chmod +x /opt/start.sh
RUN echo "cd /root" >> /root/.bashrc
CMD bash -C '/opt/start.sh';'bash';