FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04 as opencv-builder

RUN \
	apt-get update && apt-get install -y \
	build-essential \
	git \
	wget \
	ffmpeg \
	cmake pkg-config libswscale-dev \
	libtbb-dev libjpeg-dev \
	libpng-dev libtiff-dev \
	x264 \
	python3-pip \
        cmake \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

ENV OPENCV_VERSION=3.2.0

RUN pip3 install numpy


RUN git clone https://github.com/opencv/opencv_contrib.git && cd opencv_contrib && git checkout tags/${OPENCV_VERSION}

RUN wget https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.tar.gz -O opencv${OPENCV_VERSION}.tar.gz \
	&& tar zxvf opencv${OPENCV_VERSION}.tar.gz \
	&& mkdir opencv-build \ 
	&& cd opencv-build \
	&& cmake -D OPENCV_EXTRA_MODULES_PATH=/opencv_contrib/modules \
           -D WITH_FFMPEG=ON -D WITH_TBB=ON -D WITH_GTK=ON -D BUILD_EXAMPLES=OFF \
           -D WITH_GSTREAMER=ON -D WITH_CUDA=OFF -D INSTALL_PYTHON_EXAMPLES=OFF \
           -D INSTALL_C_EXAMPLES=OFF ../opencv-${OPENCV_VERSION} \
	&& make -j2 \
	&& make install


FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04 as tensorflow-builder

RUN mkdir /tensorflow

WORKDIR /tensorflow

ADD compile_tensorflow.sh .

FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04 as base


RUN \   
        apt-get update && apt-get install -y \
        libtinyxml2-dev \
        libeigen3-dev \
        libtbb-dev \
        libgstreamer1.0-dev \
        libgstreamer-plugins-base1.0-dev \
        gstreamer1.0-plugins-base \
        gstreamer1.0-plugins-good \
        gstreamer1.0-plugins-bad \
        gstreamer1.0-plugins-ugly \
        gstreamer1.0-libav \
        gstreamer1.0-doc \
        gstreamer1.0-tools \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*

RUN mkdir /traffic_analysis

WORKDIR /traffic_analysis

COPY --from=opencv-builder /opencv-build /opencv-build

COPY --from=opencv-builder /usr/local/bin/opencv* /usr/local/bin/

COPY --from=opencv-builder /usr/local/lib/ /usr/local/lib/

COPY --from=opencv-builder /usr/local/share/ /usr/local/share/

COPY --from=opencv-builder /usr/local/include/ /usr/local/include/
