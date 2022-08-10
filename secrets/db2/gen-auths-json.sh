#!/usr/bin/env bash

function usage() {
cat<<EOF
$0 takes two values as mandatory inputs: an email address and a password.

Usage/Example:
        export EMAIL=user@example.com
        export PASSWORD=OTMuMTg0LjIxNi4zNAo=
        ./$0

These will be used to generate DockerConfigJSON like this:
   {
     "auths": {
       "cp.icr.io": {
         "username": "cp",
         "password": "OTMuMTg0LjIxNi4zNAo=",
         "email": "yourUsedId@ibm.com",
         "auth": "dXNlckBleGFtcGxlLmNvbTpPVE11TVRnMExqSXhOaTR6TkFvPQo="
       }
     }
   }
The value "cp", associated with the username field is always cp. Do not change this.

Navigate to the following link to obtain a password: https://myibm.ibm.com/products-services/containerlibrary

The auth value is equivalent to base64(email:password).
EOF
}

# Is the utility jq to be found?
which jq 2>&1 > /dev/null
if [ $? -gt 0 ]; then
    echo "Can't find jq, command-line JSON processor, in the PATH."
    exit 1
fi

# Do we have the mandatory inputs?
if [ ${#EMAIL} -eq 0 ] || [ ${#PASSWORD} -eq 0 ]; then
    usage
    exit 1
fi

# Generate the auth value:
auth=$(echo "$EMAIL:$PASSWORD" | base64)

# Generate the JSON object containing an auths object:
json="
{
  \"auths\": {
    \"cp.icr.io\": {
      \"username\": \"cp\",
      \"password\": \"$PASSWORD\",
      \"email\": \"$EMAIL\",
      \"auth\": \"$auth\"
    }
  }
}"

echo $json | jq
