#This scrip adds the existing user to existing group 
#existing group 'lsc' here...
#check /etc/group file for update...

#!/bin/bash
username=( u1 u2 u3 u4 ) 
for i in ${username[@]}
do
        usermod -a -G lsc $i
done
echo "finish..."
