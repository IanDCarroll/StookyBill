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

  ##### For application repo changes:
  - coming soon

  ##### For Infra changes:
  - `terraform apply` to spin up
  - `terraform destroy` to teardown

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