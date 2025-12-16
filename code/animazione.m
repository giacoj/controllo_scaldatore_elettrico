%% PUNTO OPZIONALE: Animazione (LAYOUT LINEARE - NO ONDE)
% ESEGUIRE PRIMA IL CODICE PRINCIPALE DEI PUNTI 1-3

% --- 1. CONTROLLI DI SICUREZZA ---
if ~exist('R', 'var') || ~exist('x_e', 'var')
    errordlg('ERRORE: Variabile R non trovata! Esegui prima lo script principale.');
    error('Variabile R non trovata.'); 
end

fprintf('Avvio animazione... (Layout lineare pulito, senza onde)\n');

%% --- 2. PARAMETRI TEMPORALI ---

T_phys_end = 200;       % Tempo simulato lungo (per vedere tutto il transitorio).
Target_Wall_Time = 40;  % Tempo reale desiderato (l'animazione dura 40s).

Speed_Factor = T_phys_end / Target_Wall_Time; % Fattore di accelerazione.

dt_sim = 0.002;         % Passo Fisica (2 ms).
dt_anim = 0.05;         % Passo Grafica (50 ms).
ratio = round(dt_anim / dt_sim);

t_sim = 0:dt_sim:T_phys_end;

% --- Inizializzazione ---
[Ac, Bc, Cc, Dc] = ssdata(R);
xc = zeros(size(Ac,1), 1);      % Stato Regolatore
x_phys = x_e;                   % Stato Sistema [TR, Tout]
Target_Temp = T_out_e + 5;      % Riferimento (Gradino +5 gradi)
Max_Power_Scale = 2500;         % Fondo scala per la barra di potenza (Watt)

%% --- 3. CREAZIONE GRAFICA (LAYOUT LINEARE) ---

close all; 
f = figure('Name', 'Animazione Controllo Scaldatore', 'Color', 'w', ...
           'Position', [50, 50, 1100, 700]); % Finestra larga
shg; 

% =========================================================================
% PARTE SUPERIORE: SCHEMA A BLOCCHI FISICO/LOGICO
% =========================================================================
subplot(2, 2, [1 2]); 
axis([0 18 0 6]);      % Asse X più largo (0-18) per farci stare tutto in fila
axis off; hold on;
title(['Flusso di Controllo (Target: ' num2str(Target_Temp) '°C)'], 'FontSize', 12);

% --- 1. TERMOMETRO Tin (Costante) ---
% Posizione X = 1
rectangle('Position', [1, 1, 0.5, 4], 'EdgeColor', 'k'); 
fill([1, 1.5, 1.5, 1], [1, 1, 1.8, 1.8], 'b'); % Liquido Blu Fisso (25°C)
text(1.25, 0.5, 'T_{in}', 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
text(1.25, 5.2, '25°C', 'HorizontalAlignment', 'center', 'Color', 'b', 'FontSize', 8);

% Freccia verso destra
text(2, 3, '\rightarrow', 'FontSize', 20);

% --- 2. BLOCCO REGOLATORE ---
% Posizione X = 3 a 6
rectangle('Position', [3, 2, 3, 2], 'FaceColor', [0.9 0.9 0.9], 'Curvature', 0.1);
text(4.5, 3, 'REGOLATORE', 'HorizontalAlignment', 'center', 'FontWeight', 'bold');

% Freccia verso destra
text(6.2, 3, '\rightarrow', 'FontSize', 20);

% --- 3. BARRA POTENZA u(t) (Variabile) ---
% Posizione X = 7.5
rectangle('Position', [7.5, 1, 0.8, 4], 'EdgeColor', 'k'); 
% Creiamo il riempimento verde (altezza dinamica)
h_power_fill = fill([7.5, 8.3, 8.3, 7.5], [1, 1, 1, 1], [0 0.7 0]); 
h_power_text = text(7.9, 5.2, '0 W', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'Color', [0 0.5 0]);
text(7.9, 0.5, 'u(t)', 'HorizontalAlignment', 'center');

% Freccia verso destra
text(8.8, 3, '\rightarrow', 'FontSize', 20);

% --- 4. BLOCCO SISTEMA (Scaldatore) ---
% Posizione X = 10 a 14
rectangle('Position', [10, 1.5, 4, 3], 'FaceColor', [0.95 0.95 0.95], 'Curvature', 0.1);
text(12, 4, 'SISTEMA', 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
text(12, 1, '(Scaldatore)', 'HorizontalAlignment', 'center', 'FontSize', 8);

% Freccia verso destra
text(14.5, 3, '\rightarrow', 'FontSize', 20);

% --- 5. TERMOMETRO Tout (Variabile) ---
% Posizione X = 16
rectangle('Position', [16, 1, 0.5, 4], 'EdgeColor', 'k'); 
% Creiamo il riempimento rosso (altezza dinamica)
h_therm_fill = fill([16, 16.5, 16.5, 16], [1, 1, 1, 1], 'r');
h_therm_text = text(16.25, 5.2, '', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'Color', 'r');
text(16.25, 0.5, 'T_{out}', 'HorizontalAlignment', 'center');


% =========================================================================
% PARTE INFERIORE: GRAFICI TEMPORALI
% =========================================================================

% --- Grafico SX: Temperature ---
subplot(2, 2, 3);
hold on; grid on; box on;
h_w = animatedline('Color', 'k', 'LineStyle', '--', 'LineWidth', 1.5);
h_y = animatedline('Color', 'r', 'LineWidth', 2);
legend([h_w, h_y], {'Riferimento w', 'Uscita y'}, 'Location', 'SouthEast');
title('Temperature');
xlabel('Tempo [s]'); ylabel('°C');
xlim([0 T_phys_end]); ylim([T_in, 100]); 

% --- Grafico DX: Errore ---
subplot(2, 2, 4);
hold on; grid on; box on;
yline(0, 'k-.', 'Target', 'LineWidth', 1); % Linea dello zero
h_e = animatedline('Color', [0.9 0.5 0], 'LineWidth', 1.5); 
legend(h_e, {'Errore e(t)'}, 'Location', 'NorthEast');
title('Errore di Inseguimento');
xlabel('Tempo [s]'); ylabel('Errore [°C]');
xlim([0 T_phys_end]); ylim([-15, 15]); 

drawnow; % Forza il rendering iniziale

%% --- 4. CICLO DI SIMULAZIONE ---

start_wall_time = tic; 

for k = 1:length(t_sim)
    
    if ~ishandle(f), break; end
    time_phys = t_sim(k); 
    
    % --- LOGICA CONTROLLO & FISICA ---
    w_val = (time_phys < 1) * T_out_e + (time_phys >= 1) * Target_Temp;
    
    y_val = x_phys(2);
    e_val = w_val - y_val;
    
    % Regolatore
    dxc = Ac * xc + Bc * e_val;
    du = Cc * xc + Dc * e_val;
    xc = xc + dxc * dt_sim;
    
    % Saturazione fisica (Potenza >= 0)
    % NOTA: Usa u_e dal workspace. Se u_e manca o è 0, u_tot partirà da 0.
    u_tot = max(0, u_e + du);
    
    % Modello Fisico Non Lineare
    TR = x_phys(1); Tout = x_phys(2);
    dTR = (h_R*A_R*(Tout - TR) + u_tot/(1 + K*TR)) / (m_R*c_R);
    dTout = (m_A_dot*c_A*(T_in - Tout) + h_R*A_R*(TR - Tout)) / (m_A*c_A);
    x_phys = x_phys + [dTR; dTout] * dt_sim;
    
    % --- AGGIORNAMENTO GRAFICA ---
    if mod(k, ratio) == 0
        
        % 1. Aggiorna Grafici in basso
        addpoints(h_w, time_phys, w_val);
        addpoints(h_y, time_phys, y_val);
        addpoints(h_e, time_phys, e_val);
        
        % 2. Aggiorna Barra POTENZA u (Verde)
        h_bar_u = 1 + (u_tot / Max_Power_Scale) * 4; % Mappa 0-2500W in altezza 1-5
        if h_bar_u > 5, h_bar_u = 5; end
        if h_bar_u < 1, h_bar_u = 1; end
        set(h_power_fill, 'YData', [1, 1, h_bar_u, h_bar_u]);
        set(h_power_text, 'String', sprintf('%.0f W', u_tot), 'Position', [7.9, h_bar_u + 0.2]);
        
        % 3. Aggiorna Termometro TOUT (Rosso)
        h_bar_t = 1 + (y_val / 150)*4; % Mappa 0-150°C in altezza 1-5
        if h_bar_t > 5, h_bar_t = 5; end
        
        % Colore output (interpolazione blu->rosso)
        T_norm = max(0, min(1, (y_val - 25)/(Target_Temp - 25)));
        col = [T_norm, 0, 1-T_norm];
        
        set(h_therm_fill, 'YData', [1, 1, h_bar_t, h_bar_t], 'FaceColor', col);
        set(h_therm_text, 'String', sprintf('%.1f°C', y_val), 'Position', [16.25, h_bar_t + 0.2], 'Color', col);
        
        drawnow limitrate;
        
        % Sincronizzazione Temporale (Time Warp)
        elapsed_wall = toc(start_wall_time); 
        wanted_wall_time = time_phys / Speed_Factor;
        if elapsed_wall < wanted_wall_time
            pause(wanted_wall_time - elapsed_wall);
        end
    end
end

fprintf('Animazione completata.\n');