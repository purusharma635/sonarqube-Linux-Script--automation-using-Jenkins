sshagent(['ec2-key']) {
    sh '''
    ssh -o StrictHostKeyChecking=no ubuntu@13.233.174.189 << 'EOF'
      cd ~
      git clone https://github.com/purusharma635/sonarqube-Linux-Script--automation-using-Jenkins.git || true
      cd sonarqube-Linux-Script--automation-using-Jenkins
      chmod +x sonarqube.sh
      sudo ./sonarqube.sh
    EOF
    '''
}
