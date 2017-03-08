// NOTE: RStudio is not installed as helm chart
//       This should be delete or updated
node {

    stage ("Git checkout") {
        git "https://github.com/ministryofjustice/analytics-platform-ops.git"
    }

    stage ("Decrypt secrets") {
        withCredentials([
            file(credentialsId: 'analytics-ops-gpg.key', variable: 'GPG_KEY')]) {

            sh "git-crypt unlock ${GPG_KEY}"
        }
    }

    stage ("Deploy RStudio for user") {
        sh "jenkinsfiles/deploy_rstudio_for_user.sh ${env.PLATFORM_ENV} ${env.USERNAME}"
    }
}
