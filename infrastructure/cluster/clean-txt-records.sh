#!/bin/bash
export DIGITALOCEAN_ACCESS_TOKEN=$(cat secrets.auto.tfvars|grep do_token|awk '{print $3}'|tr -d '"')

acme_txt_records=$(doctl compute domain records list k8s.o12stack.org|grep TXT|grep "_acme-challenge"|awk '{print $1}')
for record in $acme_txt_records
do
        echo "Deleting TXT k8s.o12stack.org ${record} ..."
        doctl compute domain records delete k8s.o12stack.org ${record} -f
done
