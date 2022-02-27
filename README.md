# aws-ecs-pipeline-spring-boot

Amazon ECS Standard Deployment with CodePipeline

https://docs.aws.amazon.com/codepipeline/latest/userguide/ecs-cd-pipeline.html

### Notes

Blue Green deployment is now available on Cloudformation with a lot of restrictions and no supervizing mmi.

ECR as source produces a file imageDetails.json, whereas ECS deployment expects imageDefinition.json
S3 a codepipeline source requires S3 Bucket to be versioned


### AWS CodeDeploy Blue / Green Deployment to Amazon ECS

https://www.youtube.com/watch?v=ekh2uW1VU6U

https://github.com/awslabs/aws-cloudformation-templates/blob/master/aws/services/ECS/FargateLaunchType/services/public-service.yml

no public IP address on container 
https://stackoverflow.com/questions/68685640/aws-privatelink-cloudformation-setup-questions-from-reading-the-docs

VPC Endpoints
https://github.com/aws/copilot-cli/discussions/2378

Base Network
https://gist.github.com/jbesw/f9401b4c52a7446ef1bb71ceea8cc3e8

Settings for ALB
https://stackoverflow.com/a/22542126

Complete CI/CD with AWS CodeCommit, AWS CodeBuild, AWS CodeDeploy, and AWS CodePipeline
https://aws.amazon.com/blogs/devops/complete-ci-cd-with-aws-codecommit-aws-codebuild-aws-codedeploy-and-aws-codepipeline/

```
git remote add origin ssh://git-codecommit.eu-west-1.amazonaws.com/v1/repos/MyDemoRepo
```


Using CloudFormation to Automate Build, Test, and Deploy with CodePipeline
https://dev.to/aws/using-cloudformation-to-automate-build-test-and-deploy-with-codepipeline-l71

CommitID
https://stackoverflow.com/a/65349989
