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

    stage ("Deploy shiny app") {
        sh "jenkinsfiles/deploy_shiny_app.sh ${env.PLATFORM_ENV} ${env.APP_NAME} ${env.REPO_URL} ${env.BRANCH} ${env.REVISION}"
    }
}
