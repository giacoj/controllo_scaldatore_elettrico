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
T_out_e = 80;        %   temperatura dell'aria in uscita dal riscaldatore di equilibrio [C°]

% ingrsso del sistema
uu = 100; 

% intervallo di tempo
interv = [0 60]; % da 0 a 60 secondi

%definiamo per semplicità i parametri
alpha = (h_R*A_R)/(m_R*c_R);
beta = 1/(m_R*c_R);
gamma = m_A_dot/m_A;
psi = (h_R*A_R)/(m_A*c_A);

% funzione della dinamica del sistema
f_tilde = @(t,x)[alpha*x(2) - alpha*x(1) + beta*(uu/1+K*x(1));
                gamma*T_in-(gamma+psi)*x(2) + psi*x(1)];

% stato iniziale equilibrio
x_e = [T_R_e ; T_out_e];

% Traiettoria di stato del riscaldatore elettrico
[time, traj] = ode45(f_tilde,interv,x_e);

%plot

figure
plot(time,traj)
title('Traiettoria di stato del riscaldatore elettrico')
xlim(interv)
xlabel('tempo [s]')
ylabel('stato')
legend('Temperatura riscaldatore', ' temperatura aria in uscita dal riscaldatore')
grid on; zoom on; box on;

% Coppia di equilibrio
x_e = [T_R_e; T_out_e];
u_e = (alpha/beta)*(x_e(1) - x_e(2))*(1 + K*x_e(1));

% Linearizzazione del sistema non lineare nell'equilibrio (x_e, u_e)





