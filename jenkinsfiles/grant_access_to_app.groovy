node {

    stage ("Git checkout") {
        checkout scm
    }

    // See details on broken pip https://askubuntu.com/a/528625
    stage ("Set up python3 environment") {
        // sh "python3 -m venv venv"
        sh "python3 -m venv --without-pip venv"
        sh "curl https://bootstrap.pypa.io/get-pip.py | venv/bin/python3"
    }

    stage ("Install script dependencies") {
        sh "venv/bin/pip3 install -r jenkinsfiles/auth0-users/requirements.txt"
    }

    // Creates passwordless user in Auth0 and adds to app group
    // NOTE: Groups provided by Auth0 Authorization Extension
    stage ("Create Auth0 passwordless user and add to app group") {
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
        // See "Escaping quotes in Groovy strings":
        //     http://mrhaki.blogspot.co.uk/2009/04/escaping-quotes-in-groovy-strings.html
        params = /${env.AUTH0_DOMAIN} ${env.AUTH0_CLIENT_ID} ${env.AUTH0_CLIENT_SECRET} ${env.AUTHZ_API} "${env.APP_NAME}" ${env.EMAIL}/
        sh "venv/bin/python3 jenkinsfiles/auth0-users/grant_access_to_app.py ${params}"
      }
    }
}
