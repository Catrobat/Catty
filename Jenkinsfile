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
    stage('Prepare') {
      steps {
        sh 'make init'
      }
    }
    stage('Build') {
      steps {
        sh 'cd src && fastlane build_catty'
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
      archiveArtifacts(artifacts: 'src/fastlane/builds/', allowEmptyArchive: true)
      archiveArtifacts(artifacts: 'src/fastlane/Install.html', allowEmptyArchive: true)
      archiveArtifacts(artifacts: 'src/fastlane/Adhoc.plist', allowEmptyArchive: true)
      sh 'cd src && fastlane test_reports'
      junit testResults: 'src/fastlane/test_output/TestSummaries.xml', allowEmptyResults: true
    }
  }
}
