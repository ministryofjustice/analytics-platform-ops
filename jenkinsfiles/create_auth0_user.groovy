node {

    stage ("Git checkout") {
        checkout scm
    }

    stage ("Create Auth0 passwordless user") {
        sh "jenkinsfiles/create_auth0_user.sh ${env.EMAIL}"
    }
}
