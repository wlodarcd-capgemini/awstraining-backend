#!/usr/bin/env bash

# allowed profiles with its respective environment
# update when adding new aws account
declare -A PROFILE2ENV
declare -A REGION2HUB
if [ $? -ne 0 ]
then
    echo "ERROR: Associative arrays are not supported in bash versions older than 4.0. Please upgrade your bash." >&2
    exit 1
fi

set -e

PROFILE2ENV[backend-test]="test"
REGION2HUB[eu-central-1]="emea"
REGION2HUB[us-east-1]="us"

check_properties(){
# 1 - Path , 2-region, 3-profile
path=$1
region=$2
profile=$3

if [[ ${path} == "common"* ]]
then
    echo "INFO: Executing common main.tf from [ $path ] on $region / $environment"
    return
fi

if [[ ${path} != *"${region}"* ]];then
   echo "ERROR: Execution path: '$target_path' doesn't contain region defined as parameter: ['$region']" >&2
   exit 1
fi
set +e
echo $path | grep -q "${profile}/"
if [[ $? -ne 0 ]];then
   echo "ERROR: Execution path: '$target_path' doesn't match 'profile' parameter. [profile:'$profile']" >&2
   exit 1
fi
set -e
}



# checks tfstate file in target profile to avoid running a common module with not matching profile
check_tfstate_with_profile(){
    if [ -e  $target_path/.terraform/terraform.tfstate ]
    then
        set +e
        grep -q "profile.*$profile" $target_path/.terraform/terraform.tfstate
        profile_check=$?
        grep -q "region.*$region" $target_path/.terraform/terraform.tfstate
        region_check=$?
        grep -q "bucket.*${profile}-${region}" $target_path/.terraform/terraform.tfstate
        bucket_check=$?
        if [[ $profile_check -ne 0 ]] || [[ $region_check -ne 0 ]] || [[ $bucket_check -ne 0 ]]
        then
            pth=$(echo $path | sed "s/\/$//g")
            echo "ERROR: terraform.tfstate file does not contain requested profile/region $profile/$region." >&2
            current_time=$(date +%s)
            mv "$pth/.terraform/terraform.tfstate" "$pth/.terraform/terraform.tfstate_$current_time"
            echo "Old state was moved to $pth/.terraform/terraform.tfstate_$current_time as backup"
            echo "Please rerun the script"
            exit 1
        fi
        set -e
    fi
}

check_path_override() {
    if [[ $path == "common/"* ]]
    then
        set +e
        modpath=$(echo $path |  sed -r "s|common/[a-z]+/||")
        find environments -type d | grep -qe "^environments/$profile/.*/$region/$modpath$"
        if [ $? -eq 0 ]
        then
            RED='\033[0;31m'
            NC='\033[0m' # No Color
            mypath=$(find environments -type d | grep "^environments/$profile/.*/$region/$modpath$")
            printf "${RED}========================================================================\n" >&2
            echo "WARN: similar directory [ $mypath ] "
            echo "      found in environments directory for [ $profile/$region ]" >&2
            echo "      Continue only if You are sure that it is not a specific version of common module." >&2
            printf "========================================================================${NC}\n" >&2
        fi
        set -e
    fi

}


# ensure we're executing in the correct directory
SCRIPT_DIR=$(cd "$(dirname "$0")"; pwd)
cd "${SCRIPT_DIR}"

if [ "$#" -lt 4 ]
then
  echo "Usage: $0 PROFILE REGION DIRECTORY COMMAND [options]" >&2
  exit 1
fi

if [ ! -d "$3" ]
then
  echo "ERROR: Directory $3 does not exist" >&2
  exit 1
fi

profile=$1
region=$2
# remove trailing / from path if it exists, so that we are uniform when creating common tags
target_path=${3%/}
command=$4
options=${@:5}

# Load properties file
source 'wrapper.properties'

export AWS_PROFILE=$profile

environment=${PROFILE2ENV[$profile]}
hub=${REGION2HUB[$region]}
if [ "a" == "a$environment" ]
then
    echo "ERROR: Can not derive environment from profile [ $profile ]. Please check your parameters."
    exit 1
fi

if [ "a" == "a$hub" ]
then
    echo "ERROR: Can not derive hub from region [ $region ] . Please check your parameters."
    exit 1
fi

check_properties "$target_path" "$region" "$profile"
check_tfstate_with_profile
check_path_override

# Check if UNIQUE_BUCKET_STRING is not empty
if [ -n "$UNIQUE_BUCKET_STRING" ]; then
    suffix="-${UNIQUE_BUCKET_STRING}"
else
    suffix="<<CUSTOM_UNIQUE_BUCKET_STRING>>"
fi

# export common Terraform variables
export TF_VAR_remote_state_bucket="tf-state-${profile}-${region}${suffix}"
export TF_VAR_region=${region}
export TF_VAR_profile=${profile}
export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"
common_tags="{\"app:hub\"=\"$hub\", \"app:env\"=\"$environment\", \"app:name\"=\"backend\", terraform-path=\"$target_path\", terraform=\"true\"}"
export TF_VAR_common_tags=${common_tags}
#export TF_LOG=TRACE

cd "${target_path}"

# remove trailing slash
#state_path=($(echo $target_path | sed 's/\/*$//g'))
tf_file_name="$(basename ${target_path})"
state_path="${tf_file_name}.tfstate"

terraform get
terraform init -backend-config "bucket=${TF_VAR_remote_state_bucket}" -backend-config "key=${state_path}" -backend-config "region=${region}" -backend-config "profile=${profile}" -var environment=${environment} -var profile=${profile} -var remote_state_bucket=${TF_VAR_remote_state_bucket} -var region=${region} -var shared_credentials_file="${shared_credentials_file}" -lock=true
if [ "$command" != "init" ]
then
  echo "Running terraform command: $command"
  terraform ${command} -var remote_state_bucket=${TF_VAR_remote_state_bucket} -var region=${region} -var environment=${environment} -var profile=${profile} -var shared_credentials_file=${shared_credentials_file} ${options}
fi
