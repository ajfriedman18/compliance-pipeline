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

Retrieve the docker login command that you can use to authenticate your Docker client to your registry

```bash
aws ecr get-login --region us-east-1
```

Run the docker login command that was returned in the previous step

Build your Docker image using the following command

```bash
docker build -t ${REPO_NAME} .
```

After the build completes, tag your image so you can push the image to this repository

```bash
docker tag ${REPO_NAME}:latest ${REPO_URI}:latest
```

Run the following command to push this image to your newly created AWS repository

```bash
docker push ${REPO_URI}:latest
```

Edit vpc-pipeline.params and update the following values:

- SourceOwner
- SourceBranch
- SourceRepo
- SourceLocation
- OAuthToken
- DockerImage

The value for your Docker image can be retrieved using the following command:

```bash
echo "${REPO_URI}:latest"
```

Create the VpcPipeline Stack
```bash
aws cloudformation create-stack --stack-name "VpcPipeline" --capabilities CAPABILITY_IAM --template-body file://vpc-pipeline.template --parameters file://vpc-pipeline.params
```
