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
        sh 'fastlane po_review'
      }
    }
    stage('Run Tests') {
      steps {
        sh 'fastlane tests'
      }
    }
  }

  post {
    always {
      junit testResults: 'fastlane/test_output/TestSummaries.xml', allowEmptyResults: true
    }
  }
}
