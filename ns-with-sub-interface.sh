#!/bin/bash -eu

# Descriptions
# 1. create namespace for each sub interfaces
# 2. link up loopback interface of namespace
# 3. create sub interfaces for each physical port
# 4. attached sub interfaces to each own network namespace
# 5. link up sub interfaces
# 6. get ip address using dhcp clinet

NETNS='ns'
PHSYCAL_INTERFACES='eth0 eth1'
VLAN='4000 4001 4002 4003 4004 4005'

for i in ${NETNS};do
  for j in ${PHSYCAL_INTERFACES};do
    ip netns add ${i}-${j}
    ip netns exec ${i}-${j} ifconfig lo up
    for k in ${VLAN};do
      ip link add link ${j} name ${j}.${k} type vlan id ${k}
      ip link set ${j}.${k} netns ${i}-${j}
      ip netns exec ${i}-${j} ifconfig ${j}.${k} up
      ip netns exec ${i}-${j} dhclient ${j}.${k} &
    done
  done
done
