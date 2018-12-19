/*
 * This rule is managed by Terraform, DO NOT EDIT!
 */
function (user, context, callback) {
    var rangeCheck = require('range_check');

    var AUTHENTICATOR_LABEL = 'MOJ Analytical Platform (Dev)';
    var CONNECTION = user.identities[0].connection;
    var ENABLED_CONNECTIONS = [
        'github',
        'google-oauth2',
    ];
    var CORPORATE_NETWORK_CIDRS = [
        '157.203.176.138/31',
        '157.203.176.140/32',
        '157.203.177.190/31',
        '157.203.177.192/32',
        '212.137.36.224/32',
        '62.25.109.192/32',
        '195.92.38.16/28',
        '81.134.202.29/32',
        '195.59.75.0/24',
        '194.33.192.0/25',
        '194.33.193.0/25',
        '194.33.196.0/25',
        '194.33.197.0/25',
    ];

    var disabled_for_user = user.app_metadata && user.app_metadata.use_mfa === false;
    var disabled_for_connection = ENABLED_CONNECTIONS.indexOf(CONNECTION) === -1;
    var is_refresh_token_grant = context.protocol === 'oauth2-refresh-token';

    if (disabled_for_user || disabled_for_connection || is_refresh_token_grant) {
        return callback(null, user, context);
    }

    var userIsOnCorporateNetwork =
        rangeCheck.inRange(context.request.ip, CORPORATE_NETWORK_CIDRS);
    if (!userIsOnCorporateNetwork) {
        enableMFA(context);
    }

    function enableMFA(context) {
        context.multifactor = {
            provider: 'google-authenticator',
            // optional, the label shown in the authenticator app
            issuer: AUTHENTICATOR_LABEL,
            // optional, defaults to true. false forces 2FA every time.
            allowRememberBrowser: false,
        };
    }

    return callback(null, user, context);
}
