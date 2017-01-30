node {

    git "https://github.com/ministryofjustice/analytics-qnd-ops.git"

    stage ("Apply config") {
        sh """
        for f in k8s-templates/r-studio-config/*
        do
            cat \$f | sed \\
                -e "s/{{\\.ClientSecretB64}}/$(echo -n ${env.ClientSecret}|base64)/g" \\
                -e "s/{{\\.ClientIDB64}}/$(echo -n ${env.ClientID}|base64)/g" \\
                -e "s/{{\\.Domain}}/$(echo -n ${env.Domain}|base64)/g" | \\
            kubectl apply -f -
        done
        """
    }
}
