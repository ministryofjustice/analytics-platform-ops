node {

    stage ("Git checkout") {
        checkout scm
    }

    stage ("Decrypt secrets") {
        withCredentials([
            file(credentialsId: 'analytics-ops-gpg.key', variable: 'GPG_KEY')]) {

            sh "git-crypt unlock ${GPG_KEY}"
        }
    }

    stage ("Create platform user") {
        withCredentials([
            string(
                credentialsId: 'GITHUB_TOKEN',
                variable: 'GITHUB_TOKEN'
            )
        ]) {
            sh "/usr/local/bin/create_user ${env.USERNAME} ${env.EMAIL} --env ${env.PLATFORM_ENV} --fullname \"${env.FULLNAME}\""
        }
    }
}
