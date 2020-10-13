% Comparison of the piecewise affine approximation and norminv cdf
clc;clear;close all;

errorboundMarkerSize = 8;
errorMarkerSize = errorboundMarkerSize;
approxMarkerSize = errorboundMarkerSize; 
fontSize = 20;

Delta = 0.5;
linspace_point_density = 50;

%% max overapproximation error = 1
maxlierror=1;
tic;
[cdf_approx_m, cdf_approx_c, lb_phiinv_1x0, norminv_knots] =...
    computeNormCdfInvOverApprox(Delta, maxlierror, 1000);
toc
x_1x0 = [];
for indx = 1:length(norminv_knots)-1
    x_1x0 = [x_1x0, linspace(norminv_knots(indx), norminv_knots(indx+1),...
        linspace_point_density)];
end
y_pwa_1x0 = max(cdf_approx_m * x_1x0 + cdf_approx_c);
y_true_1x0 = norminv(1-x_1x0);
pwa_err_1x0 = y_pwa_1x0 - y_true_1x0;
piece1 = length(cdf_approx_m);

%% max overapproximation error = 1e-3
maxlierror=1e-3;
tic;
[cdf_approx_m, cdf_approx_c, lb_phiinv_0x001, norminv_knots] =...
    computeNormCdfInvOverApprox(Delta, maxlierror, 1000);
toc
x_0x001 = [];
for indx = 1:length(norminv_knots)-1
    x_0x001 = [x_0x001, linspace(norminv_knots(indx), norminv_knots(indx+1),...
        linspace_point_density)];
end
y_pwa_0x001 = max(cdf_approx_m * x_0x001 + cdf_approx_c);
y_true_0x001 = norminv(1-x_0x001);
pwa_err_0x001 = y_pwa_0x001 - y_true_0x001;
piece2 = length(cdf_approx_m);

%%
figure(1); 
clf
plot(x_0x001,y_true_0x001,'b:','LineWidth',5); 
hold on; 
plot(x_1x0(1:5:end),y_pwa_1x0(1:5:end),'ro-','MarkerSize',approxMarkerSize);
plot(x_0x001(1:5:end),y_pwa_0x001(1:5:end),'md-','MarkerSize',approxMarkerSize);
xlim([x_0x001(1),x_0x001(end)]);  
xlabel('$z$','interpreter','latex');
ylabel('$\Phi^{-1}(1-z)$, $\ell_\Phi^+(z)$','interpreter','latex');
leg=legend('$\Phi^{-1}(1-z)$',...
    sprintf('$\\ell_\\Phi^+(z)$ with $N_\\Phi=%2d$ for $\\eta=1$',piece1),...
    sprintf('$\\ell_\\Phi^+(z)$ with $N_\\Phi=%2d$ for $\\eta=10^{-3}$',piece2));
set(leg,'interpreter','latex');
%title('Piecewise-affine overapproximation of $f(x)=\Phi^{-1}(1-x)$','interpreter','latex');
box on;
grid on;
set(gca,'FontSize',fontSize);

% Here, maxlierror = 1e-3 (the last value)
figure(2)
clf
semilogy(x_1x0, ones(length(x_1x0),1),'b--','MarkerSize',errorboundMarkerSize);
hold on;
semilogy(x_0x001, maxlierror * ones(length(x_0x001),1),'b--','MarkerSize',errorboundMarkerSize);
h1=semilogy(x_1x0,pwa_err_1x0,'ro-','MarkerSize',errorMarkerSize);
h2=semilogy(x_0x001,pwa_err_0x001,'md-','MarkerSize',errorMarkerSize);
xlim([x_0x001(1),x_0x001(end)]);  
ylim([1e-20, 1]);
%ylim([log(maxlierror) - log(0.5),log(1)]);  
xlabel('$z$','interpreter','latex');
ylabel('$\log(\ell_\Phi^+(z)-\Phi^{-1}(1-z))$','interpreter','latex');
leg=legend([h1 h2], {'$\log(\ell_\Phi^+(z)-\Phi^{-1}(1-z))$ for $\eta=1$','$\log(\ell_\Phi^+(z)-\Phi^{-1}(1-z))$ for $\eta=10^{-3}$'});
set(leg,'interpreter','latex','Location','South');
set(gca,'FontSize',fontSize);