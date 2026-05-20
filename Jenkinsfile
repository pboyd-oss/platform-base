pipeline {
    agent {
        kubernetes {
            inheritFrom 'platform-builder'
        }
    }

    environment {
        IMAGE = 'harbor.tuxgrid.com/platform/base'
    }

    options {
        timeout(time: 30, unit: 'MINUTES')
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '20'))
    }

    triggers {
        pollSCM('H/5 * * * *')
    }

    stages {
        stage('Build') {
            steps {
                container('kaniko') {
                    withCredentials([usernamePassword(
                            credentialsId: 'harbor-robot-platform',
                            usernameVariable: 'HARBOR_USER',
                            passwordVariable: 'HARBOR_PASS')]) {
                        sh '''
                            mkdir -p /kaniko/.docker
                            AUTH=$(printf '%s:%s' "${HARBOR_USER}" "${HARBOR_PASS}" | base64 | tr -d '\n')
                            printf '{"auths":{"harbor.tuxgrid.com":{"auth":"%s"}}}' "${AUTH}" \
                                > /kaniko/.docker/config.json
                            PLATFORM_CA_B64=$(base64 -w0 /mitm-data/ca.pem 2>/dev/null || true)
                            /kaniko/executor \
                                --context=dir://. \
                                --dockerfile=Dockerfile \
                                --build-arg "PLATFORM_CA_B64=${PLATFORM_CA_B64}" \
                                --build-arg HTTPS_PROXY=http://127.0.0.1:8080 \
                                --build-arg HTTP_PROXY=http://127.0.0.1:8080 \
                                --destination=${IMAGE}:${GIT_COMMIT:0:7} \
                                --digest-file=${WORKSPACE}/image.digest \
                                --snapshot-mode=redo \
                                --compressed-caching=false \
                                --cache=true \
                                --cache-repo=harbor.tuxgrid.com/platform/cache/base
                        '''
                    }
                }
            }
        }

        stage('Archive') {
            steps {
                script {
                    env.IMAGE_DIGEST = readFile("${WORKSPACE}/image.digest").trim()
                    writeJSON file: 'artifacts.json', json: [
                        builds: [[tag: "${env.IMAGE}@${env.IMAGE_DIGEST}", number: env.BUILD_NUMBER]]
                    ]
                    archiveArtifacts artifacts: 'artifacts.json', fingerprint: true
                }
            }
        }

        stage('Sign')       { steps { script { platformSign(container: 'cosign') } } }
        stage('Provenance') { steps { script { platformBuildProvenance(simple: true, container: 'cosign') } } }

        stage('Promote') { steps { script { platformPromote() } } }
    }
}
