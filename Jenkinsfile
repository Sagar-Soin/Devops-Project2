pipeline{
    agent any
    
    environment{
        IMAGE_NAME = 'my-nginx-webserver-pipeline'
        JFROG_REPO = 'https://trialfd07jy.jfrog.io/artifactory/sagar-my-nginx-jfrog/'
        GIT_REPO_URL = 'https://github.com/Sagar-Soin/Devops-Project2.git'
        JFROG_URL = 'https://trialfd07jy.jfrog.io'
        KUBECONFIG = credentials('kubeconfig')   
    }
    stages{
        stage('Checkout'){
            steps{
                git branch: 'master', url: "${GIT_REPO_URL}"
            }    
        }
        stage('Build the Image using DOcker'){
            steps{
                script{
                    sh """
                        docker images 
                        docker build -t ${IMAGE_NAME} .
                    """
                }
            }
        }
        stage('Scan with Trivy If image exists') {
            steps {
                script {
                    def imageExists = sh(
                        script: "docker images | grep ${IMAGE_NAME}",
                        returnStatus: true
                    )

                    if (imageExists == 0) {
                        echo "✅ Image found: ${IMAGE_NAME}. Running Trivy scan..."

                        // 👇 This will prevent failure even if exit-code is 1
                        catchError(buildResult: 'SUCCESS', stageResult: 'SUCCESS') {
                            sh """
                                trivy image --ignore-unfixed --exit-code 1 --severity CRITICAL ${IMAGE_NAME}
                            """
                        }

                        echo "ℹ️ Trivy scan completed. Vulnerabilities (if any) reported above. Proceeding..."

                        withCredentials([usernamePassword(
                            credentialsId: 'Jfrog_SAAS',
                            usernameVariable: 'JF_USER',
                            passwordVariable: 'JF_PASS'
                        )]) {
                            sh """
                                docker tag ${IMAGE_NAME} trialfd07jy.jfrog.io/sagar-my-nginx-jfrog/${IMAGE_NAME}
                                docker login $JFROG_URL -u $JF_USER -p $JF_PASS
                                docker push trialfd07jy.jfrog.io/sagar-my-nginx-jfrog/${IMAGE_NAME}
                                echo '✅ Image pushed to JFrog successfully.'
                            """
                        }

                    } else {
                        echo "⚠️ Docker image ${IMAGE_NAME} not found. Skipping Trivy scan."
                        currentBuild.result = 'UNSTABLE'  // optional
                    }
                }
            }
        }
        stage('Deployment to K8s CLuster'){
            steps{
                withCredentials([file(credentialsId: 'config', variable: 'KUEBCONFIG')]){
                    sh """
                        export KUBECONFIG=$KUBECONFIG

                        kubectl create secret docker-registry jfrog-regcred \
                            --docker-server=trialfd07jy.jfrog.io \
                            --docker-username=$JF_USER \
                            --docker-password=$JF_PASS \
                            --docker-email=you@example.com \
                            --dry-run=client -o yaml | kubectl apply -f -
                        
                        kubectl apply -f deployment.yaml
                    """
                }
            }
        }
    }