#!/bin/bash
apt-get update --fix-missing && apt-get -y upgrade
apt install -y libid3tag0 ffmpeg x264 x265
echo "ffmpeg, codex x264 x265 installed"
echo "thanks to MPEG LA"

