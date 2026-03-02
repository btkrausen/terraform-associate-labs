# LAB-04-AWS: Managing Multiple Resources and Dependencies

## Overview
In this lab, you will expand your VPC configuration by adding multiple interconnected resources. You'll learn how Terraform manages dependencies between resources and how to structure more complex configurations. We'll create subnets, route tables, and security groups, all of which are free resources in AWS.

[![Lab 04](https://github.com/btkrausen/terraform-testing/actions/workflows/aws_lab_validation.yml/badge.svg?branch=main&event=push&job=lab_04)](https://github.com/btkrausen/terraform-testing/actions/workflows/aws_lab_validation.yml)

**Preview Mode**: Use `Cmd/Ctrl + Shift + V` in VSCode to see a nicely formatted version of this lab!

## Prerequisites
- Terraform installed
- AWS account with appropriate permissions
- Completion of [LAB-03-AWS](https://github.com/btkrausen/terraform-codespaces/blob/main/labs/lab_03_working_with_variables_and_dependencies/aws.md) with existing VPC configuration

## Estimated Time
30 minutes

## Lab Steps

### 1. Add New Variable Definitions

Add the following to your existing `variables.tf`:

```hcl
# Subnet Variables
variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "availability_zone" {
  description = "Availability zone for subnets"
  type        = string
  default     = "us-east-1a"
}
```

### 2. Create Subnets

Add the following subnet configurations to `main.tf`. Notice how we're using the resource identifier and references to the VPC that was created in Lab 2:

```hcl
# Create Subnets
resource "aws_subnet" "public" {
  vpc_id                 = aws_vpc.main.id
  cidr_block             = var.public_subnet_cidr
  availability_zone      = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
    Environment = var.environment
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.availability_zone

  tags = {
    Name = "private-subnet"
    Environment = var.environment
  }
}
```

> Notice how we're using both resource referencing (to the VPC resource) and using variables to make these resource blocks dynamic and without hardcoding any important values. By simply changing variable values, these subnets could look completely different, including different IP addresses, what availability zone they will be created in, etc.

### 3. Create Route Table

Add a route table for the subnets by adding the following resource block to `main.tf`::

```hcl
# Main Route Table
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "main-route-table"
    Environment = var.environment
  }
}
```

### 4. Create Route Table Associations

Associate the route table with both subnets by adding the following resource blocks to `main.tf`:

```hcl
# Route Table Associations
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.main.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.main.id
}
```

> Note that Terraform knows that the Private and Public subnets and the route table must be created FIRST before these associates can be created since these resources reuquire the IDs of the subnets and route table. This is called an implicit dependancy.

Also, notice how the route table associations use resource referencing to get information about the subnets and the main route table without hardcoding any values.

### 5. Create Security Group

Add a basic security group:

```hcl
# Example Security Group
resource "aws_security_group" "example" {
  name        = "example-security-group"
  description = "Example security group for our VPC"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "example-security-group"
    Environment = var.environment
  }
}
```

### 6. Add New Outputs

Add the following output blocks to your `outputs.tf` file to see information about the newly created subnets:

```hcl
output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = aws_subnet.private.id
}

output "route_table_id" {
  description = "ID of the main route table"
  value       = aws_route_table.main.id
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.example.id
}
```

### 7. Update terraform.tfvars

Add the subnet CIDR values to your existing `terraform.tfvars`:

```hcl
# Subnet Variables
public_subnet_cidr  = "10.0.1.0/24"
private_subnet_cidr = "10.0.2.0/24"
availability_zone   = us-east-1a
```

### 8. Apply the Configuration

Run the following commands:
```bash
terraform fmt
terraform validate
terraform plan
```

> Notice that you get an error, stating that variables are not allowed here. This is because the value for `availability_zone` in our `terraform.tfvars` file was not added as a string - it's missing double-quotes ("). You probably got an error like this (see how the error message gives you the file name (`terraform.tfvars`), the line where the error was caught (`line 6`), the code that is causing the error (`availability_zone = us-east-1a`), and the error message at the bottom):

```bash
terraform git:(main) ✗ terraform plan
╷
│ Error: Variables not allowed
│ 
│   on terraform.tfvars line 6:
│    6: availability_zone   = us-east-1a
│ 
│ Variables may not be used here.
```

> This proves that `terraform validate` doesn't always catch everything, and you might find errrors once you get to a `terraform plan` or `terraform apply` that wasn't caught by `terraform validate`.

Put double-quotes around the value for `availability_zone` in our `terraform.tfvars` fileas shown below:
```hcl
availability_zone = "us-east-1a"
```

Now run a terraform plan again, and it should successful create a plan.
```bash
terraform plan
```

Apply the changes:
```bash
terraform apply
```

Review the proposed changes and type `yes` when prompted to confirm.

## Understanding Resource Dependencies

Notice how Terraform automatically determines the order of resource creation:
1. The VPC must exist before subnets can be created
2. Subnets must exist before route table associations
3. The VPC must exist before the security group

This is handled through implicit dependencies, where Terraform reads the resource configurations and determines the relationships based on resource references (like `vpc_id = aws_vpc.main.id`).

## Verification Steps

In the AWS Console:
1. Navigate to the VPC service
2. Verify the subnets exist and are associated with your VPC
3. Check the route table associations
4. Verify the security group rules

## Success Criteria
Your lab is successful if:
- All resources are created successfully
- Resource dependencies are properly maintained
- All resources have the correct tags
- The security group has the specified rules
- You can see all resource IDs in the outputs

## Additional Exercises
1. Add more security group rules
2. Create subnets in different availability zones
3. Add more specific tags to different resources

## Common Issues and Solutions

If you see dependency errors:
- Verify resource references are correct
- Ensure resources exist before being referenced
- Check for circular dependencies

## Next Steps
In the next lab, we will learn about state management. Keep your Terraform configuration files intact, as we will continue to expand upon them.