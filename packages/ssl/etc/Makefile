client: client-sign.pem

client-sign.pem: client-req.pem

client-req.pem: client/config-req.txt
	openssl req -new -config client/config-req.txt -out $@

client-sign.pem: client-req.pem client/config-sign.txt
	openssl ca -config client/config-sign.txt -out $@ -infiles client-req.pem

clean:
	rm -f client-sign.pem client-req.pem
