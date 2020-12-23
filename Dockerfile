FROM ubuntu:focal as base

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y \
    nano fish curl iproute2\
    git wget sudo

RUN wget https://bootstrap.pypa.io/get-pip.py && \
	python3 get-pip.py  && \
	rm get-pip.py

RUN python3 -m pip install virtualenv

ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH=.

# Copying requirements files from host repo so we can install and cache python modules
# Everything below here is Leela-specific

RUN virtualenv venv
RUN . venv/bin/activate

COPY requirements.txt requirements.txt
RUN pip install -r ./requirements.txt

RUN apt-get update
# add packages for s3fs-fuse
RUN apt-get install -y git build-essential libfuse-dev libcurl4-openssl-dev libxml2-dev mime-support automake libtool wget tar libssl-dev fuse s3fs


FROM base as product
## All python packages have been installed, and that docker image is cached as 'base'.
#
## Now we add in the latest Daikon source files

RUN mkdir worlds
COPY pyleela pyleela
COPY config config
COPY video video

# run entrypoint
#CMD ["python3", "-m", "unittest", "-v", "pyleela.test.test_visual_transformer.TestVisualTransformer"]

ENV PATH="${PATH}:/usr/bin"

# default video to load
ENV DAIKON_OBJECT_FILE="video/harry-drink-1/harry-drink-1.object.jl"
ENV DAIKON_POSE_FILE="video/harry-drink-1/harry-drink-1.pose.jl"
ENV WAMP_SERVER="ws://host.docker.internal:1964/ws"


#CMD /usr/bin/python3  pyleela/brain/WAMPAgent.py
COPY run.sh run.sh
CMD sh ./run.sh
