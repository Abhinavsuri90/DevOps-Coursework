# Session 18: Terraform & Infrastructure as Code

**Course:** SST DevOps & Cloud · **Author:** Abhinav (24BCS10282)

Terraform v1.16.5 with the AWS provider 6.68, region `ap-south-1` (Mumbai).

| Task | Where |
| --- | --- |
| 1. Terraform S3 demo: `main.tf`, `variables.tf`, `outputs.tf`, `provider.tf`, `terraform.tfvars`, `README.md` and the full workflow | [terraform-s3-demo/](terraform-s3-demo/) → [README](terraform-s3-demo/README.md) |
| 2. AWS services research, one README per service | [aws-services/](aws-services/) |

```text
session18-terraform-iac/
├── terraform-s3-demo/
│   ├── provider.tf          # terraform block (version pins) + AWS provider with default_tags
│   ├── variables.tf         # aws_region, bucket_name (validated), environment, owner
│   ├── main.tf              # bucket + versioning + encryption + public access block + sample object
│   ├── outputs.tf           # bucket name, ARN, region, versioning status, object URI
│   ├── terraform.tfvars     # non-secret inputs (no credentials)
│   ├── .terraform.lock.hcl  # pinned provider checksums (committed on purpose)
│   └── README.md            # the complete workflow
├── aws-services/
│   ├── 01-iam/README.md            # Governance
│   ├── 02-ec2/README.md            # Compute
│   ├── 03-s3/README.md             # Storage
│   ├── 04-vpc/README.md            # Networking
│   └── 05-dynamodb-rds/README.md   # Database services
├── evidence/                # recorded command output
└── screenshots/             # renders of that output
```

## What Infrastructure as Code means

Infrastructure as Code (IaC) describes servers, networks, buckets and permissions in **versioned text files** instead of console clicks. Terraform is **declarative**: you write the desired end state, and Terraform works out the API calls needed to get there.

| Concept | Meaning | In the S3 demo |
| --- | --- | --- |
| **Provider** | Plugin that talks to one platform's API | `hashicorp/aws ~> 6.68` in [provider.tf](terraform-s3-demo/provider.tf) |
| **Resource** | Something Terraform creates and manages | `aws_s3_bucket`, `aws_s3_bucket_versioning`, `aws_s3_object` … |
| **Variable** | Input that makes the code reusable | `bucket_name` with a `validation` block that rejects invalid names before any API call |
| **Output** | Value printed after apply and readable with `terraform output` | `bucket_arn`, `sample_object_uri` |
| **State** | Terraform's record mapping code to real resource IDs (`terraform.tfstate`) | Kept locally and git-ignored, because it can contain sensitive values. Teams keep it in a remote backend (S3 + locking) |
| **Plan** | Diff between the code and reality. Nothing changes until `apply` | `terraform plan` |
| **Dependency graph** | Order derived from references (`aws_s3_bucket.demo.id`) | All four child resources wait for the bucket |

## The Terraform workflow

| Command | What it does |
| --- | --- |
| `terraform init` | Downloads the provider into `.terraform/` and writes or uses `.terraform.lock.hcl`. Needed once per folder and after provider changes |
| `terraform fmt` | Rewrites files into the canonical style (`-check` only reports) |
| `terraform validate` | Checks syntax, types and references, without calling AWS |
| `terraform plan` | Reads current state, calls AWS to refresh it, and shows `+ create`, `~ update` and `- destroy` actions |
| `terraform apply` | Executes the plan after you type `yes` (or applies a saved plan file) |
| `terraform show` | Prints the current state in human-readable form |
| `terraform output` | Prints the outputs (`-raw name` for scripts) |
| `terraform destroy` | Plans and executes the deletion of everything in the state |

`init`, `fmt`, `validate`, `providers` and `graph` were run and recorded. They need no cloud access:

![terraform init, fmt, validate and the dependency graph](screenshots/01-init-fmt-validate-graph.png)

`plan`, `apply`, `show`, `output` and `destroy` talk to AWS, so they need credentials, from `aws login` (browser sign-in) or `aws configure` (an IAM user's access key). The exact commands and what to check at each step are in [terraform-s3-demo/README.md](terraform-s3-demo/README.md#run-it-on-aws).

## AWS services research

| # | Service | Topics covered |
| --- | --- | --- |
| 01 | [IAM — Governance](aws-services/01-iam/README.md) | What IAM is, users, groups, roles, policies, permissions, least privilege, best practices, use cases |
| 02 | [EC2 — Compute](aws-services/02-ec2/README.md) | What EC2 is, AMIs, instance types, key pairs, security groups, EBS, public vs private IP, instance lifecycle, use cases |
| 03 | [S3 — Storage](aws-services/03-s3/README.md) | What S3 is, buckets, objects, storage classes, versioning, lifecycle policies, encryption, bucket policies, use cases |
| 04 | [VPC — Networking](aws-services/04-vpc/README.md) | What a VPC is, CIDR, subnets, route tables, Internet Gateway, NAT Gateway, security groups, network ACLs, public vs private subnets |
| 05 | [DynamoDB & RDS — Databases](aws-services/05-dynamodb-rds/README.md) | DynamoDB: NoSQL, tables, items, attributes, partition key, sort key, use cases. RDS: relational model, engines, DB instances, security, backups, Multi-AZ, read replicas, use cases |

## Lessons learned

- **Validate before touching the cloud.** `fmt` + `validate` (and a `validation` block on inputs) catch mistakes for free, before `plan` makes any API calls.
- **Commit the lock file, never the state.** `.terraform.lock.hcl` makes every machine use the same provider build, while `*.tfstate` stays out of Git.
- **Secure defaults belong in code.** Versioning, encryption and Block Public Access are part of the resource definitions, so every bucket created from this code gets them.
- **`destroy` is part of the workflow.** `force_destroy = true` lets the demo bucket be deleted even though it holds objects.
