#add user folder to /scratch...
#!/bin/bash
# array of all users i.e list of users
username=( user1 user2 user3 user4 ) 
for ((i=1; i<=32; i++));
do
        if [ $i -lt 10 ]; then
                for j in "${username[@]}"
                do
#                       echo 'root@node00'$i
#                       echo 'mkdir /scratch/'$j
#                       ssh root@node00$i 'mkdir /scratch/'$j
#                       echo 'root@node00'$i 'chown -R '$j:$j $j
#change user group to lsc group
                        ssh root@node00$i 'chown -R '$j:lsc '/scratch/'$j
#change access mod of user to 750 (i.e user rwx group rx other nothig)
#                       ssh root@node00$i 'chmod 750 -R /scratch/'$j
                done
        else
                for j in "${username[@]}" 
                do
#                       echo 'root@node0'$i
#                       echo 'mkdir /scratch/'$j
#                       ssh root@node0$i 'mkdir /scratch/'$j
                        ssh root@node0$i 'chown -R '$j:lsc '/scratch/'$j
#                       ssh root@node0$i 'chmod 750 -R /scratch/'$j
                done
fi
done
echo "finish..."
