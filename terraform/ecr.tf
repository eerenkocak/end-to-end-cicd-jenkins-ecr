resource "aws_ecr_repository" "app_repo" {
  name                 = var.ecr_repo_name
  image_tag_mutability = "IMMUTABLE" # Security: Prevent overwriting existing image tags
  force_delete         = true        # Clean teardown during terraform destroy

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name = var.ecr_repo_name
  }
}

# FinOps Lifecycle Policy: Retain only the last 5 images to control storage costs
resource "aws_ecr_lifecycle_policy" "cleanup_policy" {
  repository = aws_ecr_repository.app_repo.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 5 production images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 5
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
