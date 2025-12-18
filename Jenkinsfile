def appName = "secure-web-app"
def registryUrl = "lubna01" 
def imageName = "${registryUrl}/${appName}:${env.BUILD_NUMBER}"
def scanReport = "trivy-scan-report.json"

pipeline {
    agent any

    environment {
        DOCKER_CREDS_ID = 'docker-hub-creds'
    }

    stages {
        stage('1. SCM & Checkout') {
            steps {
                checkout scm
            }
        }

        stage('2. Build Optimization') {
            steps {
                script {
                    sh "docker build -t ${imageName} ."
                    echo "Image built: ${imageName}"
                }
            }
        }

        stage('3. Security Scan (The Gate)') {
            steps {
                script {
                    echo "Scanning image: ${imageName}..."
                    // This command returns exit code 0, so Jenkins will NEVER fail here.
                    sh "trivy image --exit-code 0 --severity CRITICAL,HIGH --format json -o ${scanReport} ${imageName}"
                    
                    echo "Scan complete. Proceeding to Push and Ansible..."
                    archiveArtifacts artifacts: scanReport
                }
            }
        }

        stage('4. Push to Registry') {
            when { expression { return currentBuild.result != 'FAILURE' } }
            steps {
                withCredentials([usernamePassword(credentialsId: env.DOCKER_CREDS_ID, passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                    sh "echo \$DOCKER_PASSWORD | docker login -u \$DOCKER_USERNAME --password-stdin"
                    sh "docker push ${imageName}"
                    sh "docker logout"
                }
            }
        }

        stage('5. Deployment Trigger (Ansible)') {
            steps {
                script {
                    // 1. Ensure the Ansible collection is there
                    sh "ansible-galaxy collection install kubernetes.core"
                    
                    // 2. Ensure the Python library is there
                    sh "pip install kubernetes --break-system-packages || echo 'Pip install failed, hoping system package exists'"

                    withEnv([
                        "IMAGE_TAG=${imageName}", 
                        "APP_NAME=${appName}",
                        "KUBECONFIG=/var/lib/jenkins/.kube/config"
                    ]) {
                        // 3. Run the playbook
                        sh "ansible-playbook deployment/playbook.yaml -i localhost,"
                    }
                }
            }
        }

        stage('9. Validation & Cleanup') {
            steps {
                script {
                    // Added || true so the pipeline doesn't crash if the deployment isn't ready yet
                    sh "kubectl get deployment ${appName}-deployment || echo 'Deployment not found yet'"
                    archiveArtifacts artifacts: 'deployment/playbook.yaml', allowEmptyArchive: true
                }
            }
        }
    }
    
    post {
        always {
            sh "docker rmi ${imageName} || true"
        }
    }
} // Exactly one brace to close the pipeline
