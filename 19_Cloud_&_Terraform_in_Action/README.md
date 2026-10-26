# 19

> Run against real AWS (account 737272117751). Terraform labs pin `ap-south-1`, so the CLI checks were pointed at that region too. Every resource applied was destroyed at the end of its lab.

## 01-cloud-service-models

Theory only (IaaS / PaaS / SaaS), no commands to run.

## 02-regions-and-availability-zones

```bash
…/session19-cloud-terraform/02-regions-and-availability-zones ❯ aws configure get region
ap-south-2

…/session19-cloud-terraform/02-regions-and-availability-zones ❯ aws sts get-caller-identity
{
    "UserId": "AIDA2XKGXXH3S2WPZRX4M",
    "Account": "737272117751",
    "Arn": "arn:aws:iam::737272117751:user/adminbaby"
}

…/session19-cloud-terraform/02-regions-and-availability-zones ❯ aws ec2 describe-regions --region ap-south-1 --query 'Regions[].RegionName' --output table
--------------------
|  DescribeRegions |
+------------------+
|  ap-south-2      |
|  ap-south-1      |
|  eu-north-1      |
|  eu-west-3       |
|  eu-west-2       |
|  eu-west-1       |
|  ap-northeast-3  |
|  ap-northeast-2  |
|  ap-northeast-1  |
|  ca-central-1    |
|  sa-east-1       |
|  ap-southeast-1  |
|  ap-southeast-2  |
|  eu-central-1    |
|  us-east-1       |
|  us-east-2       |
|  us-west-1       |
|  us-west-2       |
+------------------+

…/session19-cloud-terraform/02-regions-and-availability-zones ❯ aws ec2 describe-availability-zones --region ap-south-1 --query 'AvailabilityZones[].{Zone:ZoneName,Id:ZoneId,State:State}' --output table
------------------------------------------
|        DescribeAvailabilityZones       |
+----------+-------------+---------------+
|    Id    |    State    |     Zone      |
+----------+-------------+---------------+
|  aps1-az1|  available  |  ap-south-1a  |
|  aps1-az3|  available  |  ap-south-1b  |
|  aps1-az2|  available  |  ap-south-1c  |
+----------+-------------+---------------+
```

## 03-vpc-and-subnets

Only the default VPC exists before the mini project runs.

```bash
…/session19-cloud-terraform/03-vpc-and-subnets ❯ aws ec2 describe-vpcs --region ap-south-1 --query 'Vpcs[].{VpcId:VpcId,Cidr:CidrBlock,State:State}'
[
    {
        "VpcId": "vpc-0fda1ba592d26333a",
        "Cidr": "172.31.0.0/16",
        "State": "available"
    }
]

…/session19-cloud-terraform/03-vpc-and-subnets ❯ aws ec2 describe-subnets --region ap-south-1 --query 'Subnets[].{SubnetId:SubnetId,Cidr:CidrBlock,AZ:AvailabilityZone}'
[
    {
        "SubnetId": "subnet-02bd1f6649d9df230",
        "Cidr": "172.31.0.0/20",
        "AZ": "ap-south-1b"
    },
    {
        "SubnetId": "subnet-0a59ce9a92cb230bc",
        "Cidr": "172.31.16.0/20",
        "AZ": "ap-south-1c"
    },
    {
        "SubnetId": "subnet-0e44fd05c486c712d",
        "Cidr": "172.31.32.0/20",
        "AZ": "ap-south-1a"
    }
]
```

## 04-route-tables-and-internet-gateway

```bash
…/session19-cloud-terraform/04-route-tables-and-internet-gateway ❯ aws ec2 describe-route-tables --region ap-south-1 --query 'RouteTables[].Routes[]'
[
    {
        "DestinationCidrBlock": "172.31.0.0/16",
        "GatewayId": "local",
        "Origin": "CreateRouteTable",
        "State": "active"
    },
    {
        "DestinationCidrBlock": "0.0.0.0/0",
        "GatewayId": "igw-0defc15e254e08c08",
        "Origin": "CreateRoute",
        "State": "active"
    }
]
```

## 05-security-groups

```bash
…/session19-cloud-terraform/05-security-groups ❯ aws ec2 describe-security-groups --region ap-south-1 --query 'SecurityGroups[].{GroupId:GroupId,Name:GroupName,VpcId:VpcId}'
[
    {
        "GroupId": "sg-0891ea94700958d68",
        "Name": "default",
        "VpcId": "vpc-0fda1ba592d26333a"
    }
]
```

## 06-terraform-vpc

06-terraform-vpc: see ../Terraform_2/README.md

## 07-terraform-workflow

```bash
…/session19-cloud-terraform/07-terraform-workflow ❯ terraform init
Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 6.0"...
- Installing hashicorp/aws v6.70.0...
- Installed hashicorp/aws v6.70.0 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.

…/session19-cloud-terraform/07-terraform-workflow ❯ terraform fmt

…/session19-cloud-terraform/07-terraform-workflow ❯ terraform validate
Success! The configuration is valid.

…/session19-cloud-terraform/07-terraform-workflow ❯ terraform plan

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket.workflow_demo will be created
  + resource "aws_s3_bucket" "workflow_demo" {
      + acceleration_status         = (known after apply)
      + acl                         = (known after apply)
      + arn                         = (known after apply)
      + bucket                      = (known after apply)
      + bucket_domain_name          = (known after apply)
      + bucket_namespace            = (known after apply)
      + bucket_prefix               = "session19-workflow-"
      + bucket_region               = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + object_lock_enabled         = (known after apply)
      + policy                      = (known after apply)
      + region                      = "ap-south-1"
      + request_payer               = (known after apply)
      + tags                        = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "Session 19 Workflow Demo"
        }
      + tags_all                    = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "Session 19 Workflow Demo"
        }
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + cors_rule (known after apply)

      + grant (known after apply)

      + lifecycle_rule (known after apply)

      + logging (known after apply)

      + object_lock_configuration (known after apply)

      + replication_configuration (known after apply)

      + server_side_encryption_configuration (known after apply)

      + versioning (known after apply)

      + website (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + bucket_name = (known after apply)

─────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't
guarantee to take exactly these actions if you run "terraform apply" now.

…/session19-cloud-terraform/07-terraform-workflow ❯ terraform apply -auto-approve

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket.workflow_demo will be created
  + resource "aws_s3_bucket" "workflow_demo" {
      + acceleration_status         = (known after apply)
      + acl                         = (known after apply)
      + arn                         = (known after apply)
      + bucket                      = (known after apply)
      + bucket_domain_name          = (known after apply)
      + bucket_namespace            = (known after apply)
      + bucket_prefix               = "session19-workflow-"
      + bucket_region               = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + object_lock_enabled         = (known after apply)
      + policy                      = (known after apply)
      + region                      = "ap-south-1"
      + request_payer               = (known after apply)
      + tags                        = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "Session 19 Workflow Demo"
        }
      + tags_all                    = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "Session 19 Workflow Demo"
        }
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + cors_rule (known after apply)

      + grant (known after apply)

      + lifecycle_rule (known after apply)

      + logging (known after apply)

      + object_lock_configuration (known after apply)

      + replication_configuration (known after apply)

      + server_side_encryption_configuration (known after apply)

      + versioning (known after apply)

      + website (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + bucket_name = (known after apply)
aws_s3_bucket.workflow_demo: Creating...
aws_s3_bucket.workflow_demo: Creation complete after 2s [id=session19-workflow-f55b054a3405aa7442f4c8fcfd]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

bucket_name = "session19-workflow-f55b054a3405aa7442f4c8fcfd"

…/session19-cloud-terraform/07-terraform-workflow ❯ terraform output
bucket_name = "session19-workflow-f55b054a3405aa7442f4c8fcfd"

…/session19-cloud-terraform/07-terraform-workflow ❯ terraform state list
aws_s3_bucket.workflow_demo

…/session19-cloud-terraform/07-terraform-workflow ❯ terraform destroy -auto-approve
aws_s3_bucket.workflow_demo: Refreshing state... [id=session19-workflow-f55b054a3405aa7442f4c8fcfd]

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_s3_bucket.workflow_demo will be destroyed
  - resource "aws_s3_bucket" "workflow_demo" {
      - arn                         = "arn:aws:s3:::session19-workflow-f55b054a3405aa7442f4c8fcfd" -> null
      - bucket                      = "session19-workflow-f55b054a3405aa7442f4c8fcfd" -> null
      - bucket_domain_name          = "session19-workflow-f55b054a3405aa7442f4c8fcfd.s3.amazonaws.com" -> null
      - bucket_namespace            = "global" -> null
      - bucket_prefix               = "session19-workflow-" -> null
      - bucket_region               = "ap-south-1" -> null
      - bucket_regional_domain_name = "session19-workflow-f55b054a3405aa7442f4c8fcfd.s3.ap-south-1.amazonaws.com" -> null
      - force_destroy               = false -> null
      - hosted_zone_id              = "Z11RGJOFQNVJUP" -> null
      - id                          = "session19-workflow-f55b054a3405aa7442f4c8fcfd" -> null
      - object_lock_enabled         = false -> null
      - region                      = "ap-south-1" -> null
      - request_payer               = "BucketOwner" -> null
      - tags                        = {
          - "ManagedBy" = "Terraform"
          - "Name"      = "Session 19 Workflow Demo"
        } -> null
      - tags_all                    = {
          - "ManagedBy" = "Terraform"
          - "Name"      = "Session 19 Workflow Demo"
        } -> null
        # (2 unchanged attributes hidden)

      - grant {
          - id          = "507ae2b27373b77452159d69d3bea777f8b62e2dba81329ce0bc11ec7560f624" -> null
          - permissions = [
              - "FULL_CONTROL",
            ] -> null
          - type        = "CanonicalUser" -> null
            # (1 unchanged attribute hidden)
        }

      - server_side_encryption_configuration {
          - rule {
              - bucket_key_enabled = false -> null

              - apply_server_side_encryption_by_default {
                  - sse_algorithm     = "AES256" -> null
                    # (1 unchanged attribute hidden)
                }
            }
        }

      - versioning {
          - enabled    = false -> null
          - mfa_delete = false -> null
        }
    }

Plan: 0 to add, 0 to change, 1 to destroy.

Changes to Outputs:
  - bucket_name = "session19-workflow-f55b054a3405aa7442f4c8fcfd" -> null
aws_s3_bucket.workflow_demo: Destroying... [id=session19-workflow-f55b054a3405aa7442f4c8fcfd]
aws_s3_bucket.workflow_demo: Destruction complete after 1s

Destroy complete! Resources: 1 destroyed.
```

## 08-mini-project

The optional EC2 extension was skipped (no compute resources created).

```bash
…/session19-cloud-terraform/08-mini-project ❯ cp terraform.tfvars.example terraform.tfvars

…/session19-cloud-terraform/08-mini-project ❯ terraform init
Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 6.0"...
- Installing hashicorp/aws v6.70.0...
- Installed hashicorp/aws v6.70.0 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.

…/session19-cloud-terraform/08-mini-project ❯ terraform fmt
main.tf

…/session19-cloud-terraform/08-mini-project ❯ terraform validate
Success! The configuration is valid.

…/session19-cloud-terraform/08-mini-project ❯ terraform plan

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_internet_gateway.main will be created
  + resource "aws_internet_gateway" "main" {
      + arn      = (known after apply)
      + id       = (known after apply)
      + owner_id = (known after apply)
      + region   = "ap-south-1"
      + tags     = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "session19-mini-igw"
          + "Session"   = "19"
        }
      + tags_all = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "session19-mini-igw"
          + "Session"   = "19"
        }
      + vpc_id   = (known after apply)
    }

  # aws_route_table.public will be created
  + resource "aws_route_table" "public" {
      + arn              = (known after apply)
      + id               = (known after apply)
      + owner_id         = (known after apply)
      + propagating_vgws = (known after apply)
      + region           = "ap-south-1"
      + route            = [
          + {
              + cidr_block                 = "0.0.0.0/0"
              + gateway_id                 = (known after apply)
                # (12 unchanged attributes hidden)
            },
        ]
      + tags             = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "session19-mini-public-rt"
          + "Session"   = "19"
        }
      + tags_all         = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "session19-mini-public-rt"
          + "Session"   = "19"
        }
      + vpc_id           = (known after apply)
    }

  # aws_route_table_association.public will be created
  + resource "aws_route_table_association" "public" {
      + id             = (known after apply)
      + region         = "ap-south-1"
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # aws_security_group.web will be created
  + resource "aws_security_group" "web" {
      + arn                    = (known after apply)
      + description            = "Allow HTTP and HTTPS for Session 19"
      + egress                 = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = "Allow outbound IPv4"
              + from_port        = 0
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "-1"
              + security_groups  = []
              + self             = false
              + to_port          = 0
            },
        ]
      + id                     = (known after apply)
      + ingress                = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = "HTTP"
              + from_port        = 80
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 80
            },
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = "HTTPS"
              + from_port        = 443
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 443
            },
        ]
      + name                   = "session19-mini-web-sg"
      + name_prefix            = (known after apply)
      + owner_id               = (known after apply)
      + region                 = "ap-south-1"
      + revoke_rules_on_delete = false
      + tags                   = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "session19-mini-web-sg"
          + "Session"   = "19"
        }
      + tags_all               = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "session19-mini-web-sg"
          + "Session"   = "19"
        }
      + vpc_id                 = (known after apply)
    }

  # aws_subnet.public will be created
  + resource "aws_subnet" "public" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "ap-south-1a"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.20.1.0/24"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block                                = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = true
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + region                                         = "ap-south-1"
      + tags                                           = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "session19-mini-public-subnet"
          + "Session"   = "19"
        }
      + tags_all                                       = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "session19-mini-public-subnet"
          + "Session"   = "19"
        }
      + vpc_id                                         = (known after apply)
    }

  # aws_vpc.main will be created
  + resource "aws_vpc" "main" {
      + arn                                  = (known after apply)
      + cidr_block                           = "10.20.0.0/16"
      + default_network_acl_id               = (known after apply)
      + default_route_table_id               = (known after apply)
      + default_security_group_id            = (known after apply)
      + dhcp_options_id                      = (known after apply)
      + enable_dns_hostnames                 = true
      + enable_dns_support                   = true
      + enable_network_address_usage_metrics = (known after apply)
      + id                                   = (known after apply)
      + instance_tenancy                     = "default"
      + ipv6_association_id                  = (known after apply)
      + ipv6_cidr_block                      = (known after apply)
      + ipv6_cidr_block_network_border_group = (known after apply)
      + main_route_table_id                  = (known after apply)
      + owner_id                             = (known after apply)
      + region                               = "ap-south-1"
      + tags                                 = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "session19-mini-vpc"
          + "Session"   = "19"
        }
      + tags_all                             = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "session19-mini-vpc"
          + "Session"   = "19"
        }
    }

Plan: 6 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + security_group_id = (known after apply)
  + subnet_id         = (known after apply)
  + vpc_cidr          = "10.20.0.0/16"
  + vpc_id            = (known after apply)

─────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't
guarantee to take exactly these actions if you run "terraform apply" now.

…/session19-cloud-terraform/08-mini-project ❯ terraform apply -auto-approve

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_internet_gateway.main will be created
  + resource "aws_internet_gateway" "main" {
      + arn      = (known after apply)
      + id       = (known after apply)
      + owner_id = (known after apply)
      + region   = "ap-south-1"
      + tags     = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "session19-mini-igw"
          + "Session"   = "19"
        }
      + tags_all = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "session19-mini-igw"
          + "Session"   = "19"
        }
      + vpc_id   = (known after apply)
    }

  # aws_route_table.public will be created
  + resource "aws_route_table" "public" {
      + arn              = (known after apply)
      + id               = (known after apply)
      + owner_id         = (known after apply)
      + propagating_vgws = (known after apply)
      + region           = "ap-south-1"
      + route            = [
          + {
              + cidr_block                 = "0.0.0.0/0"
              + gateway_id                 = (known after apply)
                # (12 unchanged attributes hidden)
            },
        ]
      + tags             = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "session19-mini-public-rt"
          + "Session"   = "19"
        }
      + tags_all         = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "session19-mini-public-rt"
          + "Session"   = "19"
        }
      + vpc_id           = (known after apply)
    }

  # aws_route_table_association.public will be created
  + resource "aws_route_table_association" "public" {
      + id             = (known after apply)
      + region         = "ap-south-1"
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # aws_security_group.web will be created
  + resource "aws_security_group" "web" {
      + arn                    = (known after apply)
      + description            = "Allow HTTP and HTTPS for Session 19"
      + egress                 = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = "Allow outbound IPv4"
              + from_port        = 0
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "-1"
              + security_groups  = []
              + self             = false
              + to_port          = 0
            },
        ]
      + id                     = (known after apply)
      + ingress                = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = "HTTP"
              + from_port        = 80
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 80
            },
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = "HTTPS"
              + from_port        = 443
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 443
            },
        ]
      + name                   = "session19-mini-web-sg"
      + name_prefix            = (known after apply)
      + owner_id               = (known after apply)
      + region                 = "ap-south-1"
      + revoke_rules_on_delete = false
      + tags                   = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "session19-mini-web-sg"
          + "Session"   = "19"
        }
      + tags_all               = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "session19-mini-web-sg"
          + "Session"   = "19"
        }
      + vpc_id                 = (known after apply)
    }

  # aws_subnet.public will be created
  + resource "aws_subnet" "public" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "ap-south-1a"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.20.1.0/24"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block                                = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = true
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + region                                         = "ap-south-1"
      + tags                                           = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "session19-mini-public-subnet"
          + "Session"   = "19"
        }
      + tags_all                                       = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "session19-mini-public-subnet"
          + "Session"   = "19"
        }
      + vpc_id                                         = (known after apply)
    }

  # aws_vpc.main will be created
  + resource "aws_vpc" "main" {
      + arn                                  = (known after apply)
      + cidr_block                           = "10.20.0.0/16"
      + default_network_acl_id               = (known after apply)
      + default_route_table_id               = (known after apply)
      + default_security_group_id            = (known after apply)
      + dhcp_options_id                      = (known after apply)
      + enable_dns_hostnames                 = true
      + enable_dns_support                   = true
      + enable_network_address_usage_metrics = (known after apply)
      + id                                   = (known after apply)
      + instance_tenancy                     = "default"
      + ipv6_association_id                  = (known after apply)
      + ipv6_cidr_block                      = (known after apply)
      + ipv6_cidr_block_network_border_group = (known after apply)
      + main_route_table_id                  = (known after apply)
      + owner_id                             = (known after apply)
      + region                               = "ap-south-1"
      + tags                                 = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "session19-mini-vpc"
          + "Session"   = "19"
        }
      + tags_all                             = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "session19-mini-vpc"
          + "Session"   = "19"
        }
    }

Plan: 6 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + security_group_id = (known after apply)
  + subnet_id         = (known after apply)
  + vpc_cidr          = "10.20.0.0/16"
  + vpc_id            = (known after apply)
aws_vpc.main: Creating...
aws_vpc.main: Creation complete after 3s [id=vpc-0ee894adce95f254d]
aws_subnet.public: Creating...
aws_internet_gateway.main: Creating...
aws_security_group.web: Creating...
aws_internet_gateway.main: Creation complete after 1s [id=igw-0b58eb50821abd751]
aws_route_table.public: Creating...
aws_route_table.public: Creation complete after 1s [id=rtb-0192cb929600205a6]
aws_security_group.web: Creation complete after 3s [id=sg-0e8b8a71898c962c5]
aws_subnet.public: Still creating... [00m10s elapsed]
aws_subnet.public: Creation complete after 11s [id=subnet-051df322b5616e815]
aws_route_table_association.public: Creating...
aws_route_table_association.public: Creation complete after 0s [id=rtbassoc-087b534d9352e7ea7]

Apply complete! Resources: 6 added, 0 changed, 0 destroyed.

Outputs:

security_group_id = "sg-0e8b8a71898c962c5"
subnet_id = "subnet-051df322b5616e815"
vpc_cidr = "10.20.0.0/16"
vpc_id = "vpc-0ee894adce95f254d"

…/session19-cloud-terraform/08-mini-project ❯ terraform output
security_group_id = "sg-0e8b8a71898c962c5"
subnet_id = "subnet-051df322b5616e815"
vpc_cidr = "10.20.0.0/16"
vpc_id = "vpc-0ee894adce95f254d"

…/session19-cloud-terraform/08-mini-project ❯ terraform state list
aws_internet_gateway.main
aws_route_table.public
aws_route_table_association.public
aws_security_group.web
aws_subnet.public
aws_vpc.main

…/session19-cloud-terraform/08-mini-project ❯ aws ec2 describe-vpcs --region ap-south-1 --filters "Name=tag:Name,Values=session19-mini-vpc" --query 'Vpcs[].{VpcId:VpcId,Cidr:CidrBlock,State:State}'
[
    {
        "VpcId": "vpc-0ee894adce95f254d",
        "Cidr": "10.20.0.0/16",
        "State": "available"
    }
]

…/session19-cloud-terraform/08-mini-project ❯ aws ec2 describe-subnets --region ap-south-1 --filters "Name=tag:Name,Values=session19-mini-public-subnet" --query 'Subnets[].{SubnetId:SubnetId,Cidr:CidrBlock,AZ:AvailabilityZone}'
[
    {
        "SubnetId": "subnet-051df322b5616e815",
        "Cidr": "10.20.1.0/24",
        "AZ": "ap-south-1a"
    }
]

…/session19-cloud-terraform/08-mini-project ❯ aws ec2 describe-route-tables --region ap-south-1 --filters "Name=tag:Name,Values=session19-mini-public-rt" --query 'RouteTables[].{RouteTableId:RouteTableId,VpcId:VpcId}'
[
    {
        "RouteTableId": "rtb-0192cb929600205a6",
        "VpcId": "vpc-0ee894adce95f254d"
    }
]

…/session19-cloud-terraform/08-mini-project ❯ aws ec2 describe-security-groups --region ap-south-1 --filters "Name=group-name,Values=session19-mini-web-sg" --query 'SecurityGroups[].{GroupId:GroupId,VpcId:VpcId}'
[
    {
        "GroupId": "sg-0e8b8a71898c962c5",
        "VpcId": "vpc-0ee894adce95f254d"
    }
]

…/session19-cloud-terraform/08-mini-project ❯ terraform plan -destroy
aws_vpc.main: Refreshing state... [id=vpc-0ee894adce95f254d]
aws_internet_gateway.main: Refreshing state... [id=igw-0b58eb50821abd751]
aws_subnet.public: Refreshing state... [id=subnet-051df322b5616e815]
aws_security_group.web: Refreshing state... [id=sg-0e8b8a71898c962c5]
aws_route_table.public: Refreshing state... [id=rtb-0192cb929600205a6]
aws_route_table_association.public: Refreshing state... [id=rtbassoc-087b534d9352e7ea7]

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_internet_gateway.main will be destroyed
  - resource "aws_internet_gateway" "main" {
      - arn      = "arn:aws:ec2:ap-south-1:737272117751:internet-gateway/igw-0b58eb50821abd751" -> null
      - id       = "igw-0b58eb50821abd751" -> null
      - owner_id = "737272117751" -> null
      - region   = "ap-south-1" -> null
      - tags     = {
          - "ManagedBy" = "Terraform"
          - "Name"      = "session19-mini-igw"
          - "Session"   = "19"
        } -> null
      - tags_all = {
          - "ManagedBy" = "Terraform"
          - "Name"      = "session19-mini-igw"
          - "Session"   = "19"
        } -> null
      - vpc_id   = "vpc-0ee894adce95f254d" -> null
    }

  # aws_route_table.public will be destroyed
  - resource "aws_route_table" "public" {
      - arn              = "arn:aws:ec2:ap-south-1:737272117751:route-table/rtb-0192cb929600205a6" -> null
      - id               = "rtb-0192cb929600205a6" -> null
      - owner_id         = "737272117751" -> null
      - propagating_vgws = [] -> null
      - region           = "ap-south-1" -> null
      - route            = [
          - {
              - cidr_block                 = "0.0.0.0/0"
              - gateway_id                 = "igw-0b58eb50821abd751"
                # (12 unchanged attributes hidden)
            },
        ] -> null
      - tags             = {
          - "ManagedBy" = "Terraform"
          - "Name"      = "session19-mini-public-rt"
          - "Session"   = "19"
        } -> null
      - tags_all         = {
          - "ManagedBy" = "Terraform"
          - "Name"      = "session19-mini-public-rt"
          - "Session"   = "19"
        } -> null
      - vpc_id           = "vpc-0ee894adce95f254d" -> null
    }

  # aws_route_table_association.public will be destroyed
  - resource "aws_route_table_association" "public" {
      - id             = "rtbassoc-087b534d9352e7ea7" -> null
      - region         = "ap-south-1" -> null
      - route_table_id = "rtb-0192cb929600205a6" -> null
      - subnet_id      = "subnet-051df322b5616e815" -> null
        # (1 unchanged attribute hidden)
    }

  # aws_security_group.web will be destroyed
  - resource "aws_security_group" "web" {
      - arn                    = "arn:aws:ec2:ap-south-1:737272117751:security-group/sg-0e8b8a71898c962c5" -> null
      - description            = "Allow HTTP and HTTPS for Session 19" -> null
      - egress                 = [
          - {
              - cidr_blocks      = [
                  - "0.0.0.0/0",
                ]
              - description      = "Allow outbound IPv4"
              - from_port        = 0
              - ipv6_cidr_blocks = []
              - prefix_list_ids  = []
              - protocol         = "-1"
              - security_groups  = []
              - self             = false
              - to_port          = 0
            },
        ] -> null
      - id                     = "sg-0e8b8a71898c962c5" -> null
      - ingress                = [
          - {
              - cidr_blocks      = [
                  - "0.0.0.0/0",
                ]
              - description      = "HTTP"
              - from_port        = 80
              - ipv6_cidr_blocks = []
              - prefix_list_ids  = []
              - protocol         = "tcp"
              - security_groups  = []
              - self             = false
              - to_port          = 80
            },
          - {
              - cidr_blocks      = [
                  - "0.0.0.0/0",
                ]
              - description      = "HTTPS"
              - from_port        = 443
              - ipv6_cidr_blocks = []
              - prefix_list_ids  = []
              - protocol         = "tcp"
              - security_groups  = []
              - self             = false
              - to_port          = 443
            },
        ] -> null
      - name                   = "session19-mini-web-sg" -> null
      - owner_id               = "737272117751" -> null
      - region                 = "ap-south-1" -> null
      - revoke_rules_on_delete = false -> null
      - tags                   = {
          - "ManagedBy" = "Terraform"
          - "Name"      = "session19-mini-web-sg"
          - "Session"   = "19"
        } -> null
      - tags_all               = {
          - "ManagedBy" = "Terraform"
          - "Name"      = "session19-mini-web-sg"
          - "Session"   = "19"
        } -> null
      - vpc_id                 = "vpc-0ee894adce95f254d" -> null
        # (1 unchanged attribute hidden)
    }

  # aws_subnet.public will be destroyed
  - resource "aws_subnet" "public" {
      - arn                                            = "arn:aws:ec2:ap-south-1:737272117751:subnet/subnet-051df322b5616e815" -> null
      - assign_ipv6_address_on_creation                = false -> null
      - availability_zone                              = "ap-south-1a" -> null
      - availability_zone_id                           = "aps1-az1" -> null
      - cidr_block                                     = "10.20.1.0/24" -> null
      - enable_dns64                                   = false -> null
      - enable_lni_at_device_index                     = 0 -> null
      - enable_resource_name_dns_a_record_on_launch    = false -> null
      - enable_resource_name_dns_aaaa_record_on_launch = false -> null
      - id                                             = "subnet-051df322b5616e815" -> null
      - ipv6_native                                    = false -> null
      - map_customer_owned_ip_on_launch                = false -> null
      - map_public_ip_on_launch                        = true -> null
      - owner_id                                       = "737272117751" -> null
      - private_dns_hostname_type_on_launch            = "ip-name" -> null
      - region                                         = "ap-south-1" -> null
      - tags                                           = {
          - "ManagedBy" = "Terraform"
          - "Name"      = "session19-mini-public-subnet"
          - "Session"   = "19"
        } -> null
      - tags_all                                       = {
          - "ManagedBy" = "Terraform"
          - "Name"      = "session19-mini-public-subnet"
          - "Session"   = "19"
        } -> null
      - vpc_id                                         = "vpc-0ee894adce95f254d" -> null
        # (4 unchanged attributes hidden)
    }

  # aws_vpc.main will be destroyed
  - resource "aws_vpc" "main" {
      - arn                                  = "arn:aws:ec2:ap-south-1:737272117751:vpc/vpc-0ee894adce95f254d" -> null
      - assign_generated_ipv6_cidr_block     = false -> null
      - cidr_block                           = "10.20.0.0/16" -> null
      - default_network_acl_id               = "acl-05001605012df8d89" -> null
      - default_route_table_id               = "rtb-0849a03e0613af043" -> null
      - default_security_group_id            = "sg-0faf6a0ab8ee0d4dc" -> null
      - dhcp_options_id                      = "dopt-0e03335f5c206a677" -> null
      - enable_dns_hostnames                 = true -> null
      - enable_dns_support                   = true -> null
      - enable_network_address_usage_metrics = false -> null
      - id                                   = "vpc-0ee894adce95f254d" -> null
      - instance_tenancy                     = "default" -> null
      - ipv6_netmask_length                  = 0 -> null
      - main_route_table_id                  = "rtb-0849a03e0613af043" -> null
      - owner_id                             = "737272117751" -> null
      - region                               = "ap-south-1" -> null
      - tags                                 = {
          - "ManagedBy" = "Terraform"
          - "Name"      = "session19-mini-vpc"
          - "Session"   = "19"
        } -> null
      - tags_all                             = {
          - "ManagedBy" = "Terraform"
          - "Name"      = "session19-mini-vpc"
          - "Session"   = "19"
        } -> null
        # (4 unchanged attributes hidden)
    }

Plan: 0 to add, 0 to change, 6 to destroy.

Changes to Outputs:
  - security_group_id = "sg-0e8b8a71898c962c5" -> null
  - subnet_id         = "subnet-051df322b5616e815" -> null
  - vpc_cidr          = "10.20.0.0/16" -> null
  - vpc_id            = "vpc-0ee894adce95f254d" -> null

─────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't
guarantee to take exactly these actions if you run "terraform apply" now.

…/session19-cloud-terraform/08-mini-project ❯ terraform destroy -auto-approve
aws_vpc.main: Refreshing state... [id=vpc-0ee894adce95f254d]
aws_internet_gateway.main: Refreshing state... [id=igw-0b58eb50821abd751]
aws_subnet.public: Refreshing state... [id=subnet-051df322b5616e815]
aws_security_group.web: Refreshing state... [id=sg-0e8b8a71898c962c5]
aws_route_table.public: Refreshing state... [id=rtb-0192cb929600205a6]
aws_route_table_association.public: Refreshing state... [id=rtbassoc-087b534d9352e7ea7]

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_internet_gateway.main will be destroyed
  - resource "aws_internet_gateway" "main" {
      - arn      = "arn:aws:ec2:ap-south-1:737272117751:internet-gateway/igw-0b58eb50821abd751" -> null
      - id       = "igw-0b58eb50821abd751" -> null
      - owner_id = "737272117751" -> null
      - region   = "ap-south-1" -> null
      - tags     = {
          - "ManagedBy" = "Terraform"
          - "Name"      = "session19-mini-igw"
          - "Session"   = "19"
        } -> null
      - tags_all = {
          - "ManagedBy" = "Terraform"
          - "Name"      = "session19-mini-igw"
          - "Session"   = "19"
        } -> null
      - vpc_id   = "vpc-0ee894adce95f254d" -> null
    }

  # aws_route_table.public will be destroyed
  - resource "aws_route_table" "public" {
      - arn              = "arn:aws:ec2:ap-south-1:737272117751:route-table/rtb-0192cb929600205a6" -> null
      - id               = "rtb-0192cb929600205a6" -> null
      - owner_id         = "737272117751" -> null
      - propagating_vgws = [] -> null
      - region           = "ap-south-1" -> null
      - route            = [
          - {
              - cidr_block                 = "0.0.0.0/0"
              - gateway_id                 = "igw-0b58eb50821abd751"
                # (12 unchanged attributes hidden)
            },
        ] -> null
      - tags             = {
          - "ManagedBy" = "Terraform"
          - "Name"      = "session19-mini-public-rt"
          - "Session"   = "19"
        } -> null
      - tags_all         = {
          - "ManagedBy" = "Terraform"
          - "Name"      = "session19-mini-public-rt"
          - "Session"   = "19"
        } -> null
      - vpc_id           = "vpc-0ee894adce95f254d" -> null
    }

  # aws_route_table_association.public will be destroyed
  - resource "aws_route_table_association" "public" {
      - id             = "rtbassoc-087b534d9352e7ea7" -> null
      - region         = "ap-south-1" -> null
      - route_table_id = "rtb-0192cb929600205a6" -> null
      - subnet_id      = "subnet-051df322b5616e815" -> null
        # (1 unchanged attribute hidden)
    }

  # aws_security_group.web will be destroyed
  - resource "aws_security_group" "web" {
      - arn                    = "arn:aws:ec2:ap-south-1:737272117751:security-group/sg-0e8b8a71898c962c5" -> null
      - description            = "Allow HTTP and HTTPS for Session 19" -> null
      - egress                 = [
          - {
              - cidr_blocks      = [
                  - "0.0.0.0/0",
                ]
              - description      = "Allow outbound IPv4"
              - from_port        = 0
              - ipv6_cidr_blocks = []
              - prefix_list_ids  = []
              - protocol         = "-1"
              - security_groups  = []
              - self             = false
              - to_port          = 0
            },
        ] -> null
      - id                     = "sg-0e8b8a71898c962c5" -> null
      - ingress                = [
          - {
              - cidr_blocks      = [
                  - "0.0.0.0/0",
                ]
              - description      = "HTTP"
              - from_port        = 80
              - ipv6_cidr_blocks = []
              - prefix_list_ids  = []
              - protocol         = "tcp"
              - security_groups  = []
              - self             = false
              - to_port          = 80
            },
          - {
              - cidr_blocks      = [
                  - "0.0.0.0/0",
                ]
              - description      = "HTTPS"
              - from_port        = 443
              - ipv6_cidr_blocks = []
              - prefix_list_ids  = []
              - protocol         = "tcp"
              - security_groups  = []
              - self             = false
              - to_port          = 443
            },
        ] -> null
      - name                   = "session19-mini-web-sg" -> null
      - owner_id               = "737272117751" -> null
      - region                 = "ap-south-1" -> null
      - revoke_rules_on_delete = false -> null
      - tags                   = {
          - "ManagedBy" = "Terraform"
          - "Name"      = "session19-mini-web-sg"
          - "Session"   = "19"
        } -> null
      - tags_all               = {
          - "ManagedBy" = "Terraform"
          - "Name"      = "session19-mini-web-sg"
          - "Session"   = "19"
        } -> null
      - vpc_id                 = "vpc-0ee894adce95f254d" -> null
        # (1 unchanged attribute hidden)
    }

  # aws_subnet.public will be destroyed
  - resource "aws_subnet" "public" {
      - arn                                            = "arn:aws:ec2:ap-south-1:737272117751:subnet/subnet-051df322b5616e815" -> null
      - assign_ipv6_address_on_creation                = false -> null
      - availability_zone                              = "ap-south-1a" -> null
      - availability_zone_id                           = "aps1-az1" -> null
      - cidr_block                                     = "10.20.1.0/24" -> null
      - enable_dns64                                   = false -> null
      - enable_lni_at_device_index                     = 0 -> null
      - enable_resource_name_dns_a_record_on_launch    = false -> null
      - enable_resource_name_dns_aaaa_record_on_launch = false -> null
      - id                                             = "subnet-051df322b5616e815" -> null
      - ipv6_native                                    = false -> null
      - map_customer_owned_ip_on_launch                = false -> null
      - map_public_ip_on_launch                        = true -> null
      - owner_id                                       = "737272117751" -> null
      - private_dns_hostname_type_on_launch            = "ip-name" -> null
      - region                                         = "ap-south-1" -> null
      - tags                                           = {
          - "ManagedBy" = "Terraform"
          - "Name"      = "session19-mini-public-subnet"
          - "Session"   = "19"
        } -> null
      - tags_all                                       = {
          - "ManagedBy" = "Terraform"
          - "Name"      = "session19-mini-public-subnet"
          - "Session"   = "19"
        } -> null
      - vpc_id                                         = "vpc-0ee894adce95f254d" -> null
        # (4 unchanged attributes hidden)
    }

  # aws_vpc.main will be destroyed
  - resource "aws_vpc" "main" {
      - arn                                  = "arn:aws:ec2:ap-south-1:737272117751:vpc/vpc-0ee894adce95f254d" -> null
      - assign_generated_ipv6_cidr_block     = false -> null
      - cidr_block                           = "10.20.0.0/16" -> null
      - default_network_acl_id               = "acl-05001605012df8d89" -> null
      - default_route_table_id               = "rtb-0849a03e0613af043" -> null
      - default_security_group_id            = "sg-0faf6a0ab8ee0d4dc" -> null
      - dhcp_options_id                      = "dopt-0e03335f5c206a677" -> null
      - enable_dns_hostnames                 = true -> null
      - enable_dns_support                   = true -> null
      - enable_network_address_usage_metrics = false -> null
      - id                                   = "vpc-0ee894adce95f254d" -> null
      - instance_tenancy                     = "default" -> null
      - ipv6_netmask_length                  = 0 -> null
      - main_route_table_id                  = "rtb-0849a03e0613af043" -> null
      - owner_id                             = "737272117751" -> null
      - region                               = "ap-south-1" -> null
      - tags                                 = {
          - "ManagedBy" = "Terraform"
          - "Name"      = "session19-mini-vpc"
          - "Session"   = "19"
        } -> null
      - tags_all                             = {
          - "ManagedBy" = "Terraform"
          - "Name"      = "session19-mini-vpc"
          - "Session"   = "19"
        } -> null
        # (4 unchanged attributes hidden)
    }

Plan: 0 to add, 0 to change, 6 to destroy.

Changes to Outputs:
  - security_group_id = "sg-0e8b8a71898c962c5" -> null
  - subnet_id         = "subnet-051df322b5616e815" -> null
  - vpc_cidr          = "10.20.0.0/16" -> null
  - vpc_id            = "vpc-0ee894adce95f254d" -> null
aws_route_table_association.public: Destroying... [id=rtbassoc-087b534d9352e7ea7]
aws_security_group.web: Destroying... [id=sg-0e8b8a71898c962c5]
aws_route_table_association.public: Destruction complete after 1s
aws_route_table.public: Destroying... [id=rtb-0192cb929600205a6]
aws_subnet.public: Destroying... [id=subnet-051df322b5616e815]
aws_subnet.public: Destruction complete after 0s
aws_route_table.public: Destruction complete after 0s
aws_internet_gateway.main: Destroying... [id=igw-0b58eb50821abd751]
aws_security_group.web: Destruction complete after 1s
aws_internet_gateway.main: Destruction complete after 1s
aws_vpc.main: Destroying... [id=vpc-0ee894adce95f254d]
aws_vpc.main: Destruction complete after 0s

Destroy complete! Resources: 6 destroyed.
```

## cleanup-check

Final check that nothing is left behind:

```bash
…/session19-cloud-terraform/cleanup-check ❯ aws s3 ls

…/session19-cloud-terraform/cleanup-check ❯ aws ec2 describe-vpcs --region ap-south-1 --filters Name=isDefault,Values=false
{
    "Vpcs": []
}

…/session19-cloud-terraform/cleanup-check ❯ aws ec2 describe-vpcs --region us-west-1 --filters Name=isDefault,Values=false
{
    "Vpcs": []
}

…/session19-cloud-terraform/cleanup-check ❯ aws ec2 describe-vpcs --region ap-south-2 --filters Name=isDefault,Values=false
{
    "Vpcs": []
}
```
