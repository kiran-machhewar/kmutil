### Summary
Shell script utility to perform common operations as a salesforce developer

#### Usage
sh kmutil.sh -o <operation> [-u|-j|-s]
-u : Org which needs to be used, if not passed the default org will be used
-j : Job id for which the error file needs to be fetched, applicable only if the operation is bulk-api
-s : Search input, applicable only if the operation is bulk-api

#### Example
sh kmutil.sh -o bulk-api -u kiran-dev  -j 750AA00000AAABC -s search_this_string
