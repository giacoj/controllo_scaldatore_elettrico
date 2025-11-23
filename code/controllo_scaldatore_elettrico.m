% Progetto controllo di un riscaldatore elettrico
% Giacomo Nobili
% Federico Raffoni
% Marco Roca

close all; clear all; clc;

% parametri del sistema
h_R   = 50;          %  coefficiente di convezione tra riscaldatore e aria [W/(m2 C°)]
A_R   = 0.09;        %  area di scambio termico tra riscaldatore e aria [m2]
c_R   = 823.6;       %  calore specifico del riscaldatore [J/(kg C°)]
c_A   = 1010;        %  calore specifico dell'aria [J/(kg C°)]
m_R   = 1.542;       %  massa del riscaldatore [kg];
m_A   = 0.1041;      %  massa dell'aria [kg]
m_A_dot = 0.2;       %  portata massica dell'aria [kg/s].
T_in    = 25;        %  temperatura dell'aria in ingresso (costante) [C°]
K   = 2e-3;          %  coefficiente di variazione della resistenza con la temperatura  [1/C°]
T_R_e   = 200;       %  temperatura del riscaldatore di equilibrio [C°];
T_out_e = 80;        %  temperatura dell'aria in uscita dal riscaldatore di equilibrio [C°]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Punto 1
% A) 
% Funzione dello stato del sistema
x = @(t,x)[(h_R*A_R)/(m_R*c_R)*x(2)-(h_R*A_R)/(m_R*c_R)*x(1)+1/(m_R*c_R)*(uu/1+K*x(1));
                m_A_dot/m_A*T_in-(m_A_dot/m_A+(h_R*A_R)/(m_A*c_A))*x(2)+(h_R*A_R)/(m_A*c_A)*x(1)];

% Funzione dell'uscita del sistema
y = @(t,x)[0; x(2)];

% B) 
% Coppia di equilibrio
x_e = [T_R_e; T_out_e];
u_e = (h_R*A_R)*(x_e(1) - x_e(2))*(1 + K*x_e(1));

% Linearizzazione del sistema non lineare nell'equilibrio (x_e, u_e)
% δx˙ = Aδx + Bδu
% Matrice A
A1 = -(h_R*A_R)/(m_R*c_R)-(1/(m_R*c_R)*u_e*K)/(1+K*x_e(1))^2;   % df1/dx1
A2 = (h_R*A_R)/(m_R*c_R);                                       % df1/dx2
A3 = (h_R*A_R)/(m_A*c_A);                                       % df2/dx1
A4 = -m_A_dot/m_A-(h_R*A_R)/(m_A*c_A);                          % df2/dx2

A = [A1 A2; A3 A4];                                             % matrice 2x2

% Matrice B
B1 = (1/(m_R*c_R))/(1+K*x_e(1));                                  % df1/du
B2 = 0;                                                         % df2/du

B = [B1; B2];                                                   % matrice 2x1

% δy = Cδx + Dδu, 
% Matrice C
C1 = 0;                                                         % dh/dx1
C2 = 1;                                                         % dh/dx2

C = [C1 C2];                                                    % matrice 1x2

% Matrice D
D = 0;                                                          % dh/du

% Modello
modello = ss(A, B, C, D);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Punto 2
% Funzione di trasferimento G(s) tale che δY (s) = G(s)δU(s)
G = tf(modello)

% Poli di G(s)
p = pole(G);
fprintf("I poli di G:\n");
disp(p);

% Zeri di G(s) (NON NE HA)
z = zero(G);
fprintf("Gli zeri di G:\n");
disp(z);                   

% Poli e zeri nel piano complesso
figure
pzmap(G);

% Diagrammi di Bode della G
figure
bode(G);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%










