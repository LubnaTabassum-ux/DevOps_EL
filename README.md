Automated Secure Image Builder
This project implements a production-grade DevSecOps Pipeline that automates the lifecycle of a secure Node.js application, integrating automated building, security auditing, and Infrastructure-as-Code (IaC) deployment.
Architecture Overview
The pipeline ensures that every code change undergoes a rigorous security and validation process before reaching the production cluster.
Key Features
-->Shift-Left Security: Integrated Trivy scanning to identify vulnerabilities before the deployment phase.

-->Multi-Stage Docker Builds: Utilizes Alpine Linux to minimize image size and drastically reduce the security attack surface.

-->Automated Orchestration: Jenkins serves as the central CI/CD controller, managing workflow execution.

-->Infrastructure as Code (IaC): Leverages Ansible and Jinja2 templates for declarative, repeatable Kubernetes management.

-->Zero-Downtime Strategy: Utilizes Kubernetes' native Rolling Updates to ensure the application remains available during new version rollouts.
Technology Stack
Layer                  Technology
CI/CD Orchestrator     Jenkins
Containerization       Docker
Security Scanner       Trivy
Image Registry         Docker Hub
Config Management      Ansible
Container Orchestrator Kubernetes (Minikube)

Pipeline Stages (The Workflow)
1. SCM Checkout: Pulls the latest source code from the GitHub repository.
2. Build Optimization: Builds a versioned Docker image using a multi-stage Dockerfile to separate build-time and run-time environments.
3. Vulnerability Scanning: Executes Trivy to audit the image for HIGH and CRITICAL vulnerabilities; results are archived as JSON artifacts.
4. Push to Registry: Authenticates with Docker Hub using encrypted credentials and pushes the verified image.
5. Ansible Deployment:
     -->Templating: Renders Kubernetes manifests dynamically using Jinja2 (deployment.yaml.j2).
     -->Authentication: Connects via a standalone "flattened" Kubeconfig for secure access.
     -->Desired State: Deploys 2 replicas of the app in the default namespace.
6. Validation: Runs kubectl checks to verify pod health and service availability.
