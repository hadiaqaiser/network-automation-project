Module: Networks and Systems Administration
Student: Hadia Qaiser
ID: 20069602
Title: Cloud Automation Project
Goal: Build one real cloud automation pipeline using Terraform, Ansible, Docker, Node.js, and AWS Free Tier.

Overview
This project shows how I built a small cloud automation system that can create, configure, and deploy a web application automatically on AWS.
Everything was done on my MacBook Air using free tools — Terraform, Ansible, Docker, Node.js, AWS CLI, and GitHub — under the AWS Free Tier.

The pipeline works like this:
Mac → Terraform → AWS EC2 → Ansible → Docker → Browser

Tools and Purpose
Terraform	Creates AWS EC2 instance, security group, and IAM role.
Ansible	Connects to EC2 and installs Docker + deploys the app container.
Docker + Node.js	Runs the web application inside a lightweight container.
AWS CLI	Helps control EC2 and fetch IP automatically for scripts.
Git + GitHub	Version control and store all the project source code.

Folder Layout
network-automation-project/
├── ansible/        → install docker, deploy container
├── app/            → Node.js + Docker web app (pink theme)
├── terraform/      → create EC2 instance, security group, IAM role
├── docs/           → diagrams and report files
├── start-my-website.sh → one-click script to run everything
└── README.md


Step-by-Step Setup and Commands

1. Generate SSH Key (on Mac)
This key allows Terraform and Ansible to access EC2 securely.
ssh-keygen -t ed25519 -C "student-project-key" -f ~/.ssh/aws-edu-key
ls -l ~/.ssh

2. Configure AWS CLI
Link your AWS account to your Mac terminal.
aws configure
Then enter your:
	•	Access key ID
	•	Secret key
	•	Region: eu-west-1
	•	Output format: json

3. Terraform – Build Infrastructure
Navigate into your Terraform folder:
cd terraform
terraform init
terraform apply -auto-approve
To display what Terraform created:
terraform show
terraform state list

4. Ansible – Configure EC2
After EC2 is created, make sure IP is added to inventory:
cat ansible/inventory.ini
Check connection:
ansible -i ansible/inventory.ini all -m pin
Run playbook to install Docker and deploy container:
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml

5. Docker + Node.js App
The Node app runs inside a container on port 80 → 3000.
To check on EC2:
ssh -i ~/.ssh/aws-edu-key ec2-user@<public-ip>
sudo docker ps
curl -I http://127.0.0.1:3000


6. Helper Scripts (Automation)
start-my-website.sh
This one-click script does everything automatically:
	•	Finds and starts EC2
	•	Copies app files
	•	Builds + runs Docker container
	•	Opens website in browser
cd ~/Desktop/network-automation-project
./start-my-website.sh

7. View the Website
When setup completes:
open http://<public-ip>
You’ll see your pink-themed webpage showing time and random quotes.

8. Verification Commands
Use these to display your work in the presentation:
# Terraform resources
cd terraform
terraform state list
terraform show
# Ansible connectivity
ansible -i ansible/inventory.ini all -m ping
# Docker running status
ssh -i ~/.ssh/aws-edu-key ec2-user@<public-ip>
sudo docker ps
curl -I http://127.0.0.1:3000
# AWS EC2 instance info
aws ec2 describe-instances --query "Reservations[].Instances[].{ID:InstanceId,State:State.Name,PublicIP:PublicIpAddress}" --output table
