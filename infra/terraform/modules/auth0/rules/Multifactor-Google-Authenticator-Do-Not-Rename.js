/*
 * This rule is managed by Terraform, DO NOT EDIT!
 */
function (user, context, callback) {
  const enabledForUser = !user.app_metadata || user.app_metadata.use_mfa;
  const enabledConnections = splitByComma(configuration.MFA_ENABLED_CONNECTIONS);
  const isRefreshTokenExchange = context.protocol === 'oauth2-refresh-token';

  if (enabledForUser &&
      enabledConnections.includes(user.identities[0].connection) &&
      !isRefreshTokenExchange &&
      !inCorporateNetwork(context.request.ip)) {
    useMFA();
  }

  function inCorporateNetwork(ip) {
    const corporateNetworks = splitByComma(configuration.MFA_DISABLED_IP_RANGES);
    return require('range_check').inRange(ip, corporateNetworks);
  }

  function splitByComma(s) {
    return s.split(/,\s*/).map(c => c.trim());
  }

  function useMFA() {
    const env = configuration.ENV.replace(/^\w/, c => c.toUpperCase());
    context.multifactor = {
      provider: 'google-authenticator',
      // optional, the label shown in the authenticator app
      issuer: `MOJ Analytical Platform (${env})`,
      // optional, defaults to true. false forces 2FA every time.
      allowRememberBrowser: false,
    };
  }

  return callback(null, user, context);
}
