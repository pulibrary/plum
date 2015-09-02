# Aardvark: The Hydra Head that @jpstroop hasn't picked a name for

## Work Types
Scanned Books and Archival Sets

## Running the Code

    $ bundle install
    $ rake jetty:clean
    $ rake curation_concerns:jetty:config
    $ rake jetty:start
    $ rake db:migrate
    $ rake spec