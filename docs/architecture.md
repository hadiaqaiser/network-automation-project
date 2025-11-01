# Architecture

## What happens
1. Terraform creates an EC2 virtual machine on AWS.
2. Ansible installs Docker and runs our container.
3. Docker runs a Node.js web app.
4. GitHub Actions (CI/CD) redeploys automatically when we push new code.

## Diagram (Mermaid)
```mermaid
flowchart LR
  Dev[(Mac)]
  Repo[(GitHub Repo)]
  DockerHub[(Docker Hub)]
  GH[GitHub Actions]
  TF[Terraform]
  EC2[(AWS EC2)]
  User[Browser]

  Dev -- "git push" --> Repo
  Repo -- triggers --> GH
  GH -- build/push image --> DockerHub
  GH -- SSH deploy --> EC2
  TF -- creates --> EC2
  User -- "http://EC2_IP" --> EC2

  subgraph AWS
    EC2
  end