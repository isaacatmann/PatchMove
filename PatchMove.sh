#!/bin/zsh
###############################################################################
# Patch Move
# Created by: Mann Consulting (support@mann.com)
# Summary:  Moves all patches from community patch to a private title editor instance.
#
# Useage:   Simply run this and you'll be prompted for the appripriate information.
#
###############################################################################

echo -n "Community Patch ID: "
read communityPatchID

echo -n "Title Editor URL (include https://): "
read titleEditorURL

echo -n "Title Editor User: "
read titleEditorUser

echo -n "Title Editor Password: "
read -s titleEditorPassword

echo ""
echo "Generating Auth Token"
authToken=$(curl -sfu "$titleEditorUser:$titleEditorPassword" "${titleEditorURL}/v2/auth/tokens" -X POST -H 'Accept: application/json' | grep token | cut -d '"' -f 4)

communityPatchTitles=($(curl -s https://beta2.communitypatch.com/jamf/v1/${communityPatchID}/software | grep -o '"id": "[^"]*' | sed 's/"id": "//'))

for title in "${communityPatchTitles[@]}";do
  patchdata=$(curl -s https://beta2.communitypatch.com/jamf/v1/${communityPatchID}/patch/${title})
  curloutput=$(curl -s "${titleEditorURL}"/v2/softwaretitles -X POST --header "Authorization: Bearer $authToken" -H 'Content-Type: application/json' -d "$patchdata")

  if [[ $curloutput == *"errors"* ]]; then
    echo "$title Failed"
    echo "$curloutput"
  else
    echo "$title Success"
  fi
  sleep 5
done
