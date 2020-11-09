# MuleSoft Kafka Connector with Heroku Kafka

This repo is intended to demonstrate the use of [Apache Kafka Connector - Mule 4](https://www.mulesoft.com/exchange/com.mulesoft.connectors/mule-kafka-connector/) to produce a 
message to the [Heroku Kafka](https://www.heroku.com/kafka).

## Prerequisite
- [OpenSSL](https://www.openssl.org/source/) - Tested on 
version 2.6.5
- [Java](https://www.java.com/en/) - Tested on openjdk version 1.8.0_212
- [Anypoint Studio](https://www.mulesoft.com/platform/studio)

## Generate Certificates

Kafka on Heroku supports SSL to encrypt and authenticate connections, Heroku provides the certificates to connect to Kafka in PEM format. The [MuleSoft Kafka Connector](https://www.mulesoft.com/exchange/com.mulesoft.connectors/mule-kafka-connector/) requires the certificates to be in JKS format. Therefore, we need to convert the PEM certificates and keys to a PKCS12 file.

### Edit the [setup-certs.sh](https://github.com/dhavalthakkar93/MuleSoft-Kafka-Connector-with-Heroku-Kafka/blob/master/setup-certs.sh) file and make following changes

- Change **<HEROKU_APPLICATION_NAME>** with the name of the Heroku application where Kafka Cluster is provisioned
- Chage the value of **KEYSTORE_PASSWORD** and **TRUSTSTORE_PASSWORD**

### Execute Script

```
$ sh setup-certs.sh
```

It will ask you for **KEYSTORE_PASSWORD**, It will generate following files:

- keystore.jks
- truststore.jks

## Configure your MuleSoft application

### Add dependency for Kafka Connector

Once you create a new MuleSoft application, you need to add the dependency for [Apache Kafka Connector](https://www.mulesoft.com/exchange/com.mulesoft.connectors/mule-kafka-connector/), add following into **pom.xml** under **<dependencies**>:

```
<dependency>
    <groupId>com.mulesoft.connectors</groupId>
    <artifactId>mule-kafka-connector</artifactId>
    <version>4.3.5</version>
    <classifier>mule-plugin</classifier>
</dependency>
```

### Configure producer to use keystore and truststore

Configure the MuleSoft application to use Kafka Connector over SSL connection, you can use [sample producer configuration](https://github.com/dhavalthakkar93/MuleSoft-Kafka-Connector-with-Heroku-Kafka/blob/master/mule-heroku-kafka-publisher-flow.xml#L12):

- Copy and paste **keystore.jks** and **truststore.jks** file to **/src/main/resources** directory
- Change **<PATH_TO_TRUSTSTORE_JKS>** (Set the path of truststore.jks) and **<TRUSTSTORE_PASS>** (Truststore password used to generate certificates)
- Change **<PATH_TO_KEYSTORE_JKS>** (Set the path of keystore.jks) and **<KEYSTORE_PASS>** (Keystore password used to generate certificates)
- Change **<KAFKA_URL>** with the value of **KAFKA_URL** config var (`heroku config:get KAFKA_URL --app <HEROKU_APPLICATION_NAME>`)
- Change **<KAFKA_TOPIC_NAME>** with the name of topic in which you want to produce the message
- Save and Run 

## Test the application

Once your application is started you can make HTTP POST request:

```
$ curl -d '{json}' -H 'Content-Type: application/json' localhost:8081/publish
```

You can tail the Kafka topic with:

```
$ heroku kafka:topics:tail <TOPIC_NAME> --app <HEROKU_APPLICATION_NAME>
```
