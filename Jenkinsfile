pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        VPS_HOST              = credentials('vps-host')
        IMAGE_TAG             = "${env.GIT_COMMIT.take(7)}"
        BACKEND_IMAGE         = "${env.DOCKERHUB_CREDENTIALS_USR}/todo-backend:${env.IMAGE_TAG}"
        FRONTEND_IMAGE        = "${env.DOCKERHUB_CREDENTIALS_USR}/todo-frontend:${env.IMAGE_TAG}"
    }

    stages {

        // ─────────────────────────────────────
        stage('Checkout') {
        // ─────────────────────────────────────
            steps {
                checkout scm
                echo "Building commit: ${IMAGE_TAG}"
            }
        }

        // ─────────────────────────────────────
        stage('Build Images') {
        // ─────────────────────────────────────
            steps {
                script {
                    docker.build("${BACKEND_IMAGE}", "./mern-todo-app/backend")
                    docker.build("${FRONTEND_IMAGE}", "./mern-todo-app/frontend")
                }
            }
        }

        // ─────────────────────────────────────
        stage('Push to Docker Hub') {
        // ─────────────────────────────────────
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-credentials') {
                        docker.image("${BACKEND_IMAGE}").push()
                        docker.image("${FRONTEND_IMAGE}").push()
                        docker.image("${BACKEND_IMAGE}").push("latest")
                        docker.image("${FRONTEND_IMAGE}").push("latest")
                    }
                }
            }
        }

        // ─────────────────────────────────────
        stage('Deploy to VPS') {
        // ─────────────────────────────────────
            steps {
                withCredentials([
                    sshUserPrivateKey(credentialsId: 'vps-ssh-key', keyFileVariable: 'SSH_KEY'),
                    string(credentialsId: 'jwt-secret', variable: 'JWT_SECRET_VALUE')
                ]) {
                    sh """
                        scp -i \$SSH_KEY -o StrictHostKeyChecking=no \\
                            mern-todo-app/docker-compose.prod.yml \\
                            root@\$VPS_HOST:~/DevOps2_CapStonePrj/mern-todo-app/

                        ssh -i \$SSH_KEY -o StrictHostKeyChecking=no root@\$VPS_HOST '
                            cd ~/DevOps2_CapStonePrj/mern-todo-app
                            sed -i "s/IMAGE_TAG=.*/IMAGE_TAG=${IMAGE_TAG}/" .env.prod
                            export \$(cat .env.prod | xargs)
                            docker-compose -f docker-compose.prod.yml pull
                            docker-compose -f docker-compose.prod.yml up -d
                            docker image prune -f
                            docker-compose -f docker-compose.prod.yml ps
                        '
                    """
                }
            }
        }

    }

    post {
        success {
            echo "Pipeline thanh cong! App da duoc deploy len VPS."
            echo "URL: http://${VPS_HOST}:3000"
        }
        failure {
            echo "Pipeline that bai. Kiem tra logs o tren."
        }
        always {
            script {
                sh "docker image prune -f || true"
            }
        }
    }
}
