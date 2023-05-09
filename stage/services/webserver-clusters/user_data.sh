#!/bin/bash
echo "Hello World" > index.html
echo "${db_address}" >> index.html
echo "${db_port}" >> index.html
nohup busybox httpd -f -p ${server_port} &