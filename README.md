# AWS Infrastructure Automation

An end-to-end cloud automation project that provisions, configures, deploys, and verifies a containerised web service on AWS. It demonstrates practical skills relevant to cloud support, technical operations, systems administration, and technology-associate roles.

## What the project does

- Provisions AWS EC2 infrastructure, security rules, and access configuration with Terraform
- Configures the server and installs required services with Ansible
- Packages and runs a Node.js service in Docker
- Automates deployment and operational checks through a Bash script and AWS CLI
- Verifies connectivity, container status, and application availability
- Documents architecture, deployment steps, and troubleshooting commands

## Technology

- **Cloud:** AWS EC2, IAM, security groups
- **Infrastructure as code:** Terraform
- **Configuration and deployment:** Ansible, Bash, AWS CLI
- **Application runtime:** Docker, Node.js
- **Operations:** Linux, SSH, service verification, troubleshooting, Git

## Workflow

```text
Terraform provisions AWS resources
        ↓
Ansible configures the EC2 server
        ↓
Docker runs the Node.js application
        ↓
Scripts verify deployment and availability
```

## Repository structure

```text
terraform/            AWS infrastructure definitions
ansible/              Inventory and server configuration playbook
app/                  Node.js application and Dockerfile
docs/architecture.md  Technical architecture documentation
start-my-website.sh   Deployment and verification automation
```

Credentials, private keys, Terraform state, and local environment files must not be committed to the repository.
