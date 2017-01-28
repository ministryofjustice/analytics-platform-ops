node {

    git "https://github.com/ministryofjustice/analytics-qnd-ops.git"

    stage ("Apply default namespace resources") {
        sh """
        for f in k8s-templates/user-base/default-namespace/*
        do
            cat \$f | sed \\
                -e 's/{{\\.Username}}/${env.USERNAME}/g' \\
                -e 's/{{\\.EFSHostname}}/${env.EFS_HOSTNAME}/g' | \\
            kubectl apply -f -
        done
        """
    }

    stage ("Apply user namespace resources") {
        sh """
        for f in k8s-templates/user-base/user-namespace/*
        do
            cat \$f | sed \\
                -e 's/{{\\.Username}}/${env.USERNAME}/g' \\
                -e 's/{{\\.EFSHostname}}/${env.EFS_HOSTNAME}/g' | \\
            kubectl apply -n user-${env.USERNAME} -f -
        done
        """
    }
}
