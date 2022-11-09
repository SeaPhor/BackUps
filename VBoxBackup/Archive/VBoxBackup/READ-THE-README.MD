DO NOT USE THIS SCRIPT!!!!!!!!!!!!!!!!!!!!!
I AM REVISING IT- YOU DO NOT NEED ROOT
I AM REVISING IT- YOU DO NOT NEED ROOT
I AM REVISING IT- YOU DO NOT NEED MOST OF WHAT IS HERE
    Please email me for any questions- seaphor@woodbeeco.com
    2020 July 17


YOU MUST FOLLOW THESE INSTRUCTIONS!!!!
- This screipt 'REQUIRES' your 'USER' to use your "USER'S" RSA-KEYS to connect to the VM as 'ROOT'-
- 1. Generate your "USER'S" RSA-KEYS with ~/> ssh-keygen
- 2. Copy the KEY to the VM 'ROOT' account with ~/> ssh-copy-id root@hostname-of-vm and enter root password
- - 2-a. 'OR' manually copy/paste your "USER'S" ~/.ssh/id_rsa.pub into the root@hostname's ~/.ssh/authorized_keys file
- 3. Test this by ~/> ssh root@hostname-of-vm and receive 'NO PASSWORD PROMPT' and connect as 'ROOT'

1- FIRST-TIME- run script from the 'Latest_Stable/*' location, to ensure you are ready-
2- Edit / delete as it tells you
3- Once tested you can run the 'Latest_Stable/*' version
4- Do a 'git pull' to always maintain any enhancements and bug-fixes 
-
	What this sript does-
  Set Variables and Logging 
  Check command and parameter syntax
  Check for RSA Keys & ask to create if missing
  copy RSA pub to target and set check-file
  Set Backup Location and Check for non-default backup location
  First run check
  Set tmp log
  Check Log Size/Rotate
  Check Backups Number/Remove Oldest, keeping 6 for this script
  Start Logging
  Shutdown VM
  Start Export && Restart VM
  Compile and complete LogFile
  Clean up /tmp and exit

