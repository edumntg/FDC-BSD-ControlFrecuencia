%%  Programa generico
%   Flujo de carga - Barra Slack Distribuida
%   Con control de frecuencia
clc, clear, close all;

Vb = 115;
Sb = 100;
fb = 60;

tic

[BUSDATA, LINEDATA] = LoadData('BUSDATA_3barras.dat', 'RAMAS_3barras.dat');

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

PrintFDC(V0, theta0, Pgen0, Qgen0, Pload0, Qload0, Ploss0, Qloss0, Pneta0, Qneta0, Sshunt0, n);

%% Control de frecuencia
tipo = input('Ingrese tipo de perturbacion (1 = cambio en carga, 2 = cambio en generacion, 3 = salida de linea): ');
if tipo == 1 || tipo == 2
    barra = input('Ingrese la barra donde ocurre la perturbacion: ');
    dP = input('Ingrese el cambio en potencia (en p.u): ');
    
    BUSDATA2 = BUSDATA;
    if tipo == 1
        BUSDATA2(barra, 5) = BUSDATA2(barra, 5) + dP;
    else
        BUSDATA2(barra, 7) = BUSDATA2(barra, 7) + dP;
    end
    
    Beq = sum(1./R);
    
    
    %%  Ejecucion del FDC
    [Vn, thetan, Pgenn, Qgenn, Pnetan, Qnetan, Sshuntn, Pflown, Pflow_busn, ...
    Qflown, Qflow_busn, Plossn, Qlossn, Ploadn, Qloadn] = FDC(BUSDATA2, LINEDATA, G, B, g, b, n, nl);

    PrintFDC(Vn, thetan, Pgenn, Qgenn, Ploadn, Qloadn, Plossn, Qlossn, Pnetan, Qnetan, Sshuntn, n);
    
    df = -dP/Beq *fb
    fn = fb + df
else
    barrai = input('Ingrese la barra de partida de la linea: ');
    barraj = input('Ingrese la barra de llegada de la linea: ');
end


