# Certificates

Put any certificates you need to trust (should be \*.crt files) in this folder.

Here is the link to [Mozilla ca bundles](https://curl.se/docs/caextract.html).

`ca-bundle.crt` is a concatenation of [Mozilla cacert.pem](https://curl.se/ca/cacert.pem) and all \*.crt in current folder.

You can check the certificate with the following commands:

```shell
# Check one certificate
openssl x509 -in ./settings/certificates/company/company-ca.crt -text -noout
# Check a bunch of certificates
openssl storeutl -noout -text -certs ./settings/certificates/ca-bundle.crt
```
