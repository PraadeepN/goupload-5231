pipeline {
  agent {
    label "jenkins-go"
  }
  environment {
    ORG = 'praadeepn'
    APP_NAME = 'goupload-5231'
    CHARTMUSEUM_CREDS = credentials('jenkins-x-chartmuseum')
    DOCKER_REGISTRY_ORG = 'praadeepn'
  }
  stages {
    stage('CI Build and push snapshot') {
      when {
        branch 'PR-*'
      }
      environment {
        PREVIEW_VERSION = "0.0.0-SNAPSHOT-$BRANCH_NAME-$BUILD_NUMBER"
        PREVIEW_NAMESPACE = "$APP_NAME-$BRANCH_NAME".toLowerCase()
        HELM_RELEASE = "$PREVIEW_NAMESPACE".toLowerCase()
      }
      steps {
        container('go') {
          dir('/home/jenkins/go/src/github.com/praadeepn/goupload-5231') {
            checkout scm
            sh "make linux"
            sh "export VERSION=$PREVIEW_VERSION && skaffold build -f skaffold.yaml"
            sh "jx step post build --image $DOCKER_REGISTRY/$ORG/$APP_NAME:$PREVIEW_VERSION"
          }
          dir('/home/jenkins/go/src/github.com/praadeepn/goupload-5231/charts/preview') {
            sh "make preview"
            sh "jx preview --app $APP_NAME --dir ../.."
          }
        }
      }
    }
    stage('Build Release') {
      when {
        branch env.BRANCH_NAME
      }
      steps {
        container('go') {
          dir('/home/jenkins/go/src/github.com/praadeepn/goupload-5231') {
            checkout scm

            // ensure we're not on a detached head
            sh "git checkout ${env.BRANCH_NAME}"
            sh 'git config --global credential.username PraadeepN'
            sh "git config --global credential.helper store"
            sh "jx step git credentials"

            // so we can retrieve the version in later steps
            sh "echo \$(jx-release-version) > VERSION"
            sh "jx step tag --version \$(cat VERSION)"
            sh "make build"
            sh "export VERSION=`cat VERSION` && skaffold build -f skaffold.yaml"
            sh "jx step post build --image $DOCKER_REGISTRY/$ORG/$APP_NAME:\$(cat VERSION)"
          }
        }
      }
    }
    stage('Release Chart') {
      when {
        branch env.BRANCH_NAME
      }
      steps {
        container('go') {
          dir('/home/jenkins/go/src/github.com/praadeepn/goupload-5231/charts/goupload-5231') {
            sh "jx step changelog --version v\$(cat ../../VERSION)"

            // release the helm chart
            sh "jx step helm release"

            // promote through all 'Auto' promotion Environments
          }
        }
      }
    }
  }
}
