output "env" {
    value = "${var.env}"
}

output "control_panel_api_db_host" {
    value = "${module.control_panel_api.db_host}"
}

output "control_panel_api_iam_role_name" {
    value = "${module.control_panel_api.iam_role_name}"
}

output "github_webhooks_secret" {
    value = "${var.gh_hook_secret}"
    sensitive = true
}

output "webhooks_api_url" {
    value = "${module.webhooks_api.url}"
}
