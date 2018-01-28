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

### Get Enhance source
COPY configs/edu/arizona/biosemantics/semanticmarkup/enhance /opt/git/charaparser/enhance/src/main/resources/edu/arizona/biosemantics/semanticmarkup/enhance

### Setup MySQL
COPY setupDB.sh /opt/setupDB.sh
RUN chmod +x /opt/setupDB.sh
RUN /opt/setupDB.sh

### Setup remaining charparser requirements
COPY fallback_glossaries /opt/resources/glossaries
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
RUN mvn -f /opt/git/charaparser/pom.xml package -P fnaLearn
RUN mvn -f /opt/git/charaparser/pom.xml package -P fnaMarkup
RUN cp /opt/git/charaparser/target/semantic-markup-fnaLearn-${charaparserVersion}-jar-with-dependencies.jar /opt/learn.jar
RUN cp /opt/git/charaparser/target/semantic-markup-fnaMarkup-${charaparserVersion}-jar-with-dependencies.jar /opt/markup.jar
RUN echo "java -jar /opt/learn.jar \$*" >> /root/learn
RUN echo "java -jar /opt/markup.jar \$*" >> /root/markup
RUN chmod +x /root/learn
RUN chmod +x /root/markup

### Setup remaining enhance requirements
COPY ontology /opt/resources/ontology

#Build enhance step
RUN mvn -f /opt/git/charaparser/enhance/pom.xml package -P fnaRun
RUN cp /opt/git/charaparser/enhance/target/enhance-fnaRun-0.0.23-SNAPSHOT-jar-with-dependencies.jar /opt/enhance.jar
RUN echo "java -jar /opt/enhance.jar \$* -i /root/workspace/\$2 -o /root/workspace/\$2_enhanced -s /opt/resources/ontology/synonym.csv -p /opt/resources/ontology/partof.csv" >> /root/enhance
RUN chmod +x /root/enhance

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