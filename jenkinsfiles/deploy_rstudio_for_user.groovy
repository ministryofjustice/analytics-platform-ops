node {

    checkout scm

    stage ("Deploy RStudio") {
        sh """
        USERNAME=\$(echo '${env.USERNAME}' | tr '[:upper:]' '[:lower:]')
        CLIENT_SECRET=\$(echo -n "${env.CLIENT_SECRET}"|base64 -w 0)
        CLIENT_ID=\$(echo -n "${env.CLIENT_ID}"|base64 -w 0)
        DOMAIN=\$(echo -n "${env.DOMAIN}"|base64 -w 0)
        CALLBACK_URL=\$(echo -n "https://\${USERNAME}.rstudio.users.analytics.kops.integration.dsd.io/callback"|base64 -w 0)
        COOKIE_SECRET=\$(echo -n "${env.COOKIE_SECRET}"|base64 -w 0)

        for f in k8s-templates/r-studio-user/*
        do
            cat \$f \\
            | sed \\
                -e s/{{\\.Username}}/\${USERNAME}/g \\
                -e s/{{\\.ClientSecretB64}}/\${CLIENT_SECRET}/g \\
                -e s/{{\\.ClientIDB64}}/\${CLIENT_ID}/g \\
                -e s/{{\\.DomainB64}}/\${DOMAIN}/g \\
                -e s/{{\\.CallbackURLB64}}/\${CALLBACK_URL}/g \\
                -e s/{{\\.CookieSecretB64}}/\${COOKIE_SECRET}/g \\
            | kubectl apply -n user-\${USERNAME} -f -
        done
        """
    }
}
