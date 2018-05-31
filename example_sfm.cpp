#define CERES_FOUND true

#include <opencv2/sfm.hpp>
#include <iostream>
#include <fstream>

using namespace std;
using namespace cv;
using namespace cv::sfm;

static void help() {
  cout
      << "\n------------------------------------------------------------------------------------\n"
      << " This program shows the multiview reconstruction capabilities in the \n"
      << " OpenCV Structure From Motion (SFM) module.\n"
      << " It reconstruct a scene from a set of 2D images \n"
      << " Usage:\n"
      << "        example_sfm_scene_reconstruction <path_to_file> <f> <cx> <cy>\n"
      << " where: path_to_file is the file absolute path into your system which contains\n"
      << "        the list of images to use for reconstruction. \n"
      << "        f  is the focal lenght in pixels. \n"
      << "        cx is the image principal point x coordinates in pixels. \n"
      << "        cy is the image principal point y coordinates in pixels. \n"
      << "------------------------------------------------------------------------------------\n\n"
      << endl;
}

int getdir(const string _filename, vector<String> &files)
{
  ifstream myfile(_filename.c_str());
  if (!myfile.is_open()) {
    cout << "Unable to read file: " << _filename << endl;
    exit(0);
  } else {;
    size_t found = _filename.find_last_of("/\\");
    string line_str, path_to_file = _filename.substr(0, found);
    while ( getline(myfile, line_str) ) {
      cout << line_str << endl;
      files.push_back(String(line_str));
    }
  }
  return 1;
}

int main(int argc, char* argv[])
{
  // Read input parameters
  if ( argc != 5 )
  {
    help();
    exit(0);
  }

  // Parse the image paths
  vector<String> images_paths;
  getdir(argv[1], images_paths);

  // Build instrinsics
  float f  = atof(argv[2]),
        cx = atof(argv[3]), cy = atof(argv[4]);
  Matx33d K = Matx33d( f, 0, cx,
                       0, f, cy,
                       0, 0,  1);
  bool is_projective = true;
  vector<Mat> Rs_est, ts_est, points3d_estimated;
  sfm::reconstruct(images_paths, Rs_est, ts_est, K, points3d_estimated, is_projective);

  // Print output
  cout << "\n----------------------------\n" << endl;
  cout << "Reconstruction: " << endl;
  cout << "============================" << endl;
  cout << "Estimated 3D points: " << points3d_estimated.size() << endl;
  cout << "Estimated cameras: " << Rs_est.size() << endl;
  cout << "Refined intrinsics: " << endl << K << endl << endl;
  cout << "3D Visualization: " << endl;
  cout << "============================" << endl;

  // recover estimated points3d
  ofstream points_file;
  cv::MatIterator_<double> mat_it;
  points_file.open("points.txt");
  points_file.precision(std::numeric_limits<double>::digits10);
  for (int i = 0; i < points3d_estimated.size(); ++i) {
    cout << points3d_estimated[i] << endl;
    for(mat_it = points3d_estimated[i].begin<double>(); mat_it != points3d_estimated[i].end<double>(); mat_it++) {
      points_file << *mat_it << " ";
    }
    points_file << "\n";
  }

  cout << "Done. Points saved to points.txt" << endl;
  points_file.close();

  return 0;
}
