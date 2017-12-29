%% Eduardo Montilva 12-10089
% Script el cual tiene como funcion armar imprimir los resultados del flujo
% de carga


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
                Ploss_total = Ploss_total + Ploss0(i,k);
                Qloss_total = Qloss_total + Qloss0(i,k);
            end
        end
    end
end

for i = 1:n
     fprintf(' %5g', i), fprintf(' %7.4f', V0(i)), fprintf(' %8.4f', theta0(i)), fprintf(' %9.4f', abs(Pload0(i))), fprintf(' %9.4f', abs(Qload0(i))), fprintf(' %9.4f', Pgen0(i)), fprintf(' %9.4f ', Qgen0(i)), fprintf(' %9.4f', Pneta0(i)), fprintf(' %9.4f', Qneta0(i)), fprintf(' %8.4f\n', imag(Sshunt0(i)))
end
    fprintf('      \n'), fprintf('    Total              '), fprintf(' %9.4f', abs(sum(Pload0))), fprintf(' %9.4f', abs(sum(Qload0))), fprintf(' %9.4f', sum(Pgen0)), fprintf(' %9.4f', sum(Qgen0)), fprintf(' %9.4f', sum(Pneta0)), fprintf(' %9.4f', sum(Qneta0)), fprintf(' %9.4f\n\n', sum(imag(Sshunt0)))
    fprintf('    Total loss:           '), fprintf(' P: %9.4f ', Ploss_total), fprintf(' Q: %9.4f', Qloss_total)
    fprintf('\n');