node {

    git "https://github.com/ministryofjustice/analytics-qnd-ops.git"

    stage ("Apply config") {
        sh """
        for f in k8s-templates/r-studio-config/*
        do
            cat \$f | sed \\
                -e "s/{{\\.ClientSecretB64}}/\$(echo -n ${env.CLIENT_SECRET}|base64)/g" \\
                -e "s/{{\\.ClientIDB64}}/\$(echo -n ${env.CLIENT_ID}|base64)/g" \\
                -e "s/{{\\.Domain}}/\$(echo -n ${env.DOMAIN}|base64)/g" | \\
            kubectl apply -f -
        done
        """
    }
}
