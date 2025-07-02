pipeline {
  agent any

  environment {
    IMAGE_NAME  = 'my-nginx-webserver-pipeline'
    JFROG_REPO  = 'https://trialfd07jy.jfrog.io/artifactory/sagar-my-nginx-jfrog/'
    GIT_REPO_URL = 'https://github.com/Sagar-Soin/Devops-Project2.git'
    JFROG_URL    = 'https://trialfd07jy.jfrog.io'
    KUBECONFIG   = credentials('kubeconfig')
  }

  stages {
    stage('Checkout') {
      steps {
        git branch: 'master', url: "${GIT_REPO_URL}"
      }
    }

    stage('Build Docker Image') {
      steps {
        sh """
          docker images
          docker build -t ${IMAGE_NAME} .
        """
      }
    }

    stage('Trivy Scan and Push') {
      steps {
        script {
          def imageFound = sh(script: "docker images -q ${IMAGE_NAME}", returnStatus: true)

          if (imageFound == 0) {
            echo "✅ Image found: ${IMAGE_NAME}. Running Trivy scan..."

            // Use catchError to prevent this stage from failing
            catchError(buildResult: 'UNSTABLE', stageResult: 'UNSTABLE') {
              sh """
                trivy image \
                  --ignore-unfixed \
                  --severity CRITICAL \
                  --exit-code 0 \
                  --skip-version-check \
                  ${IMAGE_NAME}
              """
              
              echo "ℹ️ Trivy scan completed (warnings shown above if any)."
            }

            // Push image irrespective of scan outcome
            withCredentials([usernamePassword(
              credentialsId: 'Jfrog_SAAS',
              usernameVariable: 'JF_USER',
              passwordVariable: 'JF_PASS'
            )]) {
              sh """
                docker tag ${IMAGE_NAME} trialfd07jy.jfrog.io/sagar-my-nginx-jfrog/${IMAGE_NAME}
                docker login ${JFROG_URL} -u ${JF_USER} -p ${JF_PASS}
                docker push trialfd07jy.jfrog.io/sagar-my-nginx-jfrog/${IMAGE_NAME}
              """
            }

          } else {
            echo "⚠️ Docker image ${IMAGE_NAME} not found. Skipping scan & push."
            currentBuild.result = 'UNSTABLE'
          }
        }
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
          sh """
            kubectl create secret docker-registry jfrog-regcred \
              --docker-server=trialfd07jy.jfrog.io \
              --docker-username=${JF_USER} \
              --docker-password=${JF_PASS} \
              --docker-email=you@example.com \
              --dry-run=client -o yaml \
            | kubectl apply -f -
            kubectl apply -f deployment.yaml
          """
        }
      }
    }
  }

  post {
    unstable {
      echo '⚠️ Build marked UNSTABLE due to scan warnings or missing steps, but deployment succeeded.'
    }

    failure {
      echo '🚨 Build failed unexpectedly. Please check logs.'
    }

    success {
      echo '✅ Pipeline completed successfully!'
    }
  }
}
