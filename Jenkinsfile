pipeline {
    agent any

    options {
        buidDiscarder(logRotator(numToKeepStr:'5'))
    }

    enviroment{
        AWS_ACCESS_KEY_ID = credentials('aws-access-key')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-key')
        DOCKER_CREDS = credentials('dockerhub-creds')
        AWS_REGION = "us-east-1"
    }

    stages {
        stage('Tooling versions') {
            steps {
               sh '''
                docker --version
                docker composer --version
                aws --version
                '''
            }
        }
        stage('buid') {
            steps {
                echo 'Testing..'
                sh 'docker context use default'
                sh 'docker compose build'
                
                
            }
        }
        stage('Deploy') {
            steps {
              
            }
        }
    }
}