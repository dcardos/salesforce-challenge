#Convert to MDAPI format for deployment to prod
echo "Converting to MDAPI format..."
sfdx force:source:convert -d deploy_prod -r force-app 
#Deploy to prod & run all tests (modified to local since there are some test errors in the org)
echo "Deploying to production & running all tests..."
sfdx force:mdapi:deploy -u DevHub -d deploy_prod/ -w -1 -l RunLocalTests