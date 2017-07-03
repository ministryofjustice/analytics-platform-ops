pipeline {

    agent any

    parameters{
        string(name: 'APP_NAME', description: 'Shiny App name: e.g. rshiny-test')
        string(name: 'EMAILS', description: 'List of email addresses')
    }

    stages {
        stage ("Create Auth0 passwordless user and add to app group") {
            environment {
                AUTHZ_API_ID = 'urn:auth0-authz-api'
                AUTHZ_API_URL = credentials('auth0-authz-api-url')
                AUTH0_CLIENT = credentials('auth0-api-client')
                AUTH0_DOMAIN = "${PLATFORM_ENV}-analytics-moj.eu.auth0.com"
            }
            steps {
                sh "grant_access ${params.APP_NAME} '${params.EMAILS}'"
            }
        }
    }
}
