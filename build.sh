#!/bin/sh -e

packages="libxayagame jsoncpp libglog gflags"

g++ hello.cpp -o hello \
  -Wall -Werror -pedantic -std=c++14 \
  `pkg-config --cflags ${packages}` \
  `pkg-config --libs ${packages}` \
  -pthread
