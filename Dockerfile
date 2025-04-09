FROM ubuntu:22.04

COPY lean_hammertest_lw /home/lean_hammertest_lw

ENV TZ=America/Los_Angeles
SHELL ["/bin/bash", "-c"]

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update
RUN apt-get install -y python3 python3-pip wget
RUN yes | apt-get install unzip build-essential make cmake git
RUN yes | apt-get install bubblewrap libgmp3-dev pkg-config
RUN yes | apt-get install expect curl

WORKDIR /home

# Install z3
RUN wget https://github.com/Z3Prover/z3/releases/download/z3-4.13.4/z3-4.13.4-x64-glibc-2.35.zip
RUN unzip -q z3-4.13.4-x64-glibc-2.35.zip -d .
RUN rm z3-4.13.4-x64-glibc-2.35.zip
RUN cp /home/z3-4.13.4-x64-glibc-2.35/bin/z3 /usr/bin/z3

# Install cvc5
RUN wget https://github.com/cvc5/cvc5/releases/download/cvc5-1.2.0/cvc5-Linux-x86_64-static.zip
RUN unzip -q cvc5-Linux-x86_64-static.zip -d .
RUN rm cvc5-Linux-x86_64-static.zip
RUN cp /home/cvc5-Linux-x86_64-static/bin/cvc5 /usr/bin/cvc5

# Install zipperposition
RUN bash /home/lean_hammertest_lw/install_zipperpn.sh

# Install Lean and Lean libraries
RUN wget https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh
RUN bash elan-init.sh -y
RUN rm elan-init.sh
RUN git clone https://github.com/leanprover-community/lean-auto
RUN cd lean-auto && git checkout f1ed94c00377128e53fed4255985ebfa88fd5c48; cd ..
RUN git clone https://github.com/leanprover-community/duper
RUN cd duper && git checkout 9cd4d4d1d71034d456d06aef2e4d07c911b88c65; cd ..

# Build lean_hammertest_lw (most part of it would be building Mathlib)
RUN source /root/.elan/env && cd /home/lean_hammertest_lw && lake build