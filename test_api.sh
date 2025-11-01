# get URL from terraform output
API_URL=$(terraform -chdir=terraform output -raw api_url)

# make an authenticated request to the API
curl -X POST "${API_URL}/query" \
-H "Authorization: Bearer $(gcloud auth print-identity-token)" \
-H "Content-Type: application/json" \
-d '{"question": "Who is Kaelen Nightbreeze?"}'