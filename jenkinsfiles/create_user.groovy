node {
    stage ("Create namespace") {
sh """
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: user-${env.USERNAME}
EOF
"""
    }

    stage ("Apply kubernetes resources") {
        sh """
        for f in k8s-templates/user-resources/*
        do
            cat \$f | sed \\
                -e 's/{{\\.Username}}/${env.USERNAME}/g' \\
                -e 's/{{\\.EFSHostname}}/${env.EFS_HOSTNAME}/g' | \\
            kubectl apply -n user-${env.USERNAME} -f -
        done
        """
    }
}
