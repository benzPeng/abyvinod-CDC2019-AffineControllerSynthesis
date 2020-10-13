close all
clc

syms x;
phiinvOneMinusX = -sqrt(2) * erfcinv(2*(1-x));
%% Plot
%ezplot(phiinvOneMinusX,[0 0.5]);

%% Confirm 
xvec = 0.0001:0.01:0.5;
yvec = norminv(1-xvec);
yvec_symb = eval(subs(phiinvOneMinusX,x,xvec));
if abs(yvec_symb - yvec)>1e-8
    throw('Difference between the functions is too high!');
end

nabla1_phiinvOneMinusX = diff(phiinvOneMinusX,x);
nabla2_phiinvOneMinusX = diff(nabla1_phiinvOneMinusX,x);
nabla3_phiinvOneMinusX = diff(nabla2_phiinvOneMinusX,x);


%% Plots
figure(1);
ezplot(nabla2_phiinvOneMinusX,[0 0.5]);
title('Should be monotone decreasing');
figure(2);
ezplot(nabla3_phiinvOneMinusX,[0 0.5]);
title('Should be negative');