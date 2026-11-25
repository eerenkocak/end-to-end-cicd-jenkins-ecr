variable "aws_region" {
  description = "Target AWS region for CI/CD infrastructure"
  type        = string
  default     = "eu-north-1"
}

variable "ecr_repo_name" {
  description = "Name of the private AWS ECR repository"
  type        = string
  default     = "devsecops-telemetry-prod"
}

variable "instance_type" {
  description = "EC2 instance type for Jenkins controller (Constrained by FinOps)"
  type        = string
  default     = "t3.small"

  validation {
    condition     = contains(["t3.small", "t3.medium"], var.instance_type)
    error_message = "FinOps Guardrail: Jenkins controller must be t3.small or t3.medium."
  }
}
