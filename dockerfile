# base image
FROM ubuntu:20.04

#input GitHub runner version argument
ARG RUNNER_VERSION
ENV DEBIAN_FRONTEND=noninteractive

LABEL Author="cuddebtj"
LABEL Email="cuddebtj@gmail.com"
LABEL GitHub="https://github.com/cuddebtj"
LABEL BaseImage="ubuntu:20.04"
LABEL RunnerVersion=${RUNNER_VERSION}

# update the base packages + add a non-sudo user
RUN apt-get update -y && apt-get upgrade -y && useradd -m gh_runner

# install the packages and dependencies along with jq so we can parse JSON (add additional packages as necessary)
RUN apt-get install -y --no-install-recommends \
    curl nodejs wget unzip git jq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev python3-pip

# cd into the user directory, download and unzip the github actions runner
RUN cd /home/gh_runner && mkdir actions-runner && cd actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# install some additional dependencies
RUN chown -R gh_runner ~gh_runner && /home/gh_runner/actions-runner/bin/installdependencies.sh

# add over the start.sh script
ADD ./scripts/start.sh ./start.sh

# make the script executable
RUN chmod +x start.sh

# set the user to "gh_runner" so all subsequent commands are run as the docker user
USER gh_runner

# set the entrypoint to the start.sh script
ENTRYPOINT ["./start.sh"]