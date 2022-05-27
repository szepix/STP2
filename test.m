clear all
w =[0.03678 0.003272 -1.683 0.7041];
%odpowiedź skokowa
Lm=[w(1) w(2)];
Mm=[1 w(3) w(4)];
mod=tf(Lm,Mm);
s=step(mod);


%horyzonty
D=25;        %horyzont dynamiki
N=6;        %horyzont predykcji
Nu=10;       %horyzont sterowania

% Współczynnik kary
lambda=1;
% Warunki początkowe
krok = 1;                            
czas_symulacji = 200;                          
lIter = czas_symulacji/krok + 1;    %liczba iteracji
kp = 15;            
uk(1:13)=0;
ymod(1:13)=0;
yzad(1:15)=0;
yzad(kp:lIter-1)=1;
deltaupk = zeros(1, D-1);

% Macierz M
M=zeros(N,Nu);
for i=1:N
   for j=1:Nu
      if (i>=j)
         M(i,j)=s(i-j+1);
      end
   end
end
% Macierz Mp
MP=zeros(N,D-1);
for i=1:N
   for j=1:D-1
      if i+j<=D
         MP(i,j)=s(i+j)-s(j);
      else
         MP(i,j)=s(D)-s(j);
      end  
   end
end
% Obliczanie parametrów regulatora
I=eye(Nu);
K=((M'*M+lambda*I)^(-1))*M';
Ku=K(1,:)*MP;
Ke=sum(K(1,:));


% Pętla główna

for k=13:lIter-1
   % Obiekt
   ymod(k)=w(1)*uk(k-11)+w(2)*uk(k-12)-w(3)*ymod(k-1)-w(4)*ymod(k-2);
   % Regulator 

    for n=D-1:-1:2
      deltaupk(n)=deltaupk(n-1);    %sterowanie na horyzoncie dynamiki
    end
   uchyb(k)=yzad(k)-ymod(k);
   delta_uk=Ke*uchyb(k);
   deltaupk(1)=delta_uk; %bierzemy tylko pierwszy element sterowania
   uk(k)=uk(k-1)+delta_uk;   
   wejscie_u(k)=uk(k);
   wyjscie_y(k)=ymod(k);

end


%Przedstawienie graficzne
czas = 0:krok:czas_symulacji-1;  
stairs(czas, wyjscie_y)
xlabel('k');
hold on;
ylabel('y,yzad')
stairs(1:lIter-1,yzad,'k--')
title(['regulator DMC D=',sprintf('%g',D'),' N=',sprintf('%g',N),' Nu=',sprintf('%g',Nu),' L=',sprintf('%g',lambda)]);
legend('Wyjscie z modelu','wartosc zadana')
figure
stairs(czas, wejscie_u)
ylabel('u')
xlabel('k');
legend('sygnał sterujący')
