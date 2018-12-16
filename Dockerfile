# Starter environment for Artificial Intelligence and Big Data using docker. 
# Includes: Kafka for Pub/Sub, Spark for computation, Cassandra for storing, ElasticSearch for indexing, Kibana for visualization, Anaconda for data-science with python, Jupyter Notebook for coding, Selenium for scraping.

FROM centos:centos6

RUN yum -y update;
RUN yum -y clean all;

# Install basic tools
RUN yum install -y  wget dialog curl sudo lsof vim axel telnet nano openssh-server openssh-clients bzip2 passwd tar bc git unzip

RUN yum install -y epel-release
RUN yum install -y jq

#Install Java
RUN yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel 

#Create guest user. IMPORTANT: Change here UID 1000 to your host UID if you plan to share folders.
RUN useradd guest -u 1000
RUN echo guest | passwd guest --stdin

ENV HOME /home/guest
WORKDIR $HOME

USER guest

#Install Spark (Spark 2.1.1 - 02/05/2017, prebuilt for Hadoop 2.7 or higher)
RUN wget https://d3kbcqa49mib13.cloudfront.net/spark-2.1.1-bin-hadoop2.7.tgz
RUN tar xvzf spark-2.1.1-bin-hadoop2.7.tgz
RUN mv spark-2.1.1-bin-hadoop2.7 spark

ENV SPARK_HOME $HOME/spark

#Install Kafka
RUN wget https://www-eu.apache.org/dist/kafka/2.1.0/kafka_2.11-2.1.0.tgz
RUN tar xvzf kafka_2.11-2.1.0.tgz
RUN mv kafka_2.11-2.1.0 kafka

ENV PATH $HOME/spark/bin:$HOME/spark/sbin:$HOME/kafka/bin:$PATH

#Install Anaconda Python distribution
RUN wget https://repo.continuum.io/archive/Anaconda2-5.3.1-Linux-x86_64.sh
RUN bash Anaconda2-5.3.1-Linux-x86_64.sh -b
ENV PATH $HOME/anaconda2/bin:$PATH
RUN conda install python=2.7.10 -y

#Install Jupyer notebook + Toree Scala kernel
RUN conda install jupyter -y

#Install kaggle cli
RUN pip install kaggle

#Install Kafka Python module
RUN pip install kafka-python


USER root


#Install firefox
RUN yum install -y firefox-60.3.0-1.el6.centos

#Install geckodriver to run with Selenium
RUN wget https://github.com/mozilla/geckodriver/releases/download/v0.23.0/geckodriver-v0.23.0-linux64.tar.gz
RUN tar -xvzf geckodriver*
RUN chmod +x geckodriver
RUN mv geckodriver /usr/local/bin/

#Install Cassandra
ADD datastax.repo /etc/yum.repos.d/datastax.repo
RUN yum install -y datastax-ddc
RUN echo "/usr/lib/python2.7/site-packages" |tee /home/guest/anaconda2/lib/python2.7/site-packages/cqlshlib.pth

#Install ElasticSearch
ADD elasticsearch.repo /etc/yum.repos.d/elasticsearch.repo
RUN yum install -y elasticsearch
ADD elasticsearch.yml /etc/elasticsearch/elasticsearch.yml

#Install kibana
ADD kibana.repo /etc/yum.repos.d/kibana.repo
RUN yum install -y kibana
ADD kibana.yml /etc/kibana/kibana.yml

#Environment variables for Spark and Java
ADD setenv.sh /home/guest/setenv.sh
RUN chown guest:guest setenv.sh
RUN echo . ./setenv.sh >> .bashrc

#Startup (start SSH, Cassandra, Zookeeper, Kafka producer)
ADD startup_script.sh /usr/bin/startup_script.sh
RUN chmod +x /usr/bin/startup_script.sh

#Init Cassandra 
ADD init_cassandra.cql /home/guest/init_cassandra.cql
RUN chown guest:guest init_cassandra.cql

#Add notebooks
ADD notebooks /home/guest/notebooks
RUN chown -R guest:guest notebooks

#Not mandatory to expose ports here 
#Keeping it as a comment for log purposes
#EXPOSE 22 2181 4040 5601 7199 8888 9092 9200 9300
# 22 = ssh
# 2181 = zookeeper
# 4040 = spark UI
# 5601 = kibana
# 7199 = cassandra
# 8888 - jupyter notebook
# 9092 = kafka broker 1
# 9200 + 9300 = elasticsearch
