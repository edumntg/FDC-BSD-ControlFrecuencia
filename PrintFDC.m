%% Eduardo Montilva 12-10089
% Script el cual tiene como funcion armar imprimir los resultados del flujo
% de carga
function F = PrintFDC(V, theta, Pgen, Qgen, Pload, Qload, Ploss, Qloss, Pneta, Qneta, Sshunt, n)

    head = ['    Bus  Voltage  Angle    ------Load------    ---Generation---    ---P y Q Netos---   Injected'
            '    No.  Mag.      Rad      (p.u)   (p.u)       (p.u)    (p.u)       (p.u)    (p.u)     (p.u)  '
            '                                                                                               '];

    disp(head)

    Ploss_total = 0;
    Qloss_total = 0;
    for i = 1:n
        for k = 1:n
            %% Calculo de perdidas
            if(i ~= k)
                if k > i
                    Ploss_total = Ploss_total + Ploss(i,k);
                    Qloss_total = Qloss_total + Qloss(i,k);
                end
            end
        end
    end

    for i = 1:n
         fprintf(' %5g', i), fprintf(' %7.4f', V(i)), fprintf(' %8.4f', theta(i)), fprintf(' %9.4f', abs(Pload(i))), fprintf(' %9.4f', abs(Qload(i))), fprintf(' %9.4f', Pgen(i)), fprintf(' %9.4f ', Qgen(i)), fprintf(' %9.4f', Pneta(i)), fprintf(' %9.4f', Qneta(i)), fprintf(' %8.4f\n', imag(Sshunt(i)))
    end
        fprintf('      \n'), fprintf('    Total              '), fprintf(' %9.4f', abs(sum(Pload))), fprintf(' %9.4f', abs(sum(Qload))), fprintf(' %9.4f', sum(Pgen)), fprintf(' %9.4f', sum(Qgen)), fprintf(' %9.4f', sum(Pneta)), fprintf(' %9.4f', sum(Qneta)), fprintf(' %9.4f\n\n', sum(imag(Sshunt)))
        fprintf('    Total loss:           '), fprintf(' P: %9.4f ', Ploss_total), fprintf(' Q: %9.4f', Qloss_total)
        fprintf('\n');
end