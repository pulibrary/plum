#!/bin/sh
docker-machine start
eval $(docker-machine env)
docker-compose up -d
# forward geoserver docker port in the background
docker-machine ssh default -f -N -L 8181:localhost:8181
# forward loris docker port in the background
docker-machine ssh default -f -N -L 5004:localhost:5004

export PLUM_IIIF_URL="http://localhost:5004"
