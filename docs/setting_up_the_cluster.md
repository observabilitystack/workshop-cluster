# Setting up the workshop cluster

You should definitely do a test run *before* your workshop. This document
will guide you through the process of running the cluster before, during
and after your workshop.

> 🔥 Make sure to have alternative cloud vendors available in case 
> of unexpected downtime or maintenance!

## Weeks before the workshop

Have accounts and the corresponding __API keys for the cloud services__ ready
you are going to use. Acquire API access tokens and place them as environment
variables on your machine:

* [Hetzner](https://accounts.hetzner.com): `HCLOUD_TOKEN`
* [Digital Ocean](https://cloud.digitalocean.com/): `DIGITALOCEAN_TOKEN` and `DO_AUTH_TOKEN`

__1. Configure the trainers and participants__ in `inventors/group_vars/all/workshop.yml`. Contact the participants prior and collect their SSH  public keys.

```yaml
workshop:
  trainers:
    - name: "Torsten Köster"
      ssh_key: "ssh-rsa AAAAB3..."
    - name: "Nikolaus Winter"
      ssh_key: "ssh-rsa AAAAB3...."
  participants:
    - name: alice
      ssh_key: "ssh-rsa AAAAB3...."
    - name: bob
      ssh_key: "ssh-rsa AAAAB3...."
    - name: charlie
...
```
Adjust the _Terraform_ `instance_count` variable in `variables.tf` according to the workshop participants:

```terraform
variable "instance_count" {
  default = "1"
}
```

__2. Prepare your local machine__ for cluster setup:

```
brew install terraform@0.12 ansible figlet
brew link terraform@0.12 --force
```

__3. Prepare remote shared state__

If you're not the only trainer, it makes sense to share _Terraform_ state via their [free backend
service](https://app.terraform.io). You could use your own backend (e.g. a _Postgres_ database as well). 

![alt](terraform_backend.png)

In order to use the backend, you need to sign up to their service and join (or share) a workspace. Configure access to the backend in your `~/.terraformrc`:

````
credentials "app.terraform.io" {
  token = "..."
}
````

__4. Download the _Terraform_ plugins needed__ to spin up the cloud infrastructure:

    terraform init

## The day before the workshop

Set up the server and certificate infrastructure. The _Terraform_ `plan` task checks what infrastructure items are already existing and which needs to be created. The `apply` task executes the plan.

```
$ terraform plan
...
Plan: 9 to add, 0 to change, 0 to destroy.
$ terraform apply
```

Now a bunch of servers have spun up. They have been assigned random pet names as
hostnames. The corresponding Let's Encrypt TLS certificates are stored in 
`roles/boostrap/tls/files` for direct access out of Ansible. 

Now start provisioning the servers using Ansible. First, a general bootstrap
is applied (base os, users, Docker), then the workshop specific roles are applied:

```
ansible-playbook bootstrap.yml
ansible-playbook workshop.yml
```

![alt](workshop-login.png)

## Workshop day

Assign each participant an individual server. Keys are distributed to all machines, so participants could switch (or share) servers.

```
ansible-playbook server-2-participant.yml
```

If you have some late arrivals, adjust the server count in the _Terraform_ file and re-run the steps above. Only the one additional server will be created and provisioned.

### Terminating misbehaving instances

If any instance is misbehaving, terminate and recreate it.

````
terraform taint <SERVERNAME>
terraform plan
terratorm apply
````

> 🐄 Think cattle not pets!

## The day after the workshop

Shut down the whole infrastructure using _Terraform_:

```
terraform destroy
```
