   pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        DOCKERHUB_USERNAME    = "${env.DOCKERHUB_CREDENTIALS_USR}"
        IMAGE_TAG             = "${env.GIT_COMMIT.take(7)}"
        BACKEND_IMAGE         = "${env.DOCKERHUB_USERNAME}/todo-backend:${env.IMAGE_TAG}"
        FRONTEND_IMAGE        = "${env.DOCKERHUB_USERNAME}/todo-frontend:${env.IMAGE_TAG}"
        VPS_HOST              = credentials('vps-host')
        APP_DIR               = "mern-todo-app"

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
        stage('Verify') {
        // ─────────────────────────────────────
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                dir("${APP_DIR}/backend") {
                    sh 'npm ci'
                    sh 'npm run check'
                    sh 'npm test'
                }
            }
        }

        // ─────────────────────────────────────
        stage('Build Images') {
        // ─────────────────────────────────────
            steps {
                script {
                    docker.build("${BACKEND_IMAGE}", "./${APP_DIR}/backend")
                    docker.build("${FRONTEND_IMAGE}", "./${APP_DIR}/frontend")
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
                            ${APP_DIR}/docker-compose.prod.yml \\
                            root@${VPS_HOST}:~/DevOps2_CapStonePrj/${APP_DIR}/

                        # SSH vào VPS và deploy
                        ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no root@${VPS_HOST} '
                            cd ~/DevOps2_CapStonePrj/${APP_DIR}

                            # Backup config hiện tại để rollback
                            cp .env.prod .env.prod.backup

                            # Cập nhật IMAGE_TAG
                            sed -i "s/IMAGE_TAG=.*/IMAGE_TAG=${IMAGE_TAG}/" .env.prod

                            # Pull và deploy
                            export \$(cat .env.prod | xargs)
                            docker-compose -f docker-compose.prod.yml pull
                            docker-compose -f docker-compose.prod.yml up -d
                            docker image prune -f
                            docker-compose -f docker-compose.prod.yml ps

                            # Healthcheck sau deploy
                            echo "Waiting for backend to start..."
                            for i in \$(seq 1 5); do
                                STATUS=\$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/health || echo "000")
                                echo "Attempt \$i: HTTP \$STATUS"
                                if [ "\$STATUS" = "200" ]; then
                                    echo "Healthcheck passed!"
                                    exit 0
                                fi
                                sleep 10
                            done
                            echo "Healthcheck failed after 5 attempts"
                            exit 1
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
            echo "❌ Pipeline thất bại. Đang thực hiện rollback..."
            withCredentials([
                sshUserPrivateKey(credentialsId: 'vps-ssh-key', keyFileVariable: 'SSH_KEY')
            ]) {
                sh """
                    ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no root@${VPS_HOST} '
                        cd ~/DevOps2_CapStonePrj/${APP_DIR}
                        if [ -f .env.prod.backup ]; then
                            echo "Rolling back to previous image..."
                            cp .env.prod.backup .env.prod
                            export \$(cat .env.prod | xargs)
                            docker-compose -f docker-compose.prod.yml pull
                            docker-compose -f docker-compose.prod.yml up -d
                            echo "Rollback completed"
                        else
                            echo "No backup found, cannot rollback"
                        fi
                    ' || true
                """
            }
        }
        always {
            sh "docker image prune -f || true"
        }
    }
}