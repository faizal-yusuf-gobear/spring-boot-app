#!/bin/bash -e

# In future this script should download the DockerEE client bundle from commandline, unzip it and run eval
VERSION=$1

echo ${WORKSPACE}
cp webapp-kubernetes-${VERSION}.yaml /home/vagrant/deploy

cd /home/vagrant/client-bundle
eval "$(<env.sh)"

#helm init

#docker login dtr.local -u ${USERNAME} -p ${PASSWORD}
#cat /home/vagrant/deploy/webapp-kubernetes.yaml
kubectl apply -f /home/vagrant/deploy/webapp-kubernetes-${VERSION}.yaml