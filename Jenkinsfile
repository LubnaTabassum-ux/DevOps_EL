// Jenkinsfile (Declarative Pipeline)
def appName = "secure-web-app"
def registryUrl = "lubna01" // e.g., "myuser"
def imageName = "${registryUrl}/${appName}:${env.BUILD_NUMBER}"
def scanReport = "trivy-scan-report.json"

pipeline {
    agent any

    environment {
        // Must match the ID of the credentials stored in Jenkins (Docker Hub/Registry)
        DOCKER_CREDS_ID = 'docker-hub-creds'
    }

    stages {
        stage('1. SCM & Checkout') {
            steps {
                // Checkout code from Git (usually handled automatically by SCM trigger)
                checkout scm
            }
        }

        stage('2. Build Optimization') {
            steps {
                script {
                    // *** CRITICAL ERROR POINT FIX ***
                    // Ensure the 'dir' command points to the directory containing the Dockerfile.
                    // If Dockerfile is in the root of the repo, use 'dir('.')' or omit 'dir'.
                    // Use 'docker.build' for Jenkins Docker integration.
                    sh "docker build -t ${imageName} ."
                    echo "Image built: ${imageName}"
                }
            }
        }

        stage('3. Security Scan (The Gate)') {
            steps {
                script {
                    echo "Scanning image: ${imageName} with Trivy..."
                    // --severity CRITICAL,HIGH: Fails for high-severity or critical vulnerabilities
                    // --format json: Outputs a machine-readable report
                    // --exit-code 1: Returns a non-zero exit code if vulnerabilities are found
                    def scanCommand = "trivy image --exit-code 1 --severity CRITICAL,HIGH --format json -o ${scanReport} ${imageName}"

                    // Try/Catch block to gracefully handle the Trivy failure
                    try {
                        sh scanCommand
                        echo "Trivy Scan PASSED! No critical/high vulnerabilities found."
                    } catch (err) {
                        // The build fails here, preventing the push/deployment
                        currentBuild.result = 'FAILURE'
                        echo "Trivy Scan FAILED: High-severity vulnerabilities detected."
                        // Optional: Publish the scan report artifact
                        archiveArtifacts artifacts: scanReport
                        error("Security gate failed. Image push/deployment aborted.")
                    }
                }
            }
        }

        stage('4. Push to Registry') {
            when {
                // Only execute if the previous stage (Security Scan) passed
                expression { return currentBuild.result != 'FAILURE' }
            }
            steps {
                // Uses the defined DOCKER_CREDS_ID to securely push the image
                withCredentials([usernamePassword(credentialsId: env.DOCKER_CREDS_ID, passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                    sh "echo \$DOCKER_PASSWORD | docker login -u \$DOCKER_USERNAME --password-stdin"
                    sh "docker push ${imageName}"
                    sh "docker logout"
                    echo "Image pushed successfully to registry: ${imageName}"
                }
            }
        }

        // --- Phase 2 Stages Start Here ---
        // ... (Continued from Phase 1 Jenkinsfile)

        stage('5. Deployment Trigger (Ansible)') {
            when {
                expression { return currentBuild.result != 'FAILURE' }
            }
            steps {
                script {
                    echo "Triggering Ansible CD for image: ${imageName}"
                    // Set environment variables for the Ansible Playbook to consume
                    withEnv([
                        "IMAGE_TAG=${imageName}",
                        "APP_NAME=${appName}"
                    ]) {
                        // 6. Configuration & Deployment (Ansible)
                        // Use the Ansible command to run the playbook
                        sh "ansible-playbook deployment/playbook.yaml -i localhost,"
                    }
                }
            }
        }

        stage('9. Validation & Cleanup') {
            steps {
                // Final Check (Example: Check the running Pod image)
                sh "kubectl get deployment ${appName}-deployment -o jsonpath='{.spec.template.spec.containers[0].image}'"
                echo "Deployment validation complete. Latest image running: ${imageName}"
                archiveArtifacts artifacts: 'deployment/playbook.yaml'
            }
        }
    }
    post {
        always {
            // Best Practice: Clean up the locally built image after successful push/failure
            sh "docker rmi ${imageName} || true"
        }
    }
}
  
