pipeline {
    agent any

    environment {
        DOCKER_CREDS_ID = 'docker-hub-creds'
        APP_NAME = 'secure-web-app'
        REGISTRY_USER = 'your-dockerhub-username' // CHANGE THIS
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Optimization') {
            steps {
                sh "docker build -t ${REGISTRY_USER}/${APP_NAME}:${env.BUILD_NUMBER} ."
            }
        }

        stage('Security Scan') {
            steps {
                sh "trivy image --exit-code 1 --severity CRITICAL,HIGH ${REGISTRY_USER}/${APP_NAME}:${env.BUILD_NUMBER}"
            }
        }

        stage('Push to Registry') {
            steps {
                withCredentials([usernamePassword(credentialsId: env.DOCKER_CREDS_ID, passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                    sh "echo \$PASS | docker login -u \$USER --password-stdin"
                    sh "docker push ${REGISTRY_USER}/${APP_NAME}:${env.BUILD_NUMBER}"
                }
            }
        }

        stage('Ansible Deploy') {
            steps {
                sh "ansible-playbook deployment/playbook.yaml -e 'image_tag=${REGISTRY_USER}/${APP_NAME}:${env.BUILD_NUMBER}'"
            }
        }
    }
    
    post {
        always {
            sh "docker logout || true"
        }
    }
}
