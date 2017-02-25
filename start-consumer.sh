#!/bin/bash
export SERVICES_URL=http://localhost:8080/services

mvn package
mvn exec:java
