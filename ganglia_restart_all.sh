#!/bin/bash
for ((i=10; i<=32; i++));
do
        ssh root@node0$i '/etc/init.d/ganglia-monitor restart'
done
echo "finish..."
