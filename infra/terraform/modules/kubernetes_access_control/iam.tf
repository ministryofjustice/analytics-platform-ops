resource "aws_iam_instance_profile" "kubernetes_masters" {
  name = "kubernetes_masters"
  role = "${aws_iam_role.kubernetes_masters.name}"
}

resource "aws_iam_instance_profile" "kubernetes_nodes" {
  name = "kubernetes_nodes"
  role = "${aws_iam_role.kubernetes_nodes.name}"
}

resource "aws_iam_role" "kubernetes_masters" {
  name               = "kubernetes_masters"
  assume_role_policy = "${data.aws_iam_policy_document.kubernetes_assume_role_policy.json}"
}

resource "aws_iam_role" "kubernetes_nodes" {
  name               = "kubernetes_nodes"
  assume_role_policy = "${data.aws_iam_policy_document.kubernetes_assume_role_policy.json}"
}

resource "aws_iam_policy_attachment" "kubernetes_nodes_and_master" {
  name       = "kubernetes_nodes_attachment"
  roles      = [
    "${aws_iam_role.kubernetes_nodes.name}",
    "${aws_iam_role.kubernetes_masters.name}"
  ]
  policy_arn = "${aws_iam_policy.kubernetes_nodes_and_master.arn}"
}

resource "aws_iam_policy_attachment" "kubernetes_masters" {
  name       = "kubernetes_masters_attachment"
  roles      = [
    "${aws_iam_role.kubernetes_masters.name}"
  ]
  policy_arn = "${aws_iam_policy.kubernetes_masters.arn}"
}

resource "aws_iam_policy" "kubernetes_masters" {
  name        = "kubernetes_masters"
  description = "Policy for Kubernetes master instances"
  policy      =  "${data.aws_iam_policy_document.kubernetes_masters_aws_iam_role_policy.json}"
}

resource "aws_iam_policy" "kubernetes_nodes_and_master" {
  name        = "kubernetes_nodes_and_master"
  description = "Policy for Kubernetes node and master instances"
  policy      = "${data.aws_iam_policy_document.kubernetes_nodes_aws_iam_role_policy.json}"
}
