pipeline {
    agent any

    environment {
        VAULT_PASS = credentials('ansible-key')
    }

    stages {
        stage('Detect Changes') {
            steps {
                script {
                    env.ANSIBLE_CHANGED = sh(
                        script: "git diff --name-only HEAD~1 HEAD | grep '^ansible_config/' | wc -l",
                        returnStdout: true
                    ).trim()

                    env.FRONTEND_CHANGED = sh(
                        script: "git diff --name-only HEAD~1 HEAD | grep '^frontend/' | wc -l",
                        returnStdout: true
                    ).trim()

                    env.BACKEND_CHANGED = sh(
                        script: "git diff --name-only HEAD~1 HEAD | grep '^backend/' | wc -l",
                        returnStdout: true
                    ).trim()
                }
            }
        }

      
        
        stage('tools versioning'){
            sh '''
                echo "tool versioning"
                docker --version
                ansible --version
            '''
            
        }

        stage('perpare the enviroment '){
            shagent(['ec2-ssh-key']) {          // ← loads SSH key into agent
                sh '''
                    # Write vault password
                    echo "$VAULT_PASS" > /tmp/vault_pass.txt
                    chmod 600 /tmp/vault_pass.txt

                    # Write SSH key to temp file
                    mkdir -p /tmp/ansible
                    ssh-add -L > /tmp/ansible/ssh_key.pem
                    chmod 600 /tmp/ansible/ssh_key.pem

                    # Render inventory from template using the temp key path
                    export SSH_KEY_PATH=/tmp/ansible/ssh_key.pem

                    ansible-playbook -i ansible_config/inventory.ini \
                        ansible_config/site.yml \
                        --private-key $SSH_KEY_PATH \
                        --vault-password-file /tmp/vault_pass.txt

                    # Cleanup
                    rm -rf /tmp/ansible /tmp/vault_pass.txt
                '''
            }


            
        }



        stage('Build Frontend') {
            when {
                expression { env.FRONTEND_CHANGED != '0' } 
            }
            steps {
                sh '''
                    docker build -t mahmoudkhera/frontend ./frontend
                    docker push mahmoudkhera/frontend
                '''
            }
        }
        stage('Deploy Frontend') {
            when {
                expression { env.FRONTEND_CHANGED != '0' }
            }
            steps {
                sh '''
                    echo "Deploying frontend..."
                    ansible-playbook -i ansible_config/inventory.ini ansible_config/site.yml --tags front
                '''
            }
    }

        stage('Build Backend') {
            when {
                expression { env.BACKEND_CHANGED != '0' }   
            steps {
                sh '''
                    docker build -t mahmoudkhera/backend ./backend
                    docker push mahmoudkhera/backend
                '''
            }
        }
    }
    stage('Deploy Backend') {
        when {
            expression { env.BACKEND_CHANGED != '0' }
        }
        steps {
            sh '''
                echo "Deploying backend..."
                ansible-playbook -i ansible_config/inventory.ini ansible_config/site.yml --tags backend
            '''
        }
    }

    stage('Deploy Ansible') {
        when {
            expression { env.ANSIBLE_CHANGED != '0' }   // only if ansible_config/ changed
        }
        steps {
            sh '''
                echo "$VAULT_PASS" > /tmp/vault_pass.txt
                ansible-playbook -i ansible_config/inventory.ini \
                    ansible_config/playbook.yaml \
                    --vault-password-file /tmp/vault_pass.txt
                rm -f /tmp/vault_pass.txt
            '''
        }
    }

    post {
        always {
            sh 'rm -f /tmp/vault_pass.txt'
        }
    }
}