node {

    git "https://github.com/ministryofjustice/analytics-qnd-ops.git"

    stage ("Apply resources") {
        sh """
        USERNAME=\$(echo '${env.USERNAME}' | tr '[:upper:]' '[:lower:]')

        for f in k8s-templates/user-base/*
        do
            cat \$f | sed \\
                -e s/{{\\.Username}}/\$USERNAME/g \\
                -e s/{{\\.EFSHostname}}/${env.EFS_HOSTNAME}/g | \\
            kubectl apply -f -
        done
        """
    }
}
