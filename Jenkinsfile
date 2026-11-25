pipeline {
    agent any

    environment {
        AWS_REGION     = "eu-north-1"
        ECR_REGISTRY   = "477213278971.dkr.ecr.eu-north-1.amazonaws.com"
        ECR_REPOSITORY = "devsecops-telemetry-prod"
        CHATOPS_HOOK   = ""
    }

    stages {
        stage('1. Source Checkout & Metadata') {
            steps {
                checkout scm
                script {
                    env.GIT_SHORT_HASH = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                    env.IMAGE_TAG      = "v${env.BUILD_NUMBER}-${env.GIT_SHORT_HASH}"
                    env.FULL_IMAGE_URI = "${ECR_REGISTRY}/${ECR_REPOSITORY}:${env.IMAGE_TAG}"
                }
                echo "Initialized Build #${env.BUILD_NUMBER} | Immutable Tag: ${env.IMAGE_TAG}"
            }
        }

        stage('2. Isolated Container Unit Tests') {
            steps {
                echo "Executing isolated unit tests inside ephemeral Node container..."
                sh '''
                    docker run --rm -v "$PWD/app":/app -w /app node:20-alpine sh -c "npm install --silent && npm test"
                '''
            }
        }

        stage('3. Multi-Stage Docker Build') {
            steps {
                echo "Building optimized multi-stage production image..."
                sh '''
                    docker build -t ${FULL_IMAGE_URI} .
                '''
            }
        }

        stage('4. DevSecOps Security Gate (Trivy)') {
            steps {
                echo "Scanning image for HIGH and CRITICAL CVEs before registry push..."
                sh '''
                    docker run --rm \
                        -v /var/run/docker.sock:/var/run/docker.sock \
                        aquasec/trivy:latest image \
                        --severity HIGH,CRITICAL \
                        --exit-code 1 \
                        --no-progress \
                        ${FULL_IMAGE_URI}
                '''
            }
        }

        stage('5. Keyless AWS ECR Push (Artifact Delivery)') {
            steps {
                echo "Authenticating to AWS ECR via EC2 IAM Instance Profile and pushing immutable artifact..."
                sh '''
                    aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}
                    docker push ${FULL_IMAGE_URI}
                '''
            }
        }
    }

    post {
        always {
            echo "Pruning local container images to preserve controller disk space..."
            sh "docker rmi ${FULL_IMAGE_URI} || true"
            sh "docker image prune -f || true"
        }
        success {
            echo "SUCCESS: Artifact ${FULL_IMAGE_URI} verified and pushed to AWS ECR!"
        }
        failure {
            echo "FAILURE: Pipeline halted at quality, security, or registry delivery gate."
        }
    }
}
