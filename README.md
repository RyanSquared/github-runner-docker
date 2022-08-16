# github-runner-dockerfile
Dockerfile and build setup for running GitHub runners in Docker containers

### Usage

```
git clone -b v2.295.0 https://github.com/actions/runner
docker build -t github-runner .
docker run --detach --name=github-runner github-runner https://github.com/RyanSquared/github-runner-docker <TOKEN>
```
