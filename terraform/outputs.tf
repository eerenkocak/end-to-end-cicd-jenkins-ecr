output "jenkins_url" {
  description = "Access URL for the provisioned Jenkins Controller"
  value       = "http://${aws_instance.jenkins_cicd_server.public_ip}:8080"
}

output "ecr_repository_url" {
  description = "Target AWS ECR Repository URI for container artifacts"
  value       = aws_ecr_repository.app_repo.repository_url
}
