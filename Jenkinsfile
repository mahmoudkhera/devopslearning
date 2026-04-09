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

        stage('Tools Versioning') {
            steps {                              // ← added steps block
                sh '''
                    echo "tool versioning"
                    docker --version
                    ansible --version
                '''
            }
        }

        stage('Prepare Environment') {
            steps {                              // ← added steps block
                sshagent(['ec2-ssh-key']) {      // ← fixed typo shagent → sshagent
                    sh '''
                        echo "$VAULT_PASS" > /tmp/vault_pass.txt
                        chmod 600 /tmp/vault_pass.txt

                        mkdir -p /tmp/ansible
                        ssh-add -L > /tmp/ansible/ssh_key.pem
                        chmod 600 /tmp/ansible/ssh_key.pem

                        export SSH_KEY_PATH=/tmp/ansible/ssh_key.pem
                    '''
                }
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
                    echo "$VAULT_PASS" > /tmp/vault_pass.txt
                    chmod 600 /tmp/vault_pass.txt
                    ansible-playbook -i ansible_config/inventory.ini \
                        ansible_config/site.yml \
                        --tags front \
                        --private-key /tmp/ansible/ssh_key.pem \
                        --vault-password-file /tmp/vault_pass.txt
                    rm -f /tmp/vault_pass.txt
                '''
            }
        }

        stage('Build Backend') {
            when {
                expression { env.BACKEND_CHANGED != '0' }
            }                                    // ← added missing closing brace
            steps {
                sh '''
                    docker build -t mahmoudkhera/backend ./backend
                    docker push mahmoudkhera/backend
                '''
            }
        }

        stage('Deploy Backend') {
            when {
                expression { env.BACKEND_CHANGED != '0' }
            }
            steps {
                sh '''
                    echo "$VAULT_PASS" > /tmp/vault_pass.txt
                    chmod 600 /tmp/vault_pass.txt
                    ansible-playbook -i ansible_config/inventory.ini \
                        ansible_config/site.yml \
                        --tags backend \
                        --private-key /tmp/ansible/ssh_key.pem \
                        --vault-password-file /tmp/vault_pass.txt
                    rm -f /tmp/vault_pass.txt
                '''
            }
        }

        stage('Deploy Ansible') {
            when {
                expression { env.ANSIBLE_CHANGED != '0' }
            }
            steps {
                sh '''
                    echo "$VAULT_PASS" > /tmp/vault_pass.txt
                    chmod 600 /tmp/vault_pass.txt
                    ansible-playbook -i ansible_config/inventory.ini \
                        ansible_config/site.yml \
                        --private-key /tmp/ansible/ssh_key.pem \
                        --vault-password-file /tmp/vault_pass.txt
                    rm -f /tmp/vault_pass.txt
                '''
            }
        }

    }

    post {
        always {
            sh 'rm -f /tmp/vault_pass.txt /tmp/ansible/ssh_key.pem'
        }
    }
}