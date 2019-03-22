#!/usr/bin/env/Groovy
@Library('jenkins-reference-framework') _

nodeDeliveryPipeline {
    pcfAppName = 'cb-fe-app'
    buildCommand = 'npm run build:prod'
    testCommand = 'npm run test'
    uiParams {
        appName = 'cb-fe-app'
    }
}