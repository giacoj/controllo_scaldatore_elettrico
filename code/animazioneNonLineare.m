%% 1. ESTRAZIONE E PULIZIA DATI
rif_v = squeeze(out.logsout.get('riferimento').Values.Data);
ins_v = squeeze(out.logsout.get('ingresso').Values.Data);
stati = squeeze(out.logsout.get("x").Values.Data);
tempo = out.tout;

T_R   = stati(1, :);   
T_out = stati(2, :);

% Parametri di equilibrio e calcolo errore
T_out_e = 28.8136;
rif_v = rif_v(:) + T_out_e; 
T_out = T_out(:);
errore_v = rif_v - T_out; 

%% 2. PREPARAZIONE ANIMAZIONE
decim = 2500; 
idx   = 1:decim:length(tempo);
t_a      = tempo(idx);
rif_a    = rif_v(idx);
Pe_a     = ins_v(idx);
TR_a     = T_R(idx);
Tout_a   = T_out(idx);
errore_a = errore_v(idx);

%% 3. SETUP FIGURA E LAYOUT (CON LIMITI DINAMICI SICURI)
close all;
fig = figure('Color', 'w', 'Name', 'Monitoraggio Sistema Scaldatore', 'Position', [50, 50, 1200, 950]);

% --- AREA ANIMAZIONE (COMPATTA) ---
axSim = subplot('Position', [0.1, 0.52, 0.8, 0.42]); 
hold(axSim, 'on'); axis(axSim, 'off');
set(axSim, 'XLim', [0 14], 'YLim', [-1 14]); 

% Elementi Grafici (Riquadri, Sistema, Regolatore)
rectangle('Position', [4.5, 0.5, 4, 8.5], 'LineStyle', '--', 'EdgeColor', [0.5 0.5 0.5], 'LineWidth', 1.5);
text(6.5, 9.8, 'SCALDATORE', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 14);
hSistema = rectangle('Position', [5, 5, 3, 3.5], 'Curvature', 0.2, 'LineWidth', 2.5);
text(6.5, 6.75, 'SISTEMA', 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
rectangle('Position', [5, 1, 3, 2], 'Curvature', 0.1, 'LineWidth', 2); 
text(6.5, 2, 'REGOLATORE', 'HorizontalAlignment', 'center', 'FontWeight', 'bold');

% Frecce e Etichette
text(0.5, 7.8, 'T_{in} (25°C)', 'Color', 'b', 'FontWeight', 'bold'); 
quiver(2.5, 2, 2, 0, 0, 'Color', [0.4 0.4 0.4], 'LineWidth', 2); 
hFrecciaPe = quiver(6.5, 3, 0, 2, 0, 'Color', 'g', 'LineWidth', 2, 'MaxHeadSize', 0.8);

% Sinusoidi Fluido
res = 150;
x_in = linspace(0.5, 5, res);   
hSinIn = plot(x_in, 7.2 + 0.4*sin(x_in*10), 'b', 'LineWidth', 2.5);
x_out = linspace(8, 12.5, res); 
hSinOut = plot(x_out, 6.2 + 0.4*sin(x_out*10), 'r', 'LineWidth', 3);

% Label dinamiche
hT_tempo = text(1, 13, '', 'FontSize', 13, 'FontWeight', 'bold');
hT_rif   = text(2.3, 2, '', 'FontWeight', 'bold', 'HorizontalAlignment', 'right');
hT_pe    = text(6.7, 4, '', 'Color', [0 0.5 0], 'FontWeight', 'bold');
hT_tout  = text(12.6, 6.2, '', 'Color', 'r', 'FontWeight', 'bold');

% --- CALCOLO LIMITI DI SICUREZZA ---
% Troviamo i valori assoluti min/max per evitare che le curve escano
y_min_track = min([min(rif_v), min(T_out)]) - 5;
y_max_track = max([max(rif_v), max(T_out)]) + 5;

y_min_err = min(errore_v) - 2;
y_max_err = max(errore_v) + 2;

% --- GRAFICI TECNICI ---
t_finale = tempo(end);

% Plot Tracking (Asse X e Y fissi per stabilità)
axTrack = subplot('Position', [0.1, 0.08, 0.38, 0.35]); grid on; hold on;
hAnRif = animatedline('Color', 'k', 'LineStyle', '--', 'LineWidth', 1.2);
hAnOut = animatedline('Color', 'r', 'LineWidth', 1.5);
title('Tracking Temperatura', 'FontSize', 12); xlabel('Tempo [s]'); ylabel('Temp [°C]');
xlim(axTrack, [0, t_finale]); 
ylim(axTrack, [y_min_track, y_max_track]); % Limiti calcolati sui dati reali
legend('Riferimento', 'T_{out}', 'Location', 'southeast');

% Plot Errore (Asse X e Y fissi per stabilità)
axErr = subplot('Position', [0.55, 0.08, 0.38, 0.35]); grid on; hold on;
yline(axErr, 0, 'k-', 'Alpha', 0.5); 
hAnErr = animatedline('Color', [0.1 0.5 0.8], 'LineWidth', 1.5);
title('Errore di Regolazione', 'FontSize', 12); xlabel('Tempo [s]'); ylabel('e(t) [°C]');
xlim(axErr, [0, t_finale]); 
ylim(axErr, [y_min_err, y_max_err]); % Limiti calcolati sui dati reali

%% 4. CICLO ANIMAZIONE
% Mappa colori per la temperatura del sistema (Blu -> Rosso)
custom_map = [linspace(0,1,256)', zeros(256,1), linspace(1,0,256)'];
getColorBR = @(v, minV, maxV) custom_map(round(interp1(linspace(minV, maxV, 256), 1:256, max(minV, min(maxV, v)), 'linear')), :);

phase = 0;
for k = 1:length(t_a)
    if ~ishandle(fig), break; end
    phase = phase - 0.4; 
    
    % Update onde sinusoidali (effetto flusso)
    set(hSinIn, 'YData', 7.2 + 0.4*sin(x_in*10 + phase));
    set(hSinOut, 'YData', 6.2 + 0.4*sin(x_out*10 + phase));
    
    % Update Colore Sistema basato su TR
    set(hSistema, 'FaceColor', getColorBR(TR_a(k), 25, 220));
    
    % Update Spessore Freccia Potenza (Pe)
    set(hFrecciaPe, 'LineWidth', min(15, max(1, log10(abs(Pe_a(k)) + 1))));
    
    % Update Testi Dinamici
    set(hT_tempo, 'String', sprintf('Tempo: %.2fs', t_a(k)));
    set(hT_rif,   'String', sprintf('Rif: %.1f°C', rif_a(k)));
    set(hT_pe,    'String', sprintf('Pe: %.2eW', Pe_a(k)));
    set(hT_tout,  'String', sprintf('Tout: %.2f°C', Tout_a(k)));
    
    % Update Grafici in tempo reale
    addpoints(hAnRif, t_a(k), rif_a(k));
    addpoints(hAnOut, t_a(k), Tout_a(k));
    addpoints(hAnErr, t_a(k), errore_a(k));
    
    % Refresh grafico
    drawnow limitrate;
    pause(0.01);
end