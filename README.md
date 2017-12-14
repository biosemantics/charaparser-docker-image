# charaparser-docker-image

1. `docker run -v <local input>:<container input> -v <local workspace>:/root/workspace -it rodenhausen/charaparser-docker-image`
   * `<local input>` specifies the directory where the charaparser input files reside in the local machine
   * `<container input>` specifies the directory where the charaparser input files should be found in the container
   * `<local workspace>` specifies the directory where the workspace folder should be found in the local machine
   * recommend `<container input>` as `/root/input`
2. In container
   1. `./learn -i <container input> -z <run id>`
   2. Optionally visit `<local workspace>/<run id>/nextStep.html` to visit link for term categorization step.
   3. `./markup -i <container input> -z <run id>`
3. Outputted files and log files can be found in `<local workspace>/<run id>`


Note: After leaving the container - if you do not explicitly remove the container with `docker rm`, the container will remain running. Thus another docker run will start up a second container. You may want to use the `docker attach` command to attach input/output to the container, and/or periodically do a `docker system prune`, or one of the other cleanup commands to stay on top of your filesystem utilization due to running docker containers.
