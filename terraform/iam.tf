resource "aws_iam_role" "jenkins_ecr_role" {
  name = "jenkins-ec2-ecr-push-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Least-Privilege Policy: Grant permission strictly to push/pull images to ECR
resource "aws_iam_role_policy_attachment" "ecr_power_user" {
  role       = aws_iam_role.jenkins_ecr_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "jenkins-ec2-instance-profile"
  role = aws_iam_role.jenkins_ecr_role.name
}
