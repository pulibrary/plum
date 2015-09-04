# Plum. A Hydra head to support book digitization

[![Circle CI](https://circleci.com/gh/pulibrary/plum.svg?style=svg)](https://circleci.com/gh/pulibrary/plum)
[![Coverage Status](https://coveralls.io/repos/pulibrary/plum/badge.svg?branch=master)](https://coveralls.io/r/pulibrary/plum?branch=master)
[![Code Climate](https://codeclimate.com/github/pulibrary/plum/badges/gpa.svg)](https://codeclimate.com/github/pulibrary/plum)
[![Stories in Ready](https://badge.waffle.io/pulibrary/plum.png?label=ready&title=Ready)](https://waffle.io/pulibrary/plum)
[![Apache 2.0 License](https://img.shields.io/badge/license-Apache%202.0-blue.svg?style=plastic)](./LICENSE)


## Work Types
ScannedBook

## Running the Code

    $ bundle install
    $ rake jetty:clean
    $ rake curation_concerns:jetty:config
    $ rake jetty:start
    $ rake db:migrate
    $ rake spec
