pipeline {
    agent any
    stages {
        stage ("build") {
            when {
                branch 'master'
            }
            steps {
                build 'sn-oss-build-pulsar-grafana-dashboard-image'
            }
        }
    }
}
