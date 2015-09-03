# Pluteum: The Hydra Head that @jpstroop hasn't picked a name for

[![Build Status](https://travis-ci.org/pulibrary/pluteum.svg?branch=master)](https://travis-ci.org/pulibrary/pluteum)
[![Coverage Status](https://coveralls.io/repos/pulibrary/aardvark/badge.svg?branch=master)](https://coveralls.io/r/pulibrary/aardvark?branch=master)
[![Code Climate](https://codeclimate.com/github/pulibrary/pluteum/badges/gpa.svg)](https://codeclimate.com/github/pulibrary/pluteum)


## Work Types
Scanned Books and Archival Sets

## Running the Code

    $ bundle install
    $ rake jetty:clean
    $ rake curation_concerns:jetty:config
    $ rake jetty:start
    $ rake db:migrate
    $ rake spec
