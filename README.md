# github-runner-dockerfile
Dockerfile and build setup for running GitHub runners in Docker containers

### Usage

```
docker build -t github-runner .
docker run --detach --name=github-runner github-runner https://github.com/RyanSquared/github-runner-docker <TOKEN>
```
