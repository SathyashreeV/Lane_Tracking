# Lane Tracking

# Introduction

This code was a result from one of my courses project requirements. I wanted to implement a real case use from my Algorithms for Parameter & State Estimation course. In this project, I implemented a variety of computer vision and estimation algorithms to detect lanes on the road. The video footage used as the primary test case came from my Subaru's dashcam. As a result, I was using a genuine video file and was able to  

# Algorithms

From a very high level perspective, the computer vision algorithms used were gray scaling Sobel edge detection, and line Hough transformations.

# Discussion

#High Level Simulink Diagram

![Simulink Workflow](Images/Detailed Data/GeneralSimulinkOverview.PNG)

#Image Workflow

Below are the various images captured intermittently when my computer vision and estimation algorithms were applied

![Initial Video Image Input](Images/Detailed Data/InitialVideoImage.png)

![Gray Scaled Video Image](Images/Detailed Data/GrayScaleVideoImage.png)

![Edge Detection](Images/Detailed Data/PureEdgeDetectionImage.png)

![Region of Interest](Images/Detailed Data/EdgeDetectionImage.png)

![Output Result](Images/Detailed Data/GoodKalmanFilterImage.png)

# Kalman Filter Data

![Before Kalman Filter Dataset](Images/Detailed Data/BeforeKalman.png)

![After Kalman Filter Dataset](Images/Detailed Data/AfterKalman.png)
