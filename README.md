# 3D reconstruction from multiple 2D images

The current [structure from motion (SFM)](https://github.com/opencv/opencv_contrib/tree/master/modules/sfm) module from [openCV's extra modules](https://github.com/opencv/opencv_contrib) only runs on Linux.

As such, I used [docker](https://www.docker.com) on my Mac to reconstruct the 3D points.

## Docker Dev Environment
```sh
# Build the docker image
docker build -t python-opencv .
# Run the docker container mounting `reconstruction` folder to `/app`
docker run -it -v <path_to_reconstruction_folder>:/app python-opencv /bin/bash
```

## Run
1) Download 2D temple images from <http://vision.middlebury.edu/mview/data>

2) Save list of images to `images.txt`:
```sh
# images.txt will contain lines of filepath
# /app/temple/temple0302.png
ls temple/*.png > images.txt
sed -i -e 's/^/\/app\//' images.txt
```
3) In the docker container, compile the cpp file
```
g++ example_sfm.cpp  -L/usr/local/lib/  -lopencv_core -lopencv_sfm
```
4) Run the example with the list of images
```
./a.out images.txt 350 240 360
```

## Test
```sh
# Test eigen (http://eigen.tuxfamily.org/dox/GettingStarted.html)
g++ -I /usr/local/Cellar/eigen/3.3.4/include/eigen3 eigen_test.cpp -o eigen
./eigen


# Test with full includes
g++ example_sfm.cpp -I /usr/include/eigen3/ -I/usr/local/include/opencv -I/usr/local/include/opencv2 -L /usr/local/share/OpenCV/3rdparty/lib/ -L/usr/local/lib/ -L /usr/include/eigen3/ -lopencv_core -lopencv_imgproc -lopencv_highgui -lopencv_ml -lopencv_optflow -lopencv_sfm -lopencv_viz
```
