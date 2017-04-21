node {

    stage ("Git checkout") {
        checkout scm
    }

    // Also does the following in Authorization Extension:
    // - creates group ${env.APP_NAME}
    // - creates role 'app-viewer' for app
    // - creates permission 'view:app' for app
    // - adds this permission to role
    // - adds this role to this group
    // - adds created user to this group
    stage ("Create Auth0 passwordless user") {
      withCredentials([
        [$class: 'StringBinding', credentialsId: 'AUTH0_DOMAIN', variable:
'AUTH0_DOMAIN'],
        [$class: 'StringBinding', credentialsId: 'AUTH0_CLIENT_ID', variable:
'AUTH0_CLIENT_ID'],
        [$class: 'StringBinding', credentialsId: 'AUTH0_CLIENT_SECRET', variable:
'AUTH0_CLIENT_SECRET'],
        [$class: 'StringBinding', credentialsId: 'AUTHZ_API', variable:
'AUTHZ_API']
      ]) {
        sh "jenkinsfiles/auth0-users/create_auth0_user.py ${env.AUTH0_DOMAIN} ${env.AUTH0_CLIENT_ID} ${env.AUTH0_CLIENT_SECRET} ${env.AUTHZ_API} \\'${env.APP_NAME}\\' ${env.EMAIL}"
      }
    }
}
