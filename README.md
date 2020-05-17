# Hetzpuff
Attempts to create Kubernetes cluster out of Hetzner cloud.


## Running 

**Requirements**

Tool       | Version      | Reason                         | Install
---------- | ------------ | ------------------------------ | ------------------------------------------------------------------------------
`docker`   | `~ v19.03.5` | Build container images         | [docker.com](https://docs.docker.com/install/#supported-platforms)
`kubectl`  | `~v1.16` | Interact with the kube api     | [kubernetes.io](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
`terraform` | `~ v0.12.25` | Infrastructure as code platform | [terraform.io](https://www.terraform.io/)
`ssh-agent` | `?` | Save your ssh key   | [ssh-agent](https://linux.die.net/man/1/ssh-agent)


## Instruction

- Make sure everything is installed
- Make an account with Hetzner cloud (https://www.hetzner.com/cloud)
- Make a cloudflare account (https://www.cloudflare.com/)
- Make a file named: `variables.tf` in the `./infra` folder based on `variables-examples.tf.txt`
- Fill the new `variables.tf` with your data or append your `env` with the keys
- Go into `provisioning` folder and run `terraform init`
- Go into `hardening` folder and run `terraform init`
- Make `install-infra.sh` executable
- You might have to make other `.sh` file executable inside the `provisioning` and the `hardening` folder (depends on you setup)
- Run the `install-infra.sh` script. The terraform scripts are executed by `install-infra` one after the other. 


## Cluster 

This project is creating a Kubernetes cluster on Hetzner Cloud and using Cloudflare.
The X nodes talk together using a private VPN. 

This script is also trying to install the latest available kubernetes version.

## Hardening

The first hardening is about securing the VM and not in the Kubernetes cluster.
The script is based on the work of konstruktoid/hardening and the goal is to harden
the VM before hardening the "Kubernetes layer"



## Source

This project is made from other projects. This project
is binding together:

- Kubernetes Creation Script (https://github.com/hobby-kube/provisioning)
- Hardening Scripts (https://github.com/konstruktoid/hardening)