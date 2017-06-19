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

    stage ("Deploy RStudio for user") {
        sh "jenkinsfiles/deploy_rstudio_for_user.sh ${env.PLATFORM_ENV} ${env.USERNAME} ${env.DOCKER_TAG}"
    }
}
