#!/bin/sh

echo 'Start installing TensorRT ...'

filename="nv-tensorrt-repo-ubuntu1804-cuda10.0-trt5.0.2.6-ga-20181009_1-1_amd64.deb"
wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1oUJOLEtnLIfsyvCcdhtuBoW5aErR9d1y' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1oUJOLEtnLIfsyvCcdhtuBoW5aErR9d1y" -O nv-tensorrt-repo-ubuntu1804-cuda10.0-trt5.0.2.6-ga-20181009_1-1_amd64.deb && rm -rf /tmp/cookies.txt

dpkg -i ${filename}
apt-key add /var/nv-tensorrt-repo-ubuntu1804-cuda10.0-trt5.0.2.6-ga-20181009/7fa2af80.pub

rm -r ${filename}

apt-get update && apt-get install -y tensorrt python3-libnvinfer-dev

echo 'Finished installing TensorRT ...'

echo "downloading tensorflow"
git clone https://github.com/tensorflow/tensorflow
cd tensorflow
git checkout r1.10

echo "configure tensorflow build"
export TMP=/tmp
export PYTHON_BIN_PATH=$(which python3)
export PYTHON_LIB_PATH=/usr/local/lib/python3.5/dist-packages
export TF_NEED_JEMALLOC=1
export TF_NEED_GCP=0 # Google Cloud Platform support
export TF_NEED_HDFS=0 # Hadoop File System
export TF_NEED_S3=0 # Amazon S3 File System
export TF_NEED_AWS=0 # Amazon AWS Platform
export TF_NEED_KAFKA=0 # Apache Kafka Platform
export TF_ENABLE_XLA=1 # XLA JIT
export TF_NEED_GDR=0 # GDR
export TF_NEED_VERBS=0
export TF_NEED_OPENCL_SYCL=0
export TF_NEED_MPI=0
export CC_OPT_FLAGS="-march=native"
export TF_NEED_CUDA=1
export TF_CUDA_VERSION=10.0
export TF_CUDA_COMPUTE_CAPABILITIES=6.2
export CUDA_TOOLKIT_PATH=/usr/local/cuda
export TF_CUDNN_VERSION=7
export CUDNN_INSTALL_PATH=/usr/lib/x86_64-linux-gnu
export TF_NEED_TENSORRT=1
export TENSORRT_INSTALL_PATH=/usr/lib/x86_64-linux-gnu
export TF_CUDA_CLANG=0
export GCC_HOST_COMPILER_PATH=$(which gcc)
export TF_NCCL_VERSION=1

export TF_SET_ANDROID_WORKSPACE=0

export TF_CPP_MIN_VLOG_LEVEL=2
export TF_CPP_MIN_LOG_LEVEL=2

./configure

# build for gpu operation
#bazel build --config=opt --config=cuda --verbose_failures //tensorflow:libtensorflow_cc.so
