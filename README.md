# Pumpkin. A Hydra head to support digitization workflows

[![CircleCI](https://circleci.com/gh/IU-Libraries-Joint-Development/pumpkin.svg?style=svg)](https://circleci.com/gh/IU-Libraries-Joint-Development/pumpkin)
[![Coverage Status](https://coveralls.io/repos/github/IU-Libraries-Joint-Development/pumpkin/badge.svg?branch=master)](https://coveralls.io/github/IU-Libraries-Joint-Development/pumpkin?branch=master)
[![Code Climate](https://codeclimate.com/github/IU-Libraries-Joint-Development/pumpkin/badges/gpa.svg)](https://codeclimate.com/github/IU-Libraries-Joint-Development/pumpkin)
[![Apache 2.0 License](https://img.shields.io/badge/license-Apache%202.0-blue.svg?style=plastic)](./LICENSE)

Pumpkin is a Hydra head based on [Plum](https://github.com/pulibrary/plum) and  [CurationConcerns](http://github.com/projecthydra/curation_concerns), with two types of works:
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
    * The installer doesn't work on MacOSX 10.11 (El Capitan), but the files `kdu_compress` and `libkdu_v77R.dylib` can be extracted from the download packages and used by manually installing them in `/usr/local/bin` and `/usr/local/lib` respectively.
* [Tesseract](https://github.com/tesseract-ocr/tesseract)
    * Version 3.04 is required. You can install it on Mac OSX with `brew install
      tesseract --with-all-languages` For Ubuntu you'll have to
      [compile](https://github.com/tesseract-ocr/tesseract/wiki/Compiling) it.
* [RabbitMQ](https://www.rabbitmq.com/) (Optional)
    * Start with rabbitmq-server
    * Used for publishing create/update/delete events for systems such as
      [Pomegranate](https://github.com/pulibrary/pomegranate)

## Initial Setup
You may need to prefix rake commands with `bundle exec`,
particularly if you have a newer version of the rake gem installed. 
* Install dependencies: `bundle install`
* Setup the database: `rake db:migrate`
* Setup ActiveFedora::Noid minter: `rails g active_fedora:noid:seed`

## Running the Tests

Setup dependencies and run the test suite:

   ```sh
   $ bundle install
   $ rake db:migrate
   $ rake ci
   ```
You may need to create the tmp directory, which can be done automatically by 
starting the rails server (`rails s`) and then stopping it.

You may also want to run the Fedora and Solr servers in one window with:

   ```sh
   $ rake hydra:test_server
   ```

And run the test suite in another window:

   ```sh
   $ rake spec
   ```

## Running the Services

Pumpkin consists of several cooperating services:  Fedora, Solr, a
Blacklight (i.e. Rails) application, Redis, and an AMQP 0.9 broker such
as RabbitMQ.

Redis and the broker (if used) are assumed to be running separately, as
noted under Dependencies above.

For development and testing, Pumpkin includes wrapper scripts for Fedora
and Solr.  These will download the services as needed and start them for
you.  Rake tasks to configure and run the wrappers are included, as
detailed below.  You can stop these supporting services by typing the
interrupt character (i.e. control-C) in the console where you are
running the wrappers task.

To start Fedora and Solr services to support development:

   ```rake server:development```

They can be configured by editing ```.fcrepo_wrapper``` and
```.solr_wrapper```.

To start Fedora and Solr to support testing:

   ```rake hydra:test_server```

They can be configured by editing ```config/fcrepo_wrapper_test.yml```
and ```config/solr_wrapper_test.yml```.

In either case, you can then start Blacklight in the normal fashion for
Rails applications:

   ```rails server```

or

   ```rails console```

The Pumpkin user interface should then be available at
```http://localhost:3000/```

To start Fedora, Solr and Blacklight on the console:

   ```rake hydra:server```

Production deployment will vary depending on your local procedures and
requirements.

Please note that config/fedora.yml and config/solr.yml are for
configuring the Blacklight application's connections to Fedora and Solr,
which is separate from configuring instances of Fedora and Solr
themselves.

## Adding an Admin user

1. Run the development servers with `rake server:development`
1. Run Plum with `rails s`
1. Go to http://localhost:3000/users/auth/cas and login with CAS
1. $ rake add_admin_role

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
