# python code to add user with following specification:
# 1. user home at /home/username
# 2. user scratch at /scratch/username
# 3. add user to given groupname
# 4. change like READ,EXE for own group, ALL for user and NONE for others to /scratch/username 
# 5. change like READ,EXX for own group and others and ALL for own to /home/username
# 
# RUN EXAMPLE: AddAliceUser --username <...> --groupname <...>

#!/usr/bin/python
import sys, getopt, subprocess, crypt

def main(comm_argv):
  user_name= ''
	group_name= ''
	
	home_dir= ''
	scratch_dir= ''
	password= ''
	
	user_group= ''
	group_details= ''
	gid= ''

	# check for Number of arguments must be greater than 1
	if len(sys.argv) >1 and (sys.argv[1]== '--username') and (sys.argv[3]== '--usergroup'):
		try:
			option_list, argumrnt_list= getopt.getopt(comm_argv, '',["username=", "usergroup="]) # store command line inputs into (option, argument) list
		except getopt.GetoptError: 
			print 'create_user_accounts.py --username hemant --usergroup ICTS' # print the input format
			sys.exit(2)
		# featch argument values from list
		for option, arg in option_list:
			if option== '--username':
				user_name= arg
			elif option== '--usergroup':
				group_name= arg
	else: 
		print 'create_user_accounts.py --username hemant --usergroup ICTS # print the input format
		sys.exit(2)	

	#print 'username: ', user_name
	#print 'groupname', group_name

	home_dir= "/home/"+ user_name
	scratch_dir= "/scratch/"+ user_name
	#print 'home_dir & scratch_dir: ', home_dir+' '+scratch_dir

	user_group= user_name+ ":"+ group_name
	#print 'user_group: ', user_group
	
	#add group
	#subprocess.call(["groupadd", group_name])
	
	#find group id
	group_details= subprocess.check_output(["getent", "group", group_name])
	gid= group_details.split(':')[2]
	#print "gid: ",gid
	
	#add a home and scratch directory for user
	subprocess.call(["mkdir", "-p", home_dir, scratch_dir])
	
	#generating crpt passwd for user
	#password= subprocess.check_output(["openssl", "passwd", "-crypt", "mypassw0rd"])
	
	#add user with specific home directory and specific group with passws 'aaaa'
	subprocess.call(["useradd", "-d", home_dir, "-g", gid, "-p", crypt.crypt('aaaa','11'), user_name])
	
	#add user to a existing group
	subprocess.call(["usermod", "-G", group_name, user_name])
	
	#subprocess.call(["usermod", "-m", home_dir, user_name])
	
	#modify owrship and privileges of above created directory to user level, user group
	subprocess.call(["chown", user_group, home_dir, scratch_dir])
	subprocess.call(["chmod", "755", home_dir,])
	subprocess.call(["chmod", "750", scratch_dir])

if __name__ == "__main__":
	main(sys.argv[1:])
