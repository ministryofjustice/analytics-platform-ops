node {
    stage ("Apply default namespace resources") {
        sh """
        for f in k8s-templates/user-resources/default-namespace/*
        do
            cat \$f | sed \\
                -e 's/{{\\.Username}}/${env.USERNAME}/g' \\
                -e 's/{{\\.EFSHostname}}/${env.EFS_HOSTNAME}/g' | \\
            kubectl apply -n user-${env.USERNAME} -f -
        done
        """
    }

    stage ("Apply user namespace resources") {
        sh """
        for f in k8s-templates/user-resources/user-namespace/*
        do
            cat \$f | sed \\
                -e 's/{{\\.Username}}/${env.USERNAME}/g' \\
                -e 's/{{\\.EFSHostname}}/${env.EFS_HOSTNAME}/g' | \\
            kubectl apply -n user-${env.USERNAME} -f -
        done
        """
    }
}
