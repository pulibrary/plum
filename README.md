# Plum. A Hydra head to support book digitization

[![Circle CI](https://circleci.com/gh/pulibrary/plum.svg?style=svg)](https://circleci.com/gh/pulibrary/plum)
[![Coverage Status](https://coveralls.io/repos/pulibrary/plum/badge.svg?branch=master)](https://coveralls.io/r/pulibrary/plum?branch=master)
[![Code Climate](https://codeclimate.com/github/pulibrary/plum/badges/gpa.svg)](https://codeclimate.com/github/pulibrary/plum)
[![Stories in Ready](https://badge.waffle.io/pulibrary/plum.png?label=ready&title=Ready)](https://waffle.io/pulibrary/plum)
[![Apache 2.0 License](https://img.shields.io/badge/license-Apache%202.0-blue.svg?style=plastic)](./LICENSE)


## Work Types
ScannedResource

## Running the Code

    $ bundle install
    $ rake jetty:clean
    $ rake curation_concerns:jetty:config
    $ rake jetty:start
    $ rake db:migrate
    $ rake spec

## Configuring Loris for Development

1. Install Docker Toolbox [https://www.docker.com/toolbox](https://www.docker.com/toolbox)
  * Only necessary for mac or windows machines. For unix boxes install via 
      `wget -qO- https://get.docker.com/ | sh`
2. Within a docker-enabled terminal run `docker pull lorisimageserver/loris`
3. Start the container: `docker run --name loris -v tmp/derivatives:/usr/local/share/images -d -p 5004:5004 lorisimageserver/loris`
4. Export config variable for IIIF url: `export
   PLUM_IIIF_URL="http://<docker-ip>:5004"`
4. Images should be available at `http://<docker-ip>:5004/<generic_file_id>`
