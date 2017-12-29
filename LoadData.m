%% Carga de datos de barras y lineas desde archivo dat
function [BUSDATA, LINEDATA] = LoadData(busfile, linefile)
    BUSDATA = load(busfile, '-ascii');
    LINEDATA = load(linefile, '-ascii');
end