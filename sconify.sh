#!/bin/bash

# declare an image name
IMG_NAME=whatsentity-iexec

IMG_FROM=${IMG_NAME}:non-tee
IMG_TO=${IMG_NAME}:tee

# build the regular non-TEE image
docker build . -t ${IMG_FROM}

# run the sconifier to build the TEE image based on the non-TEE image
docker run -it --rm \
            -e LD_LIBRARY_PATH=/lib:/lib/x86_64-linux-gnu:/lib64:/usr/lib/x86_64-linux-gnu/ \
            -v /var/run/docker.sock:/var/run/docker.sock \
            registry.scontain.com:5050/sconecuratedimages/iexec-sconify-image:5.3.3-glibc \
            sconify_iexec \
            --base=ubuntu:20.04 \
            --name=${IMG_NAME} \
            --from=${IMG_FROM} \
            --to=${IMG_TO} \
            --binary-fs \
            --fs-dir=/app \
            --fs-file=/usr/lib/x86_64-linux-gnu/libcblas.so.3 \
            --fs-file=/usr/lib/x86_64-linux-gnu/libatlas.so.3 \
            --fs-file=/usr/lib/x86_64-linux-gnu/liblapack.so.3 \
            --fs-file=/usr/lib/x86_64-linux-gnu/libblas.so.3 \
            --fs-file=/usr/lib/x86_64-linux-gnu/libgfortran.so.5 \
            --fs-file=/usr/lib/x86_64-linux-gnu/libgcc_s.so.1 \
            --fs-file=/usr/lib/x86_64-linux-gnu/libquadmath.so.0 \
            --fs-file=/usr/lib/x86_64-linux-gnu/libz.so.1 \
            --fs-file=/usr/lib/x86_64-linux-gnu/libstdc++.so.6 \
            --host-path=/etc/hosts \
            --host-path=/etc/resolv.conf \
            --binary=/root/miniconda/bin/python3.9 \
            --heap=1G \
            --dlopen=2 \
            --no-color \
            --verbose \
            && echo -e "\n------------------\n" \
            && echo "successfully built TEE docker image => ${IMG_TO}" \
            && echo "application mrenclave.fingerprint is $(docker run -it --rm -e SCONE_HASH=1 ${IMG_TO})"
