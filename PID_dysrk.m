clear all
%definicja parametrów reg ciągłego
Kr = 0.39;
Ti = 7.748;
Td = 1.859;
T = 0.5;

%Inicjalizacja zmiennych obiektu
K0 = 3.3; T0 = 5; T1 = 1.99; T2 = 5.02;
%Okres próbkowania
Tp = 0.5;

%Transmitancja odbiektu
G_s = tf([0 0 K0], [T1*T2 T1+T2 1], "InputDelay", T0);
G_z = c2d(G_s, Tp);


r0 = Kr*(1+ T/(2*Ti) + Td/T);
r1 = Kr*(T/(2*Ti)- 2*Td/T -1);
r2 = (Kr*Td)/T;

num = cell2mat(G_z.Numerator);
denom = cell2mat(G_z.Denominator);
%Parametry modelu
b0 = num(3);
b1 = num(2);
a0 = denom(3);
a1 = denom(2);

kk = 3000; %koniec symulacji

%warunki początkowe
u(1:25) = 0; y(1:25) = 0;
yzad(1:25)=0; yzad(30:kk)=1;
e(1:25) = 0;

for k=25:kk
    %symulacja obiektu
    y(k)=(b1*u(k-1 - 10*2)+b0*u(k-2- 10*2))*0.951-a1*y(k-1)-a0*y(k-2);
    e(k)=yzad(k)-y(k);
    u(k)=r2*e(k-2)+r1*e(k-1)+r0*e(k)+u(k-1);
end

%wyniki symluacji
% figure; stairs(u);
% title("Wartość sterowania PID"); xlabel('k'); ylabel("u");
% name = "zad4_PID_u";
% print(name,'-dpng','-r400')

figure; stairs(y);
hold on; stairs(yzad,':');
title("Odpowiedź skokowa układu z regulatorem"); xlabel('k'); ylabel("y");
hold off;

