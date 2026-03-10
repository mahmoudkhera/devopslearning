pipeline {
    agent any

    options {
    buildDiscarder(logRotator(numToKeepStr:'5'))
    }

    environment {
        DOCKER_CREDS = credentials('dockerhub-creds')
        AWS_ACCESS_KEY_ID = credentials('aws-creds')
        AWS_SECRET_ACCESS_KEY = credentials('aws-creds')
        AWS_REGION = "eu-west-1"
    }

    stages {
        stage('Tooling versions') {
            steps {
               sh '''
                docker --version
                docker compose version
                aws --version
                aws sts get-caller-identity

                '''
            }
        }
        stage('Buid') {
            steps {
                echo 'Testing..'
                sh 'docker context use default'
                sh 'docker compose build'
                
                
            }
        }
        stage('Deploy') {
            steps {

                sh 'echo  deploying'
              
            }
        }
    }
}