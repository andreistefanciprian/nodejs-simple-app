pipeline {

   agent {
       node {
           label "centos"
       }
   }

    environment {
        CONTAINER_IMAGE_NAME = "andreistefanciprian/nodejs-app"
        CONTAINER_REGISTRY = "https://registry.hub.docker.com"
        CONTAINER_CREDENTIALS =  "docker_hub_login"
    }

    stages {

        stage('Build Docker Image') {
            when {
                branch 'master'
            }
            steps {
                script {
                    app = docker.build(CONTAINER_IMAGE_NAME)
                    app.inside {
                        sh 'echo $(curl localhost:8080)'
                    }
                }
            }
        }

        stage('Push Docker Image') {
            when {
                branch 'master'
            }
            steps {
                script {
                    docker.withRegistry(CONTAINER_REGISTRY, CONTAINER_CREDENTIALS) {
                        app.push("${env.BUILD_NUMBER}")
                        app.push("latest")
                    }
                }
            }
        }
    }
}