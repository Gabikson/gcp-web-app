#!/bin/bash

docker run --rm --name x-cloud-demo-app -p 80:8080 x-cloud-demo-app:latest --spring.profiles.active=local