ss = tf([3.3],[9.9898, 7.01, 1],'InputDelay', 5)
sysD = c2d(ss, 0.5, "zoh")
% step(ss)
% figure
% step(sysD)
%printprint("PID.png","-dpng","-r400")
Kp = 0.408;
Kr = 0.39;
Ti = 7.748;
Td = 1.1859;
T = 0.5;
r0 = Kr*(1 + T/(2*Ti) + Td/T);
r1 = Kr*(T/(2*Ti) - 2*Td/T - 1);
r2 = (Kr*Td)/T;