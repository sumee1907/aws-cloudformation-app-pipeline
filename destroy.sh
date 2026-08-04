echo "Destroying CLass End Project Infrastructure"
echo
echo "Destroying network stack..."
echo

aws cloudformation delete-stack \
  --stack-name CEP-Network

echo
echo "Destroying ECR stack..."
echo

aws cloudformation delete-stack \
  --stack-name CEP-ECR