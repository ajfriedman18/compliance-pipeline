# compliance-pipeline

Clone this repo

```bash
git clone https://github.com/mmmmmike/compliance-pipeline.git
```

Create OAuth Token in GitHub
- https://github.com/settings/tokens
- Personal Tokens > Generate new token
- Token Description: Vpc Pipeline
- Check repo:status, repo_deployment, public_repo, write:repo_hook, read:repo_hook
- Generate Token and copy to clipboard

Create ECR repo

```bash
aws cloudformation create-stack --stack-name "ComplianceToolRepo" --template-body file://ecr-repo.template --output json
```

Retrieve the repositoryName and repositoryUri for the new repo and set as env variables

```bash
aws ecr describe-repositories --output json
REPO_NAME='your repositoryName'
REPO_URI='your repositoryUri'
```

Retrieve and run the docker login command that you can use to authenticate your Docker client to your registry

```bash
eval $(aws ecr get-login --region us-east-1)
```

Build, tag, and push your Docker image using the following command

```bash
docker build -t ${REPO_NAME} .
docker tag ${REPO_NAME}:latest ${REPO_URI}:latest
docker push ${REPO_URI}:latest
```

Edit vpc-pipeline.params and update the following values. We will be using GitHub, so :

- SourceOwner: Your GitHub user name
- SourceBranch: The branch we will be building (e.g. master)
- SourceRepo: The name of your repo with your code
- OAuthToken: Generated above
- DockerImage

The value for your Docker image can be retrieved using the following command:

```bash
echo "${REPO_URI}:latest"
```

You will also need to make sure that you have connected your GitHub account to AWS CodeBuild. You can find directions on this page: https://docs.aws.amazon.com/codebuild/latest/userguide/create-project.html

Create the VpcPipeline Stack
```bash
aws cloudformation create-stack --stack-name "VpcPipeline" --capabilities CAPABILITY_IAM --template-body file://vpc-pipeline.template --parameters file://vpc-pipeline.params
```
