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
        sh "jenkinsfiles/create_user.sh ${env.PLATFORM_ENV} ${env.USERNAME} ${env.EMAIL} \"${env.FULLNAME}\""
    }
}
