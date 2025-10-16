#!/bin/bash

# ECR Credentials Setup Script
# This script generates the ECR credentials secret for ArgoCD Image Updater

set -e

# Configuration
AWS_REGION="ap-northeast-1"
ECR_REGISTRY="488363440930.dkr.ecr.ap-northeast-1.amazonaws.com"
SECRET_NAME="ecr-credentials"
NAMESPACE="argocd"
OUTPUT_FILE1="cicd/k8s/secrets/ecr-credentials.yaml"
OUTPUT_FILE2="cicd/k8s/argocd/ecr-credentials.yaml"

echo "🔧 Setting up ECR credentials for ArgoCD Image Updater..."

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI is not installed. Please install it first."
    exit 1
fi

# Check if AWS credentials are configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS credentials are not configured. Please run 'aws configure' first."
    exit 1
fi

# Get ECR login token
echo "📝 Getting ECR login token..."
ECR_TOKEN=$(aws ecr get-login-password --region $AWS_REGION)

if [ -z "$ECR_TOKEN" ]; then
    echo "❌ Failed to get ECR login token. Check AWS credentials and permissions."
    exit 1
fi

# Generate the secret YAML (for both locations)
echo "📄 Generating ECR credentials secret..."
SECRET_CONTENT=$(echo -n '{"auths":{"'${ECR_REGISTRY}'":{"username":"AWS","password":"'${ECR_TOKEN}'"}}}' | base64 -w 0)

# Create secrets directory if it doesn't exist
mkdir -p cicd/k8s/secrets

# Generate first file
cat > $OUTPUT_FILE1 <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: ${SECRET_NAME}
  namespace: ${NAMESPACE}
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: ${SECRET_CONTENT}
EOF

# Generate second file
cat > $OUTPUT_FILE2 <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: ${SECRET_NAME}
  namespace: ${NAMESPACE}
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: ${SECRET_CONTENT}
EOF

echo "✅ ECR credentials secret generated:"
echo "   - $OUTPUT_FILE1"
echo "   - $OUTPUT_FILE2"
echo ""
echo "🚀 To apply the secret, run:"
echo "   kubectl apply -f $OUTPUT_FILE2"
echo "   # OR using kustomize:"
echo "   kubectl apply -k cicd/k8s/argocd/"
echo ""
echo "🔄 To update the secret in the future, run:"
echo "   ./scripts/setup-ecr-credentials.sh && kubectl apply -f cicd/k8s/argocd/ecr-credentials.yaml"
echo ""
echo "⚠️  Note: The ECR token expires after 12 hours. You may need to regenerate it periodically."