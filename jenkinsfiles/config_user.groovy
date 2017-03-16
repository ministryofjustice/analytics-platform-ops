node {

    stage ("Git checkout") {
        checkout scm
    }

    stage ("User setup (e.g. git config, etc...)") {
        sh "jenkinsfiles/config_user.sh ${env.PLATFORM_ENV} ${env.USERNAME}"
    }
}
