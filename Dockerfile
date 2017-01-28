FROM ubuntu:16.04

RUN apt-get update
RUN apt-get install -y ruby jq
RUN gem install cfn-nag
