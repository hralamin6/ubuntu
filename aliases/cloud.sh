#!/usr/bin/env zsh
# =============================================================================
# aliases/cloud.sh — Cloud (AWS, GCP, Azure, Kubernetes, Terraform)
# =============================================================================

# ---------------------------------------------------------------------------
# AWS CLI
# ---------------------------------------------------------------------------
alias aws='aws'
alias awsv='aws --version'
alias awswho='aws sts get-caller-identity'
alias awsregions='aws ec2 describe-regions --query "Regions[*].RegionName" --output text'
alias awszones='aws ec2 describe-availability-zones --output text'
alias awsec2='aws ec2 describe-instances --query "Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType,PublicIpAddress,Tags[?Key==\`Name\`].Value|[0]]" --output table'
alias awss3ls='aws s3 ls'
alias awss3cp='aws s3 cp'
alias awss3sync='aws s3 sync'
alias awselbls='aws elbv2 describe-load-balancers --output table'
alias awsrds='aws rds describe-db-instances --output table'
alias awslambda='aws lambda list-functions --output table'
alias awslogs='aws logs describe-log-groups --output table'
alias awsecr='aws ecr describe-repositories --output table'
alias awsecs='aws ecs list-clusters --output table'
alias awseks='aws eks list-clusters --output text'
alias awsiam='aws iam list-users --output table'
alias awssecrets='aws secretsmanager list-secrets --output table'
alias awsssm='aws ssm describe-parameters --output table'
alias awsprice='aws pricing describe-services'
alias awscf='aws cloudformation list-stacks --output table'
alias awsroute53='aws route53 list-hosted-zones --output table'
alias awsvpcs='aws ec2 describe-vpcs --output table'
alias awssg='aws ec2 describe-security-groups --output table'
alias awskp='aws ec2 describe-key-pairs --output table'
alias awsprofiles='cat ~/.aws/credentials | grep "\[" | tr -d "[]"'
alias awsconfig='aws configure'

# ---------------------------------------------------------------------------
# KUBERNETES (kubectl)
# ---------------------------------------------------------------------------
if command -v kubectl &>/dev/null; then
  alias k='kubectl'
  alias kv='kubectl version'
  alias kg='kubectl get'
  alias kga='kubectl get all'
  alias kgp='kubectl get pods'
  alias kgpa='kubectl get pods --all-namespaces'
  alias kgpw='kubectl get pods -w'
  alias kgs='kubectl get services'
  alias kgsa='kubectl get services --all-namespaces'
  alias kgd='kubectl get deployments'
  alias kgda='kubectl get deployments --all-namespaces'
  alias kgn='kubectl get nodes'
  alias kgnw='kubectl get nodes -o wide'
  alias kgns='kubectl get namespaces'
  alias kgcm='kubectl get configmaps'
  alias kgsc='kubectl get secrets'
  alias kgpvc='kubectl get pvc'
  alias kgpv='kubectl get pv'
  alias kging='kubectl get ingress'
  alias kgcj='kubectl get cronjobs'
  alias kgj='kubectl get jobs'
  alias kgrs='kubectl get replicasets'
  alias kgds='kubectl get daemonsets'
  alias kgsts='kubectl get statefulsets'
  alias kghpa='kubectl get hpa'
  alias kgsc='kubectl get storageclasses'
  alias kgsec='kubectl get secrets'

  # Describe
  alias kd='kubectl describe'
  alias kdp='kubectl describe pod'
  alias kdn='kubectl describe node'
  alias kds='kubectl describe service'
  alias kdd='kubectl describe deployment'

  # Apply / Create / Delete
  alias ka='kubectl apply -f'
  alias kcr='kubectl create'
  alias krm='kubectl delete'
  alias krmp='kubectl delete pod'
  alias krmf='kubectl delete -f'
  alias krmns='kubectl delete namespace'

  # Logs
  alias kl='kubectl logs'
  alias klf='kubectl logs -f'
  alias klt='kubectl logs --tail=100'
  alias klft='kubectl logs -f --tail=100'

  # Exec
  alias kex='kubectl exec -it'
  alias kexb='kubectl exec -it -- bash'
  alias kexs='kubectl exec -it -- sh'

  # Context / Namespace
  alias kctx='kubectl config get-contexts'
  alias kctxu='kubectl config use-context'
  alias kns='kubectl config set-context --current --namespace'
  alias kcur='kubectl config current-context'
  alias kconf='kubectl config view'

  # Rollout
  alias kro='kubectl rollout'
  alias kros='kubectl rollout status'
  alias kroh='kubectl rollout history'
  alias kroru='kubectl rollout restart'
  alias kroud='kubectl rollout undo'

  # Scale
  alias ksc='kubectl scale'
  alias kscd='kubectl scale deployment'

  # Port-forward
  alias kpf='kubectl port-forward'

  # Top
  alias ktop='kubectl top'
  alias ktopp='kubectl top pods'
  alias ktopn='kubectl top nodes'

  # Useful combos
  alias kdrain='kubectl drain --ignore-daemonsets --delete-emptydir-data'
  alias kuncordon='kubectl uncordon'
  alias kcordon='kubectl cordon'
  alias kwatch='watch kubectl get pods'
  alias kall='kubectl get all --all-namespaces'
fi

# ---------------------------------------------------------------------------
# HELM
# ---------------------------------------------------------------------------
if command -v helm &>/dev/null; then
  alias h='helm'
  alias hls='helm list'
  alias hlsa='helm list --all-namespaces'
  alias hi='helm install'
  alias hu='helm upgrade'
  alias hui='helm upgrade --install'
  alias hrm='helm uninstall'
  alias hst='helm status'
  alias hd='helm delete'
  alias hget='helm get'
  alias hga='helm get all'
  alias hgv='helm get values'
  alias hgl='helm get manifest'
  alias hrepo='helm repo'
  alias hrepoa='helm repo add'
  alias hrepou='helm repo update'
  alias hrepols='helm repo list'
  alias hsearch='helm search repo'
  alias hpull='helm pull'
  alias htemplate='helm template'
  alias hlint='helm lint'
  alias hcreate='helm create'
fi

# ---------------------------------------------------------------------------
# TERRAFORM
# ---------------------------------------------------------------------------
if command -v terraform &>/dev/null; then
  alias tf='terraform'
  alias tfi='terraform init'
  alias tfiu='terraform init -upgrade'
  alias tfp='terraform plan'
  alias tfo='terraform plan -out=tfplan'
  alias tfa='terraform apply'
  alias tfaa='terraform apply -auto-approve'
  alias tfat='terraform apply tfplan'
  alias tfd='terraform destroy'
  alias tfda='terraform destroy -auto-approve'
  alias tfs='terraform show'
  alias tfsf='terraform show tfplan'
  alias tfst='terraform state'
  alias tfstl='terraform state list'
  alias tfstsh='terraform state show'
  alias tfstmv='terraform state mv'
  alias tfstrm='terraform state rm'
  alias tfv='terraform validate'
  alias tff='terraform fmt'
  alias tfr='terraform refresh'
  alias tfout='terraform output'
  alias tfoutj='terraform output -json'
  alias tfwr='terraform workspace'
  alias tfwrl='terraform workspace list'
  alias tfwrn='terraform workspace new'
  alias tfwrs='terraform workspace select'
  alias tfwrd='terraform workspace delete'
  alias tflock='terraform providers lock'
  alias tfprov='terraform providers'
  alias tfupgrade='terraform get -upgrade'
  alias tfimport='terraform import'
fi

# ---------------------------------------------------------------------------
# GCP (gcloud)
# ---------------------------------------------------------------------------
if command -v gcloud &>/dev/null; then
  alias gc='gcloud'
  alias gcv='gcloud --version'
  alias gcwho='gcloud auth list'
  alias gclogin='gcloud auth login'
  alias gcproj='gcloud projects list'
  alias gcsetproj='gcloud config set project'
  alias gcconf='gcloud config list'
  alias gccompute='gcloud compute instances list'
  alias gcsql='gcloud sql instances list'
  alias gcgke='gcloud container clusters list'
  alias gcfn='gcloud functions list'
  alias gcrun='gcloud run services list'
  alias gcbuild='gcloud builds list'
  alias gcbucket='gsutil ls'
  alias gciam='gcloud iam service-accounts list'
fi

# ---------------------------------------------------------------------------
# AZURE (az)
# ---------------------------------------------------------------------------
if command -v az &>/dev/null; then
  alias azlogin='az login'
  alias azwho='az account show'
  alias azsubs='az account list --output table'
  alias azset='az account set --subscription'
  alias azrg='az group list --output table'
  alias azvm='az vm list --output table'
  alias azaks='az aks list --output table'
  alias azacr='az acr list --output table'
  alias azfn='az functionapp list --output table'
  alias azweb='az webapp list --output table'
  alias azdb='az sql server list --output table'
fi
