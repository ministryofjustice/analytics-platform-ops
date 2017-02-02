node {

    checkout scm

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
                -e s/{{\\.RequestCPU}}/${env.REQUEST_CPU}/g \\
                -e s/{{\\.RequestMemory}}/${env.REQUEST_MEMORY}/g \\
                -e s/{{\\.LimitsCPU}}/${env.LIMITS_CPU}/g \\
                -e s/{{\\.LimitsMemory}}/${LIMITS_MEMORY}/g \\
            | kubectl apply -n user-\$USERNAME -f -
        done
        """
    }
}
