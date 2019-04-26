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

  stages {
    stage('Carthage') {
      steps {
        sh 'make init'
      }
    }
    stage('Browserstack') {
      steps {
        sh 'cd src && fastlane po_review'
      }
    }
    /*stage('Run Tests') {
      steps {
        sh 'cd src && fastlane tests'
      }
    }*/
  }

  post {
    always {
      junit testResults: 'src/fastlane/test_output/TestSummaries.xml', allowEmptyResults: true
      archiveArtifacts(artifacts: 'src/fastlane/builds/', allowEmptyArchive: true)
      archiveArtifacts(artifacts: 'src/fastlane/install.html', allowEmptyArchive: true)
    }
  }
}
