#!/bin/sh
# https://docs.aws.amazon.com/codepipeline/latest/userguide/ecs-cd-pipeline.html
PROJECT_NAME=$1 && cat <<EOF > buildspec.yml
version: 0.2
# https://docs.aws.amazon.com/codepipeline/latest/userguide/ecs-cd-pipeline.html
phases:
  pre_build:
    commands:
      - echo Logging in to Amazon ECR...
      - aws --version
      - aws ecr get-login --no-include-email --region eu-west-1 | sh
      - REPOSITORY_URI=467420073914.dkr.ecr.eu-west-1.amazonaws.com/${MAVEN_PROJECT_NAME}
      - COMMIT_HASH=\$(echo \$CODEBUILD_RESOLVED_SOURCE_VERSION | cut -c 1-7)
      - IMAGE_TAG=\${COMMIT_HASH:=latest}
      - git clone https://github.com/erwanjouan/aws-ecs-pipeline-spring-boot.git .
      - ls -ltR
      - git submodule update --init
      - ls -ltR
  build:
    commands:
      - echo Build started on \$(date)
      - echo Building the Docker image...
      - mvn spring-boot:build-image -f code/pom.xml
      - docker tag \$MAVEN_PROJECT_NAME:\$PROJECT_VERSION \$REPOSITORY_URI:\$IMAGE_TAG
      - docker tag \$MAVEN_PROJECT_NAME:\$PROJECT_VERSION \$REPOSITORY_URI:latest
  post_build:
    commands:
      - echo Build started on \$(date)
      - echo Pushing the Docker images...
      - docker push \$REPOSITORY_URI:latest
      - docker push \$REPOSITORY_URI:\$IMAGE_TAG
      - echo Writing image definitions file...
      - printf '[{"name":"${MAVEN_PROJECT_NAME}","imageUri":"%s"}]' \$REPOSITORY_URI:\$IMAGE_TAG > imagedefinitions.json

artifacts:
  files: imagedefinitions.json

cache:
  paths:
    - '/root/.m2/**/*'
EOF