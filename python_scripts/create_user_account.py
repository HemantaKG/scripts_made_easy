##
##

#!/usr/bin/python
import sys, getopt, subprocess

def main(comm_argv):
	group_name= ''
	user_name= ''
	full_name= ''
	e_mail= ''
	gecos_info= ''
	home_dir= ''
	scratch_dir= ''
	user_group= ''
	group_details= ''
	gid= ''

	# check for Number of arguments must be greater than 1
	if len(sys.argv) >1 and (sys.argv[1]== '--username') and (sys.argv[3]== '--full-name') and (sys.argv[5]== '--e-mail') and (sys.argv[7]== '--user-group'):
		try:
			option_list, argumrnt_list= getopt.getopt(comm_argv, '',["username=", "full-name=", "e-mail=", "user-group="]) # store command line inputs into (option, argument) list
		except getopt.GetoptError: 
			print 'create_user_accounts.py --username hemant --full-name GHKumar --e-mail h.k1704@gmail.com --user-group IISc' # print the input format
			sys.exit(2)
		# featch argument values from list
		for option, arg in option_list:
			if option== '--username':
				user_name= arg
			elif option== '--full-name':
				full_name= arg
			elif option== '--e-mail':
				e_mail= arg
			elif option== '--user-group':
				group_name= arg
	else: 
		print 'create_user_accounts.py --username hemant --full-name GHKumar --e-mail h.k1704@gmail.com --user-group IISc' # print the input format
		sys.exit(2)	

	#print 'username: ', user_name
	#print 'fullname ', full_name
	#print 'email ', e_mail
	#print 'groupname', group_name
	gecos_info= full_name+ ","+ e_mail
	#print 'gecos_info: ', gecos_info
	home_dir= "/home/"+ user_name
	scratch_dir= "/scratch/"+ user_name
	#print 'home_dir & scratch_dir: ', home_dir+' '+scratch_dir
	user_group= user_name+ ":"+ group_name
	#print 'user_group: ', user_group
	
	#add group
	subprocess.call(["groupadd", group_name])
	
	#find group id
	group_details= subprocess.check_output(["getent", "group", group_name])
	gid= group_details.split(':')[2]
	#print "gid: ",gid
	
	#add user with specific home directory, GECOS details and specific group
	subprocess.call(["useradd", "-d", home_dir, "-c", gecos_info, "-g", gid, user_name])
	
	subprocess.call(["usermod", "-G", group_name, user_name])
	
	#add directory
	subprocess.call(["mkdir", "-p", home_dir, scratch_dir])
	
	#subprocess.call(["usermod", "-m", home_dir, user_name])
	
	#modify privileges of usre and other users
	subprocess.call(["chown", user_group, home_dir, scratch_dir])
	subprocess.call(["chmod", "755", home_dir, scratch_dir])


if __name__ == "__main__":
	main(sys.argv[1:])
