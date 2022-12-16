# Exit if there is any error
set -e

showErrorFn() {
  RED_COLOR='\033[0;31m'
  NO_COLOR='\033[0m'
  echo ${RED_COLOR}$1${NO_COLOR}
}

showSuccessFn() {
  GREEN_COLOR='\033[0;32m'
  NO_COLOR='\033[0m'
  echo ${GREEN_COLOR}$1${NO_COLOR}
}

authenticateToSalesforce() {  
  if [[ -z "$sf_alias" ]]
  then
    echo "Salesforce alias is not passed. Selecting default org."
    configSetInfo=$(sfdx config:get defaultusername --json)
    defaultOrgAlias=$(echo $configSetInfo \
      | grep -o '"value": "[^"]*' | grep -o '[^"]*$' )  
    echo $defaultOrgAlias
    #get username
    echo "Fetching the username"
    echo "Print: "$defaultOrgAlias
    # Adding double quotes to do the exact matching
    searchString=$(echo \"$defaultOrgAlias\")
    sf_alias=$defaultOrgAlias
  else
    searchString=$(echo \"$sf_alias\")
  fi      
  username=$(grep $searchString ~/.sfdx/alias.json | grep -o '"[^"]\+"' | sed 's/"//g' |  tail -n1)
  access_token=$(grep -o '"accessToken": "[^"]*' ~/.sfdx/$username.json | grep -o '[^"]*$')
  instance_url=$(grep -o '"instanceUrl": "[^"]*' ~/.sfdx/$username.json | grep -o '[^"]*$') 
  sfdx force:apex:execute -f apexcode.cls -u $sf_alias > output.log  
  access_token=00D$(grep 'DEBUG|<ACCESS_TOKEN>' output.log | cut -d' ' -f3)
  rm output.log
  #get access and domain from the file   
  echo "\nWould you like to continue for the instance \033[1m${instance_url}\033[0m with user \033[1m${username}\033[0m (y/n)?"
  read proceed
  if [[ "$proceed" != "y" ]] ; 
  then
    echo "Exiting program...";
    exit 1
  fi
}



doSFLogin() {
  echo "Enter the domain:"
  read sf_domain
  echo "Enter the username:"
  read sf_username
  echo "Enter the password concatenated with security key if any:"
  read sf_password
  echo "Enter Client Id if any, else hit enter and default will be selected:"
  read sf_client_id
  echo "Enter Secrete Id if any, else hit enter and default will be selected:"
  read sf_secrete_id

  echo 'GETTING THE ACCESS TOKEN'
  oauth_response=$(curl -X POST $sf_domain'/services/oauth2/token' \
     -d grant_type=password \
     -d 'client_id='$sf_client_id \
     -d 'client_secret='$sf_secrete_id \
     -d 'username='$sf_username \
     -d 'password='$sf_password )
  echo $oauth_response
}

getBulkAPIJobResult() {
  echo "sf_alias is : "$sf_alias
  echo "Inside Fetch Bulk API Files"
  resultType=$1
  if [[ -z "$job_id" ]]
  then
    RED='\033[0;31m'
    NC='\033[0m' # No Color    
    #printf "${RED}Error...Please pass the job id. -j <job_id>${NC}\n"
    showErrorFn 'Error...Please pass the job id. -j <job_id>'
    exit 1
  fi
  authenticateToSalesforce
  mkdir -p bulk_api_error
  curl -X GET \
     $instance_url'/services/data/v49.0/jobs/ingest/'$job_id'/'$resultType'/' \
     -H "authorization: Bearer "$access_token -o './bulk_api_error/'$job_id'_bulkresultexport.csv'  
  showSuccessFn 'File is generated, please check the file.'
  if ! [[ -z "$search_input" ]]
  then
    echo "Searching ${search_input}. Result..."      
    if  grep $search_input ./bulk_api_error/${job_id}_bulkresultexport.csv
    then       
      showSuccessFn "Search Result Begin................................................................................................"
      grep $search_input ./bulk_api_error/${job_id}_bulkresultexport.csv
      showSuccessFn "Search Result End.................................................................................................."
    else
      showErrorFn "${search_input} not found"
    fi
  fi
}

bulkAPIGetJobError() { 
  authenticateToSalesforce 
  getBulkAPIJobResult 'failedResults'
}

bulkAPIGetJobSuccess() {
  authenticateToSalesforce
  getBulkAPIJobResult 'successfulResults'
}

abort_bulk_job() {
  authenticateToSalesforce
  while read p; do 
    echo "\nAborting..${p}"
    curl -X PATCH -H "authorization: Bearer "$access_token -H 'Content-Type:application/json' \
    -d @abortjob.json $instance_url/services/data/v56.0/jobs/ingest/${p}
  done < ./$filename  
  showSuccessFn "\nAborted All Jobs"  
}

helpFunction()
{
   echo ""
   echo "Usage: sh kmutil.sh -o operation -u sf-username"
   echo -e "\t-o Operation which needs to be performed e.g. bulk-api-*, sf-login"
   echo -e "\t-u Org to be used, specify alias"
   echo -e "\t-j Job Id (applicable for bulk-api-* operation)"
   echo -e "\t-s Search String (applicable for bulk-api operation)" 
   echo -e "\t-f file (applicable for bulk-api-abort operation)" 
   exit 1 # Exit script after printing help
}


# Parse Arguments
while [[ $# -gt 0 ]]
do
  case "$1" in
    -h|--help)
        helpFunction 
        exit 1 # Exit script after printing help
        ;;
    -o)
        operation=$2
        shift
        shift
        ;;
    -u)
        sf_alias=$2
        shift
        shift
        ;;
    -j)
        job_id=$2
        shift
        shift
        ;;
    -s)
        search_input=$2
        shift
        shift
        ;;
    -f)
        filename=$2
        shift
        shift
        ;;
    -*|--*|*)
        echo "Unknown option $1"
        echo "Please use sh kmutil.sh --help"
        exit 1
        ;;
  esac
done

case "$operation" in  
  sf-login)    
    doSFLogin    
    ;;
  bulk-api-get-job-error)      
    bulkAPIGetJobError      
    ;;
  bulk-api-get-job-success)
    bulkAPIGetJobSuccess
    ;;
  bulk-api-abort)    
    abort_bulk_job
    ;;
  -*|--*|*)
    echo "Unknown operation"
    exit 1
    ;;
esac


  