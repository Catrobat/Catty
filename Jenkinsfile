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
	sh 'sudo xcode-select -s /Applications/Xcode10.1.app'
        sh 'make init'
      }
    }
    stage('Browserstack') {
      steps {
        sh 'cd src && fastlane po_review'
      }
    }
    stage('Run Tests') {
      steps {
        sh 'cd src && fastlane tests'
      }
    }
  }

  post {
    always {
      junit testResults: 'src/fastlane/test_output/TestSummaries.xml', allowEmptyResults: true
    }
  }
}
