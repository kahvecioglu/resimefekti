#include <opencv2/opencv.hpp>
#include <iostream>

extern "C" {
    const char* applyFilter(const char* imagePath, const char* filter) {
        cv::Mat image = cv::imread(imagePath);
        if (image.empty()) {
            return "Error: Image not found";
        }

        if (strcmp(filter, "grayscale") == 0) {
            cv::cvtColor(image, image, cv::COLOR_BGR2GRAY);
        } else if (strcmp(filter, "blur") == 0) {
            cv::GaussianBlur(image, image, cv::Size(15, 15), 0);
        }

        std::string outputPath = "processed_image.png";
        cv::imwrite(outputPath, image);
        return outputPath.c_str();
    }
}
