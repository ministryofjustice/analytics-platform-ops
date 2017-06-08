node {

    properties([
        parameters([
            string(
                name: 'APP_NAME',
                description: 'Shiny App name',
                defaultValue: ''),
            string(
                name: 'EMAILS',
                description: 'List of email addresses',
                defaultValue: ''),
        ])
    ])

    stage ("Git checkout") {
        checkout scm
    }

    // Creates passwordless user in Auth0 and adds to app group
    // NOTE: Groups provided by Auth0 Authorization Extension
    env.AUTHZ_API_ID = "urn:auth0-authz-api"
    env.AUTH0_DOMAIN = "${env.ENV}-analytics-moj.eu.auth0.com"
    stage ("Create Auth0 passwordless user and add to app group") {
      withCredentials([
        usernamePassword(
            credentialsId: 'auth0-api-client',
            usernameVariable: 'CLIENT_ID',
            passwordVariable: 'CLIENT_SECRET'),
        string(
            credentialsId: 'auth0-authz-api-url',
            variable: 'AUTHZ_API_URL')
      ]) {
        sh "/usr/local/bin/grant_access ${env.APP_NAME} '${env.EMAILS}'"
      }
    }
}
