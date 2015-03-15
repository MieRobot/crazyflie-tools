function [xdot,y] = CrazyflieModel(t,x,u,Ixx,Iyy,Ixy,Kf,varargin)
%function [xdot,y] = CrazyflieModel(t,x,u,Ixx,Iyy,Izz,Ixy,Km,Kf,varargin)

% States:
% x
% y
% z
% phi (roll)
% theta (pitch)
% psi (yaw)
% xdot
% ydot
% zdot
% phidot
% thetadot
% psidot
%
% Inputs:
% omega^2 for each rotor

% Known parameters
g = 9.81;
m = 0.03337; % mass in Kg
L = 0.046; % Distance from rotor to COM (in m)

% Unknown parameters
% Ixx = 1E-6*Ixx;
% Iyy = 1E-6*Iyy;
% Izz = 1E-6*Izz;
% Ixy = 1E-7*Ixy;
% Ixx = 2.15E-6;
% Iyy = 2.15E-6;
Izz = 4.29E-6;
% Ixy = 2.37E-7;
Km = 0.0001;
% Kf = 0.004522393588278*Kf;
%Kf = 0.004522393588278;

I = [Ixx Ixy 0; Ixy Iyy 0; 0 0 Izz]; % Inertia matrix
invI = inv(I);

% states
phi = x(4);
theta = x(5);
psi = x(6);

phidot = x(10);
thetadot = x(11);
psidot = x(12);

% These are omega^2
w1 = u(1);
w2 = u(2);
w3 = u(3);
w4 = u(4);

% Thrust = kf*omega^2
F1 = Kf*w1; 
F2 = Kf*w2;
F3 = Kf*w3;
F4 = Kf*w4;

% Moments = km*omega^2
M1 = Km*w1;
M2 = Km*w2;
M3 = Km*w3;
M4 = Km*w4;

% Rotation matrix from body to world frames
[R,dR] = rpy2rotmat([phi;theta;psi]);
Rdot = reshape(dR(:,1)*phidot+dR(:,2)*thetadot+dR(:,3)*psidot,3,3);

xyz_ddot = (1/m)*([0;0;-m*g] + R*[0;0;F1+F2+F3+F4]);

% angular vel in base frame
pqr = rpydot2angularvel([phi;theta;psi],[phidot;thetadot;psidot]); 

% angular vel in body frame
pqr = R'*pqr;

% angular acceleration in body frame
pqr_dot = invI*([L*(F4-F2);L*(F3-F1);(M2+M4-M1-M3)]-cross(pqr,I*pqr));

% Now, convert pqr_dot to rpy_ddot
[Phi, dPhi] = angularvel2rpydotMatrix([phi;theta;psi]);
Phidot = reshape(dPhi(:,1)*phidot+dPhi(:,2)*thetadot+dPhi(:,3)*psidot,3,3);

rpy_ddot = Phidot*R*pqr + Phi*Rdot*pqr + Phi*R*pqr_dot;

xdot = [x(7:12);xyz_ddot;rpy_ddot];

%y = [x(1:3);pqr];
%y = pqr;
y = pqr(1:2);

end