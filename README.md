### Summary
Shell script utility to perform common operations as a salesforce developer

---
### sh kmutil.sh -o bulk-api-get-job-error
Fetches the bulk job failed records file and if -s paramter is passed then searches the passed element in the file
#### Command Syntax
-j JOB_ID

[-s SEARCH_INPUT]

[-u user-sf-alias]
##### Paramters
-j
- Required
- Job Id
- Type : String

-s
- Optional
- Search Input String
- Type : String

-u
- Optional
- sfdx org alias, if not passed default org will be used
- Type : String
---
### sh kmutil.sh -o bulk-api-get-job-success
Fetches the bulk job success records file and if -s paramter is passed then searches the passed element in the file
#### Command Syntax
-j JOB_ID

[-u user-sf-alias]

[-s SEARCH_INPUT]
##### Paramters
-j
- Required
- Job Id
- Type : String

-u
- Optional
- sfdx org alias, if not passed default org will be used
- Type : String

-s
- Optional
- Search Input String
- Type : String
---
### sh kmutil.sh -o bulk-api-abort
Aborts the job ids which are passed
#### Command Syntax
-f file

[-u user-sf-alias]
##### Paramters
-f
- Required
- File which contains ids of the bulk api jobs separated by new lines
- Type : File

-u
- Optional
- sfdx org alias, if not passed default org will be used
- Type : String

-s
- Optional
- Search Input String
- Type : String
---
### sh kmutil.sh -o sf-login
This is a self guided command, which will ask for multiple paramters

 
