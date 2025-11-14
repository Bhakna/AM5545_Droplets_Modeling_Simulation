clc;
clear variables;
close all;

% Notations used :
% x -> We
% y -> B

% curve 1
xdata = [5, 6, 7, 10];
ydata = [1.0, 0.75, 0.6, 0.5];
p1 = polyfit(xdata, ydata, 3);

% curve 2
xdata = [10, 20, 24.6, 50];
ydata = [0.5, 0.7001, 0.7501, 0.8];
p2 = polyfit(xdata, ydata, 3);

% curve 2 contd
p2_contd = [0, 0.8];

% curve 31
xdata = [10, 30, 40, 50];
ydata = [0.5, 0.475, 0.45, 0.4];
p31 = polyfit(xdata, ydata, 3);

% curve 32
xdata = [15, 30, 40, 50];
ydata = [0.0, 0.17, 0.185, 0.2];
p32 = polyfit(xdata, ydata, 3);

% plotting
figure(1)
hold on

x = linspace(5, 10, 100);
plot(x, polyval(p1, x), "Color", "Black", LineWidth=1.75)

x = linspace(10, 50, 100);
plot(x, polyval(p2, x), "Black", LineWidth=1.75)

x = linspace(50, 80, 100);
plot(x, polyval(p2_contd, x), "Black", LineWidth=1.75)

x = linspace(10, 61.1535, 100);
plot(x, polyval(p31, x), "Color", "Black", LineWidth=1.75)

x = linspace(15, 61.1535, 100);
plot(x, polyval(p32, x), "Color", "Black", LineWidth=1.75)

hold off
grid on
grid minor
axis([0, 50, 0, 1])
xlabel('We')
ylabel('B')
fontsize(20, "points")

% data = struct;
% data.p1 = p1;
% data.p2 = p2;
% data.p31 = p31;
% data.p32 = p32;
% 
% writestruct(data, "We_B_cubic_appx.xml")
