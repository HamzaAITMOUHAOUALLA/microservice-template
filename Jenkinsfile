pipeline {
    agent any
    
    environment {

        /* ================= GLOBAL ================= */

        IMAGE_NAME        = "${env.IMAGE_NAME}"
        CONTAINER_NAME    = "${env.CONTAINER_NAME ?: IMAGE_NAME + '-staging'}"
        STAGING_PORT      = "${env.STAGING_PORT ?: '8080'}"

        /* ================= HARBOR ================= */

        HARBOR_REGISTRY   = "${env.HARBOR_REGISTRY}"
        HARBOR_PROJECT    = "${env.HARBOR_PROJECT}"

        /* ================= TEMPLATE ================= */

        TEMPLATE_REPO   = "${env.TEMPLATE_REPO}"
        TEMPLATE_BRANCH = "${env.TEMPLATE_BRANCH ?: 'main'}"

        /* ================= GITOPS ================= */

        GITOPS_REPO       = "${env.GITOPS_REPO}"
        GITOPS_PATH       = "${env.GITOPS_PATH}"

        /* ================= SOURCE ================= */

        SOURCE_REPO       = "${env.SOURCE_REPO}"
        SOURCE_BRANCH     = "${env.SOURCE_BRANCH ?: 'main'}"
    }

    stages {

    /* ===================================================== */
    /* ======================= CI ========================== */
    /* ===================================================== */

        stage('Checkout') {
            steps {
                git branch: "${SOURCE_BRANCH}",
                    url: "https://${SOURCE_REPO}"
            }
        }
    stages {

        stage('Skip Bot Commit') {
            steps {
                script {
                    def author = sh(script: "git log -1 --pretty=%an", returnStdout: true).trim()
                    if (author == "ci@jenkins.com") {
                        currentBuild.result = 'NOT_BUILT'
                        error("Skipping bot commit")
                    }
                }
            }
        }

        stage('Verify Variables') {
            steps {
                script {
                    def required = [
                        'IMAGE_NAME',
                        'HARBOR_REGISTRY',
                        'HARBOR_PROJECT',
                        'GITOPS_REPO',
                        'TEMPLATE_REPO',
                        'GITOPS_PATH',
                        'SOURCE_REPO'
                    ]
                    for (var in required) {
                        if (!env."${var}") {
                            error "Missing variable: ${var} ❌"
                        }
                    }
                }
            }
        }

        stage('Build') {
            steps {
                sh '''
                if [ -f mvnw ]; then
                  chmod +x mvnw
                  ./mvnw clean package -DskipTests
                else
                  mvn clean package -DskipTests
                fi
                '''
            }
        }
/*
        stage('Unit Tests') {
            steps {
                sh '''
                if [ -f mvnw ]; then
                  ./mvnw test
                else
                  mvn test
                fi
                '''
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQubeServer') {
                    withCredentials([string(credentialsId: 'jenkinstoken', variable: 'SONAR_TOKEN')]) {
                        sh '''
                        if [ -f mvnw ]; then
                          ./mvnw sonar:sonar -Dsonar.login=$SONAR_TOKEN
                        else
                          mvn sonar:sonar -Dsonar.login=$SONAR_TOKEN
                        fi
                        '''
                    }
                }
            }
        }
*/
    /* ===================================================== */
    /* ================== SECURITY ========================= */
    /* ===================================================== */

        stage('Docker Build (Staging Image)') {
            steps {
                sh "docker build -t ${IMAGE_NAME}:staging ."
            }
        }
        /*
        stage('Trivy Security Scan') {
            steps {
                sh '''
                docker run --rm \
                  -v /var/run/docker.sock:/var/run/docker.sock \
                  -v trivy-cache:/root/.cache/ \
                  aquasec/trivy:latest image \
                  --timeout 10m \
                  --scanners vuln \
                  --severity HIGH,CRITICAL \
                  --exit-code 1 \
                  ${IMAGE_NAME}:staging
                '''
            }
        }*/

    /* ===================================================== */
    /* ================== STAGING ========================== */
    /* ===================================================== */

        stage('Clean Previous Container') {
            steps {
                sh '''
                docker stop ${CONTAINER_NAME} || true
                docker rm ${CONTAINER_NAME} || true
                '''
            }
        }

        stage('Deploy to Staging') {
            steps {
                sh '''
                docker run -d \
                  --name ${CONTAINER_NAME} \
                  --network ci-network \
                  -p ${STAGING_PORT}:8080 \
                  ${IMAGE_NAME}:staging
                '''
            }
        }
        stage('Checkout Template') {
            steps {
                dir('template') {
                    git branch: "${TEMPLATE_BRANCH}",
                    url: "https://${TEMPLATE_REPO}"
                }
            }
        }       
        stage('E2E Tests') {
            steps {
                sh '''
                chmod +x template/scripts/e2e-test.sh
                template/scripts/e2e-test.sh
                '''
            }
        }

    /* ===================================================== */
    /* ================== PRODUCTION ======================= */
    /* ===================================================== */

        stage('Calculate Version') {
            steps {
                sh '''
                chmod +x template/scripts//calculate-version.sh
                template/scripts/calculate-version.sh
                '''
            }
        }

        stage('Build & Push Production Image') {
            steps {
               /* withCredentials([usernamePassword(
                    credentialsId: 'harbor-credentials',
                    usernameVariable: 'HARBOR_USER',
                    passwordVariable: 'HARBOR_PASS'
                )]) {*/
                    sh '''
                    chmod +x template/scripts/push-image.sh
                    template/scripts/push-image.sh
                    '''
               // }

            }
        }

        stage('Update GitOps Repository') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'git-credentials',
                    usernameVariable: 'GIT_USER',
                    passwordVariable: 'GIT_PASS'
                )]) {
                    sh '''
                    chmod +x template/scripts/update-gitops.sh
                    template/scripts/update-gitops.sh
                    '''
                }
            }
        }

        stage('Persist Version') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'git-credentials',
                    usernameVariable: 'GIT_USER',
                    passwordVariable: 'GIT_PASS'
                )]) {
                    sh '''
                    chmod +x template/scripts/persist-version.sh
                    template/scripts/persist-version.sh
                    '''
                }
            }
        }
    }

    post {
        always {
            sh 'docker logout || true'
        }
    }
}