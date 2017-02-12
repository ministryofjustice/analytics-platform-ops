node {

    checkout scm

    stage ("Apply resources") {
        sh """
        for f in k8s-templates/global*
        do
            cat \$f \\
            | sed \\
                -e s/{{\\.EFSHostname}}/${env.EFS_HOSTNAME}/g \\
            | kubectl apply -f -
        done
        """
    }
}
