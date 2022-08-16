# github-runner-dockerfile
Dockerfile and build setup for running GitHub runners in Docker containers

### Usage

```
DOCKER_BUILDKIT=1 docker build -t github-runner .
docker run github-runner https://github.com/RyanSquared/github-runner-docker <TOKEN>
```
