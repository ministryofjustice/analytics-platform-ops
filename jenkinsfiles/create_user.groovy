node {

    git "https://github.com/ministryofjustice/analytics-qnd-ops.git"

    stage ("Apply resources") {
        sh """
        USERNAME=\$(echo '${env.USERNAME}' | tr '[:upper:]' '[:lower:]')

        for f in user-base/default-namespace/*
        do
            cat \$f \
            | sed \
                -e s/{{\.Username}}/\$USERNAME/g \
                -e s/{{\.EFSHostname}}/${env.EFS_HOSTNAME}/g \
            | kubectl apply -f -
        done

        for f in user-base/user-namespace/*
        do
            cat $f \
            | sed -e s/{{.Username}}/\$USERNAME/g \
            | kubectl apply -n user-\$USERNAME -f -
        done
        """
    }
}
