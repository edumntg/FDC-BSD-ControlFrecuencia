%% Eduardo Montilva 12-10089
% Script para la solucion del flujo de carga, mediante fsolve

function [V, th, Pgen, Qgen, Pneta, Qneta, Sshunt, Pflow, Pflow_bus, Qflow, Qflow_bus, Ploss, Qloss, Ploada, Qloada] = FDC(BUSDATA, LINEDATA, G, B, g, b, n, nl)

    Pneta = zeros(n, 1);                            % Potencia activa neta de cada barra
    Qneta = zeros(n, 1);                            % Potencia reactiva neta de cada barra
    theta = zeros(n, 1);                            % Angulo del voltaje de cada barra (especificado)
    Vabs = zeros(n, 1);                             % Voltaje de cada barra (especificado)

    Pgen = zeros(n, 1);
    Qgen = zeros(n, 1);

    Pconsig = zeros(n, 1);
    Qconsig = zeros(n, 1);

    Pflow = zeros(n, n);
    Qflow = zeros(n, n);

    Pflow_bus = zeros(n, 1);
    Qflow_bus = zeros(n, 1);

    Ploss = zeros(n,n);
    Qloss = zeros(n,n);
    Ploss_total = 0;
    Qloss_total = 0;
    Pload = zeros(n, 1);
    Qload = zeros(n, 1);
    Ploada = zeros(n, 1);
    Qloada = zeros(n, 1);
    Sshunt = zeros(n, 1);
    
    bustype = zeros(n, 1);
    refang = zeros(n, 1);
    
    for i = 1:n 

        %% Se crean variables que seran de utilidad durante el flujo de carga
        bustype(i) = BUSDATA(i, 2);
        Vabs(i) = BUSDATA(i, 3);
        theta(i) = BUSDATA(i, 4);

        %% Calculamos la potencia neta por barra

        Pload(i) = -BUSDATA(i, 5);
        Qload(i) = -BUSDATA(i, 6);
        
        Ploada(i) = BUSDATA(i, 5);
        Qloada(i) = BUSDATA(i, 6);
        
        Pconsig(i) = BUSDATA(i, 7);
        Qconsig(i) = BUSDATA(i, 8);
        
        refang(i) = BUSDATA(i, 12);
        
        Pneta(i) = Pconsig(i)-Pload(i);
        Qneta(i) = Qconsig(i)-Qload(i);
    end

    Pdesbalance = sum(Pconsig) - abs(sum(Pload));

    V = Vabs;
    th = theta;

    X0 = zeros(2*n, 1);     % Siempre habra un total de 2*n incognitas en el sistema, sin importar que barra sea la referencia angular
    v = 1;
    for i = 1:n
        if bustype(i) == 1 % incognitas: P, Q y theta (si no es ref ang)
            X0(v) = Pconsig(i);
            X0(v + 1) = Qconsig(i);
            v = v + 2;
            if refang(i) == 0 % no es ref ang
                X0(v) = th(i);
                v = v + 1;
            end
        elseif bustype(i) == 2 % incognitas: delta y Q
            if refang(i) == 0 % no es ref ang
                X0(v) = th(i);
                v = v + 1;
            end
            X0(v) = Qconsig(i);
            v = v + 1;
        elseif bustype(i) == 0 %incognitas: V y delta
            if refang(i) == 0 % no es ref ang
                X0(v) = th(i);
                v = v + 1;
            end
            X0(v) = V(i);
            v = v + 1;
        end
    end

    %% Ejecucion del fsolve (iteraciones)
    options = optimset('Display','off');
    
    [x,~,exitflag] = fsolve(@(x)FDCSolver(x, LINEDATA, bustype, refang, V, th, Pload, Qload, Pconsig, Qconsig, G, B, g, b, Pdesbalance, n, nl), X0, options);
    exitflag
    x
    %% Una vez terminadas las iteraciones, se obtienen las variables de salida y se recalculan potencias
    v = 1;
    for i = 1:n
        if bustype(i) == 1 % incognitas: P, Q y delta (si no es ref ang)
            Pgen(i) = x(v);
            Qgen(i) = x(v + 1);
            v = v + 2;
            if refang(i) == 0
                th(i) = x(v);
                v = v + 1;
            end
        elseif bustype(i) == 2 % incognitas: delta(si no es ref ang) y Q
            if refang(i) == 0
                th(i) = x(v);
                v = v + 1;
            end
            Qgen(i) = x(v);
            v = v + 1;
        elseif bustype(i) == 0 %incognitas: V y delta(si no es ref ang)
            if refang(i) == 0
                th(i) = x(v);
                v = v + 1;
            end
            V(i) = x(v);
            v = v + 1;
        end
    end

    %% Calculo de flujos en lineas y perdidas
    for i = 1:n
        for k = 1:n
            if i ~= k
                Pflow(i,k) = (-G(i,k) + g(i,k))*V(i)^2 + V(i)*V(k)*(G(i,k)*cos(th(i) - th(k)) + B(i,k)*sin(th(i) - th(k)));
                Qflow(i,k) = (B(i,k) - b(i,k))*V(i)^2 + V(i)*V(k)*(-B(i,k)*cos(th(i) - th(k)) + G(i,k)*sin(th(i) - th(k)));
            end
        end
        Pflow_bus(i) = sum(Pflow(i, 1:size(Pflow, 2)));
        Qflow_bus(i) = sum(Qflow(i, 1:size(Qflow, 2)));
    end

    %% Calculo de las perdidas
    for i = 1:n
        for k = 1:n
            %% Calculo de perdidas
            if i ~= k
                Ploss(i,k) = Pflow(i,k) + Pflow(k,i);
                Qloss(i,k) = Qflow(i,k) + Qflow(k,i);

                if k > i
                    Ploss_total = Ploss_total + Ploss(i,k);
                    Qloss_total = Qloss_total + Qloss(i,k);
                end
            end
        end
    end

    for i = 1:nl
        from = LINEDATA(i, 1);
        to = LINEDATA(i, 2);
        if(from == to)                      % es un shunt
            bus = from;
            z = 1i*LINEDATA(i, 4);
            Sshunt(bus) = conj(z)\V(bus)^2;
            Qneta(bus) = Qneta(bus) - imag(Sshunt(bus));
        end
    end

%     for i = 1:n
%         Pgen(i) = 0;
%         Qgen(i) = 0;
%         if bustype(i) ~= 0  % no es PQ
%             Pgen(i) = abs(Pload(i)) + Pflow_bus(i);
%             Qgen(i) = abs(Qload(i)) + Qflow_bus(i) + imag(Sshunt(i));
%         end
%     end

    for i = 1:n
        Pneta(i) = Pgen(i) - abs(Pload(i));
        Qneta(i) = Qgen(i) - abs(Qload(i)) - imag(Sshunt(i));
    end

    Pdesbalance = Pdesbalance + Ploss_total;

    %% VARIABLES PARA GARANTIZAR EL BUEN FUNCIONAMIENTO DEL PROGRAMA
    % La P de salida en cada barra debe ser igual a la P neta de la misma
    fprintf('Diferencia entre Pneta y Psalida para cada barra: %s\n', mat2str(Pgen - abs(Pload) - Pflow_bus));
    fprintf('Diferencia entre Qneta y Qsalida para cada barra: %s\n', mat2str(Qgen - imag(Sshunt) - abs(Qload) - Qflow_bus));
    Pdesbalance_result = sum(Pgen) - abs(sum(Pload));
    fprintf('Desbalance inicial en el sistema: %s\n', num2str(Pdesbalance));
    fprintf('Desbalance final en el sistema: %s\n\n', num2str(Pdesbalance_result));
end