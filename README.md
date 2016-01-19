# eq-terraform

Terraform project that creates the infrastructure for the EQ project alpha.

## Setting up Terraform

1. Install terraform(terraform.io) and add the binary to your shell path.

2. Ensure that you have signed up for a heroku account and have generated an API
key.

3. Copy `terraform.tfvars.example` to `terraform.tfvars` and replace your heroku
key in the file, adding your email address that you use to login with.

4. Run `terraform plan -var 'env=testdeploy'` to check the output of terraform.

5. Run `terraform apply -var 'env=testdeploy'` to create your infrastructure
environment.