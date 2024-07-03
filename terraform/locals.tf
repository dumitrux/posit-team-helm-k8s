locals {
  # Merge input tags, and deployment-specific tags
  tags = merge(
    var.tags,
    {
      CreatedBy   = "Terraform"
      Environment = var.environment
      Workload    = "Posit-Team"
    }
  )
}
