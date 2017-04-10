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
        sh "jenkinsfiles/deploy_rstudio_for_user.sh ${env.PLATFORM_ENV} ${env.USERNAME} ${env.AWS_ACCESS_KEY_ID} ${env.AWS_SECRET_ACCESS_KEY}"
    }
}
