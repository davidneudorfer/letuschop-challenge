#!/bin/bash
set -e

echo "########## starting cloud-init ##########"
echo "I coulda been a contender."

NODENAME="${node_name}-$(hostname)"

mkdir /root/.aws/
cat > /root/.aws/config <<EOL
[default]
region = ${region}
output = json
EOL

echo "########## initializing setup-network-environment ##########"

service setup-network-environment start

# ensure setup-network-environment has started
TRIES=30
until [  -f /etc/network-environment ]; do
  let TRIES-=1
  echo "/etc/network-environment doesn't exist yet. Retries left: $TRIES"
  if [ $TRIES -le 0 ]; then
    STATUS="setup-network-environment failed to start"
    echo $STATUS
    exit 27
  fi
  sleep 2
done

echo "########## initializing consul ##########"

CONSUL_FILE_FINAL=/etc/consul.d/consul.json
CONSUL_FILE_TMP=$CONSUL_FILE_FINAL.tmp

sed -i -- "s/{{ hostname }}/$(hostname)/g" $CONSUL_FILE_TMP
sed -i -- "s/{{ region }}/${region}/g" $CONSUL_FILE_TMP
sed -i -- "s/{{ consul_bootstrap_expect }}/${consul_bootstrap_expect}/g" $CONSUL_FILE_TMP

sudo mv $CONSUL_FILE_TMP $CONSUL_FILE_FINAL

source /etc/network-environment

service consul start

echo "########## verify consul cluster membership ##########"

CONSUL_SERVERS=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=letuschop" \
  --query 'Reservations[].Instances[].NetworkInterfaces[].PrivateIpAddresses[].PrivateIpAddress' \
  --output json | jq -r '.[]' | grep -v "$DEFAULT_IPV4")

while true; do
  # working around this issue on consul startup: https://github.com/hashicorp/consul/issues/775
  HEALTH_CHECKS=$(curl -s http://localhost:8500/v1/health/node/$(hostname)) || echo -n "."

  if [ "$HEALTH_CHECKS" != "No cluster leader" ]; then
    SERF_HEALTH_STATUS=`echo $HEALTH_CHECKS | jq -e -r '.[] | select(.CheckID == "serfHealth").Status'` || echo -n "."
    if [ "$SERF_HEALTH_STATUS" == "passing" ]; then
      echo "$(hostname) has joined the cluster, continuing..."
      break
    fi
    sleep 3
  else
    consul join $CONSUL_SERVERS
  fi
done

echo "########## initializing consul-template ##########"

service consul-template start

exit 0
