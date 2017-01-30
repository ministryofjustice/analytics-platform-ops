node {

    git "https://github.com/ministryofjustice/analytics-qnd-ops.git"

    stage ("Deploy RStudio") {
        sh """
        USERNAME=${env.USERNAME}
        CALLBACK_URL=$(echo -n "https://r-studio.${env.USERNAME}.users.analytics.kops.integration.dsd.io/callback"|base64)
        COOKIE_SECRET=$(echo -n "${env.COOKIE_SECRET}"|base64)

        for f in k8s-templates/r-studio-user/*
        do
            cat \$f | sed \\
                -e s/{{\\.Username}}/\${USERNAME}/g \\
                -e s/{{\\.CallbackURLB64}}/\${CALLBACK_URL}/g \\
                -e s/{{\\.CookieSecretB64}}/\${COOKIE_SECRET}/g | \\
            kubectl apply -f -
        done
        """
    }
}
