#!/usr/bin/env groovy

pipeline {
  agent {
    label 'MAC'
  }
  
  tools {nodejs "NodeJS"}
  
  parameters {
     separator(name: "BROWSERSTACK", sectionHeader: "BrowerStack configuration",
                separatorStyle: "border-width: 0",
                sectionHeaderStyle: """
                background-color: #ffff00;
                text-align: center;
                padding: 4px;
                color: #000000;
                font-size: 20px;
                font-weight: normal;
                font-family: 'Orienta', sans-serif;
                letter-spacing: 1px;
                font-style: italic;
                """)
    choice choices: ['IosDevices', 'iPhone 14 Pro-16', 'iPhone 14 Pro Max-16', 'iPhone 14 Plus-16', 'iPhone 14-16', 'iPhone 12 Pro Max-16', 'iPhone 12 Pro-16', 'iPhone 12 Mini-16', 'iPhone 11 Pro Max-16', 'iPhone XS-15', 'iPhone 13 Pro Max-15', 'iPhone 13 Pro-15', 'iPhone 13 Mini-15', 'iPhone 13-15', 'iPhone 11 Pro-15', 'iPhone 11-15', 'iPhone XS-14', 'iPhone 12 Pro Max-14', 'iPhone 12 Pro-14', 'iPhone 12 Mini-14', 'iPhone 12-14', 'iPhone 11 Pro Max-14', 'iPhone 11-14', 'iPhone XS-13', 'iPhone 11 Pro Max-13', 'iPhone 11 Pro-13', 'iPhone 11-13', 'iPhone XR-15', 'iPhone 8-15', 'iPhone 8-13', 'iPhone SE 2020-16', 'iPhone SE 2022-15', 'iPhone SE 2020-13', 'iPad Air 4-14', 'iPad 9th-15', 'iPad Pro 12.9 2022-16', 'iPad Pro 12.9 2020-16', 'iPad Pro 11 2022-16', 'iPad 10th-16', 'iPad Air 5-15', 'iPad Pro 12.9 2021-14', 'iPad Pro 12.9 2020-14', 'iPad Pro 11 2021-14', 'iPad Pro 12.9 2020-13', 'iPad 8th-16', 'iPad Pro 12.9 2018-15', 'iPad Mini 2021-15', 'iPad 8th-14', 'iPad Mini 2019-13', 'iPad Air 2019-13'], description: 'Available IOS Devices on BrowserStack', name: 'BROWSERSTACK_IOS_DEVICES'
    booleanParam name: 'BROWSERSTACK_TESTING', defaultValue: false, description: 'When selected testing runs over BrowserStack'
    booleanParam name: 'DEVICE_TESTING', defaultValue: true, description: 'When selected UI-testing runs locally'
    choice choices: ['1', '2', '3', '4',' 5'], description: 'Number of Shards for running tests on BrowserStack. <a href="https://app-automate.browserstack.com/dashboard/v2/builds/">BrowserStack Dashboard</a>', name: 'BROWSERSTACK_SHARDS'
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

  stages {
    stage('Prepare') {
      steps {
        withCredentials([usernamePassword(credentialsId: '29a4006b-0d8b-4fe9-9237-b00856bdb0de', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
          script {
            unlockMACKeychain "${PASSWORD}"
          }
        }
        sh 'cd src && bundle install'
      }
    }
    stage('Build') {
      when {
            expression { params.DEVICE_TESTING == true }
      }
      steps {
        sh 'cd src && bundle exec fastlane ios build_catty'
      }
      post {
        always {
          archiveArtifacts(artifacts: 'src/fastlane/builds/', allowEmptyArchive: true)
          archiveArtifacts(artifacts: 'src/fastlane/Install.html', allowEmptyArchive: true)
          archiveArtifacts(artifacts: 'src/fastlane/Adhoc.plist', allowEmptyArchive: true)
        }
      }
    }
    stage('BrowserStack testing') {
        when {
            expression { params.BROWSERSTACK_TESTING == true }
        }
        steps {
            sh 'cd src && bundle exec fastlane ios ui_tests_app_automate'
            withCredentials([usernamePassword(credentialsId: 'browserstack', passwordVariable: 'BROWSERSTACK_ACCESS_KEY', usernameVariable: 'BROWSERSTACK_USERNAME')]) {
                script {
                  browserStack('src/fastlane/app_automate')
                } 
            }
        }
        post {
            always {
              junit skipPublishingChecks: true, testResults: 'src/fastlane/report.xml'
              // junitAndCoverage "$reports/jacoco/jacocoTestDebugUnitTestReport/jacoco.xml", 'unit', javaSrc
            }
        }
    }
    stage('Test') {
      steps {
        sh 'cd src && bundle exec fastlane ios tests'
      }
    }
  }

  post {
    always {
      junit testResults: 'src/fastlane/test_output/report.junit', allowEmptyResults: true
    }
  }
}
