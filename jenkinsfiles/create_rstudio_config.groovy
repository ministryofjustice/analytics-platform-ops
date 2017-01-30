node {

    git "https://github.com/ministryofjustice/analytics-qnd-ops.git"

    stage ("Apply config") {
        sh """
        for f in k8s-templates/r-studio-config/*
        do
            cat \$f | sed \\
                -e s/{{\\.ClientSecretB64}}/${env.CLIENT_SECRET}/g \\
                -e s/{{\\.ClientIDB64}}/${env.CLIENT_ID}/g \\
                -e s/{{\\.Domain}}/${env.DOMAIN}/g | \\
            kubectl apply -f -
        done
        """
    }
}
