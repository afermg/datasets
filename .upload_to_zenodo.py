import csv
import json
import hashlib
import os
from pathlib import Path

import requests

ACCESS_TOKEN = os.environ.get("ZENODO_ACCESS_TOKEN")
DEPOSITION_ID = "12974922"
DATA = {'metadata': 
            {"title": "The Joint Undertaking for Morpholgical Profiling (JUMP) Consortium Datasets Index",
            "creators": [
                {
                    "name": "The JUMP Cell Painting Consortium"
                      },
            ],
            "upload_type": "dataset", 
            "access_right": "open",}}
FILES = ["profile_index.csv"]



headers = {"Content-Type": "application/json"}
params = {'access_token': ACCESS_TOKEN}

### Convenience functions
def hash_csv_url(url:str):
    """
    Download csv from url, skip the first column (hash) and
    return the hash corresponding to the concatenated remains
    """
    if url.startswith("http"):
        response = requests.get(url, params=params)
        reader = csv.reader(response.content.decode('utf-8').splitlines(), dialect='unix')
        result = concat_skip_hash_iterable(reader)
    else:
        with open(url, "r") as f:
            reader = csv.reader(f)
            result = concat_skip_hash_iterable(reader)
    return result


def concat_skip_hash_iterable(iterable):
    # Skip first line and concat the rest from an iterable
    concat = ""
    for i,line in enumerate(iterable):
        if i>1:
            concat += "".join(line)
    return hash(concat)

def get_latest_csv_hash(RECORD_ID:str):
    r = requests.get(f"https://zenodo.org/api/records/{RECORD_ID}/versions/latest").json()
    files = requests.get(r["links"]["files"]).json()
    latest_csv_hash = hash_csv_url(files["entries"][0]["links"]["content"])
    return latest_csv_hash

def get_record_latest_version(RECORD_ID:str):
    requests.get(f"https://zenodo.org/api/deposit/depositions/{DEPOSITION_ID}", params=params).json()
    original_record = requests.get(f"https://zenodo.org/api/records/{DEPOSITION_ID}", params=params).json()
    record = original_record["metadata"]["relations"]["version"][-1]
    latest_record = requests.get(f"https://zenodo.org/api/records/{latest_record['parent']['pid_value']}", params=params).json()
    assert latest_record["metadata"]["relations"]["version"][-1]["is_last"] == True, "Found record is not true"
    return latest_record["id"]

    
### Process
# Before anything, check for relevant changes between the local version and the latest remote
## Find latest remote
    
# Run this to create a new independent deposition
if DEPOSITION_ID is None:
    r = requests.post('https://zenodo.org/api/deposit/depositions',
                      params=params,json={})
    DEPOSITION_ID = r.json()["id"]
    bucket_url = r.json()["links"]["bucket"]

# Upload file(s) to bucket
for filepath in FILES:
    filename = Path(filepath).name
    with open(filepath, "rb") as fp:
        r = requests.put(
            "%s/%s" % (bucket_url, filename),
            data=fp,
            params=params,
        )

# Add metadata
r = requests.put(f'https://zenodo.org/api/deposit/depositions/{DEPOSITION_ID}',
                 params=params, data=json.dumps(DATA),
                 headers=headers)

# Upload new version
def upload_new_version(latest_record_id:str):
    r = requests.put(f"https://zenodo.org/api/deposit/depositions/{latest_record_id}/actions/newversion", params=params).json()

    
deposition_keys = requests.get(f'https://zenodo.org/api/deposit/depositions/{latest_record_id}', params=params).json()
nv = requests.get('https://zenodo.org/api/deposit/depositions/12988713/actions/newversion', params=params).json()
