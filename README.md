# Network Systems & Administration CA Project

## What this project does
- Creates an EC2 server in AWS using Terraform (Infrastructure as Code).
- Uses Ansible to install Docker and run a container on that server.
- Uses Docker to run a simple Node.js web app.
- Uses GitHub Actions (CI/CD) to automatically redeploy the container when code changes.

## Folder layout
- `terraform/` → builds the cloud server (AWS EC2, security group, SSH access)
- `ansible/` → configures that server (install docker, run container)
- `app/` → the actual web app + Dockerfile
- `.github/workflows/` → CI/CD pipeline
- `docs/` → architecture diagram + report template

## How to use (high level)
1. Generate SSH keys for AWS and configure AWS CLI.
2. `terraform init` + `terraform apply` to create the EC2 instance.
3. Put the EC2 public IP into `ansible/inventory.ini`.
4. Run `ansible-playbook -i ansible/inventory.ini ansible/playbook.yml` to install Docker and run the app.
5. Go to `http://<your-EC2-ip>/` in a browser.
6. Push new code to `main` branch → GitHub Actions builds a new Docker image and auto-redeploys it.

## Clean up
Use `terraform destroy` to tear everything down so you don’t get billed.