# End-to-End CI/CD Pipeline & Artifact Management (Jenkins, Trivy & AWS ECR)

[English Documentation](#english-version) | [Turkce Dokumantasyon](#turkce-versiyon)

---

## <a name="english-version"></a>English Version

This repository implements a complete, automated **End-to-End CI/CD & Artifact Delivery Pipeline** on **AWS (`eu-north-1`)** provisioned via **Terraform**, featuring Keyless IAM Instance Profile Authentication, multi-stage Docker builds, **Aqua Security Trivy** vulnerability gating, and immutable image delivery to **Amazon Elastic Container Registry (ECR)**.

### Key Architectural & DevSecOps Practices

* **Keyless AWS Authentication (IAM Instance Profile):** Eliminates static AWS access keys from Jenkins credentials by attaching a least-privilege IAM Role (`AmazonEC2ContainerRegistryPowerUser`) directly to the EC2 controller.
* **Immutable Artifact Management (ECR):** Tags every release with both the Jenkins build number and short Git commit HASH (`v1-a7f9c2c`) inside an `IMMUTABLE`, AES256-encrypted ECR repository to guarantee auditability and deterministic rollbacks.
* **FinOps ECR Lifecycle Policy:** Automatically expires older container images beyond the latest 5 releases to prevent unbounded registry storage costs.
* **DevSecOps Security Gate (Trivy):** Scans every built image for `HIGH` and `CRITICAL` CVEs via Docker socket mounting, blocking the push stage (`--exit-code 1`) if any vulnerability is detected.
* **Infrastructure as Code (`terraform/`):** Provisions the ECR repository, IAM profile, and IMDSv2-hardened Jenkins EC2 controller with FinOps credit caps.

### Project Structure

```text
end-to-end-cicd-jenkins-ecr/
|-- app/

|   |-- package.json     # Node.js dependencies & test scripts
|   |-- server.js        # Telemetry REST API
|   `-- test.js          # Automated unit & sanity checks
|-- terraform/

|   |-- main.tf          # Hardened EC2 & Security Group
|   |-- ecr.tf           # IMMUTABLE AWS ECR & Lifecycle Policy
|   |-- iam.tf           # Keyless IAM Role & Instance Profile
|   |-- variables.tf     # FinOps validation guardrails
|   |-- outputs.tf       # ECR URI & Jenkins URL telemetry
|   `-- userdata.sh      # Automated Jenkins, Docker, AWS CLI & Trivy bootstrap
|-- Dockerfile           # Multi-stage, non-root production image
|-- .dockerignore        # Build context filter
|-- Jenkinsfile          # Declarative CI/CD pipeline with Trivy & AWS ECR push
|-- .gitignore           # State & dependency exclusion rules
`-- README.md
```

---

## <a name="turkce-versiyon"></a>Turkce Versiyon

Bu depo, **AWS (`eu-north-1`)** uzerinde **Terraform, Jenkins, Docker, Trivy ve AWS ECR** kullanilarak insa edilmis uctan uca otomatik bir **CI/CD ve Artifact Yonetim** mimarisidir. GitHub'a yapilan her `push` isleminde tetiklenir; kodu izole konteynerde test eder, multi-stage Docker imaji derler, Trivy guvenlik taramasindan gecirir ve sifrelere ihtiyac duymadan dogrudan AWS ECR deposuna yukler.

### One Cikan Mimari ve DevSecOps Pratikleri

* **Sifresiz AWS Kimlik Dogrulamasi (Keyless IAM Profile):** Jenkins sunucusuna sabit AWS sifreleri gommemek icin EC2 sunucusuna dogrudan en az yetkili IAM Role (`AmazonEC2ContainerRegistryPowerUser`) baglanmistir.
* **Degismez (Immutable) Artifact Yonetimi (ECR):** Her surum, `image_tag_mutability = "IMMUTABLE"` korumasi altindaki AES256 sifreli ECR deposuna hem Jenkins Build numarasi hem de Git Commit HASH ile (`v1-a7f9c2c`) etiketlenerek gonderilir.
* **FinOps ECR Yasam Dongusu Politikasi:** Depolama maliyetlerini kontrol altinda tutmak icin yalnizca son 5 imaj saklanir, eskiler otomatik silinir.
* **DevSecOps Guvenlik Kapisi (Trivy):** ECR'ye gondermeden once imaj `HIGH` ve `CRITICAL` zafiyetlere karsi taranir; kritik acik bulunursa pipeline otomatik durdurulur (`--exit-code 1`).
* **Kod Olarak Altyapi (`terraform/`):** ECR deposu, IAM yetkileri ve IMDSv2 sertlestirmeli Jenkins sunucusu Terraform ile tek komutta kurulur.
