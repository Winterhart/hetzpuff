#!/bin/sh

printf "\n *** Cluster Installation *** \n"

function destroyPrevious() {
    printf "\n Destroy Previous Config Files and Terraform..."
    # Remove files in provisioning
    cd ./provisioning 
    terraform destroy --auto-approve

    rm ./utils/user/resources/IP.json
    touch ./utils/user/resources/IP.json
    cd ..

    # Remove hardening
    cd ./hardening
    rm terraform.tfstate && rm terraform.tfstate.backup
    cd ..
}

function installVariables() {
    printf "\n Install Variables ..."
    rm ./provisioning/variables.tf
    cp variables.tf ./provisioning
    rm ./hardening/variables.tf
    cp variables.tf ./hardening

}

function startProvisioning() {
    printf "\n Start Provisioning Terraform"
    cd ./provisioning
    ssh-add -k ~/.ssh/id_ed25519
    terraform plan -out "plan"
    terraform apply "plan"
    cd ..
}

# Copy the IPs to variables.tf file in /hardening
function transferIPData() {
    printf "\n Save cluster IPs to hardening terraform...\n"
    export tf_ips=""
    export ips=$(cat ./provisioning/utils/user/resources/IP.json) 
    printf "\n IPS : \n"
    echo "$ips"
    for ipLine in $ips
    do
    export ip=$(echo $ipLine | jq .ip)
    tf_ips="${tf_ips},${ip}"
    done

    export final_ips="default=[${tf_ips:1}]"
    echo $final_ips

    printf "\n Writing variables.tf in hardening \n"
    echo "variable "ips" { $final_ips }" >> ./hardening/variables.tf
}

function startHardening() {
    printf "\n Start Hardening Terraform..."
    cd ./hardening
    ssh-add -k ~/.ssh/id_ed25519
    terraform plan -out "plan"
    terraform apply "plan"
    cd ..
}


destroyPrevious;
installVariables;
startProvisioning;
transferIPData;
startHardening;
