…/session19-cloud-terraform/06-terraform-vpc main ? ❯ aws configure
AWS Access Key ID [****************NJ
AWS Secret Access Key [****************
Default region name [us-east-1]: us-west-1
Default output format [json]: 

…/session19-cloud-terraform/06-terraform-vpc main ? ❯ terraform init
Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 6.0"...
- Installing hashicorp/aws v6.67.0...
- Installed hashicorp/aws v6.67.0 (signed by HashiCorp)

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

…/session19-cloud-terraform/06-terraform-vpc main ? ❯ terraform validat
Terraform has no command named "validat". Did you mean "validate"?

To see all of Terraform's top-level commands, run:
  terraform -help


…/session19-cloud-terraform/06-terraform-vpc main ? ✗ terraform validate
Success! The configuration is valid.


…/session19-cloud-terraform/06-terraform-vpc main ? ❯ terraform plan

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
          + "Name"      = "session19-igw"
          + "Session"   = "19"
        }
      + tags_all = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "session19-igw"
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
          + "Name"      = "session19-public-rt"
          + "Session"   = "19"
        }
      + tags_all         = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "session19-public-rt"
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
      + description            = "Security group for Session 19 web traffic"
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
      + name                   = "session19-web-sg"
      + name_prefix            = (known after apply)
      + owner_id               = (known after apply)
      + region                 = "ap-south-1"
      + revoke_rules_on_delete = false
      + tags                   = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "session19-web-sg"
          + "Session"   = "19"
        }
      + tags_all               = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "session19-web-sg"
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
      + cidr_block                                     = "10.0.1.0/24"
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
          + "Name"      = "session19-public-subnet"
          + "Session"   = "19"
        }
      + tags_all                                       = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "session19-public-subnet"
          + "Session"   = "19"
        }
      + vpc_id                                         = (known after apply)
    }

  # aws_vpc.main will be created
  + resource "aws_vpc" "main" {
      + arn                                  = (known after apply)
      + cidr_block                           = "10.0.0.0/16"
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
          + "Name"      = "session19-vpc"
          + "Session"   = "19"
        }
      + tags_all                             = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "session19-vpc"
          + "Session"   = "19"
        }
    }

Plan: 6 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + security_group_id = (known after apply)
  + subnet_id         = (known after apply)
  + vpc_cidr          = "10.0.0.0/16"
  + vpc_id            = (known after apply)

───────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't
guarantee to take exactly these actions if you run "terraform apply" now.

…/session19-cloud-terraform/06-terraform-vpc main ? ❯ terraform apply

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
          + "Name"      = "session19-igw"
          + "Session"   = "19"
        }
      + tags_all = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "session19-igw"
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
          + "Name"      = "session19-public-rt"
          + "Session"   = "19"
        }
      + tags_all         = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "session19-public-rt"
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
      + description            = "Security group for Session 19 web traffic"
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
      + name                   = "session19-web-sg"
      + name_prefix            = (known after apply)
      + owner_id               = (known after apply)
      + region                 = "ap-south-1"
      + revoke_rules_on_delete = false
      + tags                   = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "session19-web-sg"
          + "Session"   = "19"
        }
      + tags_all               = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "session19-web-sg"
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
      + cidr_block                                     = "10.0.1.0/24"
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
          + "Name"      = "session19-public-subnet"
          + "Session"   = "19"
        }
      + tags_all                                       = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "session19-public-subnet"
          + "Session"   = "19"
        }
      + vpc_id                                         = (known after apply)
    }

  # aws_vpc.main will be created
  + resource "aws_vpc" "main" {
      + arn                                  = (known after apply)
      + cidr_block                           = "10.0.0.0/16"
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
          + "Name"      = "session19-vpc"
          + "Session"   = "19"
        }
      + tags_all                             = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "session19-vpc"
          + "Session"   = "19"
        }
    }

Plan: 6 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + security_group_id = (known after apply)
  + subnet_id         = (known after apply)
  + vpc_cidr          = "10.0.0.0/16"
  + vpc_id            = (known after apply)

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_vpc.main: Creating...
aws_vpc.main: Creation complete after 2s [id=vpc-0ea78e3c86afcc173]
aws_internet_gateway.main: Creating...
aws_subnet.public: Creating...
aws_security_group.web: Creating...
aws_internet_gateway.main: Creation complete after 1s [id=igw-0ff5c1b63bb6ccdc7]
aws_route_table.public: Creating...
aws_route_table.public: Creation complete after 2s [id=rtb-0a69c1dd8ff4f73d7]
aws_security_group.web: Creation complete after 3s [id=sg-0824183315bdacc1b]
aws_subnet.public: Still creating... [00m10s elapsed]
aws_subnet.public: Creation complete after 11s [id=subnet-0981ab67c3765573f]
aws_route_table_association.public: Creating...
aws_route_table_association.public: Creation complete after 1s [id=rtbassoc-045bd5a41105abc34]

Apply complete! Resources: 6 added, 0 changed, 0 destroyed.

Outputs:

security_group_id = "sg-0824183315bdacc1b"
subnet_id = "subnet-0981ab67c3765573f"
vpc_cidr = "10.0.0.0/16"
vpc_id = "vpc-0ea78e3c86afcc173"

…/session19-cloud-terraform/06-terraform-vpc main ? ❯ terraform destroy
aws_vpc.main: Refreshing state... [id=vpc-0ea78e3c86afcc173]
aws_internet_gateway.main: Refreshing state... [id=igw-0ff5c1b63bb6ccdc7]
aws_subnet.public: Refreshing state... [id=subnet-0981ab67c3765573f]
aws_security_group.web: Refreshing state... [id=sg-0824183315bdacc1b]
aws_route_table.public: Refreshing state... [id=rtb-0a69c1dd8ff4f73d7]
aws_route_table_association.public: Refreshing state... [id=rtbassoc-045bd5a41105abc34]

Terraform used the selected providers to generate the following execution plan. Resource actions are
indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_internet_gateway.main will be destroyed
  - resource "aws_internet_gateway" "main" {
      - arn      = "arn:aws:ec2:ap-south-1:304166770455:internet-gateway/igw-0ff5c1b63bb6ccdc7" -> null
      - id       = "igw-0ff5c1b63bb6ccdc7" -> null
      - owner_id = "304166770455" -> null
      - region   = "ap-south-1" -> null
      - tags     = {
          - "ManagedBy" = "Terraform"
          - "Name"      = "session19-igw"
          - "Session"   = "19"
        } -> null
      - tags_all = {
          - "ManagedBy" = "Terraform"
          - "Name"      = "session19-igw"
          - "Session"   = "19"
        } -> null
      - vpc_id   = "vpc-0ea78e3c86afcc173" -> null
    }

  # aws_route_table.public will be destroyed
  - resource "aws_route_table" "public" {
      - arn              = "arn:aws:ec2:ap-south-1:304166770455:route-table/rtb-0a69c1dd8ff4f73d7" -> null
      - id               = "rtb-0a69c1dd8ff4f73d7" -> null
      - owner_id         = "304166770455" -> null
      - propagating_vgws = [] -> null
      - region           = "ap-south-1" -> null
      - route            = [
          - {
              - cidr_block                 = "0.0.0.0/0"
              - gateway_id                 = "igw-0ff5c1b63bb6ccdc7"
                # (12 unchanged attributes hidden)
            },
        ] -> null
      - tags             = {
          - "ManagedBy" = "Terraform"
          - "Name"      = "session19-public-rt"
          - "Session"   = "19"
        } -> null
      - tags_all         = {
          - "ManagedBy" = "Terraform"
          - "Name"      = "session19-public-rt"
          - "Session"   = "19"
        } -> null
      - vpc_id           = "vpc-0ea78e3c86afcc173" -> null
    }

  # aws_route_table_association.public will be destroyed
  - resource "aws_route_table_association" "public" {
      - id             = "rtbassoc-045bd5a41105abc34" -> null
      - region         = "ap-south-1" -> null
      - route_table_id = "rtb-0a69c1dd8ff4f73d7" -> null
      - subnet_id      = "subnet-0981ab67c3765573f" -> null
        # (1 unchanged attribute hidden)
    }

  # aws_security_group.web will be destroyed
  - resource "aws_security_group" "web" {
      - arn                    = "arn:aws:ec2:ap-south-1:304166770455:security-group/sg-0824183315bdacc1b" -> null
      - description            = "Security group for Session 19 web traffic" -> null
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
      - id                     = "sg-0824183315bdacc1b" -> null
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
      - name                   = "session19-web-sg" -> null
      - owner_id               = "304166770455" -> null
      - region                 = "ap-south-1" -> null
      - revoke_rules_on_delete = false -> null
      - tags                   = {
          - "ManagedBy" = "Terraform"
          - "Name"      = "session19-web-sg"
          - "Session"   = "19"
        } -> null
      - tags_all               = {
          - "ManagedBy" = "Terraform"
          - "Name"      = "session19-web-sg"
          - "Session"   = "19"
        } -> null
      - vpc_id                 = "vpc-0ea78e3c86afcc173" -> null
        # (1 unchanged attribute hidden)
    }

  # aws_subnet.public will be destroyed
  - resource "aws_subnet" "public" {
      - arn                                            = "arn:aws:ec2:ap-south-1:304166770455:subnet/subnet-0981ab67c3765573f" -> null
      - assign_ipv6_address_on_creation                = false -> null
      - availability_zone                              = "ap-south-1a" -> null
      - availability_zone_id                           = "aps1-az1" -> null
      - cidr_block                                     = "10.0.1.0/24" -> null
      - enable_dns64                                   = false -> null
      - enable_lni_at_device_index                     = 0 -> null
      - enable_resource_name_dns_a_record_on_launch    = false -> null
      - enable_resource_name_dns_aaaa_record_on_launch = false -> null
      - id                                             = "subnet-0981ab67c3765573f" -> null
      - ipv6_native                                    = false -> null
      - map_customer_owned_ip_on_launch                = false -> null
      - map_public_ip_on_launch                        = true -> null
      - owner_id                                       = "304166770455" -> null
      - private_dns_hostname_type_on_launch            = "ip-name" -> null
      - region                                         = "ap-south-1" -> null
      - tags                                           = {
          - "ManagedBy" = "Terraform"
          - "Name"      = "session19-public-subnet"
          - "Session"   = "19"
        } -> null
      - tags_all                                       = {
          - "ManagedBy" = "Terraform"
          - "Name"      = "session19-public-subnet"
          - "Session"   = "19"
        } -> null
      - vpc_id                                         = "vpc-0ea78e3c86afcc173" -> null
        # (4 unchanged attributes hidden)
    }

  # aws_vpc.main will be destroyed
  - resource "aws_vpc" "main" {
      - arn                                  = "arn:aws:ec2:ap-south-1:304166770455:vpc/vpc-0ea78e3c86afcc173" -> null
      - assign_generated_ipv6_cidr_block     = false -> null
      - cidr_block                           = "10.0.0.0/16" -> null
      - default_network_acl_id               = "acl-05978c183dfef6e6e" -> null
      - default_route_table_id               = "rtb-0ca98bf38002faa29" -> null
      - default_security_group_id            = "sg-0c4fa91d22278b503" -> null
      - dhcp_options_id                      = "dopt-04ade85e35b6e1ed8" -> null
      - enable_dns_hostnames                 = true -> null
      - enable_dns_support                   = true -> null
      - enable_network_address_usage_metrics = false -> null
      - id                                   = "vpc-0ea78e3c86afcc173" -> null
      - instance_tenancy                     = "default" -> null
      - ipv6_netmask_length                  = 0 -> null
      - main_route_table_id                  = "rtb-0ca98bf38002faa29" -> null
      - owner_id                             = "304166770455" -> null
      - region                               = "ap-south-1" -> null
      - tags                                 = {
          - "ManagedBy" = "Terraform"
          - "Name"      = "session19-vpc"
          - "Session"   = "19"
        } -> null
      - tags_all                             = {
          - "ManagedBy" = "Terraform"
          - "Name"      = "session19-vpc"
          - "Session"   = "19"
        } -> null
        # (4 unchanged attributes hidden)
    }

Plan: 0 to add, 0 to change, 6 to destroy.

Changes to Outputs:
  - security_group_id = "sg-0824183315bdacc1b" -> null
  - subnet_id         = "subnet-0981ab67c3765573f" -> null
  - vpc_cidr          = "10.0.0.0/16" -> null
  - vpc_id            = "vpc-0ea78e3c86afcc173" -> null

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

aws_route_table_association.public: Destroying... [id=rtbassoc-045bd5a41105abc34]
aws_security_group.web: Destroying... [id=sg-0824183315bdacc1b]
aws_route_table_association.public: Destruction complete after 1s
aws_route_table.public: Destroying... [id=rtb-0a69c1dd8ff4f73d7]
aws_subnet.public: Destroying... [id=subnet-0981ab67c3765573f]
aws_security_group.web: Destruction complete after 1s
aws_subnet.public: Destruction complete after 0s
aws_route_table.public: Destruction complete after 1s
aws_internet_gateway.main: Destroying... [id=igw-0ff5c1b63bb6ccdc7]
aws_internet_gateway.main: Destruction complete after 0s
aws_vpc.main: Destroying... [id=vpc-0ea78e3c86afcc173]
aws_vpc.main: Destruction complete after 1s

Destroy complete! Resources: 6 destroyed.

…/session19-cloud-terraform/06-terraform-vpc main ? ❯ ls
Permissions Size User Date Modified Name
.rw-r--r--  1.8k adam  3 Oct 17:39  󱁢 main.tf
.rw-r--r--   426 adam 29 Sep 11:44  󱁢 outputs.tf
.rw-r--r--  4.8k adam 29 Sep 11:44  󰂺 README.md
.rw-r--r--   182 adam  3 Oct 18:10  󱁢 terraform.tfstate
.rw-r--r--   12k adam  3 Oct 18:10   terraform.tfstate.backup
.rw-r--r--    26 adam 29 Sep 11:44   terraform.tfvars.example
.rw-r--r--   138 adam 29 Sep 11:44  󱁢 variables.tf
.rw-r--r--   195 adam 29 Sep 11:44  󱁢 versions.tf

…/session19-cloud-terraform/06-terraform-vpc main ? ❯ nvim variables.tf 

…/session19-cloud-terraform/06-terraform-vpc main  ? ❯ terraform validate
Success! The configuration is valid.


…/session19-cloud-terraform/06-terraform-vpc main  ? ❯ terraform plan

Planning failed. Terraform encountered an error while generating this plan.

╷
│ Error: invalid AWS Region: ap-west-1
│ 
│   with provider["registry.terraform.io/hashicorp/aws"],
│   on versions.tf line 12, in provider "aws":
│   12: provider "aws" {
│ 
╵

…/session19-cloud-terraform/06-terraform-vpc main  ? ✗ nvim variables.tf 

…/session19-cloud-terraform/06-terraform-vpc main  ? ❯ terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are
indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_internet_gateway.main will be created
  + resource "aws_internet_gateway" "main" {
      + arn      = (known after apply)
      + id       = (known after apply)
      + owner_id = (known after apply)
      + region   = "us-west-1"
      + tags     = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "session19-igw"
          + "Session"   = "19"
        }
      + tags_all = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "session19-igw"
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
      + region           = "us-west-1"
      + route            = [
          + {
              + cidr_block                 = "0.0.0.0/0"
              + gateway_id                 = (known after apply)
                # (12 unchanged attributes hidden)
            },
        ]
      + tags             = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "session19-public-rt"
          + "Session"   = "19"
        }
      + tags_all         = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "session19-public-rt"
          + "Session"   = "19"
        }
      + vpc_id           = (known after apply)
    }

  # aws_route_table_association.public will be created
  + resource "aws_route_table_association" "public" {
      + id             = (known after apply)
      + region         = "us-west-1"
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # aws_security_group.web will be created
  + resource "aws_security_group" "web" {
      + arn                    = (known after apply)
      + description            = "Security group for Session 19 web traffic"
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
      + name                   = "session19-web-sg"
      + name_prefix            = (known after apply)
      + owner_id               = (known after apply)
      + region                 = "us-west-1"
      + revoke_rules_on_delete = false
      + tags                   = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "session19-web-sg"
          + "Session"   = "19"
        }
      + tags_all               = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "session19-web-sg"
          + "Session"   = "19"
        }
      + vpc_id                 = (known after apply)
    }

  # aws_subnet.public will be created
  + resource "aws_subnet" "public" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "us-west-1a"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.0.1.0/24"
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
      + region                                         = "us-west-1"
      + tags                                           = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "session19-public-subnet"
          + "Session"   = "19"
        }
      + tags_all                                       = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "session19-public-subnet"
          + "Session"   = "19"
        }
      + vpc_id                                         = (known after apply)
    }

  # aws_vpc.main will be created
  + resource "aws_vpc" "main" {
      + arn                                  = (known after apply)
      + cidr_block                           = "10.0.0.0/16"
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
      + region                               = "us-west-1"
      + tags                                 = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "session19-vpc"
          + "Session"   = "19"
        }
      + tags_all                             = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "session19-vpc"
          + "Session"   = "19"
        }
    }

Plan: 6 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + security_group_id = (known after apply)
  + subnet_id         = (known after apply)
  + vpc_cidr          = "10.0.0.0/16"
  + vpc_id            = (known after apply)

─────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly
these actions if you run "terraform apply" now.

…/session19-cloud-terraform/06-terraform-vpc main  ? ❯ terraform fmt

…/session19-cloud-terraform/06-terraform-vpc main  ? ❯ terraform validate
Success! The configuration is valid.


…/session19-cloud-terraform/06-terraform-vpc main  ? ❯ terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are
indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_internet_gateway.main will be created
  + resource "aws_internet_gateway" "main" {
      + arn      = (known after apply)
      + id       = (known after apply)
      + owner_id = (known after apply)
      + region   = "us-west-1"
      + tags     = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "session19-igw"
          + "Session"   = "19"
        }
      + tags_all = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "session19-igw"
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
      + region           = "us-west-1"
      + route            = [
          + {
              + cidr_block                 = "0.0.0.0/0"
              + gateway_id                 = (known after apply)
                # (12 unchanged attributes hidden)
            },
        ]
      + tags             = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "session19-public-rt"
          + "Session"   = "19"
        }
      + tags_all         = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "session19-public-rt"
          + "Session"   = "19"
        }
      + vpc_id           = (known after apply)
    }

  # aws_route_table_association.public will be created
  + resource "aws_route_table_association" "public" {
      + id             = (known after apply)
      + region         = "us-west-1"
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # aws_security_group.web will be created
  + resource "aws_security_group" "web" {
      + arn                    = (known after apply)
      + description            = "Security group for Session 19 web traffic"
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
      + name                   = "session19-web-sg"
      + name_prefix            = (known after apply)
      + owner_id               = (known after apply)
      + region                 = "us-west-1"
      + revoke_rules_on_delete = false
      + tags                   = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "session19-web-sg"
          + "Session"   = "19"
        }
      + tags_all               = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "session19-web-sg"
          + "Session"   = "19"
        }
      + vpc_id                 = (known after apply)
    }

  # aws_subnet.public will be created
  + resource "aws_subnet" "public" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "us-west-1a"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.0.1.0/24"
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
      + region                                         = "us-west-1"
      + tags                                           = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "session19-public-subnet"
          + "Session"   = "19"
        }
      + tags_all                                       = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "session19-public-subnet"
          + "Session"   = "19"
        }
      + vpc_id                                         = (known after apply)
    }

  # aws_vpc.main will be created
  + resource "aws_vpc" "main" {
      + arn                                  = (known after apply)
      + cidr_block                           = "10.0.0.0/16"
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
      + region                               = "us-west-1"
      + tags                                 = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "session19-vpc"
          + "Session"   = "19"
        }
      + tags_all                             = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "session19-vpc"
          + "Session"   = "19"
        }
    }

Plan: 6 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + security_group_id = (known after apply)
  + subnet_id         = (known after apply)
  + vpc_cidr          = "10.0.0.0/16"
  + vpc_id            = (known after apply)

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_vpc.main: Creating...
aws_vpc.main: Creation complete after 6s [id=vpc-0955852e28092540e]
aws_internet_gateway.main: Creating...
aws_subnet.public: Creating...
aws_security_group.web: Creating...
aws_internet_gateway.main: Creation complete after 2s [id=igw-0f05e13e9f1ea1214]
aws_route_table.public: Creating...
aws_security_group.web: Creation complete after 5s [id=sg-0a17f856a99b60a4c]
aws_route_table.public: Creation complete after 3s [id=rtb-0072793d2f6825629]
aws_subnet.public: Still creating... [00m10s elapsed]
aws_subnet.public: Creation complete after 13s [id=subnet-0dee42e412b39f189]
aws_route_table_association.public: Creating...
aws_route_table_association.public: Creation complete after 1s [id=rtbassoc-045731bcfa7f2111e]

Apply complete! Resources: 6 added, 0 changed, 0 destroyed.

Outputs:

security_group_id = "sg-0a17f856a99b60a4c"
subnet_id = "subnet-0dee42e412b39f189"
vpc_cidr = "10.0.0.0/16"
vpc_id = "vpc-0955852e28092540e"

…/session19-cloud-terraform/06-terraform-vpc main  ? ❯ aws configure list
      Name                    Value             Type    Location
      ----                    -----             ----    --------
   profile                <not set>             None    None
access_key     ****************NJNR shared-credentials-file    
secret_key     ****************dxgi shared-credentials-file    
    region                us-west-1      config-file    ~/.aws/config

…/session19-cloud-terraform/06-terraform-vpc main  ? ❯ terraform show
# aws_internet_gateway.main:
resource "aws_internet_gateway" "main" {
    arn      = "arn:aws:ec2:us-west-1:304166770455:internet-gateway/igw-0f05e13e9f1ea1214"
    id       = "igw-0f05e13e9f1ea1214"
    owner_id = "304166770455"
    region   = "us-west-1"
    tags     = {
        "ManagedBy" = "Terraform"
        "Name"      = "session19-igw"
        "Session"   = "19"
    }
    tags_all = {
        "ManagedBy" = "Terraform"
        "Name"      = "session19-igw"
        "Session"   = "19"
    }
    vpc_id   = "vpc-0955852e28092540e"
}

# aws_route_table.public:
resource "aws_route_table" "public" {
    arn              = "arn:aws:ec2:us-west-1:304166770455:route-table/rtb-0072793d2f6825629"
    id               = "rtb-0072793d2f6825629"
    owner_id         = "304166770455"
    propagating_vgws = []
    region           = "us-west-1"
    route            = [
        {
            carrier_gateway_id         = null
            cidr_block                 = "0.0.0.0/0"
            core_network_arn           = null
            destination_prefix_list_id = null
            egress_only_gateway_id     = null
            gateway_id                 = "igw-0f05e13e9f1ea1214"
            ipv6_cidr_block            = null
            local_gateway_id           = null
            nat_gateway_id             = null
            network_interface_id       = null
            odb_network_arn            = null
            transit_gateway_id         = null
            vpc_endpoint_id            = null
            vpc_peering_connection_id  = null
        },
    ]
    tags             = {
        "ManagedBy" = "Terraform"
        "Name"      = "session19-public-rt"
        "Session"   = "19"
    }
    tags_all         = {
        "ManagedBy" = "Terraform"
        "Name"      = "session19-public-rt"
        "Session"   = "19"
    }
    vpc_id           = "vpc-0955852e28092540e"
}

# aws_route_table_association.public:
resource "aws_route_table_association" "public" {
    gateway_id     = null
    id             = "rtbassoc-045731bcfa7f2111e"
    region         = "us-west-1"
    route_table_id = "rtb-0072793d2f6825629"
    subnet_id      = "subnet-0dee42e412b39f189"
}

# aws_security_group.web:
resource "aws_security_group" "web" {
    arn                    = "arn:aws:ec2:us-west-1:304166770455:security-group/sg-0a17f856a99b60a4c"
    description            = "Security group for Session 19 web traffic"
    egress                 = [
        {
            cidr_blocks      = [
                "0.0.0.0/0",
            ]
            description      = "Allow outbound IPv4"
            from_port        = 0
            ipv6_cidr_blocks = []
            prefix_list_ids  = []
            protocol         = "-1"
            security_groups  = []
            self             = false
            to_port          = 0
        },
    ]
    id                     = "sg-0a17f856a99b60a4c"
    ingress                = [
        {
            cidr_blocks      = [
                "0.0.0.0/0",
            ]
            description      = "HTTP"
            from_port        = 80
            ipv6_cidr_blocks = []
            prefix_list_ids  = []
            protocol         = "tcp"
            security_groups  = []
            self             = false
            to_port          = 80
        },
        {
            cidr_blocks      = [
                "0.0.0.0/0",
            ]
            description      = "HTTPS"
            from_port        = 443
            ipv6_cidr_blocks = []
            prefix_list_ids  = []
            protocol         = "tcp"
            security_groups  = []
            self             = false
            to_port          = 443
        },
    ]
    name                   = "session19-web-sg"
    name_prefix            = null
    owner_id               = "304166770455"
    region                 = "us-west-1"
    revoke_rules_on_delete = false
    tags                   = {
        "ManagedBy" = "Terraform"
        "Name"      = "session19-web-sg"
        "Session"   = "19"
    }
    tags_all               = {
        "ManagedBy" = "Terraform"
        "Name"      = "session19-web-sg"
        "Session"   = "19"
    }
    vpc_id                 = "vpc-0955852e28092540e"
}

# aws_subnet.public:
resource "aws_subnet" "public" {
    arn                                            = "arn:aws:ec2:us-west-1:304166770455:subnet/subnet-0dee42e412b39f189"
    assign_ipv6_address_on_creation                = false
    availability_zone                              = "us-west-1a"
    availability_zone_id                           = "usw1-az1"
    cidr_block                                     = "10.0.1.0/24"
    customer_owned_ipv4_pool                       = null
    enable_dns64                                   = false
    enable_lni_at_device_index                     = 0
    enable_resource_name_dns_a_record_on_launch    = false
    enable_resource_name_dns_aaaa_record_on_launch = false
    id                                             = "subnet-0dee42e412b39f189"
    ipv6_cidr_block                                = null
    ipv6_cidr_block_association_id                 = null
    ipv6_native                                    = false
    map_customer_owned_ip_on_launch                = false
    map_public_ip_on_launch                        = true
    outpost_arn                                    = null
    owner_id                                       = "304166770455"
    private_dns_hostname_type_on_launch            = "ip-name"
    region                                         = "us-west-1"
    tags                                           = {
        "ManagedBy" = "Terraform"
        "Name"      = "session19-public-subnet"
        "Session"   = "19"
    }
    tags_all                                       = {
        "ManagedBy" = "Terraform"
        "Name"      = "session19-public-subnet"
        "Session"   = "19"
    }
    vpc_id                                         = "vpc-0955852e28092540e"
}

# aws_vpc.main:
resource "aws_vpc" "main" {
    arn                                  = "arn:aws:ec2:us-west-1:304166770455:vpc/vpc-0955852e28092540e"
    assign_generated_ipv6_cidr_block     = false
    cidr_block                           = "10.0.0.0/16"
    default_network_acl_id               = "acl-0e275d2af213e6d7e"
    default_route_table_id               = "rtb-01ba1936d931f6c2b"
    default_security_group_id            = "sg-0655f5b42e9f9f1c1"
    dhcp_options_id                      = "dopt-069f35e0d7c11bd71"
    enable_dns_hostnames                 = true
    enable_dns_support                   = true
    enable_network_address_usage_metrics = false
    id                                   = "vpc-0955852e28092540e"
    instance_tenancy                     = "default"
    ipv6_association_id                  = null
    ipv6_cidr_block                      = null
    ipv6_cidr_block_network_border_group = null
    ipv6_ipam_pool_id                    = null
    ipv6_netmask_length                  = 0
    main_route_table_id                  = "rtb-01ba1936d931f6c2b"
    owner_id                             = "304166770455"
    region                               = "us-west-1"
    tags                                 = {
        "ManagedBy" = "Terraform"
        "Name"      = "session19-vpc"
        "Session"   = "19"
    }
    tags_all                             = {
        "ManagedBy" = "Terraform"
        "Name"      = "session19-vpc"
        "Session"   = "19"
    }
}


Outputs:

security_group_id = "sg-0a17f856a99b60a4c"
subnet_id = "subnet-0dee42e412b39f189"
vpc_cidr = "10.0.0.0/16"
vpc_id = "vpc-0955852e28092540e"

…/session19-cloud-terraform/06-terraform-vpc main  ? ❯ state list
bash: command not found: state

…/session19-cloud-terraform/06-terraform-vpc main  ? ✗ aws state list
Note: AWS CLI version 2, the latest major version of the AWS CLI, is now stable and recommended for general use. For more information, see the AWS CLI version 2 installation instructions at: https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html

usage: aws [options] <command> <subcommand> [<subcommand> ...] [parameters]
To see help text, you can run:

  aws help
  aws <command> help
  aws <command> <subcommand> help

aws: error: argument command: Invalid choice, valid choices are:

accessanalyzer                           | account                                 
acm                                      | acm-pca                                 
aiops                                    | amp                                     
amplify                                  | amplifybackend                          
amplifyuibuilder                         | apigateway                              
apigatewaymanagementapi                  | apigatewayv2                            
appconfig                                | appconfigdata                           
appfabric                                | appflow                                 
appintegrations                          | application-autoscaling                 
application-insights                     | application-signals                     
applicationcostprofiler                  | appmesh                                 
apprunner                                | appstream                               
appsync                                  | arc-region-switch                       
arc-zonal-shift                          | artifact                                
athena                                   | auditmanager                            
autoscaling                              | autoscaling-plans                       
b2bi                                     | backup                                  
backup-gateway                           | backupsearch                            
batch                                    | bcm-dashboards                          
bcm-data-exports                         | bcm-pricing-calculator                  
bcm-recommended-actions                  | bedrock                                 
bedrock-agent                            | bedrock-agent-runtime                   
bedrock-agentcore                        | bedrock-agentcore-control               
bedrock-data-automation                  | bedrock-data-automation-runtime         
bedrock-runtime                          | billing                                 
billingconductor                         | braket                                  
budgets                                  | ce                                      
chatbot                                  | chime                                   
chime-sdk-identity                       | chime-sdk-media-pipelines               
chime-sdk-meetings                       | chime-sdk-messaging                     
chime-sdk-voice                          | cleanrooms                              
cleanroomsml                             | cloud9                                  
cloudcontrol                             | clouddirectory                          
cloudformation                           | cloudfront                              
cloudfront-keyvaluestore                 | cloudhsm                                
cloudhsmv2                               | cloudsearch                             
cloudsearchdomain                        | cloudtrail                              
cloudtrail-data                          | cloudwatch                              
codeartifact                             | codebuild                               
codecatalyst                             | codecommit                              
codeconnections                          | codeguru-reviewer                       
codeguru-security                        | codeguruprofiler                        
codepipeline                             | codestar-connections                    
codestar-notifications                   | cognito-identity                        
cognito-idp                              | cognito-sync                            
comprehend                               | comprehendmedical                       
compute-optimizer                        | compute-optimizer-automation            
connect                                  | connect-contact-lens                    
connectcampaigns                         | connectcampaignsv2                      
connectcases                             | connecthealth                           
connectparticipant                       | controlcatalog                          
controltower                             | cost-optimization-hub                   
cur                                      | customer-profiles                       
databrew                                 | dataexchange                            
datapipeline                             | datasync                                
datazone                                 | dax                                     
deadline                                 | detective                               
devicefarm                               | devops-agent                            
devops-guru                              | directconnect                           
discovery                                | dlm                                     
dms                                      | docdb                                   
docdb-elastic                            | drs                                     
ds                                       | ds-data                                 
dsql                                     | dynamodb                                
dynamodbstreams                          | ebs                                     
ec2                                      | ec2-instance-connect                    
ecr                                      | ecr-public                              
ecs                                      | efs                                     
eks                                      | eks-auth                                
elasticache                              | elasticbeanstalk                        
elb                                      | elbv2                                   
elementalinference                       | emr                                     
emr-containers                           | emr-serverless                          
entityresolution                         | es                                      
events                                   | evs                                     
finspace                                 | finspace-data                           
firehose                                 | fis                                     
fms                                      | forecast                                
forecastquery                            | frauddetector                           
freetier                                 | fsx                                     
gamelift                                 | gameliftstreams                         
geo-maps                                 | geo-places                              
geo-routes                               | glacier                                 
globalaccelerator                        | glue                                    
grafana                                  | greengrass                              
greengrassv2                             | groundstation                           
guardduty                                | health                                  
healthlake                               | iam                                     
identitystore                            | imagebuilder                            
importexport                             | inspector                               
inspector-scan                           | inspector2                              
interconnect                             | internetmonitor                         
invoicing                                | iot                                     
iot-data                                 | iot-jobs-data                           
iot-managed-integrations                 | iotdeviceadvisor                        
iotevents                                | iotevents-data                          
iotfleetwise                             | iotsecuretunneling                      
iotsitewise                              | iotthingsgraph                          
iottwinmaker                             | iotwireless                             
ivs                                      | ivs-realtime                            
ivschat                                  | kafka                                   
kafkaconnect                             | kendra                                  
kendra-ranking                           | keyspaces                               
keyspacesstreams                         | kinesis                                 
kinesis-video-archived-media             | kinesis-video-media                     
kinesis-video-signaling                  | kinesis-video-webrtc-storage            
kinesisanalytics                         | kinesisanalyticsv2                      
kinesisvideo                             | kms                                     
lakeformation                            | lambda                                  
launch-wizard                            | lex-models                              
lex-runtime                              | lexv2-models                            
lexv2-runtime                            | license-manager                         
license-manager-linux-subscriptions      | license-manager-user-subscriptions      
lightsail                                | location                                
logs                                     | lookoutequipment                        
m2                                       | machinelearning                         
macie2                                   | mailmanager                             
managedblockchain                        | managedblockchain-query                 
marketplace-agreement                    | marketplace-catalog                     
marketplace-deployment                   | marketplace-discovery                   
marketplace-entitlement                  | marketplace-reporting                   
marketplacecommerceanalytics             | mediaconnect                            
mediaconvert                             | medialive                               
mediapackage                             | mediapackage-vod                        
mediapackagev2                           | mediastore                              
mediastore-data                          | mediatailor                             
medical-imaging                          | memorydb                                
meteringmarketplace                      | mgh                                     
mgn                                      | migration-hub-refactor-spaces           
migrationhub-config                      | migrationhuborchestrator                
migrationhubstrategy                     | mpa                                     
mq                                       | mturk                                   
mwaa                                     | mwaa-serverless                         
neptune                                  | neptune-graph                           
neptunedata                              | network-firewall                        
networkflowmonitor                       | networkmanager                          
networkmonitor                           | notifications                           
notificationscontacts                    | nova-act                                
oam                                      | observabilityadmin                      
odb                                      | omics                                   
opensearch                               | opensearchserverless                    
organizations                            | osis                                    
outposts                                 | panorama                                
partnercentral-account                   | partnercentral-benefits                 
partnercentral-channel                   | partnercentral-selling                  
payment-cryptography                     | payment-cryptography-data               
pca-connector-ad                         | pca-connector-scep                      
pcs                                      | personalize                             
personalize-events                       | personalize-runtime                     
pi                                       | pinpoint                                
pinpoint-email                           | pinpoint-sms-voice                      
pinpoint-sms-voice-v2                    | pipes                                   
polly                                    | pricing                                 
proton                                   | qapps                                   
qbusiness                                | qconnect                                
quicksight                               | ram                                     
rbin                                     | rds                                     
rds-data                                 | redshift                                
redshift-data                            | redshift-serverless                     
rekognition                              | repostspace                             
resiliencehub                            | resource-explorer-2                     
resource-groups                          | resourcegroupstaggingapi                
rolesanywhere                            | route53                                 
route53-recovery-cluster                 | route53-recovery-control-config         
route53-recovery-readiness               | route53domains                          
route53globalresolver                    | route53profiles                         
route53resolver                          | rtbfabric                               
rum                                      | s3control                               
s3files                                  | s3outposts                              
s3tables                                 | s3vectors                               
sagemaker                                | sagemaker-a2i-runtime                   
sagemaker-edge                           | sagemaker-featurestore-runtime          
sagemaker-geospatial                     | sagemaker-metrics                       
sagemaker-runtime                        | savingsplans                            
scheduler                                | schemas                                 
sdb                                      | secretsmanager                          
security-ir                              | securityagent                           
securityhub                              | securitylake                            
serverlessrepo                           | service-quotas                          
servicecatalog                           | servicecatalog-appregistry              
servicediscovery                         | ses                                     
sesv2                                    | shield                                  
signer                                   | signer-data                             
signin                                   | simpledbv2                              
simspaceweaver                           | sms-voice                               
snow-device-management                   | snowball                                
sns                                      | socialmessaging                         
sqs                                      | ssm                                     
ssm-contacts                             | ssm-guiconnect                          
ssm-incidents                            | ssm-quicksetup                          
ssm-sap                                  | sso                                     
sso-admin                                | sso-oidc                                
stepfunctions                            | storagegateway                          
sts                                      | supplychain                             
support                                  | support-app                             
sustainability                           | swf                                     
synthetics                               | taxsettings                             
textract                                 | timestream-influxdb                     
timestream-query                         | timestream-write                        
tnb                                      | transcribe                              
transfer                                 | translate                               
trustedadvisor                           | uxc                                     
verifiedpermissions                      | voice-id                                
vpc-lattice                              | waf                                     
waf-regional                             | wafv2                                   
wellarchitected                          | wickr                                   
wisdom                                   | workdocs                                
workmail                                 | workmailmessageflow                     
workspaces                               | workspaces-instances                    
workspaces-thin-client                   | workspaces-web                          
xray                                     | s3api                                   
s3                                       | configure                               
deploy                                   | configservice                           
runtime.sagemaker                        | history                                 
help                                    

…/session19-cloud-terraform/06-terraform-vpc main  ? ✗ terraform state list
aws_internet_gateway.main
aws_route_table.public
aws_route_table_association.public
aws_security_group.web
aws_subnet.public
aws_vpc.main

…/session19-cloud-terraform/06-terraform-vpc main  ? ❯ terraform destroy
aws_vpc.main: Refreshing state... [id=vpc-0955852e28092540e]
aws_internet_gateway.main: Refreshing state... [id=igw-0f05e13e9f1ea1214]
aws_subnet.public: Refreshing state... [id=subnet-0dee42e412b39f189]
aws_security_group.web: Refreshing state... [id=sg-0a17f856a99b60a4c]
aws_route_table.public: Refreshing state... [id=rtb-0072793d2f6825629]
aws_route_table_association.public: Refreshing state... [id=rtbassoc-045731bcfa7f2111e]

Terraform used the selected providers to generate the following execution plan. Resource actions are
indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_internet_gateway.main will be destroyed
  - resource "aws_internet_gateway" "main" {
      - arn      = "arn:aws:ec2:us-west-1:304166770455:internet-gateway/igw-0f05e13e9f1ea1214" -> null
      - id       = "igw-0f05e13e9f1ea1214" -> null
      - owner_id = "304166770455" -> null
      - region   = "us-west-1" -> null
      - tags     = {
          - "ManagedBy" = "Terraform"
          - "Name"      = "session19-igw"
          - "Session"   = "19"
        } -> null
      - tags_all = {
          - "ManagedBy" = "Terraform"
          - "Name"      = "session19-igw"
          - "Session"   = "19"
        } -> null
      - vpc_id   = "vpc-0955852e28092540e" -> null
    }

  # aws_route_table.public will be destroyed
  - resource "aws_route_table" "public" {
      - arn              = "arn:aws:ec2:us-west-1:304166770455:route-table/rtb-0072793d2f6825629" -> null
      - id               = "rtb-0072793d2f6825629" -> null
      - owner_id         = "304166770455" -> null
      - propagating_vgws = [] -> null
      - region           = "us-west-1" -> null
      - route            = [
          - {
              - cidr_block                 = "0.0.0.0/0"
              - gateway_id                 = "igw-0f05e13e9f1ea1214"
                # (12 unchanged attributes hidden)
            },
        ] -> null
      - tags             = {
          - "ManagedBy" = "Terraform"
          - "Name"      = "session19-public-rt"
          - "Session"   = "19"
        } -> null
      - tags_all         = {
          - "ManagedBy" = "Terraform"
          - "Name"      = "session19-public-rt"
          - "Session"   = "19"
        } -> null
      - vpc_id           = "vpc-0955852e28092540e" -> null
    }

  # aws_route_table_association.public will be destroyed
  - resource "aws_route_table_association" "public" {
      - id             = "rtbassoc-045731bcfa7f2111e" -> null
      - region         = "us-west-1" -> null
      - route_table_id = "rtb-0072793d2f6825629" -> null
      - subnet_id      = "subnet-0dee42e412b39f189" -> null
        # (1 unchanged attribute hidden)
    }

  # aws_security_group.web will be destroyed
  - resource "aws_security_group" "web" {
      - arn                    = "arn:aws:ec2:us-west-1:304166770455:security-group/sg-0a17f856a99b60a4c" -> null
      - description            = "Security group for Session 19 web traffic" -> null
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
      - id                     = "sg-0a17f856a99b60a4c" -> null
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
      - name                   = "session19-web-sg" -> null
      - owner_id               = "304166770455" -> null
      - region                 = "us-west-1" -> null
      - revoke_rules_on_delete = false -> null
      - tags                   = {
          - "ManagedBy" = "Terraform"
          - "Name"      = "session19-web-sg"
          - "Session"   = "19"
        } -> null
      - tags_all               = {
          - "ManagedBy" = "Terraform"
          - "Name"      = "session19-web-sg"
          - "Session"   = "19"
        } -> null
      - vpc_id                 = "vpc-0955852e28092540e" -> null
        # (1 unchanged attribute hidden)
    }

  # aws_subnet.public will be destroyed
  - resource "aws_subnet" "public" {
      - arn                                            = "arn:aws:ec2:us-west-1:304166770455:subnet/subnet-0dee42e412b39f189" -> null
      - assign_ipv6_address_on_creation                = false -> null
      - availability_zone                              = "us-west-1a" -> null
      - availability_zone_id                           = "usw1-az1" -> null
      - cidr_block                                     = "10.0.1.0/24" -> null
      - enable_dns64                                   = false -> null
      - enable_lni_at_device_index                     = 0 -> null
      - enable_resource_name_dns_a_record_on_launch    = false -> null
      - enable_resource_name_dns_aaaa_record_on_launch = false -> null
      - id                                             = "subnet-0dee42e412b39f189" -> null
      - ipv6_native                                    = false -> null
      - map_customer_owned_ip_on_launch                = false -> null
      - map_public_ip_on_launch                        = true -> null
      - owner_id                                       = "304166770455" -> null
      - private_dns_hostname_type_on_launch            = "ip-name" -> null
      - region                                         = "us-west-1" -> null
      - tags                                           = {
          - "ManagedBy" = "Terraform"
          - "Name"      = "session19-public-subnet"
          - "Session"   = "19"
        } -> null
      - tags_all                                       = {
          - "ManagedBy" = "Terraform"
          - "Name"      = "session19-public-subnet"
          - "Session"   = "19"
        } -> null
      - vpc_id                                         = "vpc-0955852e28092540e" -> null
        # (4 unchanged attributes hidden)
    }

  # aws_vpc.main will be destroyed
  - resource "aws_vpc" "main" {
      - arn                                  = "arn:aws:ec2:us-west-1:304166770455:vpc/vpc-0955852e28092540e" -> null
      - assign_generated_ipv6_cidr_block     = false -> null
      - cidr_block                           = "10.0.0.0/16" -> null
      - default_network_acl_id               = "acl-0e275d2af213e6d7e" -> null
      - default_route_table_id               = "rtb-01ba1936d931f6c2b" -> null
      - default_security_group_id            = "sg-0655f5b42e9f9f1c1" -> null
      - dhcp_options_id                      = "dopt-069f35e0d7c11bd71" -> null
      - enable_dns_hostnames                 = true -> null
      - enable_dns_support                   = true -> null
      - enable_network_address_usage_metrics = false -> null
      - id                                   = "vpc-0955852e28092540e" -> null
      - instance_tenancy                     = "default" -> null
      - ipv6_netmask_length                  = 0 -> null
      - main_route_table_id                  = "rtb-01ba1936d931f6c2b" -> null
      - owner_id                             = "304166770455" -> null
      - region                               = "us-west-1" -> null
      - tags                                 = {
          - "ManagedBy" = "Terraform"
          - "Name"      = "session19-vpc"
          - "Session"   = "19"
        } -> null
      - tags_all                             = {
          - "ManagedBy" = "Terraform"
          - "Name"      = "session19-vpc"
          - "Session"   = "19"
        } -> null
        # (4 unchanged attributes hidden)
    }

Plan: 0 to add, 0 to change, 6 to destroy.

Changes to Outputs:
  - security_group_id = "sg-0a17f856a99b60a4c" -> null
  - subnet_id         = "subnet-0dee42e412b39f189" -> null
  - vpc_cidr          = "10.0.0.0/16" -> null
  - vpc_id            = "vpc-0955852e28092540e" -> null

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

aws_route_table_association.public: Destroying... [id=rtbassoc-045731bcfa7f2111e]
aws_security_group.web: Destroying... [id=sg-0a17f856a99b60a4c]
aws_route_table_association.public: Destruction complete after 2s
aws_subnet.public: Destroying... [id=subnet-0dee42e412b39f189]
aws_route_table.public: Destroying... [id=rtb-0072793d2f6825629]
aws_security_group.web: Destruction complete after 2s
aws_route_table.public: Destruction complete after 2s
aws_internet_gateway.main: Destroying... [id=igw-0f05e13e9f1ea1214]
aws_subnet.public: Destruction complete after 2s
aws_internet_gateway.main: Destruction complete after 1s
aws_vpc.main: Destroying... [id=vpc-0955852e28092540e]
aws_vpc.main: Destruction complete after 1s

Destroy complete! Resources: 6 destroyed.

…/session19-cloud-terraform/06-terraform-vpc main  ? ❯ 
