pipeline {
  agent any

  stages {
    stage('Carthage') {
      steps {
        sh 'make init'
      }
    }
    stage('Run Tests') {
      steps {
        sh 'cd src && fastlane tests'
      }
    }
    stage('Brockerstack') {
      steps {
        sh ' cd src && fastlane po_review'
      }
    }
    stage('Archive') {
      steps {
        archiveArtifacts(artifacts: 'src/fastlane/test_output/', allowEmptyArchive: true)
      }
    }
  }
}
