# Find the latest version of the dataset
ZENODO_ENDPOINT="https://zenodo.org"
DEPOSITION_PREFIX="${ZENODO_ENDPOINT}/api/deposit/depositions"
ORIGINAL_ID=""
FILE_TO_VERSION="profile_index.csv"

if [ -z "${ORIGINAL_ID}" ]; then # Only get latest id when provided an original one
    echo "Creating new deposition"
    DEPOSITION_ENDPOINT="${DEPOSITION_PREFIX}"
else # Update existing dataset
    echo "Previous ID Exists"
    LATEST_ID=$(curl "$ZENODO_ENDPOINT/records/$ORIGINAL_ID/latest" |
		    grep records | sed 's/.*href=".*\.org\/records\/\(.*\)".*/\1/')
    REMOTE_HASH=$(curl -H "Content-Type: application/json" -X GET  --data "{}" \
		       "${DEPOSITION_PREFIX}/${LATEST_ID}/files?access_token=${ZENODO_TOKEN}" |
		  jq ".[] .links .download" | xargs curl | md5sum)
    LOCAL_HASH=$(md5sum ${FILE_TO_VERSION})

    echo "Checking for changes in file contents: Remote ${REMOTE_HASH} vs Local ${LOCAL_HASH}"
    if [ "$REMOTE_HASH" = "$LOCAL_HASH" ]; then
	echo "The urls and md5sums have not changed"
	exit 0
    fi

    echo "Creating new version"
    DEPOSITION_ENDPOINT="${DEPOSITION_PREFIX}/${LATEST_ID}/actions/newversion"
fi


if [ -z "$ZENODO_TOKEN" ]; then # Check Zenodo Token
    echo "Access token not available"
    exit 1
else 
    echo "Access token found"
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
echo "New deposition ID is ${DEPOSITION}"

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
     --upload-file ${FILE_TO_VERSION} \
     $BUCKET/${FILE_TO_VERSION}?access_token="$ZENODO_TOKEN"


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

