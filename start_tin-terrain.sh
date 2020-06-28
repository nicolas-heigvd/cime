#!/bin/bash


sudo docker-compose -f docker-compose.yml down -v;
sudo docker-compose -f docker-compose.yml up;

