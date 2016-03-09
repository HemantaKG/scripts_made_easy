#!/bin/bash
for ((i=10; i<=32; i++));
do
        ssh root@node0$i 'mount -a'
done
echo "finish..."
