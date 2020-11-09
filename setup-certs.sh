# Fetch certs and key from config variable
client_cert=`heroku config:get KAFKA_CLIENT_CERT --app <HEROKU_APPLICATION_NAME>`
client_key=`heroku config:get KAFKA_CLIENT_CERT_KEY --app <HEROKU_APPLICATION_NAME>`
trusted_cert=`heroku config:get KAFKA_TRUSTED_CERT --app <HEROKU_APPLICATION_NAME>`

# Write config vars to files.
echo "$client_cert" >> cert.pem
echo "$client_key" >> key.pem
echo "$trusted_cert" > trusted_cert.pem

# Set passwords
KEYSTORE_PASSWORD='changeit'
TRUSTSTORE_PASSWORD='changeit'

# Generate PKCS12 from cert.pem and key.pem
openssl pkcs12 -export -out cert.pkcs12 -in cert.pem -inkey key.pem -password pass:$KEYSTORE_PASSWORD

# Download jetty
wget https://dejim.s3.us-east-1.amazonaws.com/jetty-6.1.7.jar

# Convert PKCS12 to JKS (Will ask you for keystore password)
java -cp jetty-6.1.7.jar org.mortbay.jetty.security.PKCS12Import cert.pkcs12 keystore.jks

# Export trusted certificate as .der format
openssl x509 -in trusted_cert.pem -out cert.der -outform der

# Import trusted certificate to truststore
keytool -importcert -alias mule -file cert.der -keystore truststore.jks -storepass $TRUSTSTORE_PASSWORD
