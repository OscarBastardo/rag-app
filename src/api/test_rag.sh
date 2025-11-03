# get URL from terraform output
API_URL=$(terraform -chdir=terraform output -raw api_url)

# check for required argument
if [ $# -lt 1 ]; then
    echo "Usage: $0 <QUESTION>"
    exit 1
fi

QUESTION="$1"

# make an authenticated request to the API
curl -X POST "${API_URL}/query" \
-H "Authorization: Bearer $(gcloud auth print-identity-token)" \
-H "Content-Type: application/json" \
-d "{\"question\": \"$QUESTION\"}"