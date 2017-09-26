# Plum. A Hydra head to support digitization workflows

[![Circle CI](https://circleci.com/gh/pulibrary/plum.svg?style=svg)](https://circleci.com/gh/pulibrary/plum)
[![Coverage Status](https://coveralls.io/repos/pulibrary/plum/badge.svg?branch=master)](https://coveralls.io/r/pulibrary/plum?branch=master)
[![Code Climate](https://codeclimate.com/github/pulibrary/plum/badges/gpa.svg)](https://codeclimate.com/github/pulibrary/plum)
[![Stories in Ready](https://badge.waffle.io/pulibrary/plum.png?label=ready&title=Ready)](https://waffle.io/pulibrary/plum)
[![Apache 2.0 License](https://img.shields.io/badge/license-Apache%202.0-blue.svg?style=plastic)](./LICENSE)

Plum is a Hydra head based on [Hyrax](http://github.com/projecthydra-labs/hyrax), with two types of works:
* ScannedResource: a book or other resource composed of one or more scanned pages
* MultiVolumeWork: a book set, sammelband or other resource composed of multiple ScannedResources

## Features
* Drag-and-drop tools for reordering FileSets and editing structure
* Generating IIIF manifests for Collections and Works based on that structure
* Building PDFs of Works based on their IIIF manifests
* Performing OCR with Tesseract
* Simple state-based workflow
* Retrieving external metadata from our finding aids and catalog web services

## Dependencies

* [Redis](http://redis.io/)
    * Start Redis with `redis-server` or if you're on certain Linuxes, you can do this via `sudo service redis-server start`.
* [Kakadu](http://kakadusoftware.com/)
    * On a mac, extract the file and run the pkg installer therein (don't get distracted by the files called kdu_show)
* [Tesseract](https://github.com/tesseract-ocr/tesseract)
    * Version 3.04 is required. You can install it on Mac OSX with `brew install
      tesseract --with-all-languages` For Ubuntu you'll have to
      [compile](https://github.com/tesseract-ocr/tesseract/wiki/Compiling) it.
* [RabbitMQ](https://www.rabbitmq.com/) (Optional)
    * Start with rabbitmq-server
    * Used for publishing create/update/delete events for systems such as 
      [Pomegranate](https://github.com/pulibrary/pomegranate)

## Initial Setup

After cloning the Plum repository:

* Install dependencies: `bundle install`
* Setup the database: `rake db:migrate`
* Setup ActiveFedora::Noid minter: `rails g active_fedora:noid:seed`
* Create the default admin set: `rake hyrax:default_admin_set:create`
* Load the workflows in `config/workflows`: `rake hyrax:workflow:load`

## Running the Tests

Run the test suite:

   ```sh
   $ rake ci
   ```

You may also want to run the Fedora and Solr servers in one window with:

   ```sh
   $ rake hydra:test_server
   ```

And run the test suite in another window:

   ```sh
   $ rake spec
   ```

### Javascript tests

To run the Javascript test suite, run:

   ```sh
   $ rake spec:javascript
   ```

You can then open the file `tmp/jasmine/runner.html` in a browser to run the tests in that browser.
You may need to pass options to allow access to local files, e.g., on MacOSX, you can quit Chrome
and then open it with the Javascript tests:

   ```sh
   $ open -a "Google Chrome" tmp/jasmine/runner.html --args --allow-file-access-from-files
   ```

## Adding an Admin user and assigning workflow roles

1. Run the development servers with `rake hydra:server` (or run Rails and Solr/Fedora separately with `rails s` and `rake server:development`).
1. Go to http://localhost:3000/users/auth/cas and login with CAS
1. $ rake add_admin_role
1. Go to http://localhost:3000/admin/workflow_roles and grant workflow roles

## Configuring Loris for Development

1. Install Docker Toolbox [https://www.docker.com/toolbox](https://www.docker.com/toolbox)
  * Only necessary for mac or windows machines. For unix boxes install via 
      `wget -qO- https://get.docker.com/ | sh`
1. Start a docker VM: `docker-machine start default`
1. Setup your docker environment: `eval "$(docker-machine env default)"`
1. Retrieve the loris image: `docker pull lorisimageserver/loris`
1. Start the container:
  ```
  docker run --name loris -v /path/to/plum/tmp/derivatives:/usr/local/share/images -d -p 5004:5004 lorisimageserver/loris
  ```
1. Find the docker IP address with `docker-machine ls`
1. Export config variable for IIIF url: `export
   PLUM_IIIF_URL="http://<docker-ip>:5004"`
1. Images should be available at `http://<docker-ip>:5004/` based on the FileSet id.  e.g., if your docker IP address is 192.168.99.100, the full view of FileSet `70795765b` would be at http://192.168.99.100:5004/70%2F79%2F%2F57%2F65%2Fb-intermediate_file.jp2/full/full/0/default.jpg
