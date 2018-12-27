//@Library('jenkins-library') _

pipeline{

  agent {label 'jenkinsagent'}
    
  stages {
    stage('Build App'){
      steps {
              sh "echo ${WORKSPACE}"
              sh "docker run --rm -v ${workspace}:/usr/src/mymaven -v m2maven:/root/.m2:rw -w /usr/src/mymaven maven:3.5-alpine mvn clean package"    
      }//end steps
      post {
        always {
                junit "target/surefire-reports/*.xml"
        }
      }
    }//end build app
    stage('Code Analysis'){
      steps {
        sh "echo run sonarqube scan"
        sh "docker run --rm -v ${workspace}:/usr/src/mymaven -v ${workspace}/maven-conf:/usr/share/maven/ref/ -v m2maven:/root/.m2:rw -w /usr/src/mymaven maven:3.5-alpine mvn sonar:sonar"
      }
    }
    stage('Build & Tag Image') {
      steps {
        script {
            def pom = readMavenPom file: 'pom.xml'
            sh "cp ${workspace}/target/*.jar ${workspace}/deploy" 
            dir('deploy') {                 
                  //sh "docker build --rm -t demo/webapp --build-arg name=${NAME} --build-arg version=${VERSION} ."
                  sh "docker build --rm -t demo/webapp --build-arg name=${pom.version} --build-arg version=${pom.version} ."
                  sh "docker tag demo/webapp dtr.local/demo/webapp:${pom.version}"
       	    }
        }
      }
    }
    stage('Push to Repository') { 
      steps {
        script {
          def pom = readMavenPom file: 'pom.xml'
            parallel (
              DTR: {
                  dir('deploy') {
                      //withDockerRegistry(url: 'https://dtr.local', credentialsId: 'dtr-credentials') {}
                      sh "docker push dtr.local/demo/webapp:${pom.version}"
                  }
              },
              Artifactory: {  
                script {
                  sh "echo push binary to artifactory"
                  /*def server = Artifactory.server('artifactory')
                  def uploadSpec = """{
                      "files":[
                                {
                                "pattern": "target/*.jar",
                                "target": "apprepo/${pom.name}/${pom.version}/"
                                }
                      ]
                  }"""                    
                      server.upload(uploadSpec)
                      def buildInfo = server.upload(uploadSpec)
                      server.publishBuildInfo(buildInfo)
                */
                }
              }
            )
          }//end script
        }//end steps
    }//end push
    stage('Deploy App') {
      steps {
        script {
          def pom = readMavenPom file: 'pom.xml' 
          dir('deploy') {
              //sh "echo app deployed"
              sh "sh kubectl-deploy.sh ${pom.version}"
              //sh "VERSION=${pom.version} docker stack deploy -c docker-compose.yml webapp"
          }
        }
      }
    }
  }//end stages  
  post {
    always {
        script {
          try {
            // Use slackNotifier.groovy from shared library and provide current build result as parameter    
            //slackNotifier(currentBuild.currentResult)
            cleanWs()
          }catch (err){
            echo "All good"
          }
        }//end script  
    }
  }
}//end pipeline
