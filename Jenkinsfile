pipeline {

   agent {
       node {
           label "centos"
       }
   }

    environment {
        DOCKER_IMAGE_NAME = "andreistefanciprian/nodejs-simple-app"
    }

    stages {

        stage('Clone repository') {
            /* Cloning the Repository to our Workspace */
            checkout scm
        }

        stage('Build Docker Image') {
            when {
                branch 'jenkinsfile-with-scm'
            }
            steps {
                script {
                    app = docker.build(DOCKER_IMAGE_NAME)
                    app.inside {
                        sh 'echo $(curl localhost:8080)'
                    }
                }
            }
        }

        stage('Push Docker Image') {
            when {
                branch 'jenkinsfile-with-scm'
            }
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'docker_hub_login') {
                        app.push("${env.BUILD_NUMBER}")
                        app.push("latest")
                    }
                }
            }
        }
    }
}