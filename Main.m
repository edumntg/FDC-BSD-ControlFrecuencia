%%  Programa generico
%   Flujo de carga - Barra Slack Distribuida
%   Con control de frecuencia
clc, clear, close all;

Vb = 115;
Sb = 100;

tic

[BUSDATA, LINEDATA] = LoadData('BUSDATA_2barras.dat', 'RAMAS_2barras.dat');

n = size(BUSDATA, 1);           % el numero de filas en el archivo excel es igual al numero de barras
nl = size(LINEDATA, 1);         % el numero de filas en el archivo excel es igual al numero de ramas

%% Aqui se cargaran en vectores los parametros
R = zeros(n, 1);
droop = zeros(n, 1);
Pmax = zeros(n, 1);

for i = 1:n 
    droop(i, 1) = BUSDATA(i, 10);
    Pmax(i, 1) = BUSDATA(i, 11);
    R(i, 1) = droop(i, 1)/Pmax(i, 1);
end

%%  Formacion de la Ybus para el FDC
[Ybus, G, B, g, b] = CreateYbus(LINEDATA, n, nl);

%%  Ejecucion del FDC
[V0, theta0, Pgen0, Qgen0, Pneta0, Qneta0, Sshunt0, Pflow0, Pflow_bus0, ...
Qflow0, Qflow_bus0, Ploss0, Qloss0, Pload0, Qload0] = FDC(BUSDATA, LINEDATA, G, B, g, b, n, nl);

PrintFDC;
