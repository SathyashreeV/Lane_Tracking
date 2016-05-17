clear all;
close all;
clc;

load 'After Kalman Filter.mat'
after = ans';
load 'Before Kalman Filter.mat'
before = ans';

%Plot before Kalman Filtering
figure;
plot(before(:, 1), before(:, 2));
hold on;
plot(before(:, 1), before(:, 3));
hold on;
plot(before(:, 1), before(:, 4));
hold on;
plot(before(:, 1), before(:, 5));
xlabel('t')
ylabel('Hough Values')
legend('x', 'y', 'width', 'height');
title('All Hough Values Before Kalman Filter');

figure;
plot(after(:,1), after(:,2));
hold on;
plot(after(:,1), after(:,3));
hold on;
plot(after(:,1), after(:,4));
hold on;
plot(after(:,1), after(:,5));
xlabel('t')
ylabel('Hough Values Filtered')
legend('x', 'y', 'width', 'height');
title('All Hough Values After Kalman Filter');

% X
figure;
plot(before(:, 1), before(:, 2), 'b');
hold on;
plot(after(:,1), after(:,2), 'r');

xlabel('t');
ylabel('X');
title('X value vs Time');
legend('Before Kalman Filter', 'After Kalman Filter');

% Y
figure;
plot(before(:, 1), before(:, 3), 'b');
hold on;
plot(after(:,1), after(:,3), 'r');

xlabel('t');
ylabel('X');
title('Y value vs Time');
legend('Before Kalman Filter', 'After Kalman Filter');

% width
figure;
plot(before(:, 1), before(:, 4), 'b');
hold on;
plot(after(:,1), after(:,4), 'r');

xlabel('t');
ylabel('Width');
title('Width value vs Time');
legend('Before Kalman Filter', 'After Kalman Filter');

% height
figure;
plot(before(:, 1), before(:, 5), 'b');
hold on;
plot(after(:,1), after(:,5), 'r');

xlabel('t');
ylabel('Height');
title('Height value vs Time');
legend('Before Kalman Filter', 'After Kalman Filter');


















