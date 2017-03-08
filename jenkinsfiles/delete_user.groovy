node {

    stage ("Git checkout") {
        checkout scm
    }

    stage ("Delete platform user") {
        sh "jenkinsfiles/delete_user.sh ${env.USERNAME}"
    }
}
