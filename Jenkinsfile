#!/usr/bin/env groovy

pipeline {
  agent {
    label 'MAC'
  }

  environment {
    PATH = "$HOME/.rbenv/shims:$PATH"
  }

  options {
    timeout(time: 2, unit: 'HOURS')
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '30', artifactNumToKeepStr: '30'))
  }

  triggers {
    issueCommentTrigger('.*test this please.*')
  }

  stage('Test') {
      steps {
        sh 'cd src && bundle exec fastlane ios upload_to_browserstack'
      }
    }
  }

//   stages {
//     stage('Prepare') {
//       steps {
//         withCredentials([usernamePassword(credentialsId: '29a4006b-0d8b-4fe9-9237-b00856bdb0de', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
//           script {
//             unlockMACKeychain "${PASSWORD}"
//           }
//         }
//         sh 'cd src && bundle install'
//       }
//     }
//     stage('Build') {
//       steps {
//         sh 'cd src && bundle exec fastlane ios build_catty'
//       }
//       post {
//         always {
//           archiveArtifacts(artifacts: 'src/fastlane/builds/', allowEmptyArchive: true)
//           archiveArtifacts(artifacts: 'src/fastlane/Install.html', allowEmptyArchive: true)
//           archiveArtifacts(artifacts: 'src/fastlane/Adhoc.plist', allowEmptyArchive: true)
//         }
//       }
//     }
//     stage('Test') {
//       steps {
//         sh 'cd src && bundle exec fastlane ios tests'
//       }
//     }
//   }

//   post {
//     always {
//       junit testResults: 'src/fastlane/test_output/report.junit', allowEmptyResults: true
//     }
//   }
// }

// pipeline {
//   agent {
//     label 'MAC'
//   }

//   environment {
//     PATH = "$HOME/.rbenv/shims:$PATH"
//   }

//   options {
//     timeout(time: 2, unit: 'HOURS')
//     timestamps()
//     buildDiscarder(logRotator(numToKeepStr: '30', artifactNumToKeepStr: '30'))
//   }

//   triggers {
//     issueCommentTrigger('.*test this please.*')
//   }

//   stages {
//     stage('Prepare') {
//       steps {
//         withCredentials([usernamePassword(credentialsId: '29a4006b-0d8b-4fe9-9237-b00856bdb0de', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
//           script {
//             unlockMACKeychain "${PASSWORD}"
//           }
//         }
//         sh 'cd src && bundle install'
//       }
//     }
//     stage('Build') {
//       steps {
//         sh 'cd src && bundle exec fastlane ios build_catty'
//       }
//       post {
//         always {
//           archiveArtifacts(artifacts: 'src/fastlane/builds/', allowEmptyArchive: true)
//           archiveArtifacts(artifacts: 'src/fastlane/Install.html', allowEmptyArchive: true)
//           archiveArtifacts(artifacts: 'src/fastlane/Adhoc.plist', allowEmptyArchive: true)
//         }
//       }
//     }
//     stage('Test') {
//       steps {
//         sh 'cd src && bundle exec fastlane ios tests'
//       }
//     }
//   }

  // post {
  //   always {
  //     junit testResults: 'src/fastlane/test_output/report.junit', allowEmptyResults: true
  //   }
  // }
}
