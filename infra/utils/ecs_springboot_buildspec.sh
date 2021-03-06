#!/bin/sh
# https://docs.aws.amazon.com/codepipeline/latest/userguide/ecs-cd-pipeline.html
cat <<EOF > buildspec.yml
version: 0.2
# https://docs.aws.amazon.com/codepipeline/latest/userguide/ecs-cd-pipeline.html
env:
  git-credential-helper: yes
phases:
  pre_build:
    commands:
      - echo Logging in to Amazon ECR...
      - aws --version
      - aws ecr get-login --no-include-email --region eu-west-1 | sh
      - REPOSITORY_URI=467420073914.dkr.ecr.eu-west-1.amazonaws.com/\$MAVEN_PROJECT_NAME
      - git submodule update --init --recursive
      - echo IMAGE_TAG \$IMAGE_TAG
      - cd code && git fetch && git checkout \$IMAGE_TAG && cd ..
  build:
    commands:
      - echo Build started on \$(date)
      - echo Building the Docker image...
      - mvn spring-boot:build-image -f code/pom.xml
      - docker tag \$MAVEN_PROJECT_NAME:\$PROJECT_VERSION \$REPOSITORY_URI:\$IMAGE_TAG
      - docker tag \$MAVEN_PROJECT_NAME:\$PROJECT_VERSION \$REPOSITORY_URI:latest
      - echo Pushing the Docker images...
      - echo REPOSITORY_URI \$REPOSITORY_URI
      - docker push \$REPOSITORY_URI:latest
      - docker push \$REPOSITORY_URI:\$IMAGE_TAG
  post_build:
    commands:
      - echo Build started on \$(date)
      - cp infra/pipeline/*.yml .

artifacts:
  files: ./infrastructure.yml

cache:
  paths:
    - '/root/.m2/**/*'
EOF