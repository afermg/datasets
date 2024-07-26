# Find the latest version of the dataset
ZENODO_ENDPOINT="https://zenodo.org"
ORIGINAL_ID="12974922"
LATEST_ID=$(curl "$ZENODO_ENDPOINT/records/$ORIGINAL_ID/latest" |
		grep records | sed 's/.*href=".*\.org\/records\/\(.*\)".*/\1/')

# TODO Check that local != LATEST in a fine-grained manner
clean_and_hash () {
    # Remove first row and column and calculate hash of remaning data
    cat $1 | awk -F"," '!($1="")' | tail -n +2 | md5sum
}
REMOTE_HASH=$(curl -H "Content-Type: application/json" -X GET  --data "{}" \
		   "${DEPOSITION_ENDPOINT}/files?access_token=${ZENODO_TOKEN}" |
		  jq ".[] .links .download" | xargs curl | clean_and_hash)
LOCAL_HASH=$(clean_and_hash profile_index.csv)

if [ "$REMOTE_HASH" = "$LOCAL_HASH" ]; then
    echo "The urls and md5sums have not changed"
    exit 1
fi


if [[ -n $LATEST_ID ]]; then # Create new version
    echo "Creating new version"
    DEPOSITION_ENDPOINT="${ZENODO_ENDPOINT}/api/deposit/depositions/${DEPOSIT}/actions/newversion"
else # Create new update entry
    echo "Creating new deposition"
    DEPOSITION_ENDPOINT="${ZENODO_ENDPOINT}/api/deposit/depositions"
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

# Reoccurrent variables
BUCKET_DATA=$(curl "${ZENODO_ENDPOINT}/api/deposit/depositions/$DEPOSITION?access_token=$ZENODO_TOKEN")
DEPOSITION_ENDPOINT="${ZENODO_ENDPOINT}/api/deposit/depositions/${DEPOSITION}"

if [ "$BUCKET" = "null" ]; then
    echo "Could not find URL for upload. Response from server:"
    echo "$BUCKET_DATA"
    exit 1
fi

# Upload file
curl --progress-bar \
     --retry 5 \
     --retry-delay 5 \
     -o /dev/null \
     --upload-file profile_index.csv \
     $BUCKET/profile_index.csv?access_token="$ZENODO_TOKEN"


# Upload Metadata
echo -e '{"metadata": {
    "creators": [
        {
            "name": "The JUMP Cell Painting Consortium"
        }
    ],
    "title": "The Joint Undertaking for Morpholgical Profiling (JUMP) Consortium Datasets Index",
    "upload_type": "dataset", 
    "access_right": "open"
}}' > metadata.json

curl --progress-bar \
     --retry 5 \
     --retry-delay 5 \
     -H "Content-Type: application/json" \
     -X PUT\
     --data @metadata.json \
     "${DEPOSITION_ENDPOINT}?access_token=${ZENODO_TOKEN}"

# Publish
echo "Publishing"
curl --progress-bar \
     --retry 5 \
     --retry-delay 5 \
     -H "Content-Type: application/json" \
     -X POST\
     --data "{}"\
    "${DEPOSITION_ENDPOINT}/actions/publish?access_token=${ZENODO_TOKEN}"\
  | jq .id

