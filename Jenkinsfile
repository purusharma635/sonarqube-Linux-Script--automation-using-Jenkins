pipeline {
    agent any

    stages {
        stage('Install SonarQube') {
            steps {
                // Go to your repo and run script
                dir('sonarqube-Linux-Script--automation-using-Jenkins') {
                    sh 'chmod +x sonarqube.sh'
                    sh 'sudo ./sonarqube.sh'
                }
            }
        }
    }
}
