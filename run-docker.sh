#!/bin/sh
docker-machine start
eval $(docker-machine env)
docker-compose up -d

# forward geoserver docker port in the background
docker-machine ssh default -f -N -L 8181:localhost:8181

# forward loris docker port in the background
docker-machine ssh default -f -N -L 5004:localhost:5004

# redis
docker-machine ssh default -f -N -L 6379:localhost:6379

# rabbitmq
docker-machine ssh default -f -N -L 5672:localhost:5672
docker-machine ssh default -f -N -L 15672:localhost:15672

# geoblacklight
docker-machine ssh default -f -N -L 3001:localhost:3001

export PLUM_IIIF_URL="http://localhost:5004"
