// NOTE: RStudio is not installed as helm chart
//       This should be delete or updated
node {

    checkout scm

    stage ("Deploy RStudio") {
        sh """
        USERNAME=\$(echo '${env.USERNAME}' | tr '[:upper:]' '[:lower:]')
        TOOLS_DOMAIN=${env.TOOLS_DOMAIN}
        CLIENT_SECRET=\$(echo -n "${env.CLIENT_SECRET}"|base64 -w 0)
        CLIENT_ID=\$(echo -n "${env.CLIENT_ID}"|base64 -w 0)
        DOMAIN=\$(echo -n "${env.DOMAIN}"|base64 -w 0)
        CALLBACK_URL=\$(echo -n "https://\${USERNAME}.rstudio.${TOOLS_DOMAIN}/callback"|base64 -w 0)
        COOKIE_SECRET=\$(echo -n "${env.COOKIE_SECRET}"|base64 -w 0)
        AWS_DEFAULT_REGION=${env.AWS_DEFAULT_REGION}
        AWS_ACCESS_KEY_ID=\$(echo -n "${env.AWS_ACCESS_KEY_ID}"|base64 -w 0)
        AWS_SECRET_ACCESS_KEY=\$(echo -n "${AWS_SECRET_ACCESS_KEY}"|base64 -w 0)

        for f in k8s-templates/r-studio-user/*
        do
            cat \$f \\
            | sed \\
                -e s/{{\\.Username}}/\${USERNAME}/g \\
                -e s/{{\\.ToolsDomain}}/\${TOOLS_DOMAIN}/g \\
                -e s/{{\\.ClientSecretB64}}/\${CLIENT_SECRET}/g \\
                -e s/{{\\.ClientIDB64}}/\${CLIENT_ID}/g \\
                -e s/{{\\.DomainB64}}/\${DOMAIN}/g \\
                -e s/{{\\.CallbackURLB64}}/\${CALLBACK_URL}/g \\
                -e s/{{\\.CookieSecretB64}}/\${COOKIE_SECRET}/g \\
                -e s/{{\\.AWSDefaultRegion}}/\${AWS_DEFAULT_REGION}/g \\
                -e s/{{\\.AWSAccessKeyIDB64}}/\${AWS_ACCESS_KEY_ID}/g \\
                -e s/{{\\.AWSSecretAccessKeyB64}}/\${AWS_SECRET_ACCESS_KEY}/g \\
            | kubectl apply -n user-\${USERNAME} -f -
        done
        """
    }
}
