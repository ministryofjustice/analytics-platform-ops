node {

    stage ("Git checkout") {
        git "https://github.com/ministryofjustice/analytics-platform-ops.git"
    }

    stage ("Delete platform user") {
        sh "jenkinsfiles/delete_user.sh ${env.USERNAME}"
    }
}
