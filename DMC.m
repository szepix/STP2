clear
%Inicjalizacja zmiennych obiektu
K0 = 3.3; T0 = 5; T1 = 1.99; T2 = 5.02;
%Okres próbkowania
Tp = 0.5;

%Transmitancja odbiektu
G_s = tf([0 0 K0], [T1*T2 T1+T2 1], "InputDelay", T0);
G_z = c2d(G_s, Tp);
% test = 0;
% f = step(G_z, 10000);
% for k=1:10000
%     if(f(k) >= 0.998*f(10000) && f(k) <= 0.999*f(10000))
%         test = k;
%     end
% end
num = cell2mat(G_z.Numerator);
denom = cell2mat(G_z.Denominator);
%Parametry modelu
b0 = num(3);
b1 = num(2);
a0 = denom(3);
a1 = denom(2);

%Horyzonty
D = 80; %Horyzont Dynamiki
N= 20;    %Horyzont predykcji
Nu = 2; %Horyzont sterowania

%Macierz odpowiedzi skokowej
s = step(G_z, D);

%Współczynnik kary
lamb = 1;

kk = 3000; %koniec symulacji
kp = max(13,D+1); %początek symulacji
ks = max(16,D+4); %chwila skoku wartosci zadania

%War początkowe
u(1:kp) = 0; y(1:kp) = 0;
yzad(1:ks)=0; yzad(ks:kk)=1;
e(1:kp) = 0;
%Macierz M
M = zeros(N,Nu);
for i=1:N
   for j=1:Nu
       if i>=j
           M(i,j)=s(i-j+1);
       end
   end
end

%Macierz MP
MP = zeros(N,D-1);
for i = 1:N
    for j = 1:(D-1)
        MP(i,j) = s(i+j) - s(j);
    end
end

K = ((M'*M + lamb * eye(Nu))^(-1))* M';
deltaupk = zeros(D-1, 1);
Y = zeros(N,1);
%główne wykonanie programu
for k=kp:kk
    for n=1:N
        Yzad(n,1) = yzad(k);
    end
    %symulacja obiektu
    y(k)=(b1*u(k-1 - 10*1)+b0*u(k-2 -10*1))*1-a1*y(k-1)-a0*y(k-2);
    for n=1:N
        Y(n) = y(k);
    end
    %DMC
    for n = 1:D-1
        deltaupk(n) = u(k-n) - u(k-n-1);
    end
    Yo = MP*deltaupk+Y;
    delta_uk = K*(Yzad - Yo);
   u(k)=u(k-1)+delta_uk(1);   
   wejscie_u(k)=u(k);
   wyjscie_y(k)=y(k);
    
    
    
end

czas = 0:1:kk-1;  
stairs(czas, wyjscie_y)
hold on
stairs(czas,yzad,'k--')
title(['regulator DMC D=',sprintf('%g',D'),' N=',sprintf('%g',N),' Nu=',sprintf('%g',Nu),' L=',sprintf('%g',lamb)]);
legend('Wyjscie z modelu','wartosc zadana')


