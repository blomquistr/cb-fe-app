#!/usr/bin/env groovy
@Library('jenkins-reference-framework@CLOUDBEES-87_fe-app') _

nodeDeliveryPipeline {
    appName = 'cb-fe-app'
    buildCommand = 'ng build'
    testCommand = 'ng test'
    artifactoryRepoKey = 'cicd-services'
    artifactoryGroupName = 'com.mrll.cicd'
}