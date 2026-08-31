resource "aws_iam_openid_connect_provider" "github" {
  url             = local.oidc_url
  client_id_list  = [local.oidc_audience]
  thumbprint_list = local.oidc_thumbprints
  tags            = local.tags
}
