pipeline {
  agent any

  stages {
    stage('Install SonarQube on EC2') {
      steps {
        sshagent(['ec2-key']) {
          sh '''
            ssh -o StrictHostKeyChecking=no ubuntu@13.233.174.189'
              sudo apt update -y
              git clone https://github.com/purusharma635/sonarqube-Linux-Script--automation-using-Jenkins.git || true
              cd sonarqube-Linux-Script--automation-using-Jenkins
              chmod +x sonarqube.sh
              sudo ./sonarqube.sh
            '
          '''
        }
      }
    }
  }
}
