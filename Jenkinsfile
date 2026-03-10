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
        TASK_DEFINITION = "task-definition"
        SUBNET_ID = "subnet-0722f338ba30430ee"
        SECURITY_GROUP = "nginx-security-group"
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
                sh'docker compose down --rmi all'
                
                
            }
        }
        stage('Deploy') {
            steps {

                sh 'echo  deploying'

                  sh '''
                aws ecs create-service \
                  --cluster test-cluster \
                  --service-name  test-service\
                  --task-definition $TASK_DEFINITION \
                  --desired-count 1 \
                  --launch-type FARGATE \
                  --network-configuration "awsvpcConfiguration={
                      subnets=[$SUBNETS],
                      securityGroups=[$SECURITY_GROUP],
                      assignPublicIp=DISABLED
                  }"
                '''
              
            }
        }
    }
}