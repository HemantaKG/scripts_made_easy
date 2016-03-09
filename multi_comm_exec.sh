#executing multiple commands on single line...
#operator like ';' and '&&' used to execute mutiple commands over a single line 
#';' is executes all command with out stopping on any error... means if next command excutes iff the previous one compleated without errror...
#'&&' this operator stops executing at the command if any error rises... it stops moving forword...
#the othe method is encloseing all commands in between '<< EOF ... EOF'... as following...

#!/bin/bash
for(( i=0; i<10; i++));
do
        ssh root@node00$i << EOF 
pwd
hostname
hostname -i
EOF
done
echo "Finish..."
