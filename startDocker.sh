#! /bin/sh

docker build -t ebooks-ui . \
&& docker run -it \
-p 127.0.0.1:3000:3000 ebooks-ui
