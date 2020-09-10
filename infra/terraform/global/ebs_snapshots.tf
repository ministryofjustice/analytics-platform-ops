// Backup etcd volumes attached to kubernetes masters -->

// Create Snapshot policy document
data "template_file" "lambda_create_snapshot_policy" {
  template = file(
    "assets/create_etcd_ebs_snapshot/lambda_create_snapshot_policy.json",
  )
}

// Lambda requires that we zip the distribution in order to deploy it
data "archive_file" "kubernetes_etcd_ebs_snapshot_code" {
  source_file = "assets/create_etcd_ebs_snapshot/create_etcd_ebs_snapshot"
  output_path = "assets/create_etcd_ebs_snapshot/create_etcd_ebs_snapshot.zip"
  type        = "zip"
}

module "kubernetes_etcd_ebs_snapshot" {
  source                = "./modules/lambda_mgmt"
  lambda_function_name  = "create_etcd_ebs_snapshot"
  zipfile               = "assets/create_etcd_ebs_snapshot/create_etcd_ebs_snapshot.zip"
  handler               = "create_etcd_ebs_snapshot"
  source_code_hash      = data.archive_file.kubernetes_etcd_ebs_snapshot_code.output_base64sha256
  lamda_policy          = data.template_file.lambda_create_snapshot_policy.rendered
  environment_variables = var.create_etcd_ebs_snapshot_env_vars
  tags                  = local.tags
}

// Prune snapshots -->

data "template_file" "lambda_prune_ebs_snapshots_policy" {
  template = file("assets/prune_ebs_snapshots/prune_ebs_snapshots_policy.json")
}

// Lambda requires that we zip the distribution in order to deploy it
data "archive_file" "kubernetes_prune_ebs_snapshots_code" {
  source_file = "assets/prune_ebs_snapshots/prune_ebs_snapshots"
  output_path = "assets/prune_ebs_snapshots/prune_ebs_snapshots.zip"
  type        = "zip"
}

module "kubernetes_prune_ebs_snapshots" {
  source                = "./modules/lambda_mgmt"
  lambda_function_name  = "prune_ebs_snapshots"
  zipfile               = "assets/prune_ebs_snapshots/prune_ebs_snapshots.zip"
  handler               = "prune_ebs_snapshots"
  source_code_hash      = data.archive_file.kubernetes_prune_ebs_snapshots_code.output_base64sha256
  lamda_policy          = data.template_file.lambda_prune_ebs_snapshots_policy.rendered
  environment_variables = var.prune_etcd_ebs_snapshot_env_vars
  tags                  = local.tags
}

