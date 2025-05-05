pipeline {
    agent {
        kubernetes {
            label 'jenkins_slave2'
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: dockerimage
    image: yousra000/dind:latest
    securityContext:
      privileged: true
"""
        }
    }

    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION    = 'us-east-1'
    }

    options {
        skipDefaultCheckout(false)
        timeout(time: 30, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Verify Tools') {
            steps {
                container('dockerimage') {
                    sh '''
                        echo "=== Tools Version ==="
                        docker --version
                        aws --version
                        trivy --version
                    '''
                }
            }
        }

        stage('AWS Configure') {
            steps {
                container('dockerimage') {
                    sh '''
                        aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID"
                        aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY"
                        aws configure set region $AWS_DEFAULT_REGION
                        aws sts get-caller-identity
                    '''
                }
            }
        }

        stage('Set Image Tag') {
            steps {
                script {
                    env.COMMIT_COUNT = sh(script: 'git rev-list --count HEAD', returnStdout: true).trim()
                    env.COMMIT_HASH = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    env.TAG = "${env.COMMIT_COUNT}.${env.COMMIT_HASH}"
                    echo "Generated image tag: ${env.TAG}"
                }
            }
        }

        stage('Get ECR Info') {
            steps {
                container('dockerimage') {
                    script {
                        env.REGISTRY = sh(
                            script: 'aws ecr describe-repositories --query "repositories[0].repositoryUri" --output text | cut -d "/" -f1',
                            returnStdout: true
                        ).trim()

                        env.REPOSITORY = sh(
                            script: 'aws ecr describe-repositories --query "repositories[0].repositoryName" --output text',
                            returnStdout: true
                        ).trim()

                        echo "ECR Registry: ${env.REGISTRY}"
                        echo "ECR Repository: ${env.REPOSITORY}"
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                container('dockerimage') {
                    dir('nodeapp') {
                        sh """
                            docker build -t ${env.REGISTRY}/${env.REPOSITORY}:${env.TAG} .
                        """
                    }
                }
            }
        }

        stage('Trivy Scan') {
            steps {
                container('dockerimage') {
                    dir('nodeapp') {
                        script {
                            def trivyScan = sh(script: "trivy image --severity HIGH,CRITICAL ${env.REGISTRY}/${env.REPOSITORY}:${env.TAG}", returnStatus: true)
                            if (trivyScan != 0) {
                                echo "Trivy found vulnerabilities — continuing anyway."
                            } else {
                                echo "Trivy scan passed."
                            }
                        }
                    }
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                container('dockerimage') {
                    dir('nodeapp') {
                        sh """
                            aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | \
                            docker login --username AWS --password-stdin ${env.REGISTRY}
                            docker push ${env.REGISTRY}/${env.REPOSITORY}:${env.TAG}
                        """
                    }
                }
            }
        }
    }
}
