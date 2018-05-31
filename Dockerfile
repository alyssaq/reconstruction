FROM python:3.6
LABEL maintainer="Alyssa Quek"

WORKDIR /

# Common libs and for OpenCV
RUN apt-get update && \
  apt-get install -y \
  build-essential \
  cmake \
  git \
  wget \
  unzip \
  yasm \
  vim \
  ninja-build \
  pkg-config \
  libswscale-dev \
  libtbb2 \
  libtbb-dev \
  libjpeg-dev \
  libpng-dev \
  libtiff-dev \
  libjasper-dev \
  libavformat-dev \
  libpq-dev \
  libeigen3-dev

# SFM dependencies: google-glog + gflags, blas + lapack, suitespare, VTK (viz toolkit)
RUN apt-get install -y \
  libgoogle-glog-dev \
  libatlas-base-dev \
  libsuitesparse-dev \
  libvtk5-dev \
  python-vtk \
  libgtk2.0-dev \
  libqt4-dev

RUN pip install --upgrade pip && pip install numpy

# Install Ceres Solver
RUN ceres_version=1.14.0 \
  && wget https://github.com/ceres-solver/ceres-solver/archive/"$ceres_version".zip -O ceres-solver.zip \
  && unzip ceres-solver.zip \
  && cd ceres-solver-"$ceres_version" \
  && mkdir build && cd build \
  && cmake -G Ninja .. \
  && ninja -j4 \
  && ninja install \
  && ldconfig

ENV PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig:/usr/lib/pkgconfig
# Include eigen into C++ build include
ENV CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:/usr/include/eigen3/:/usr/local/include/opencv:/usr/local/include/opencv2
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib

# Force HAVE_EIGEN and GFLAGS_FOUND to TRUE as cmake does not seem to set those flags correctly
RUN cv_version=3.4.1 \
  && wget https://github.com/opencv/opencv/archive/"$cv_version".zip -O opencv.zip \
  && unzip opencv.zip \
  && wget https://github.com/opencv/opencv_contrib/archive/"$cv_version".zip -O opencv_contrib.zip \
  && unzip opencv_contrib \
  && mkdir /opencv-"$cv_version"/cmake_binary \
  && cd /opencv-"$cv_version"/cmake_binary \
  && cmake -G Ninja \
    -DOPENCV_EXTRA_MODULES_PATH=/opencv_contrib-"$cv_version"/modules \
    -DHAVE_EIGEN=TRUE -DGFLAGS_FOUND=TRUE \
    -DBUILD_opencv_legacy=OFF \
    -DBUILD_TIFF=ON \
    -DENABLE_AVX=ON \
    -DWITH_OPENGL=ON \
    -DWITH_OPENCL=ON \
    -DWITH_IPP=ON \
    -DWITH_TBB=ON \
    -DWITH_EIGEN=ON \
    -DWITH_VTK=ON \
    -DWITH_V4L=ON \
    -DBUILD_EXAMPLES=OFF \
    -DINSTALL_C_EXAMPLES=OFF \
    -DINSTALL_PYTHON_EXAMPLES=ON \
    -DBUILD_TESTS=OFF \
    -DBUILD_PERF_TESTS=OFF \
    -DCMAKE_BUILD_TYPE=RELEASE \
    -DCMAKE_INSTALL_PREFIX=$(python3.6 -c "import sys; print(sys.prefix)") \
    -DPYTHON_EXECUTABLE=$(which python3.5) \
    -DPYTHON_INCLUDE_DIR=$(python3.6 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
    -DPYTHON_PACKAGES_PATH=$(python3.6 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") .. \
  && ninja -j4 install \
  && rm /opencv.zip \
  && rm /opencv_contrib.zip

RUN pip install -r requirements.txt

# Define default command
CMD ["bash"]
