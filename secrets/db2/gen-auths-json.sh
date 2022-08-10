#!/usr/bin/env bash

function usage() {
cat<<EOF
$0 takes two values as mandatory inputs: an email address and a password.

Usage:

       $0 -e user@example.com -p OTMuMTg0LjIxNi4zNAo=

These will be used to generate JSON like this:
   {
     "auths": {
       "cp.icr.io": {
         "username": "cp",
         "password": "OTMuMTg0LjIxNi4zNAo=",
         "email": "user@example.com",
         "auth": "dXNlckBleGFtcGxlLmNvbTpPVE11TVRnMExqSXhOaTR6TkFvPQo="
       }
     }
   }

The auth value is equivalent to base64(email:password).
EOF
}

while getopts "e:p:h" opt; do
    case $opt in
        e)
            email=$OPTARG;
            ;;
        p)
            password=$OPTARG;
            ;;
        h)
            usage;
            exit 0;
            ;;
        *)
            usage;
            exit 1;
            ;;
  esac
done

# Is the utility jq to be found?
which jq 2>&1 > /dev/null
if [ $? -gt 0 ]; then
    echo "Can't find jq, command-line JSON processor, in the PATH."
    exit 1
fi

# Do we have the mandatory inputs?
if [ ${#email} -eq 0 ] || [ ${#password} -eq 0 ]; then
    usage
    exit 1
fi

# Generate the auth value:
auth=$(echo "$email:$password" | base64)

# Generate the JSON object containing an auths object:
json="
{
  \"auths\": {
    \"cp.icr.io\": {
      \"username\": \"cp\",
      \"password\": \"$password\",
      \"email\": \"$email\",
      \"auth\": \"$auth\"
    }
  }
}"

echo $json | jq

# TODO: block unsafe inputs, e.g., shell will execute back-ticked commands inside the string args
