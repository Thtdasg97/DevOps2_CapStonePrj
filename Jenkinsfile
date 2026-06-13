   pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        DOCKERHUB_USERNAME    = "${env.DOCKERHUB_CREDENTIALS_USR}"
        IMAGE_TAG             = "${env.GIT_COMMIT.take(7)}"
        BACKEND_IMAGE         = "${env.DOCKERHUB_USERNAME}/todo-backend:${env.IMAGE_TAG}"
        FRONTEND_IMAGE        = "${env.DOCKERHUB_USERNAME}/todo-frontend:${env.IMAGE_TAG}"
        VPS_HOST              = credentials('vps-host')
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
                    docker.build("${BACKEND_IMAGE}", "./backend")
                    docker.build("${FRONTEND_IMAGE}", "./frontend")
                }
            }
        }

        // ─────────────────────────────────────
        stage('Push to Docker Hub') {
        // ─────────────────────────────────────
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-credentials') {
                        // Push với tag commit SHA
                        docker.image("${BACKEND_IMAGE}").push()
                        docker.image("${FRONTEND_IMAGE}").push()
                        // Push lại với tag "latest"
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
                        # Copy docker-compose.prod.yml lên VPS
                        scp -i ${SSH_KEY} -o StrictHostKeyChecking=no \\
                            docker-compose.prod.yml \\
                            root@${VPS_HOST}:~/DevOps2_CapStonePrj/mern-todo-app/

                        # SSH vào VPS và deploy
                        ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no root@${VPS_HOST} '
                            cd ~/DevOps2_CapStonePrj/mern-todo-app

                            # Cập nhật IMAGE_TAG
                            sed -i "s/IMAGE_TAG=.*/IMAGE_TAG=${IMAGE_TAG}/" .env.prod

                            # Pull và deploy
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
            echo "✅ Pipeline thành công! App đã được deploy lên VPS."
            echo "🌐 URL: http://${VPS_HOST}:3000"
        }
        failure {
            echo "❌ Pipeline thất bại. Kiểm tra logs ở trên."
        }
        always {
            node {
                sh "docker image prune -f || true"
            }
        }
    }
}