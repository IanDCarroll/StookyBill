# StookyBill
A foundational RTMP broadcasting server

Use an RTMP video source like OBS or Atem Mini
and broadcast that video live to remote viewers via VLC or web browser
or to other remote video producers

`RTMP Video Stream Source >-> StookyBill >-> Remote Video Stream Viewer`

[StookyBill](https://en.wikipedia.org/wiki/Stooky_Bill) is named after a famous puppet in one of the first TV broadcasts by [John Logie Baird](https://en.wikipedia.org/wiki/John_Logie_Baird) in 1926  
=> Learn more about [TV Broadcast History](https://en.wikipedia.org/wiki/History_of_television)

### Dependencies

  - [AWS](https://aws.amazon.com/) (Alternate cloud hosting to come)
  - [Terraform](https://www.terraform.io/)
  - [Docker](https://www.docker.com/)
  - [nginx-rtmp Docker Image](https://hub.docker.com/r/tiangolo/nginx-rtmp/)

### Local Setup

  -  `docker-compose up`

### Local Testing
  #### Automated Testing

  - Coming soon

  #### Manual Testing
  - the most straightforward way to manually test is with OBS and VLC
  - [Setup Manual Testing](docs/manual_testing.md)
  - Run StookyBill Locally:  
  `docker-compose up`
  - Validate what OBS sends is what VLC recieves

### Contributing

  - StookyBill's default branch is called `monster` because `main` is boring and it's an excellent excuse to get [Monster Mash by Bobby Pickett](https://youtu.be/SOFCQ2bfmHw) stuck in your head as you `git pull` from the `monster` branch.

### CI/CD and Deployment

  #### Setup
  - Install [Terraform CLI](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started)
  - `terraform init` if this is your first run
  - Make sure you have [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) and that its [Configured](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html#cli-configure-quickstart-region)

  #### Run

  ##### For application repo changes: (docs found in AWS Console => ECR)
    - Login to AWS us-west-2 via console: `aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin <MY_AWS_ACCOUNT_ID>.dkr.ecr.us-west-2.amazonaws.com`
    You shoud see `Login Succeeded` in the terminal
    - Spin up a local image: `docker-compose up`
    - Tag the image as stookybill: `docker tag tiangolo/nginx-rtmp:latest stookybill` # what about the ports, dawg?
    - Tag stookybill with the aws repo url: `docker tag stookybill <MY_AWS_ACCOUNT_ID>.dkr.ecr.us-west-2.amazonaws.com/stookybill-repo:stookybill`
    - [Push the Docker Image to ECR](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/docker-basics.html#use-ecr)
    `docker push <MY_AWS_ACCOUNT_ID>.dkr.ecr.us-west-2.amazonaws.com/stookybill-repo:stookybill`
    - (do something to make sure stookybill gets deployed into ECS - hit a button in the ECS task actions to create) `aws ecs run-task`

    - Delete repo (to save on storage costs): `aws ecr delete-repository --repository-name stookybill-repo --region us-west-2 --force`

  ##### For Infra changes:

  - `terraform apply` to provision 
  - Find the task-definition name and revision in the AWS Console under ECS Task Definitions
  - `aws ecs run-task --cluster stookybill-cluster --task-definition build-run-stookybill-task:<MY_CURRENT_REVISION>` to spin up
  - `aws ecs stop-task build-run-stookybill-task:<MY_CURRENT_REVISION>` to spin down
  - `terraform destroy` to teardown (and save on service costs)

  #### Updating the lock file

    - `terraform init`
    - Run tests
    - Commit the changes to `.terraform.lock.hcl` along with the infrastructure changes.
    - if you're simply updating versions use `terraform init -upgrade` run tests, and submit as an indipendent PR.

### Production Monitoring and Telemetry

  - Coming soon

### Additional Resources

  - [Terraform Up and Running](https://www.amazon.com/Terraform-Running-Writing-Infrastructure-Code/dp/1492046906)
  - [Terraform Docs](https://www.terraform.io/docs/language/index.html)
  - [AWS Terraform Docker Up](https://medium.com/avmconsulting-blog/how-to-deploy-a-dockerised-node-js-application-on-aws-ecs-with-terraform-3e6bceb48785)
  - [nginx-rtmp-module docs](https://github.com/arut/nginx-rtmp-module/wiki/Directives)
  - [nginx](https://www.nginx.com/)
  - [manual Windows RTMP server setup](https://www.youtube.com/watch?v=n-EdUHNK9UI)
  - [FFMPEG](https://www.ffmpeg.org/)
  - [A more robust nginx-rtmp Docker Image](https://github.com/alfg/docker-nginx-rtmp)
  - [.m3u8 stream files](https://en.wikipedia.org/wiki/M3U)