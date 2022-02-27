ECR_ROOT_URL:=467420073914.dkr.ecr.eu-west-1.amazonaws.com
PROJECT_NAME:=aws-ecs-pipeline-spring-boot

init:
	INIT_BUCKET_NAME=$(PROJECT_NAME)-init && \
	mvn clean -f code/pom.xml && \
	./infra/utils/ecs_springboot_buildspec.sh $(PROJECT_NAME) && \
	zip -r $(PROJECT_NAME).zip * && \
	aws s3 mb s3://$${INIT_BUCKET_NAME} &&\
	aws s3 cp $(PROJECT_NAME).zip s3://$${INIT_BUCKET_NAME}/init/ && \
	aws cloudformation deploy \
		--capabilities CAPABILITY_NAMED_IAM \
		--template-file ./infra/pipeline/init.yml \
		--stack-name $(PROJECT_NAME)-init \
		--parameter-overrides \
			ProjectName=$(PROJECT_NAME) \
			ArtifactInputBucketName=$${INIT_BUCKET_NAME} && \
	aws s3 sync ./infra/pipeline/ s3://$${INIT_BUCKET_NAME}/cloudformation/ && \
	./infra/utils/git_init.sh $(PROJECT_NAME) && \
	make push

push:
	MAVEN_PROJECT_NAME=$$(./infra/utils/get_mvn_project_name.sh) && \
	MAVEN_PROJECT_VERSION=$$(./infra/utils/get_mvn_project_version.sh) && \
	aws ecr create-repository --repository-name $${MAVEN_PROJECT_NAME} || true && \
	mvn spring-boot:build-image -f code/pom.xml && \
	aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin $(ECR_ROOT_URL) && \
	docker tag $${MAVEN_PROJECT_NAME}:$${MAVEN_PROJECT_VERSION} $(ECR_ROOT_URL)/$${MAVEN_PROJECT_NAME}:$${MAVEN_PROJECT_VERSION} && \
	docker tag $${MAVEN_PROJECT_NAME}:$${MAVEN_PROJECT_VERSION} $(ECR_ROOT_URL)/$${MAVEN_PROJECT_NAME}:latest && \
	docker push $(ECR_ROOT_URL)/$${MAVEN_PROJECT_NAME}:latest && \
	docker push $(ECR_ROOT_URL)/$${MAVEN_PROJECT_NAME}:$${MAVEN_PROJECT_VERSION}

deploy:
	PROJECT_NAME=$$(./infra/utils/get_mvn_project_name.sh) && \
	MAVEN_PROJECT_VERSION=$$(./infra/utils/get_mvn_project_version.sh) && \
	INIT_BUCKET_NAME=$(PROJECT_NAME)-init && \
	aws s3 sync ./infra/pipeline/ s3://$${INIT_BUCKET_NAME}/cloudformation/ && \
    aws cloudformation deploy \
		--capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND \
		--template-file ./infra/pipeline/_global.yml \
		--stack-name $(PROJECT_NAME)-global \
		--parameter-overrides \
			ProjectName=$(PROJECT_NAME) \
			ProjectVersion=$${MAVEN_PROJECT_VERSION} \
			ArtifactInitBucketName=$${INIT_BUCKET_NAME}

destroy:
	@PROJECT_NAME=$$(./infra/utils/get_mvn_project_name.sh) && \
	INIT_BUCKET_NAME=$(PROJECT_NAME)-init && \
	aws s3 rm s3://$(PROJECT_NAME)-output --recursive || true && \
	aws s3 rm s3://$${INIT_BUCKET_NAME} --recursive || true && \
	aws s3 rb s3://$${INIT_BUCKET_NAME} && \
	aws ecr delete-repository --force --repository-name $(PROJECT_NAME) && \
	aws cloudformation delete-stack --stack-name $(PROJECT_NAME)-global || true && \
	aws cloudformation delete-stack --stack-name $(PROJECT_NAME)-init || true

check:
	cd ./infra/utils/ && ./control_page.sh && cat control_page.html && cd -