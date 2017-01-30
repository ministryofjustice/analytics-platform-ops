node {

    git "https://github.com/ministryofjustice/analytics-qnd-ops.git"

    stage ("Deploy RStudio") {
        sh """
        CALLBACK_URL=\$(echo -n "https://${env.USERNAME}.r-studio.users.analytics.kops.integration.dsd.io/callback"|base64 -w 0)
        COOKIE_SECRET=\$(echo -n "${env.COOKIE_SECRET}"|base64 -w 0)

        for f in k8s-templates/r-studio-user/*
        do
            cat \$f | sed \\
                -e s/{{\\.Username}}/${env.USERNAME}/g \\
                -e s/{{\\.CallbackURLB64}}/\${CALLBACK_URL}/g \\
                -e s/{{\\.CookieSecretB64}}/\${COOKIE_SECRET}/g | \\
            kubectl apply -f -
        done
        """
    }
}
