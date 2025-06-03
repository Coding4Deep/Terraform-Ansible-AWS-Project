pipeline {
    agent any

    // tools{
    //     maven 'maven3.9'
       
    // }
    
    stages {
        stage('git Checkout') {
            steps {
                git branch:'SpringBoot_Full_Stack', url: 'https://github.com/Coding4Deep/Multi_App_Platform.git'
            }
        }
        stage('build'){
            steps{
                sh ' ./mvnw clean install ' // mvn clean install
				
				
            }
        }
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                        sh ' ./mvnw sonar:sonar'  // mvn sonar:sonar
                        
                }
            }
        }
        stage('Docker Image Build & Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'DockerHub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    script {
                         sh 'docker build -t deepaksag/springboot-k8s:v1.0.0 .'
                         sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                         sh 'docker images'
          
                    }
               }
           }
        }             
    }
}
