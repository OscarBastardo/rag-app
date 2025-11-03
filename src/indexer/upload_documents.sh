# get GCS bucket name from terraform output
BUCKET_NAME=$(terraform -chdir=terraform output -raw gcs_bucket_name)

# delete existing contents in the bucket
gsutil -m rm -r gs://${BUCKET_NAME}/documents/*

# upload new documents to the bucket
gsutil cp -r data/* gs://${BUCKET_NAME}/documents/
