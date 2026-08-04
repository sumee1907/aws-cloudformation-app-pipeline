echo "Deploying CloudFormation templates..."
echo
echo "Deploying network stack..."
echo

aws cloudformation deploy \
  --template-file cloudformation/network.yaml \
  --stack-name CEP-Network

echo
echo "Deploying ECR stack..."
echo

aws cloudformation deploy \
  --template-file cloudformation/ecr.yaml \
  --stack-name CEP-ECR

