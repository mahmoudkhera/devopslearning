pipeline {
    agent any

    environment {
        VAULT_PASS = credentials('ansible-key')

        ENV_FILE  = credentials('.env')
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

                    echo "Ansible:  ${env.ANSIBLE_CHANGED}"
                    echo "Frontend: ${env.FRONTEND_CHANGED}"
                    echo "Backend:  ${env.BACKEND_CHANGED}"
                }
            }
        }

        stage('Tools Versioning') {
            steps {
                sh '''
                    echo "=== Current Directory ==="
                    pwd
                    echo "=== Files ==="
                    ls -la
                    docker --version
                    ansible --version
                '''
            }
        }

        stage('Prepare Environment') {
            steps {
                sshagent(['ec2-ssh-key']) {
                    sh '''
                        # Write vault password
                        echo "$VAULT_PASS" > /tmp/vault_pass.txt
                        chmod 600 /tmp/vault_pass.txt

                        # write .env file
                        echo "$ENV_FILE" >ansible_config/.env

                        # Write SSH key
                        mkdir -p /tmp/ansible
                        ssh-add -L > /tmp/ansible/ssh_key.pem
                        chmod 600 /tmp/ansible/ssh_key.pem
                    '''

                    // Render inventory from template
                    sh '''
                        ansible-playbook ansible_config/generate_inventory.yaml \
                            --vault-password-file /tmp/vault_pass.txt
                    '''
                }

                script {
                    env.SSH_KEY_PATH = '/tmp/ansible/ssh_key.pem'  
                }
            }
        }

        // stage('Build Frontend') {
        //     when { expression { env.FRONTEND_CHANGED != '0' } }
        //     steps {
        //         sh '''
        //             docker build -t mahmoudkhera/frontend ./frontend
        //             docker push mahmoudkhera/frontend
        //         '''
        //     }
        // }

        stage('Deploy Frontend') {
            when { expression { env.FRONTEND_CHANGED != '0' } }
            steps {
                sshagent(['ec2-ssh-key']) {
                    sh '''
                        echo "$VAULT_PASS" > /tmp/vault_pass.txt
                        chmod 600 /tmp/vault_pass.txt
                        ansible-playbook -i ansible_config/inventory.ini \
                            ansible_config/playbook.yaml \
                            --tags front \
                            --private-key ${SSH_KEY_PATH} \
                            --vault-password-file /tmp/vault_pass.txt
                        rm -f /tmp/vault_pass.txt
                    '''
                }
            }
        }

        // stage('Build Backend') {
        //     when { expression { env.BACKEND_CHANGED != '0' } }
        //     steps {
        //         sh '''
        //             docker build -t mahmoudkhera/backend ./backend
        //             docker push mahmoudkhera/backend
        //         '''
        //     }
        // }

        stage('Deploy Backend') {
            when { expression { env.BACKEND_CHANGED != '0' } }
            steps {
                sshagent(['ec2-ssh-key']) {
                    sh '''
                        echo "$VAULT_PASS" > /tmp/vault_pass.txt
                        chmod 600 /tmp/vault_pass.txt
                        ansible-playbook -i ansible_config/inventory.ini \
                            ansible_config/splaybook.yaml  \
                            --tags backend \
                            --private-key ${SSH_KEY_PATH} \
                            --vault-password-file /tmp/vault_pass.txt
                        rm -f /tmp/vault_pass.txt
                    '''
                }
            }
        }

        stage('Deploy Ansible') {
            when { expression { env.ANSIBLE_CHANGED != '0' } }
            steps {
                sshagent(['ec2-ssh-key']) {
                    sh '''
                        echo "$VAULT_PASS" > /tmp/vault_pass.txt
                        chmod 600 /tmp/vault_pass.txt
                        ansible-playbook -i ansible_config/inventory.ini \
                            ansible_config/playbook.yaml  \
                            --private-key ${SSH_KEY_PATH} \
                            --vault-password-file /tmp/vault_pass.txt
                        rm -f /tmp/vault_pass.txt
                    '''
                }
            }
        }

    }

    post {
        always {
            sh 'rm -f /tmp/vault_pass.txt /tmp/ansible/ssh_key.pem'
        }
    }
}