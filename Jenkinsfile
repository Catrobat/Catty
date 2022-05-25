#!/usr/bin/env groovy

pipeline {
  agent {
    label 'MAC'
  }

  options {
    timeout(time: 2, unit: 'HOURS')
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '30', artifactNumToKeepStr: '30'))
  }

  triggers {
    issueCommentTrigger('.*test this please.*')
  }

  stages {
    stage('Unlock keychain') {
      steps {
        withCredentials([usernamePassword(credentialsId: '29a4006b-0d8b-4fe9-9237-b00856bdb0de', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
          script {
            unlockMACKeychain "${PASSWORD}"
          }
        }
      }
    }
    stage('Build') {
      steps {
        sh 'cd src && fastlane build_catty'
      }
      post {
        always {
          archiveArtifacts(artifacts: 'src/fastlane/builds/', allowEmptyArchive: true)
          archiveArtifacts(artifacts: 'src/fastlane/Install.html', allowEmptyArchive: true)
          archiveArtifacts(artifacts: 'src/fastlane/Adhoc.plist', allowEmptyArchive: true)
        }
      }
    }
    stage('Test') {
      steps {
        sh 'cd src && fastlane tests'
      }
    }
  }

  post {
    always {
      junit testResults: 'src/fastlane/test_output/report.junit', allowEmptyResults: true
    }
  }
}
