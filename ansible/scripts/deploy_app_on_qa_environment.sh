echo 'Deploying App on Kubernetes'
envsubst < k8s/petclinic_chart/values-template.yml > k8s/petclinic_chart/values.yml
sed -i s/HELM_VERSION/${BUILD_NUMBER}/ k8s/petclinic_chart/Chart.yml
AWS_REGION=$AWS_REGION helm repo add stable-petclinic s3://petclinic-helm-charts-jelloul/stablemyapp/ || echo "repository name already exists"
AWS_REGION=$AWS_REGION helm repo update
helm package k8s/petclinic_chart
AWS_REGION=$AWS_REGION helm s3 push --force petclinic_chart-${BUILD_NUMBER}.tgz stable-petclinic
envsubst < ansible/playbooks/qa-petclinic-deploy-template >ansible/playbooks/qa-petclinic-deploy.yml
ansible-playbook -i ./ansible/inventory/qa_stack_dynamic_inventory_aws_ec2.yml ./ansible/playbooks/qa-petclinic-deploy.yml