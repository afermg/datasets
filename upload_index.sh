# Find the latest version of the dataset
ZENODO_ENDPOINT="https://zenodo.org"
DEPOSITION_PREFIX="${ZENODO_ENDPOINT}/api/deposit/depositions"
ORIGINAL_ID=""
LATEST_ID=$(curl "$ZENODO_ENDPOINT/records/$ORIGINAL_ID/latest" |
		grep records | sed 's/.*href=".*\.org\/records\/\(.*\)".*/\1/')
FILE_TO_VERSION="profile_index.csv"

# Check that there is new information in ${FILE_TO_INDEX} 
clean_and_hash () {
    # Remove first row and column and calculate hash of remaining data
    cat $1 | awk -F"," '!($1="")' | tail -n +2 | md5sum
}
REMOTE_HASH=$(curl -H "Content-Type: application/json" -X GET  --data "{}" \
		   "${DEPOSITION_PREFIX}/${LATEST_ID}/files?access_token=${ZENODO_TOKEN}" |
		  jq ".[] .links .download" | xargs curl | md5sum)
LOCAL_HASH=$(md5sum ${FILE_TO_INDEX})


if [ -z "$ZENODO_TOKEN" ]; then
    echo "Access token not available"
    exit 1
else 
    echo "Access token found"
fi

echo "Checking for changes in file contents: Remote ${REMOTE_HASH} vs Local ${LOCAL_HASH}"
if [ "$REMOTE_HASH" = "$LOCAL_HASH" ]; then
    echo "The urls and md5sums have not changed"
    exit 0
fi


if [[ -n $LATEST_ID ]]; then # Create new version
    echo "Creating new version"
    DEPOSITION_ENDPOINT="${DEPOSITION_PREFIX}/${LATEST_ID}/actions/newversion"
else # Create new update entry
    echo "Creating new deposition"
    DEPOSITION_ENDPOINT="${DEPOSITION_PREFIX}"
fi

# Create new deposition
DEPOSITION=$(curl --progress-bar \
		  --retry 5 \
		  --retry-delay 5 \
		  -H "Content-Type: application/json" \
		  -X POST\
		  --data "{}" \
		  "${DEPOSITION_ENDPOINT}?access_token=${ZENODO_TOKEN}"\
		 | jq .id)

# Variables
BUCKET_DATA=$(curl "${DEPOSITION_PREFIX}/$DEPOSITION?access_token=$ZENODO_TOKEN")
BUCKET=$(echo "$BUCKET_DATA" | jq --raw-output .links.bucket)

if [ "$BUCKET" = "null" ]; then
    echo "Could not find URL for upload. Response from server:"
    echo "$BUCKET_DATA"
    exit 1
fi

# Upload file
echo "Uploading file to bucket $BUCKET"
curl --progress-bar \
     --retry 5 \
     --retry-delay 5 \
     -o /dev/null \
     --upload-file ${FILE_TO_INDEX} \
     $BUCKET/${FILE_TO_INDEX}?access_token="$ZENODO_TOKEN"


# Upload Metadata
echo -e '{"metadata": {
    "title": "The Joint Undertaking for Morphological Profiling (JUMP) Consortium Datasets Index",
    "creators": [
        {
            "name": "The JUMP Cell Painting Consortium"
        }
    ],
    "upload_type": "dataset", 
    "access_right": "open"
}}' > metadata.json

NEW_DEPOSITION_ENDPOINT="${DEPOSITION_PREFIX}/${DEPOSITION}"
echo "Uploading file to $NEW_DEPOSITION_ENDPOINT"
curl --progress-bar \
     --retry 5 \
     --retry-delay 5 \
     -H "Content-Type: application/json" \
     -X PUT\
     --data @metadata.json \
     "${NEW_DEPOSITION_ENDPOINT}?access_token=${ZENODO_TOKEN}"

# Publish
echo "Publishing to $NEW_DEPOSITION_ENDPOINT"
curl --progress-bar \
     --retry 5 \
     --retry-delay 5 \
     -H "Content-Type: application/json" \
     -X POST\
     --data "{}"\
    "${NEW_DEPOSITION_ENDPOINT}/actions/publish?access_token=${ZENODO_TOKEN}"\
  | jq .id

