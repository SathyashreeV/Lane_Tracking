# Lane Tracking

# Introduction

This code was the end product result from one of my course projects. In this project, I implemented a few computer vision and estimation algorithms to detect lanes on the road. The video footage used as the primary test case came from my Subaru's dashcam. The day/night time dynamics my camera picked up posed new problems to an already difficult problem in computer vision technology.   

# Algorithms

From a very high level perspective, the computer vision algorithms used were gray scale decomposition, Sobel edge detection, and line Hough transformations. A Kalman filter was also used to smooth out and help follow along a road path for a given time. 

### Kalman Filtering

Kalman filtering provided an interesting dynamic to the computer vision algorithm and brought in a layer of memory in order to detect lanes. In essence, the Kalman filter attempts to estimate a trend within a dynamic system; the filter has a current measurement and future measurement prediction system. The Kalman filter works by constantly trying to guess the next measurement in the system and compares itself with the real measurement of the system. This constant comparison changes the Kalman filters tracking algorithm to trust more of it's previous measurement values or more of the new incoming values in a markovian chain.

The filter has very desirable characteristics as it is very light on memory so it does not require a lot of memory overhead in order to calculate new measurements in time. This would bring forth a multitude of trade-offs between offline and onine estimation, but that would be for another topic entirely.  

# Discussion

#High Level Simulink Diagram

![Simulink Workflow](Images/Detailed Data/GeneralSimulinkOverview.PNG)

#Image Workflow

Below are the various images captured intermittently when my computer vision and estimation algorithms were applied

### Inital Video Image Input
![Initial Video Image Input](Images/Detailed Data/InitialVideoImage.png)

###Gray Scaled Video Image
![Gray Scaled Video Image](Images/Detailed Data/GrayScaleVideoImage.png)

###Edge Detection
![Edge Detection](Images/Detailed Data/PureEdgeDetectionImage.png)

###Region of Interest
![Region of Interest](Images/Detailed Data/EdgeDetectionImage.png)

###Output Result
![Output Result](Images/Detailed Data/GoodKalmanFilterImage.png)

# Kalman Filter Data

### Before Kalman Filter was applied
![Before Kalman Filter Dataset](Images/Detailed Data/BeforeKalman.png)

### After Kalman Filter was applied
![After Kalman Filter Dataset](Images/Detailed Data/AfterKalman.png)
