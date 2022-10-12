# github-runner-docker
Dockerfile and build setup for running GitHub runners in Docker containers

## Usage

```
docker build -t github-runner .
docker run --detach --name=github-runner github-runner -v github-runner-config:/opt/runner/persistent https://github.com/RyanSquared/github-runner-docker <TOKEN>
```

## Self-Bootstrapping

The bootstrapper can build new versions of itself automatically using the
GitHub action in this repository. To enable this functionality, it is ideal to
set up a system capable of using Git and Docker. In these instructions, the
URL https://github.com/RyanSquared/github-runner-docker can be replaced with
the location of a (cloned, not forked) repository containing the GitHub runner.
The URL ghcr.io/ryansquared/github-runner-docker can be replaced with the
GitHub registry that matches the GitHub repository.

### Building the Runner

```sh
git clone https://github.com/RyanSquared/github-runner-docker
cd github-runner-docker
docker build -t ghcr.io/ryansquared/github-runner-docker .
```

### Running the Runner

**Note:** if a Docker socket is passed, the Docker container will change the
ownership of the socket to be owned by the `docker` group inside the container,
which may be a different group ID from outside of the container. I do not
currently know a way around this.

Using whatever deployment method is your preferred (my current setup uses Just
Pretend It Never Goes Offline ops), run the container with the following
arguments:

```sh
# GitHub runner token: ACIUTEI3PHIEKEIDAIB4ASH1VO5UC
# Obtained from:
# https://github.com/RyanSquared/github-runner-docker/settings/actions/runners
docker run \
  --name github-runner-bootstrapped \
  --detach \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v github-runner-bootstrapped-config:/opt/runner/ \
  --rm \
  ghcr.io/ryansquared/github-runner-docker \
  https://github.com/RyanSquared/github-runner-docker \
  ACIUTEI3PHIEKEIDAIB4ASH1VO5UC
```

### Updating the Runner

Because the GitHub action included in the repository automatically pushes to
the same ghcr container address we used when initially building the container,
any updates to the repository should eventually be reflected in the container.
It won't pull from the GitHub container registry because it will use the one
that was previously built, which still exists on the machine.

### System Maintenance

Be sure to run `docker system prune` every so often to ensure that build
artifacts that are no longer used are being removed from the machine.

### Additional Flags

You can pass the following to Docker to get extra functionality:

* `-v $PWD/keys.asc:/opt/keys/gpg/keys.asc`: Add PGP keys for use with
  `git verify-commit` and other commands.
* `-v $PWD/signing_keys.txt:/opt/signing_keys.txt`: Add PGP key fingerprints
  to be pulled from a keyserver, similar to above.
* `-v /var/run/docker.sock:/var/run/docker.sock`: Give access to the Docker
  runtime from inside the container, for the purpose of building new Docker
  containers. Container still needs `docker.io` installed, as it's not
  installed by default.

### Updating

The following files should be updated:

- `Dockerfile`: the RUNNER_VERSION argument
- `.github/workflows/docker-push.yaml`: the `git clone` command
- `README.md`: the usage instructions

Be sure to pull the latest version of the runner repository before building.
