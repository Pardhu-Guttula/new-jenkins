pipeline {
    agent any 
    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub')
        DOCKER_TAG = getVersion()
    }
    stages { 
        stage('SCM Checkout') {
            steps{
            git branch: 'main', credentialsId: 'Github', 
            url: 'https://github.com/Pardhu-Guttula/new-jenkins'
            }
        }

        stage('Build docker image') {
            steps {  
                sh 'docker build -t pardhuguttula/ansible:${DOCKER_TAG} .'
            }
        }
        stage('login to dockerhub') {
            steps{
                sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
            }
        }
        stage('push image') {
            steps{
                sh 'docker push pardhuguttula/ansible:${DOCKER_TAG}'
            }
        }
        stage('Ansible') {
            steps{
                ansiblePlaybook credentialsId: 'target-server', disableHostKeyChecking: true, extras: "-e DOCKER_TAG=${DOCKER_TAG}", installation: 'ansible', inventory: 'dev.inv', playbook: 'deployment.yml', vaultTmpPath: ''
            }
        }
         
    }
}
def getVersion(){
    def commitHash = sh label:'', returnStdout: true, script: 'git rev-parse --short HEAD'
    return commitHash
}
