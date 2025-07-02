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
    stage('Push'){
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
