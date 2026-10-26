# 18

> Run against real AWS (account 737272117751). All labs pin `ap-south-1` in the provider block, so that region was used. Every resource applied was destroyed at the end of its lab.

## 01-iac-basics

```bash
…/session18-terraform-iac/01-iac-basics ❯ terraform init
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

…/session18-terraform-iac/01-iac-basics ❯ terraform fmt

…/session18-terraform-iac/01-iac-basics ❯ terraform validate
Success! The configuration is valid.

…/session18-terraform-iac/01-iac-basics ❯ terraform plan

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket.iac_demo will be created
  + resource "aws_s3_bucket" "iac_demo" {
      + acceleration_status         = (known after apply)
      + acl                         = (known after apply)
      + arn                         = (known after apply)
      + bucket                      = (known after apply)
      + bucket_domain_name          = (known after apply)
      + bucket_namespace            = (known after apply)
      + bucket_prefix               = "session18-iac-"
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
          + "Environment" = "dev"
          + "Name"        = "Session 18 IaC Demo"
        }
      + tags_all                    = {
          + "Environment" = "dev"
          + "Name"        = "Session 18 IaC Demo"
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

…/session18-terraform-iac/01-iac-basics ❯ terraform apply -auto-approve

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket.iac_demo will be created
  + resource "aws_s3_bucket" "iac_demo" {
      + acceleration_status         = (known after apply)
      + acl                         = (known after apply)
      + arn                         = (known after apply)
      + bucket                      = (known after apply)
      + bucket_domain_name          = (known after apply)
      + bucket_namespace            = (known after apply)
      + bucket_prefix               = "session18-iac-"
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
          + "Environment" = "dev"
          + "Name"        = "Session 18 IaC Demo"
        }
      + tags_all                    = {
          + "Environment" = "dev"
          + "Name"        = "Session 18 IaC Demo"
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
aws_s3_bucket.iac_demo: Creating...
aws_s3_bucket.iac_demo: Creation complete after 1s [id=session18-iac-51c09473d8f3e02ad6c75d0893]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

bucket_name = "session18-iac-51c09473d8f3e02ad6c75d0893"

…/session18-terraform-iac/01-iac-basics ❯ terraform output bucket_name
"session18-iac-51c09473d8f3e02ad6c75d0893"

…/session18-terraform-iac/01-iac-basics ❯ terraform state list
aws_s3_bucket.iac_demo

…/session18-terraform-iac/01-iac-basics ❯ terraform destroy -auto-approve
aws_s3_bucket.iac_demo: Refreshing state... [id=session18-iac-51c09473d8f3e02ad6c75d0893]

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_s3_bucket.iac_demo will be destroyed
  - resource "aws_s3_bucket" "iac_demo" {
      - arn                         = "arn:aws:s3:::session18-iac-51c09473d8f3e02ad6c75d0893" -> null
      - bucket                      = "session18-iac-51c09473d8f3e02ad6c75d0893" -> null
      - bucket_domain_name          = "session18-iac-51c09473d8f3e02ad6c75d0893.s3.amazonaws.com" -> null
      - bucket_namespace            = "global" -> null
      - bucket_prefix               = "session18-iac-" -> null
      - bucket_region               = "ap-south-1" -> null
      - bucket_regional_domain_name = "session18-iac-51c09473d8f3e02ad6c75d0893.s3.ap-south-1.amazonaws.com" -> null
      - force_destroy               = false -> null
      - hosted_zone_id              = "Z11RGJOFQNVJUP" -> null
      - id                          = "session18-iac-51c09473d8f3e02ad6c75d0893" -> null
      - object_lock_enabled         = false -> null
      - region                      = "ap-south-1" -> null
      - request_payer               = "BucketOwner" -> null
      - tags                        = {
          - "Environment" = "dev"
          - "Name"        = "Session 18 IaC Demo"
        } -> null
      - tags_all                    = {
          - "Environment" = "dev"
          - "Name"        = "Session 18 IaC Demo"
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
  - bucket_name = "session18-iac-51c09473d8f3e02ad6c75d0893" -> null
aws_s3_bucket.iac_demo: Destroying... [id=session18-iac-51c09473d8f3e02ad6c75d0893]
aws_s3_bucket.iac_demo: Destruction complete after 0s

Destroy complete! Resources: 1 destroyed.
```

## 02-terraform-architecture

```bash
…/session18-terraform-iac/02-terraform-architecture ❯ terraform init
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

…/session18-terraform-iac/02-terraform-architecture ❯ terraform fmt

…/session18-terraform-iac/02-terraform-architecture ❯ terraform validate
Success! The configuration is valid.

…/session18-terraform-iac/02-terraform-architecture ❯ terraform plan

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket.architecture_demo will be created
  + resource "aws_s3_bucket" "architecture_demo" {
      + acceleration_status         = (known after apply)
      + acl                         = (known after apply)
      + arn                         = (known after apply)
      + bucket                      = (known after apply)
      + bucket_domain_name          = (known after apply)
      + bucket_namespace            = (known after apply)
      + bucket_prefix               = "session18-architecture-"
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
          + "Name" = "Session 18 Architecture Demo"
        }
      + tags_all                    = {
          + "Name" = "Session 18 Architecture Demo"
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
  + bucket_arn = (known after apply)

─────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't
guarantee to take exactly these actions if you run "terraform apply" now.

…/session18-terraform-iac/02-terraform-architecture ❯ terraform apply -auto-approve

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket.architecture_demo will be created
  + resource "aws_s3_bucket" "architecture_demo" {
      + acceleration_status         = (known after apply)
      + acl                         = (known after apply)
      + arn                         = (known after apply)
      + bucket                      = (known after apply)
      + bucket_domain_name          = (known after apply)
      + bucket_namespace            = (known after apply)
      + bucket_prefix               = "session18-architecture-"
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
          + "Name" = "Session 18 Architecture Demo"
        }
      + tags_all                    = {
          + "Name" = "Session 18 Architecture Demo"
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
  + bucket_arn = (known after apply)
aws_s3_bucket.architecture_demo: Creating...
aws_s3_bucket.architecture_demo: Creation complete after 2s [id=session18-architecture-dc5740bb49774934d7837d5389]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

bucket_arn = "arn:aws:s3:::session18-architecture-dc5740bb49774934d7837d5389"

…/session18-terraform-iac/02-terraform-architecture ❯ terraform state list
aws_s3_bucket.architecture_demo

…/session18-terraform-iac/02-terraform-architecture ❯ terraform show

…/session18-terraform-iac/02-terraform-architecture ❯ terraform destroy -auto-approve
aws_s3_bucket.architecture_demo: Refreshing state... [id=session18-architecture-dc5740bb49774934d7837d5389]

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_s3_bucket.architecture_demo will be destroyed
  - resource "aws_s3_bucket" "architecture_demo" {
      - arn                         = "arn:aws:s3:::session18-architecture-dc5740bb49774934d7837d5389" -> null
      - bucket                      = "session18-architecture-dc5740bb49774934d7837d5389" -> null
      - bucket_domain_name          = "session18-architecture-dc5740bb49774934d7837d5389.s3.amazonaws.com" -> null
      - bucket_namespace            = "global" -> null
      - bucket_prefix               = "session18-architecture-" -> null
      - bucket_region               = "ap-south-1" -> null
      - bucket_regional_domain_name = "session18-architecture-dc5740bb49774934d7837d5389.s3.ap-south-1.amazonaws.com" -> null
      - force_destroy               = false -> null
      - hosted_zone_id              = "Z11RGJOFQNVJUP" -> null
      - id                          = "session18-architecture-dc5740bb49774934d7837d5389" -> null
      - object_lock_enabled         = false -> null
      - region                      = "ap-south-1" -> null
      - request_payer               = "BucketOwner" -> null
      - tags                        = {
          - "Name" = "Session 18 Architecture Demo"
        } -> null
      - tags_all                    = {
          - "Name" = "Session 18 Architecture Demo"
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
  - bucket_arn = "arn:aws:s3:::session18-architecture-dc5740bb49774934d7837d5389" -> null
aws_s3_bucket.architecture_demo: Destroying... [id=session18-architecture-dc5740bb49774934d7837d5389]
aws_s3_bucket.architecture_demo: Destruction complete after 0s

Destroy complete! Resources: 1 destroyed.
```

## 03-providers

```bash
…/session18-terraform-iac/03-providers ❯ aws sts get-caller-identity
{
    "UserId": "AIDA2XKGXXH3S2WPZRX4M",
    "Account": "737272117751",
    "Arn": "arn:aws:iam::737272117751:user/adminbaby"
}

…/session18-terraform-iac/03-providers ❯ terraform init
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

…/session18-terraform-iac/03-providers ❯ terraform validate
Success! The configuration is valid.

…/session18-terraform-iac/03-providers ❯ terraform plan

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket.provider_demo will be created
  + resource "aws_s3_bucket" "provider_demo" {
      + acceleration_status         = (known after apply)
      + acl                         = (known after apply)
      + arn                         = (known after apply)
      + bucket                      = (known after apply)
      + bucket_domain_name          = (known after apply)
      + bucket_namespace            = (known after apply)
      + bucket_prefix               = "session18-provider-"
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
          + "Name" = "Session 18 Provider Demo"
        }
      + tags_all                    = {
          + "Name" = "Session 18 Provider Demo"
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
  + bucket_id = (known after apply)

─────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't
guarantee to take exactly these actions if you run "terraform apply" now.

…/session18-terraform-iac/03-providers ❯ terraform apply -auto-approve

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket.provider_demo will be created
  + resource "aws_s3_bucket" "provider_demo" {
      + acceleration_status         = (known after apply)
      + acl                         = (known after apply)
      + arn                         = (known after apply)
      + bucket                      = (known after apply)
      + bucket_domain_name          = (known after apply)
      + bucket_namespace            = (known after apply)
      + bucket_prefix               = "session18-provider-"
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
          + "Name" = "Session 18 Provider Demo"
        }
      + tags_all                    = {
          + "Name" = "Session 18 Provider Demo"
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
  + bucket_id = (known after apply)
aws_s3_bucket.provider_demo: Creating...
aws_s3_bucket.provider_demo: Creation complete after 1s [id=session18-provider-4a4ae82b9b3c11205eb6f7ac85]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

bucket_id = "session18-provider-4a4ae82b9b3c11205eb6f7ac85"

…/session18-terraform-iac/03-providers ❯ terraform destroy -auto-approve
aws_s3_bucket.provider_demo: Refreshing state... [id=session18-provider-4a4ae82b9b3c11205eb6f7ac85]

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_s3_bucket.provider_demo will be destroyed
  - resource "aws_s3_bucket" "provider_demo" {
      - arn                         = "arn:aws:s3:::session18-provider-4a4ae82b9b3c11205eb6f7ac85" -> null
      - bucket                      = "session18-provider-4a4ae82b9b3c11205eb6f7ac85" -> null
      - bucket_domain_name          = "session18-provider-4a4ae82b9b3c11205eb6f7ac85.s3.amazonaws.com" -> null
      - bucket_namespace            = "global" -> null
      - bucket_prefix               = "session18-provider-" -> null
      - bucket_region               = "ap-south-1" -> null
      - bucket_regional_domain_name = "session18-provider-4a4ae82b9b3c11205eb6f7ac85.s3.ap-south-1.amazonaws.com" -> null
      - force_destroy               = false -> null
      - hosted_zone_id              = "Z11RGJOFQNVJUP" -> null
      - id                          = "session18-provider-4a4ae82b9b3c11205eb6f7ac85" -> null
      - object_lock_enabled         = false -> null
      - region                      = "ap-south-1" -> null
      - request_payer               = "BucketOwner" -> null
      - tags                        = {
          - "Name" = "Session 18 Provider Demo"
        } -> null
      - tags_all                    = {
          - "Name" = "Session 18 Provider Demo"
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
  - bucket_id = "session18-provider-4a4ae82b9b3c11205eb6f7ac85" -> null
aws_s3_bucket.provider_demo: Destroying... [id=session18-provider-4a4ae82b9b3c11205eb6f7ac85]
aws_s3_bucket.provider_demo: Destruction complete after 1s

Destroy complete! Resources: 1 destroyed.
```

## 04-resources

```bash
…/session18-terraform-iac/04-resources ❯ terraform init
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

…/session18-terraform-iac/04-resources ❯ terraform fmt

…/session18-terraform-iac/04-resources ❯ terraform validate
Success! The configuration is valid.

…/session18-terraform-iac/04-resources ❯ terraform plan

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket.demo will be created
  + resource "aws_s3_bucket" "demo" {
      + acceleration_status         = (known after apply)
      + acl                         = (known after apply)
      + arn                         = (known after apply)
      + bucket                      = (known after apply)
      + bucket_domain_name          = (known after apply)
      + bucket_namespace            = (known after apply)
      + bucket_prefix               = "session18-resource-"
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
          + "Environment" = "dev"
          + "Name"        = "Session 18 Resource Demo"
        }
      + tags_all                    = {
          + "Environment" = "dev"
          + "Name"        = "Session 18 Resource Demo"
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

─────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't
guarantee to take exactly these actions if you run "terraform apply" now.

…/session18-terraform-iac/04-resources ❯ terraform apply -auto-approve

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket.demo will be created
  + resource "aws_s3_bucket" "demo" {
      + acceleration_status         = (known after apply)
      + acl                         = (known after apply)
      + arn                         = (known after apply)
      + bucket                      = (known after apply)
      + bucket_domain_name          = (known after apply)
      + bucket_namespace            = (known after apply)
      + bucket_prefix               = "session18-resource-"
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
          + "Environment" = "dev"
          + "Name"        = "Session 18 Resource Demo"
        }
      + tags_all                    = {
          + "Environment" = "dev"
          + "Name"        = "Session 18 Resource Demo"
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
aws_s3_bucket.demo: Creating...
aws_s3_bucket.demo: Creation complete after 2s [id=session18-resource-8d4d90ef88b25bbc859cf87cec]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

…/session18-terraform-iac/04-resources ❯ terraform state list
aws_s3_bucket.demo

…/session18-terraform-iac/04-resources ❯ terraform show
# aws_s3_bucket.demo:
resource "aws_s3_bucket" "demo" {
    acceleration_status         = null
    arn                         = "arn:aws:s3:::session18-resource-8d4d90ef88b25bbc859cf87cec"
    bucket                      = "session18-resource-8d4d90ef88b25bbc859cf87cec"
    bucket_domain_name          = "session18-resource-8d4d90ef88b25bbc859cf87cec.s3.amazonaws.com"
    bucket_namespace            = "global"
    bucket_prefix               = "session18-resource-"
    bucket_region               = "ap-south-1"
    bucket_regional_domain_name = "session18-resource-8d4d90ef88b25bbc859cf87cec.s3.ap-south-1.amazonaws.com"
    force_destroy               = false
    hosted_zone_id              = "Z11RGJOFQNVJUP"
    id                          = "session18-resource-8d4d90ef88b25bbc859cf87cec"
    object_lock_enabled         = false
    policy                      = null
    region                      = "ap-south-1"
    request_payer               = "BucketOwner"
    tags                        = {
        "Environment" = "dev"
        "Name"        = "Session 18 Resource Demo"
    }
    tags_all                    = {
        "Environment" = "dev"
        "Name"        = "Session 18 Resource Demo"
    }

    grant {
        id          = "507ae2b27373b77452159d69d3bea777f8b62e2dba81329ce0bc11ec7560f624"
        permissions = [
            "FULL_CONTROL",
        ]
        type        = "CanonicalUser"
        uri         = null
    }

    server_side_encryption_configuration {
        rule {
            bucket_key_enabled = false

            apply_server_side_encryption_by_default {
                kms_master_key_id = null
                sse_algorithm     = "AES256"
            }
        }
    }

    versioning {
        enabled    = false
        mfa_delete = false
    }
}
```

Exercise: added the `Project`, `Environment` and `Owner` tags to `main.tf` (left unaligned on purpose), then ran `fmt` + `plan`:

```bash
…/session18-terraform-iac/04-resources ❯ terraform fmt
main.tf

…/session18-terraform-iac/04-resources ❯ terraform plan
aws_s3_bucket.demo: Refreshing state... [id=session18-resource-8d4d90ef88b25bbc859cf87cec]

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # aws_s3_bucket.demo will be updated in-place
  ~ resource "aws_s3_bucket" "demo" {
        id                          = "session18-resource-8d4d90ef88b25bbc859cf87cec"
      ~ tags                        = {
            "Environment" = "dev"
            "Name"        = "Session 18 Resource Demo"
          + "Owner"       = "student"
          + "Project"     = "terraform-training"
        }
      ~ tags_all                    = {
          + "Owner"       = "student"
          + "Project"     = "terraform-training"
            # (2 unchanged elements hidden)
        }
        # (14 unchanged attributes hidden)

        # (3 unchanged blocks hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.

─────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't
guarantee to take exactly these actions if you run "terraform apply" now.

…/session18-terraform-iac/04-resources ❯ terraform destroy -auto-approve
aws_s3_bucket.demo: Refreshing state... [id=session18-resource-8d4d90ef88b25bbc859cf87cec]

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_s3_bucket.demo will be destroyed
  - resource "aws_s3_bucket" "demo" {
      - arn                         = "arn:aws:s3:::session18-resource-8d4d90ef88b25bbc859cf87cec" -> null
      - bucket                      = "session18-resource-8d4d90ef88b25bbc859cf87cec" -> null
      - bucket_domain_name          = "session18-resource-8d4d90ef88b25bbc859cf87cec.s3.amazonaws.com" -> null
      - bucket_namespace            = "global" -> null
      - bucket_prefix               = "session18-resource-" -> null
      - bucket_region               = "ap-south-1" -> null
      - bucket_regional_domain_name = "session18-resource-8d4d90ef88b25bbc859cf87cec.s3.ap-south-1.amazonaws.com" -> null
      - force_destroy               = false -> null
      - hosted_zone_id              = "Z11RGJOFQNVJUP" -> null
      - id                          = "session18-resource-8d4d90ef88b25bbc859cf87cec" -> null
      - object_lock_enabled         = false -> null
      - region                      = "ap-south-1" -> null
      - request_payer               = "BucketOwner" -> null
      - tags                        = {
          - "Environment" = "dev"
          - "Name"        = "Session 18 Resource Demo"
        } -> null
      - tags_all                    = {
          - "Environment" = "dev"
          - "Name"        = "Session 18 Resource Demo"
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
aws_s3_bucket.demo: Destroying... [id=session18-resource-8d4d90ef88b25bbc859cf87cec]
aws_s3_bucket.demo: Destruction complete after 0s

Destroy complete! Resources: 1 destroyed.
```

## 05-variables

README only asks for `plan` here, so nothing was applied.

```bash
…/session18-terraform-iac/05-variables ❯ cp terraform.tfvars.example terraform.tfvars

…/session18-terraform-iac/05-variables ❯ cat terraform.tfvars
aws_region   = "ap-south-1"
environment  = "dev"
project_name = "student-project"

…/session18-terraform-iac/05-variables ❯ terraform init
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

…/session18-terraform-iac/05-variables ❯ terraform fmt

…/session18-terraform-iac/05-variables ❯ terraform validate
Success! The configuration is valid.

…/session18-terraform-iac/05-variables ❯ terraform plan

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket.demo will be created
  + resource "aws_s3_bucket" "demo" {
      + acceleration_status         = (known after apply)
      + acl                         = (known after apply)
      + arn                         = (known after apply)
      + bucket                      = (known after apply)
      + bucket_domain_name          = (known after apply)
      + bucket_namespace            = (known after apply)
      + bucket_prefix               = "student-project-dev-"
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
          + "Environment" = "dev"
          + "Project"     = "student-project"
        }
      + tags_all                    = {
          + "Environment" = "dev"
          + "Project"     = "student-project"
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

─────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't
guarantee to take exactly these actions if you run "terraform apply" now.
```

Exercise: changed `environment = "dev"` to `environment = "test"` in `terraform.tfvars`:

```bash
…/session18-terraform-iac/05-variables ❯ cat terraform.tfvars
aws_region   = "ap-south-1"
environment  = "test"
project_name = "student-project"

…/session18-terraform-iac/05-variables ❯ terraform plan

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket.demo will be created
  + resource "aws_s3_bucket" "demo" {
      + acceleration_status         = (known after apply)
      + acl                         = (known after apply)
      + arn                         = (known after apply)
      + bucket                      = (known after apply)
      + bucket_domain_name          = (known after apply)
      + bucket_namespace            = (known after apply)
      + bucket_prefix               = "student-project-test-"
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
          + "Environment" = "test"
          + "Project"     = "student-project"
        }
      + tags_all                    = {
          + "Environment" = "test"
          + "Project"     = "student-project"
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

─────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't
guarantee to take exactly these actions if you run "terraform apply" now.
```

## 06-outputs

```bash
…/session18-terraform-iac/06-outputs ❯ terraform init
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

…/session18-terraform-iac/06-outputs ❯ terraform plan

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket.demo will be created
  + resource "aws_s3_bucket" "demo" {
      + acceleration_status         = (known after apply)
      + acl                         = (known after apply)
      + arn                         = (known after apply)
      + bucket                      = (known after apply)
      + bucket_domain_name          = (known after apply)
      + bucket_namespace            = (known after apply)
      + bucket_prefix               = "session18-output-"
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
          + "Name" = "Session 18 Output Demo"
        }
      + tags_all                    = {
          + "Name" = "Session 18 Output Demo"
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
  + bucket_arn    = (known after apply)
  + bucket_id     = (known after apply)
  + bucket_region = "ap-south-1"

─────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't
guarantee to take exactly these actions if you run "terraform apply" now.

…/session18-terraform-iac/06-outputs ❯ terraform apply -auto-approve

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket.demo will be created
  + resource "aws_s3_bucket" "demo" {
      + acceleration_status         = (known after apply)
      + acl                         = (known after apply)
      + arn                         = (known after apply)
      + bucket                      = (known after apply)
      + bucket_domain_name          = (known after apply)
      + bucket_namespace            = (known after apply)
      + bucket_prefix               = "session18-output-"
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
          + "Name" = "Session 18 Output Demo"
        }
      + tags_all                    = {
          + "Name" = "Session 18 Output Demo"
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
  + bucket_arn    = (known after apply)
  + bucket_id     = (known after apply)
  + bucket_region = "ap-south-1"
aws_s3_bucket.demo: Creating...
aws_s3_bucket.demo: Creation complete after 2s [id=session18-output-a5f7362aeacb8a0e97f6a42cef]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

bucket_arn = "arn:aws:s3:::session18-output-a5f7362aeacb8a0e97f6a42cef"
bucket_id = "session18-output-a5f7362aeacb8a0e97f6a42cef"
bucket_region = "ap-south-1"

…/session18-terraform-iac/06-outputs ❯ terraform output
bucket_arn = "arn:aws:s3:::session18-output-a5f7362aeacb8a0e97f6a42cef"
bucket_id = "session18-output-a5f7362aeacb8a0e97f6a42cef"
bucket_region = "ap-south-1"

…/session18-terraform-iac/06-outputs ❯ terraform output bucket_id
"session18-output-a5f7362aeacb8a0e97f6a42cef"
```

Exercise: added an `output "bucket_name"` block to `main.tf`:

```bash
…/session18-terraform-iac/06-outputs ❯ terraform apply -auto-approve
aws_s3_bucket.demo: Refreshing state... [id=session18-output-a5f7362aeacb8a0e97f6a42cef]

Changes to Outputs:
  + bucket_name   = "session18-output-a5f7362aeacb8a0e97f6a42cef"

You can apply this plan to save these new output values to the Terraform
state, without changing any real infrastructure.

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

bucket_arn = "arn:aws:s3:::session18-output-a5f7362aeacb8a0e97f6a42cef"
bucket_id = "session18-output-a5f7362aeacb8a0e97f6a42cef"
bucket_name = "session18-output-a5f7362aeacb8a0e97f6a42cef"
bucket_region = "ap-south-1"

…/session18-terraform-iac/06-outputs ❯ terraform output bucket_name
"session18-output-a5f7362aeacb8a0e97f6a42cef"

…/session18-terraform-iac/06-outputs ❯ terraform destroy -auto-approve
aws_s3_bucket.demo: Refreshing state... [id=session18-output-a5f7362aeacb8a0e97f6a42cef]

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_s3_bucket.demo will be destroyed
  - resource "aws_s3_bucket" "demo" {
      - arn                         = "arn:aws:s3:::session18-output-a5f7362aeacb8a0e97f6a42cef" -> null
      - bucket                      = "session18-output-a5f7362aeacb8a0e97f6a42cef" -> null
      - bucket_domain_name          = "session18-output-a5f7362aeacb8a0e97f6a42cef.s3.amazonaws.com" -> null
      - bucket_namespace            = "global" -> null
      - bucket_prefix               = "session18-output-" -> null
      - bucket_region               = "ap-south-1" -> null
      - bucket_regional_domain_name = "session18-output-a5f7362aeacb8a0e97f6a42cef.s3.ap-south-1.amazonaws.com" -> null
      - force_destroy               = false -> null
      - hosted_zone_id              = "Z11RGJOFQNVJUP" -> null
      - id                          = "session18-output-a5f7362aeacb8a0e97f6a42cef" -> null
      - object_lock_enabled         = false -> null
      - region                      = "ap-south-1" -> null
      - request_payer               = "BucketOwner" -> null
      - tags                        = {
          - "Name" = "Session 18 Output Demo"
        } -> null
      - tags_all                    = {
          - "Name" = "Session 18 Output Demo"
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
  - bucket_arn    = "arn:aws:s3:::session18-output-a5f7362aeacb8a0e97f6a42cef" -> null
  - bucket_id     = "session18-output-a5f7362aeacb8a0e97f6a42cef" -> null
  - bucket_name   = "session18-output-a5f7362aeacb8a0e97f6a42cef" -> null
  - bucket_region = "ap-south-1" -> null
aws_s3_bucket.demo: Destroying... [id=session18-output-a5f7362aeacb8a0e97f6a42cef]
aws_s3_bucket.demo: Destruction complete after 1s

Destroy complete! Resources: 1 destroyed.
```

## 07-init-plan-apply

Also tried the saved-plan flow (`plan -out=tfplan` -> `apply tfplan`). The bucket was destroyed after the lab.

```bash
…/session18-terraform-iac/07-init-plan-apply ❯ terraform init
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

…/session18-terraform-iac/07-init-plan-apply ❯ terraform fmt

…/session18-terraform-iac/07-init-plan-apply ❯ terraform validate
Success! The configuration is valid.

…/session18-terraform-iac/07-init-plan-apply ❯ terraform plan

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket.lifecycle_demo will be created
  + resource "aws_s3_bucket" "lifecycle_demo" {
      + acceleration_status         = (known after apply)
      + acl                         = (known after apply)
      + arn                         = (known after apply)
      + bucket                      = (known after apply)
      + bucket_domain_name          = (known after apply)
      + bucket_namespace            = (known after apply)
      + bucket_prefix               = "session18-lifecycle-"
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
          + "Name" = "Session 18 Lifecycle Demo"
        }
      + tags_all                    = {
          + "Name" = "Session 18 Lifecycle Demo"
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

…/session18-terraform-iac/07-init-plan-apply ❯ terraform plan -out=tfplan

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket.lifecycle_demo will be created
  + resource "aws_s3_bucket" "lifecycle_demo" {
      + acceleration_status         = (known after apply)
      + acl                         = (known after apply)
      + arn                         = (known after apply)
      + bucket                      = (known after apply)
      + bucket_domain_name          = (known after apply)
      + bucket_namespace            = (known after apply)
      + bucket_prefix               = "session18-lifecycle-"
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
          + "Name" = "Session 18 Lifecycle Demo"
        }
      + tags_all                    = {
          + "Name" = "Session 18 Lifecycle Demo"
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

Saved the plan to: tfplan

To perform exactly these actions, run the following command to apply:
    terraform apply "tfplan"

…/session18-terraform-iac/07-init-plan-apply ❯ terraform apply tfplan
aws_s3_bucket.lifecycle_demo: Creating...
aws_s3_bucket.lifecycle_demo: Creation complete after 1s [id=session18-lifecycle-d278d9be7c839146a6a5502805]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

bucket_name = "session18-lifecycle-d278d9be7c839146a6a5502805"

…/session18-terraform-iac/07-init-plan-apply ❯ terraform output
bucket_name = "session18-lifecycle-d278d9be7c839146a6a5502805"

…/session18-terraform-iac/07-init-plan-apply ❯ terraform state list
aws_s3_bucket.lifecycle_demo

…/session18-terraform-iac/07-init-plan-apply ❯ terraform destroy -auto-approve
aws_s3_bucket.lifecycle_demo: Refreshing state... [id=session18-lifecycle-d278d9be7c839146a6a5502805]

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_s3_bucket.lifecycle_demo will be destroyed
  - resource "aws_s3_bucket" "lifecycle_demo" {
      - arn                         = "arn:aws:s3:::session18-lifecycle-d278d9be7c839146a6a5502805" -> null
      - bucket                      = "session18-lifecycle-d278d9be7c839146a6a5502805" -> null
      - bucket_domain_name          = "session18-lifecycle-d278d9be7c839146a6a5502805.s3.amazonaws.com" -> null
      - bucket_namespace            = "global" -> null
      - bucket_prefix               = "session18-lifecycle-" -> null
      - bucket_region               = "ap-south-1" -> null
      - bucket_regional_domain_name = "session18-lifecycle-d278d9be7c839146a6a5502805.s3.ap-south-1.amazonaws.com" -> null
      - force_destroy               = false -> null
      - hosted_zone_id              = "Z11RGJOFQNVJUP" -> null
      - id                          = "session18-lifecycle-d278d9be7c839146a6a5502805" -> null
      - object_lock_enabled         = false -> null
      - region                      = "ap-south-1" -> null
      - request_payer               = "BucketOwner" -> null
      - tags                        = {
          - "Name" = "Session 18 Lifecycle Demo"
        } -> null
      - tags_all                    = {
          - "Name" = "Session 18 Lifecycle Demo"
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
  - bucket_name = "session18-lifecycle-d278d9be7c839146a6a5502805" -> null
aws_s3_bucket.lifecycle_demo: Destroying... [id=session18-lifecycle-d278d9be7c839146a6a5502805]
aws_s3_bucket.lifecycle_demo: Destruction complete after 1s

Destroy complete! Resources: 1 destroyed.
```

## 08-destroy

```bash
…/session18-terraform-iac/08-destroy ❯ terraform init
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

…/session18-terraform-iac/08-destroy ❯ terraform apply -auto-approve

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket.destroy_demo will be created
  + resource "aws_s3_bucket" "destroy_demo" {
      + acceleration_status         = (known after apply)
      + acl                         = (known after apply)
      + arn                         = (known after apply)
      + bucket                      = (known after apply)
      + bucket_domain_name          = (known after apply)
      + bucket_namespace            = (known after apply)
      + bucket_prefix               = "session18-destroy-"
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
          + "Name" = "Session 18 Destroy Demo"
        }
      + tags_all                    = {
          + "Name" = "Session 18 Destroy Demo"
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
aws_s3_bucket.destroy_demo: Creating...
aws_s3_bucket.destroy_demo: Creation complete after 1s [id=session18-destroy-732d197a453dc34083dc712937]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

…/session18-terraform-iac/08-destroy ❯ terraform state list
aws_s3_bucket.destroy_demo

…/session18-terraform-iac/08-destroy ❯ terraform plan -destroy
aws_s3_bucket.destroy_demo: Refreshing state... [id=session18-destroy-732d197a453dc34083dc712937]

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_s3_bucket.destroy_demo will be destroyed
  - resource "aws_s3_bucket" "destroy_demo" {
      - arn                         = "arn:aws:s3:::session18-destroy-732d197a453dc34083dc712937" -> null
      - bucket                      = "session18-destroy-732d197a453dc34083dc712937" -> null
      - bucket_domain_name          = "session18-destroy-732d197a453dc34083dc712937.s3.amazonaws.com" -> null
      - bucket_namespace            = "global" -> null
      - bucket_prefix               = "session18-destroy-" -> null
      - bucket_region               = "ap-south-1" -> null
      - bucket_regional_domain_name = "session18-destroy-732d197a453dc34083dc712937.s3.ap-south-1.amazonaws.com" -> null
      - force_destroy               = false -> null
      - hosted_zone_id              = "Z11RGJOFQNVJUP" -> null
      - id                          = "session18-destroy-732d197a453dc34083dc712937" -> null
      - object_lock_enabled         = false -> null
      - region                      = "ap-south-1" -> null
      - request_payer               = "BucketOwner" -> null
      - tags                        = {
          - "Name" = "Session 18 Destroy Demo"
        } -> null
      - tags_all                    = {
          - "Name" = "Session 18 Destroy Demo"
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

─────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't
guarantee to take exactly these actions if you run "terraform apply" now.

…/session18-terraform-iac/08-destroy ❯ terraform destroy -auto-approve
aws_s3_bucket.destroy_demo: Refreshing state... [id=session18-destroy-732d197a453dc34083dc712937]

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_s3_bucket.destroy_demo will be destroyed
  - resource "aws_s3_bucket" "destroy_demo" {
      - arn                         = "arn:aws:s3:::session18-destroy-732d197a453dc34083dc712937" -> null
      - bucket                      = "session18-destroy-732d197a453dc34083dc712937" -> null
      - bucket_domain_name          = "session18-destroy-732d197a453dc34083dc712937.s3.amazonaws.com" -> null
      - bucket_namespace            = "global" -> null
      - bucket_prefix               = "session18-destroy-" -> null
      - bucket_region               = "ap-south-1" -> null
      - bucket_regional_domain_name = "session18-destroy-732d197a453dc34083dc712937.s3.ap-south-1.amazonaws.com" -> null
      - force_destroy               = false -> null
      - hosted_zone_id              = "Z11RGJOFQNVJUP" -> null
      - id                          = "session18-destroy-732d197a453dc34083dc712937" -> null
      - object_lock_enabled         = false -> null
      - region                      = "ap-south-1" -> null
      - request_payer               = "BucketOwner" -> null
      - tags                        = {
          - "Name" = "Session 18 Destroy Demo"
        } -> null
      - tags_all                    = {
          - "Name" = "Session 18 Destroy Demo"
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
aws_s3_bucket.destroy_demo: Destroying... [id=session18-destroy-732d197a453dc34083dc712937]
aws_s3_bucket.destroy_demo: Destruction complete after 0s

Destroy complete! Resources: 1 destroyed.

…/session18-terraform-iac/08-destroy ❯ terraform state list
```

## 09-state

```bash
…/session18-terraform-iac/09-state ❯ terraform init
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

…/session18-terraform-iac/09-state ❯ terraform apply -auto-approve

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket.state_demo will be created
  + resource "aws_s3_bucket" "state_demo" {
      + acceleration_status         = (known after apply)
      + acl                         = (known after apply)
      + arn                         = (known after apply)
      + bucket                      = (known after apply)
      + bucket_domain_name          = (known after apply)
      + bucket_namespace            = (known after apply)
      + bucket_prefix               = "session18-state-"
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
          + "Name" = "Session 18 State Demo"
        }
      + tags_all                    = {
          + "Name" = "Session 18 State Demo"
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
  + bucket_id = (known after apply)
aws_s3_bucket.state_demo: Creating...
aws_s3_bucket.state_demo: Creation complete after 1s [id=session18-state-80e7c11a32b44767449d59cb30]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

bucket_id = "session18-state-80e7c11a32b44767449d59cb30"

…/session18-terraform-iac/09-state ❯ terraform state list
aws_s3_bucket.state_demo

…/session18-terraform-iac/09-state ❯ terraform state show aws_s3_bucket.state_demo
# aws_s3_bucket.state_demo:
resource "aws_s3_bucket" "state_demo" {
    acceleration_status         = null
    arn                         = "arn:aws:s3:::session18-state-80e7c11a32b44767449d59cb30"
    bucket                      = "session18-state-80e7c11a32b44767449d59cb30"
    bucket_domain_name          = "session18-state-80e7c11a32b44767449d59cb30.s3.amazonaws.com"
    bucket_namespace            = "global"
    bucket_prefix               = "session18-state-"
    bucket_region               = "ap-south-1"
    bucket_regional_domain_name = "session18-state-80e7c11a32b44767449d59cb30.s3.ap-south-1.amazonaws.com"
    force_destroy               = false
    hosted_zone_id              = "Z11RGJOFQNVJUP"
    id                          = "session18-state-80e7c11a32b44767449d59cb30"
    object_lock_enabled         = false
    policy                      = null
    region                      = "ap-south-1"
    request_payer               = "BucketOwner"
    tags                        = {
        "Name" = "Session 18 State Demo"
    }
    tags_all                    = {
        "Name" = "Session 18 State Demo"
    }

    grant {
        id          = "507ae2b27373b77452159d69d3bea777f8b62e2dba81329ce0bc11ec7560f624"
        permissions = [
            "FULL_CONTROL",
        ]
        type        = "CanonicalUser"
        uri         = null
    }

    server_side_encryption_configuration {
        rule {
            bucket_key_enabled = false

            apply_server_side_encryption_by_default {
                kms_master_key_id = null
                sse_algorithm     = "AES256"
            }
        }
    }

    versioning {
        enabled    = false
        mfa_delete = false
    }
}

…/session18-terraform-iac/09-state ❯ terraform show
# aws_s3_bucket.state_demo:
resource "aws_s3_bucket" "state_demo" {
    acceleration_status         = null
    arn                         = "arn:aws:s3:::session18-state-80e7c11a32b44767449d59cb30"
    bucket                      = "session18-state-80e7c11a32b44767449d59cb30"
    bucket_domain_name          = "session18-state-80e7c11a32b44767449d59cb30.s3.amazonaws.com"
    bucket_namespace            = "global"
    bucket_prefix               = "session18-state-"
    bucket_region               = "ap-south-1"
    bucket_regional_domain_name = "session18-state-80e7c11a32b44767449d59cb30.s3.ap-south-1.amazonaws.com"
    force_destroy               = false
    hosted_zone_id              = "Z11RGJOFQNVJUP"
    id                          = "session18-state-80e7c11a32b44767449d59cb30"
    object_lock_enabled         = false
    policy                      = null
    region                      = "ap-south-1"
    request_payer               = "BucketOwner"
    tags                        = {
        "Name" = "Session 18 State Demo"
    }
    tags_all                    = {
        "Name" = "Session 18 State Demo"
    }

    grant {
        id          = "507ae2b27373b77452159d69d3bea777f8b62e2dba81329ce0bc11ec7560f624"
        permissions = [
            "FULL_CONTROL",
        ]
        type        = "CanonicalUser"
        uri         = null
    }

    server_side_encryption_configuration {
        rule {
            bucket_key_enabled = false

            apply_server_side_encryption_by_default {
                kms_master_key_id = null
                sse_algorithm     = "AES256"
            }
        }
    }

    versioning {
        enabled    = false
        mfa_delete = false
    }
}


Outputs:

bucket_id = "session18-state-80e7c11a32b44767449d59cb30"

…/session18-terraform-iac/09-state ❯ terraform state pull
{
  "version": 4,
  "terraform_version": "1.15.9",
  "serial": 2,
  "lineage": "e78221f2-4fdf-5daa-e778-07f84d25a8d6",
  "outputs": {
    "bucket_id": {
      "value": "session18-state-80e7c11a32b44767449d59cb30",
      "type": "string"
    }
  },
  "resources": [
    {
      "mode": "managed",
      "type": "aws_s3_bucket",
      "name": "state_demo",
      "provider": "provider[\"registry.terraform.io/hashicorp/aws\"]",
      "instances": [
        {
          "schema_version": 0,
          "attributes": {
            "acceleration_status": "",
            "acl": null,
            "arn": "arn:aws:s3:::session18-state-80e7c11a32b44767449d59cb30",
            "bucket": "session18-state-80e7c11a32b44767449d59cb30",
            "bucket_domain_name": "session18-state-80e7c11a32b44767449d59cb30.s3.amazonaws.com",
            "bucket_namespace": "global",
            "bucket_prefix": "session18-state-",
            "bucket_region": "ap-south-1",
            "bucket_regional_domain_name": "session18-state-80e7c11a32b44767449d59cb30.s3.ap-south-1.amazonaws.com",
            "cors_rule": [],
            "force_destroy": false,
            "grant": [
              {
                "id": "507ae2b27373b77452159d69d3bea777f8b62e2dba81329ce0bc11ec7560f624",
                "permissions": [
                  "FULL_CONTROL"
                ],
                "type": "CanonicalUser",
                "uri": ""
              }
            ],
            "hosted_zone_id": "Z11RGJOFQNVJUP",
            "id": "session18-state-80e7c11a32b44767449d59cb30",
            "lifecycle_rule": [],
            "logging": [],
            "object_lock_configuration": [],
            "object_lock_enabled": false,
            "policy": "",
            "region": "ap-south-1",
            "replication_configuration": [],
            "request_payer": "BucketOwner",
            "server_side_encryption_configuration": [
              {
                "rule": [
                  {
                    "apply_server_side_encryption_by_default": [
                      {
                        "kms_master_key_id": "",
                        "sse_algorithm": "AES256"
                      }
                    ],
                    "bucket_key_enabled": false
                  }
                ]
              }
            ],
            "tags": {
              "Name": "Session 18 State Demo"
            },
            "tags_all": {
              "Name": "Session 18 State Demo"
            },
            "timeouts": null,
            "versioning": [
              {
                "enabled": false,
                "mfa_delete": false
              }
            ],
            "website": [],
            "website_domain": null,
            "website_endpoint": null
          },
          "sensitive_attributes": [],
          "identity_schema_version": 0,
          "identity": {
            "account_id": "737272117751",
            "bucket": "session18-state-80e7c11a32b44767449d59cb30",
            "region": "ap-south-1"
          },
          "private": "eyJlMmJmYjczMC1lY2FhLTExZTYtOGY4OC0zNDM2M2JjN2M0YzAiOnsiY3JlYXRlIjoxMjAwMDAwMDAwMDAwLCJkZWxldGUiOjM2MDAwMDAwMDAwMDAsInJlYWQiOjEyMDAwMDAwMDAwMDAsInVwZGF0ZSI6MTIwMDAwMDAwMDAwMH19"
        }
      ]
    }
  ],
  "check_results": null
}
```

Exercise: changed the `Name` tag in `main.tf` to `"Session 18 State Demo - updated"`:

```bash
…/session18-terraform-iac/09-state ❯ terraform plan
aws_s3_bucket.state_demo: Refreshing state... [id=session18-state-80e7c11a32b44767449d59cb30]

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # aws_s3_bucket.state_demo will be updated in-place
  ~ resource "aws_s3_bucket" "state_demo" {
        id                          = "session18-state-80e7c11a32b44767449d59cb30"
      ~ tags                        = {
          ~ "Name" = "Session 18 State Demo" -> "Session 18 State Demo - updated"
        }
      ~ tags_all                    = {
          ~ "Name" = "Session 18 State Demo" -> "Session 18 State Demo - updated"
        }
        # (14 unchanged attributes hidden)

        # (3 unchanged blocks hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.

─────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't
guarantee to take exactly these actions if you run "terraform apply" now.

…/session18-terraform-iac/09-state ❯ terraform apply -auto-approve
aws_s3_bucket.state_demo: Refreshing state... [id=session18-state-80e7c11a32b44767449d59cb30]

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # aws_s3_bucket.state_demo will be updated in-place
  ~ resource "aws_s3_bucket" "state_demo" {
        id                          = "session18-state-80e7c11a32b44767449d59cb30"
      ~ tags                        = {
          ~ "Name" = "Session 18 State Demo" -> "Session 18 State Demo - updated"
        }
      ~ tags_all                    = {
          ~ "Name" = "Session 18 State Demo" -> "Session 18 State Demo - updated"
        }
        # (14 unchanged attributes hidden)

        # (3 unchanged blocks hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.
aws_s3_bucket.state_demo: Modifying... [id=session18-state-80e7c11a32b44767449d59cb30]
aws_s3_bucket.state_demo: Modifications complete after 0s [id=session18-state-80e7c11a32b44767449d59cb30]

Apply complete! Resources: 0 added, 1 changed, 0 destroyed.

Outputs:

bucket_id = "session18-state-80e7c11a32b44767449d59cb30"

…/session18-terraform-iac/09-state ❯ terraform show
# aws_s3_bucket.state_demo:
resource "aws_s3_bucket" "state_demo" {
    acceleration_status         = null
    arn                         = "arn:aws:s3:::session18-state-80e7c11a32b44767449d59cb30"
    bucket                      = "session18-state-80e7c11a32b44767449d59cb30"
    bucket_domain_name          = "session18-state-80e7c11a32b44767449d59cb30.s3.amazonaws.com"
    bucket_namespace            = "global"
    bucket_prefix               = "session18-state-"
    bucket_region               = "ap-south-1"
    bucket_regional_domain_name = "session18-state-80e7c11a32b44767449d59cb30.s3.ap-south-1.amazonaws.com"
    force_destroy               = false
    hosted_zone_id              = "Z11RGJOFQNVJUP"
    id                          = "session18-state-80e7c11a32b44767449d59cb30"
    object_lock_enabled         = false
    policy                      = null
    region                      = "ap-south-1"
    request_payer               = "BucketOwner"
    tags                        = {
        "Name" = "Session 18 State Demo - updated"
    }
    tags_all                    = {
        "Name" = "Session 18 State Demo - updated"
    }

    grant {
        id          = "507ae2b27373b77452159d69d3bea777f8b62e2dba81329ce0bc11ec7560f624"
        permissions = [
            "FULL_CONTROL",
        ]
        type        = "CanonicalUser"
        uri         = null
    }

    server_side_encryption_configuration {
        rule {
            bucket_key_enabled = false

            apply_server_side_encryption_by_default {
                kms_master_key_id = null
                sse_algorithm     = "AES256"
            }
        }
    }

    versioning {
        enabled    = false
        mfa_delete = false
    }
}


Outputs:

bucket_id = "session18-state-80e7c11a32b44767449d59cb30"

…/session18-terraform-iac/09-state ❯ terraform destroy -auto-approve
aws_s3_bucket.state_demo: Refreshing state... [id=session18-state-80e7c11a32b44767449d59cb30]

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_s3_bucket.state_demo will be destroyed
  - resource "aws_s3_bucket" "state_demo" {
      - arn                         = "arn:aws:s3:::session18-state-80e7c11a32b44767449d59cb30" -> null
      - bucket                      = "session18-state-80e7c11a32b44767449d59cb30" -> null
      - bucket_domain_name          = "session18-state-80e7c11a32b44767449d59cb30.s3.amazonaws.com" -> null
      - bucket_namespace            = "global" -> null
      - bucket_prefix               = "session18-state-" -> null
      - bucket_region               = "ap-south-1" -> null
      - bucket_regional_domain_name = "session18-state-80e7c11a32b44767449d59cb30.s3.ap-south-1.amazonaws.com" -> null
      - force_destroy               = false -> null
      - hosted_zone_id              = "Z11RGJOFQNVJUP" -> null
      - id                          = "session18-state-80e7c11a32b44767449d59cb30" -> null
      - object_lock_enabled         = false -> null
      - region                      = "ap-south-1" -> null
      - request_payer               = "BucketOwner" -> null
      - tags                        = {
          - "Name" = "Session 18 State Demo - updated"
        } -> null
      - tags_all                    = {
          - "Name" = "Session 18 State Demo - updated"
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
  - bucket_id = "session18-state-80e7c11a32b44767449d59cb30" -> null
aws_s3_bucket.state_demo: Destroying... [id=session18-state-80e7c11a32b44767449d59cb30]
aws_s3_bucket.state_demo: Destruction complete after 0s

Destroy complete! Resources: 1 destroyed.

…/session18-terraform-iac/09-state ❯ terraform state list
```

## terraform-s3-demo

```bash
…/session18-terraform-iac/terraform-s3-demo ❯ aws sts get-caller-identity
{
    "UserId": "AIDA2XKGXXH3S2WPZRX4M",
    "Account": "737272117751",
    "Arn": "arn:aws:iam::737272117751:user/adminbaby"
}

…/session18-terraform-iac/terraform-s3-demo ❯ terraform init
Initializing the backend...

Initializing provider plugins...
- Reusing previous version of hashicorp/aws from the dependency lock file
- Installing hashicorp/aws v6.66.0...
- Installed hashicorp/aws v6.66.0 (signed by HashiCorp)

Terraform has made some changes to the provider dependency selections recorded
in the .terraform.lock.hcl file. Review those changes and commit them to your
version control system if they represent changes you intended to make.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.

…/session18-terraform-iac/terraform-s3-demo ❯ terraform fmt

…/session18-terraform-iac/terraform-s3-demo ❯ terraform validate
Success! The configuration is valid.

…/session18-terraform-iac/terraform-s3-demo ❯ terraform apply -auto-approve

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket.devops553 will be created
  + resource "aws_s3_bucket" "devops553" {
      + acceleration_status         = (known after apply)
      + acl                         = (known after apply)
      + arn                         = (known after apply)
      + bucket                      = "yatri1107"
      + bucket_domain_name          = (known after apply)
      + bucket_namespace            = (known after apply)
      + bucket_prefix               = (known after apply)
      + bucket_region               = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = true
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + object_lock_enabled         = (known after apply)
      + policy                      = (known after apply)
      + region                      = "ap-south-1"
      + request_payer               = (known after apply)
      + tags                        = {
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
          + "Name"        = "yatri1107"
          + "Project"     = "Session18"
        }
      + tags_all                    = {
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
          + "Name"        = "yatri1107"
          + "Project"     = "Session18"
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
  + bucket_arn    = (known after apply)
  + bucket_name   = "yatri1107"
  + bucket_region = "ap-south-1"
aws_s3_bucket.devops553: Creating...
╷
│ Error: creating S3 Bucket (yatri1107): operation error S3: CreateBucket, https response error StatusCode: 409, RequestID: 30R1443G3S3Y9H5X, HostID: cQRSG+OZLMeNM857lAoWzwdK7/9bKCGYZqjrtRL2dy5qt8PzwIsKspFesTyhNDM/MIEN/zKrT/EpSqdxcMq1yBRNOCS1lB7n, BucketAlreadyExists: The requested bucket name is not available. The bucket namespace is shared by all users of the system. Please select a different name and try again.
│ 
│   with aws_s3_bucket.devops553,
│   on main.tf line 1, in resource "aws_s3_bucket" "devops553":
│    1: resource "aws_s3_bucket" "devops553" {
│ 
╵
```

The default `bucket_name = "yatri1107"` is already taken by another AWS account (409 `BucketAlreadyExists`; S3 names are global). Fix: create `terraform.tfvars` with a random suffix:

```bash
…/session18-terraform-iac/terraform-s3-demo ❯ echo 'bucket_name = "yatri1107-a79987"' > terraform.tfvars && cat terraform.tfvars
bucket_name = "yatri1107-a79987"

…/session18-terraform-iac/terraform-s3-demo ❯ terraform plan

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket.devops553 will be created
  + resource "aws_s3_bucket" "devops553" {
      + acceleration_status         = (known after apply)
      + acl                         = (known after apply)
      + arn                         = (known after apply)
      + bucket                      = "yatri1107-a79987"
      + bucket_domain_name          = (known after apply)
      + bucket_namespace            = (known after apply)
      + bucket_prefix               = (known after apply)
      + bucket_region               = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = true
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + object_lock_enabled         = (known after apply)
      + policy                      = (known after apply)
      + region                      = "ap-south-1"
      + request_payer               = (known after apply)
      + tags                        = {
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
          + "Name"        = "yatri1107-a79987"
          + "Project"     = "Session18"
        }
      + tags_all                    = {
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
          + "Name"        = "yatri1107-a79987"
          + "Project"     = "Session18"
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
  + bucket_arn    = (known after apply)
  ~ bucket_name   = "yatri1107" -> "yatri1107-a79987"

─────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't
guarantee to take exactly these actions if you run "terraform apply" now.

…/session18-terraform-iac/terraform-s3-demo ❯ terraform apply -auto-approve

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket.devops553 will be created
  + resource "aws_s3_bucket" "devops553" {
      + acceleration_status         = (known after apply)
      + acl                         = (known after apply)
      + arn                         = (known after apply)
      + bucket                      = "yatri1107-a79987"
      + bucket_domain_name          = (known after apply)
      + bucket_namespace            = (known after apply)
      + bucket_prefix               = (known after apply)
      + bucket_region               = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = true
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + object_lock_enabled         = (known after apply)
      + policy                      = (known after apply)
      + region                      = "ap-south-1"
      + request_payer               = (known after apply)
      + tags                        = {
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
          + "Name"        = "yatri1107-a79987"
          + "Project"     = "Session18"
        }
      + tags_all                    = {
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
          + "Name"        = "yatri1107-a79987"
          + "Project"     = "Session18"
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
  + bucket_arn    = (known after apply)
  ~ bucket_name   = "yatri1107" -> "yatri1107-a79987"
aws_s3_bucket.devops553: Creating...
aws_s3_bucket.devops553: Creation complete after 4s [id=yatri1107-a79987]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

bucket_arn = "arn:aws:s3:::yatri1107-a79987"
bucket_name = "yatri1107-a79987"
bucket_region = "ap-south-1"

…/session18-terraform-iac/terraform-s3-demo ❯ terraform output
bucket_arn = "arn:aws:s3:::yatri1107-a79987"
bucket_name = "yatri1107-a79987"
bucket_region = "ap-south-1"

…/session18-terraform-iac/terraform-s3-demo ❯ terraform output bucket_name
"yatri1107-a79987"

…/session18-terraform-iac/terraform-s3-demo ❯ terraform state list
aws_s3_bucket.devops553

…/session18-terraform-iac/terraform-s3-demo ❯ terraform state show aws_s3_bucket.demo
No instance found for the given address!

This command requires that the address references one specific instance.
To view the available instances, use "terraform state list". Please modify
the address to reference a specific instance.
```

The README uses `aws_s3_bucket.demo`, but the resource in `main.tf` is actually called `devops553`, so use that address:

```bash
…/session18-terraform-iac/terraform-s3-demo ❯ terraform state show aws_s3_bucket.devops553
# aws_s3_bucket.devops553:
resource "aws_s3_bucket" "devops553" {
    acceleration_status         = null
    arn                         = "arn:aws:s3:::yatri1107-a79987"
    bucket                      = "yatri1107-a79987"
    bucket_domain_name          = "yatri1107-a79987.s3.amazonaws.com"
    bucket_namespace            = "global"
    bucket_prefix               = null
    bucket_region               = "ap-south-1"
    bucket_regional_domain_name = "yatri1107-a79987.s3.ap-south-1.amazonaws.com"
    force_destroy               = true
    hosted_zone_id              = "Z11RGJOFQNVJUP"
    id                          = "yatri1107-a79987"
    object_lock_enabled         = false
    policy                      = null
    region                      = "ap-south-1"
    request_payer               = "BucketOwner"
    tags                        = {
        "Environment" = "dev"
        "ManagedBy"   = "Terraform"
        "Name"        = "yatri1107-a79987"
        "Project"     = "Session18"
    }
    tags_all                    = {
        "Environment" = "dev"
        "ManagedBy"   = "Terraform"
        "Name"        = "yatri1107-a79987"
        "Project"     = "Session18"
    }

    grant {
        id          = "507ae2b27373b77452159d69d3bea777f8b62e2dba81329ce0bc11ec7560f624"
        permissions = [
            "FULL_CONTROL",
        ]
        type        = "CanonicalUser"
        uri         = null
    }

    server_side_encryption_configuration {
        rule {
            bucket_key_enabled = false

            apply_server_side_encryption_by_default {
                kms_master_key_id = null
                sse_algorithm     = "AES256"
            }
        }
    }

    versioning {
        enabled    = false
        mfa_delete = false
    }
}

…/session18-terraform-iac/terraform-s3-demo ❯ aws s3 ls
2026-10-26 14:31:26 yatri1107-a79987

…/session18-terraform-iac/terraform-s3-demo ❯ aws s3api head-bucket --bucket yatri1107-a79987
{
    "BucketArn": "arn:aws:s3:::yatri1107-a79987",
    "BucketRegion": "ap-south-1",
    "AccessPointAlias": false
}

…/session18-terraform-iac/terraform-s3-demo ❯ terraform plan -destroy
aws_s3_bucket.devops553: Refreshing state... [id=yatri1107-a79987]

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_s3_bucket.devops553 will be destroyed
  - resource "aws_s3_bucket" "devops553" {
      - arn                         = "arn:aws:s3:::yatri1107-a79987" -> null
      - bucket                      = "yatri1107-a79987" -> null
      - bucket_domain_name          = "yatri1107-a79987.s3.amazonaws.com" -> null
      - bucket_namespace            = "global" -> null
      - bucket_region               = "ap-south-1" -> null
      - bucket_regional_domain_name = "yatri1107-a79987.s3.ap-south-1.amazonaws.com" -> null
      - force_destroy               = true -> null
      - hosted_zone_id              = "Z11RGJOFQNVJUP" -> null
      - id                          = "yatri1107-a79987" -> null
      - object_lock_enabled         = false -> null
      - region                      = "ap-south-1" -> null
      - request_payer               = "BucketOwner" -> null
      - tags                        = {
          - "Environment" = "dev"
          - "ManagedBy"   = "Terraform"
          - "Name"        = "yatri1107-a79987"
          - "Project"     = "Session18"
        } -> null
      - tags_all                    = {
          - "Environment" = "dev"
          - "ManagedBy"   = "Terraform"
          - "Name"        = "yatri1107-a79987"
          - "Project"     = "Session18"
        } -> null
        # (3 unchanged attributes hidden)

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
  - bucket_arn    = "arn:aws:s3:::yatri1107-a79987" -> null
  - bucket_name   = "yatri1107-a79987" -> null
  - bucket_region = "ap-south-1" -> null

─────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't
guarantee to take exactly these actions if you run "terraform apply" now.

…/session18-terraform-iac/terraform-s3-demo ❯ terraform destroy -auto-approve
aws_s3_bucket.devops553: Refreshing state... [id=yatri1107-a79987]

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_s3_bucket.devops553 will be destroyed
  - resource "aws_s3_bucket" "devops553" {
      - arn                         = "arn:aws:s3:::yatri1107-a79987" -> null
      - bucket                      = "yatri1107-a79987" -> null
      - bucket_domain_name          = "yatri1107-a79987.s3.amazonaws.com" -> null
      - bucket_namespace            = "global" -> null
      - bucket_region               = "ap-south-1" -> null
      - bucket_regional_domain_name = "yatri1107-a79987.s3.ap-south-1.amazonaws.com" -> null
      - force_destroy               = true -> null
      - hosted_zone_id              = "Z11RGJOFQNVJUP" -> null
      - id                          = "yatri1107-a79987" -> null
      - object_lock_enabled         = false -> null
      - region                      = "ap-south-1" -> null
      - request_payer               = "BucketOwner" -> null
      - tags                        = {
          - "Environment" = "dev"
          - "ManagedBy"   = "Terraform"
          - "Name"        = "yatri1107-a79987"
          - "Project"     = "Session18"
        } -> null
      - tags_all                    = {
          - "Environment" = "dev"
          - "ManagedBy"   = "Terraform"
          - "Name"        = "yatri1107-a79987"
          - "Project"     = "Session18"
        } -> null
        # (3 unchanged attributes hidden)

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
  - bucket_arn    = "arn:aws:s3:::yatri1107-a79987" -> null
  - bucket_name   = "yatri1107-a79987" -> null
  - bucket_region = "ap-south-1" -> null
aws_s3_bucket.devops553: Destroying... [id=yatri1107-a79987]
aws_s3_bucket.devops553: Destruction complete after 2s

Destroy complete! Resources: 1 destroyed.
```

## cleanup-check

Final check that nothing is left behind:

```bash
…/session18-terraform-iac/cleanup-check ❯ aws s3 ls

…/session18-terraform-iac/cleanup-check ❯ aws ec2 describe-vpcs --region ap-south-1 --filters Name=isDefault,Values=false
{
    "Vpcs": []
}

…/session18-terraform-iac/cleanup-check ❯ aws ec2 describe-vpcs --region us-west-1 --filters Name=isDefault,Values=false
{
    "Vpcs": []
}

…/session18-terraform-iac/cleanup-check ❯ aws ec2 describe-vpcs --region ap-south-2 --filters Name=isDefault,Values=false
{
    "Vpcs": []
}
```
