/*
 * This rule is managed by Terraform, DO NOT EDIT!
 */
function (user, context, callback) {
  const arn_prefix = `arn:aws:iam::${configuration.AWS_ACCOUNT_ID}`;
  const env = configuration.ENV;
  const username = user.nickname.toLowerCase();
  const role_arn = `${arn_prefix}:role/${env}_user_${username}`;
  const provider_arn = `${arn_prefix}:saml-provider/${env}-auth0`;

  user.awsRole = role_arn + ',' + provider_arn;
  user.awsRoleSession = username;

  context.samlConfiguration.mappings = {
    'https://aws.amazon.com/SAML/Attributes/Role': 'awsRole',
    'https://aws.amazon.com/SAML/Attributes/RoleSessionName': 'awsRoleSession'
  };

  callback(null, user, context);
}
