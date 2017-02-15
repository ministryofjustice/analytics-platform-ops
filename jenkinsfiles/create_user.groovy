node {

    checkout scm

    withCredentials([
        file(credentialsId: 'analytics-ops-gpg.key', variable: 'GPG_KEY')]) {

        sh "git-crypt unlock ${GPG_KEY}"
    }

    stage ("Apply resources") {
        sh """
        USERNAME=\$(echo '${env.USERNAME}' | tr '[:upper:]' '[:lower:]')

        for f in k8s-templates/user-base/default-namespace/*
        do
            cat \$f \\
            | sed \\
                -e s/{{\\.Username}}/\$USERNAME/g \\
                -e s/{{\\.EFSHostname}}/${env.EFS_HOSTNAME}/g \\
            | kubectl apply -f -
        done

        for f in k8s-templates/user-base/user-namespace/*
        do
            cat \$f \\
            | sed \\
                -e s/{{\\.Username}}/\$USERNAME/g \\
            | kubectl apply -n user-\$USERNAME -f -
        done
        """
    }
}
