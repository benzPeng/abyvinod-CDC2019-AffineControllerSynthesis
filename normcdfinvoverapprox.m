clear;
close all;
clc;

separate_fig = true;
n_lin_consts = 20; % Requires lower lb_delta
pwa_accuracy_list = [1e-3, 1];
eta_accuracy = {'10^{-3}', '1'};
color_str = {'bd--','ko--'};
legend_string_str = '$\\ell_\\Phi^+(\\alpha)$ with $N_\\Phi=%d$ for $\\eta=%s$';    

max_delta = 0.5;
x_true = 1e-4:1e-3:max_delta;

figure(1);
clf;
plot(x_true, norminv(1-x_true), 'r-','linewidth',5,'DisplayName', '$\Phi^{-1}(1-\alpha)$');
set(gca,'FontSize', 40);
box on;
grid on;
legend('interpreter','latex');
ylim([0, 5]);
xlim([0,0.5]);
ylabel('$\Phi^{-1}(1-\alpha)$','interpreter','latex'); 
xlabel('$\alpha$','interpreter','latex'); 
% title('Approximation quality');
savefig('../../../Paper/2019/XXX_CDC_AffineFeedback/figs/phiinv_orig.fig');
saveas(gcf,'../../../Paper/2019/XXX_CDC_AffineFeedback/figs/phiinv_orig.png');

figure(2); 
clf;
plot(x_true, norminv(1-x_true), 'r-','linewidth',5,'DisplayName', '$\Phi^{-1}(1-\alpha)$');
hold on;

if separate_fig
    figure(3); 
    clf;
    plot(x_true, norminv(1-x_true), 'r-','linewidth',5,'DisplayName', '$\Phi^{-1}(1-\alpha)$');
    hold on;
end

figure(30);
clf;
hold on;

for indx=1:2
    pwa_accuracy = pwa_accuracy_list(indx);
    [invcdf_approx_m, invcdf_approx_c, lb_delta, norminv_knots] =...
        computeNormCdfInvOverApprox(max_delta, pwa_accuracy, n_lin_consts);
    legend_string = sprintf(legend_string_str, length(invcdf_approx_c), ...
        eta_accuracy{indx});
        
    x_err = 0;
    x_err(1) = lb_delta;
    for x_val = norminv_knots(2:end)
        x_err = [x_err, linspace(x_err(end), x_val, 100)];
    end
    y_pwa = max(invcdf_approx_m*x_err+invcdf_approx_c);
    y_true_err = norminv(1-x_err);
    err_bn_pwa_and_true = y_pwa-y_true_err;

    if separate_fig
        figure(1+indx);
    else
        figure(2);
    end
    plot(norminv_knots, norminv(1- norminv_knots), color_str{indx}, 'MarkerSize', 10, ...
        'DisplayName', legend_string, 'LineWidth', 2, 'MarkerSize',20);

    figure(30);
    color_str_current = color_str{indx};
    plot([0, 0.5], pwa_accuracy * [1, 1], color_str_current(1), ...
        'DisplayName', sprintf('$\\eta=%s$', eta_accuracy{indx}), ...
        'LineWidth', 4);
    plot(x_err, err_bn_pwa_and_true, color_str_current, ...
        'DisplayName', legend_string, 'LineWidth', 4);
end

figure(2);
set(gca,'FontSize', 40);
box on;
grid on;
legend('interpreter','latex');
xlim([0,0.5]);
ylim([0, 5]);
ylabel('$\Phi^{-1}(1-\alpha),\ell_\Phi^+(\alpha)$','interpreter','latex'); 
xlabel('$\alpha$','interpreter','latex'); 
% title('Approximation quality');
if separate_fig
    savefig('../../../Paper/2019/XXX_CDC_AffineFeedback/figs/phiinv_tight.fig');
    saveas(gcf,'../../../Paper/2019/XXX_CDC_AffineFeedback/figs/phiinv_tight.png');
else
    savefig('../../../Paper/2019/XXX_CDC_AffineFeedback/figs/phiinv_all.fig');
    saveas(gcf,'../../../Paper/2019/XXX_CDC_AffineFeedback/figs/phiinv_all.png');
end

if separate_fig
    figure(3);
    set(gca,'FontSize', 40);
    box on;
    grid on;
    legend('interpreter','latex');
    xlim([0,0.5]);
    ylim([0, 5]);
    ylabel('$\Phi^{-1}(1-\alpha),\ell_\Phi^+(\alpha)$','interpreter','latex'); 
    xlabel('$\alpha$','interpreter','latex'); 
%     title('Approximation quality');
    savefig('../../../Paper/2019/XXX_CDC_AffineFeedback/figs/phiinv_loose.fig');
    saveas(gcf,'../../../Paper/2019/XXX_CDC_AffineFeedback/figs/phiinv_loose.png');
end

figure(30);
set(gca,'FontSize', 40);
box on;
grid on;
legend('interpreter','latex','Location','Best');
set(gca, 'YScale', 'log')
xlim([0,0.5]);
ylabel('$\ell_\Phi^+(\alpha)-\Phi^{-1}(1-\alpha)$','interpreter','latex'); 
xlabel('$\alpha$','interpreter','latex'); 
% title('Approximation quality');
savefig('../../../Paper/2019/XXX_CDC_AffineFeedback/figs/phiinv_error.fig');
saveas(gcf,'../../../Paper/2019/XXX_CDC_AffineFeedback/figs/phiinv_error.png');
