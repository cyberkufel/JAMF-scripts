#!/bin/bash
#!/usr/bin/expect


cuser=$4
cpw=$5

bootstrapstatus="$(sudo profiles status -type bootstraptoken)"
echo "...Token Status..."
echo "$bootstrapstatus"

#bscheck=$(echo $bootstrapstatus | grep escrowed | cut -d ":" -f 3)
bscheck=$(echo $bootstrapstatus | grep escrowed | awk '{ print $NF }')
 
if [[ $bscheck = "YES" ]];then
	echo "Already escrowed to server...nothing to do"
    jamf recon
    exit 0
else
	echo "Not escrowed...executing: profiles install -type bootstraptoken"
    
    # Get required variables. Note that in EXPECT scripts, the variable arguments are one value lower (thus $argv 3 is actually $4).
	set adminName "[lindex $argv 3]"
	set adminPass "[lindex $argv 4]"

	#This will create and escrow the bootstraptoken on the Jamf Pro Server
    #profiles install -type bootstraptoken
	spawn /usr/bin/profiles install -type bootstraptoken

	expect "Enter the admin user name:"
	send "$adminName\r"
	expect "Enter the password for user '$adminName':"
	send "$adminPass\r"
	expect eof
  
    profiles install -type bootstraptoken -user "$cuser" -password "$cpw"
    
    echo "...Token Status 2..."
    bootstrapstatus="$(sudo profiles status -type bootstraptoken)"
	echo "$bootstrapstatus"
    jamf recon
fi

#Return the final return code 
exit $?

exit 0
