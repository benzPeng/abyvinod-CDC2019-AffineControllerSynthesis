clear
clc
close all

ft_run = 1;
cc_open_run = 1;
cc_affine_run = 1;
cc_uni_affine_run = 1;
verbose_dc = 2;
verbose_uni = 1;


%% Right initial state
initial_state = [0.75;         % Initial x relative position
                 -0.75;         % Initial y relative position
                 0;             % Initial x relative velocity
                 0];            % Initial y relative velocity
slice_at_vx_vy = initial_state(3:4);             
disp('First initial state under study');
disp(initial_state');
Figure2_helper_script

%% Monte Carlo plot: Setup
figure(1);
clf
plot(safe_set.slice([3,4], slice_at_vx_vy).intersect(Polyhedron('lb',[-1.25,-1.25],'ub',[1.25,0.5])), 'color', 'y');
hold on;
plot(target_set.slice([3,4], slice_at_vx_vy), 'color', 'g');
box on;
grid on;
scatter(initial_state(1),initial_state(2),300,'k^');
legend_cell = {'Safe set','Target set','Initial state'};
xlabel('$x$','interpreter','latex');
ylabel('$y$','interpreter','latex');
set(gca,'FontSize',40)

%% Monte Carlo plot: Right initial state
figure(1);
hold on
plot_trajs
fprintf('chance-affine opt value: %1.3f\n',1 - (1 - lb_stoch_reach_avoid_cc_pwl_closed)*(1-options.max_input_viol_prob));
store_values_one = [lb_stoch_reach_avoid_ft, lb_stoch_reach_avoid_cc_pwl,...
    lb_stoch_reach_avoid_cc_pwl_closed;
    sum(mcarlo_result_ft)/n_mcarlo_sims, sum(mcarlo_result_cc_pwl)/n_mcarlo_sims,...
        sum(mcarlo_result_cc_pwl_closed)/n_mcarlo_sims;
    elapsed_time_ft, elapsed_time_cc_pwl, elapsed_time_cc_pwl_closed];

%% Left initial state
initial_state = [-1.15;         % Initial x relative position
                 -1.15;         % Initial y relative position
                 0;             % Initial x relative velocity
                 0];            % Initial y relative velocity
slice_at_vx_vy = initial_state(3:4);             
disp('Second initial state under study');
disp(initial_state');
Figure2_helper_script

%% Monte Carlo plot: Left initial state
figure(1);
hold on
h = scatter(initial_state(1),initial_state(2),300,'k^');
h.Annotation.LegendInformation.IconDisplayStyle = 'off';
plot_trajs
fprintf('chance-affine opt value: %1.3f\n',1 - (1 - lb_stoch_reach_avoid_cc_pwl_closed)*(1-options.max_input_viol_prob));
store_values_two = [lb_stoch_reach_avoid_ft, lb_stoch_reach_avoid_cc_pwl,...
    lb_stoch_reach_avoid_cc_pwl_closed, lb_stoch_reach_avoid_cc_uni_pwl_closed;
    sum(mcarlo_result_ft)/n_mcarlo_sims, sum(mcarlo_result_cc_pwl)/n_mcarlo_sims,...
        sum(mcarlo_result_cc_pwl_closed)/n_mcarlo_sims, ...
        sum(mcarlo_result_cc_uni_pwl_closed)/n_mcarlo_sims;
    elapsed_time_ft, elapsed_time_cc_pwl, elapsed_time_cc_pwl_closed, ...
        elapsed_time_cc_uni_pwl_closed];

%% Store data
save('run.mat','store_values_one','store_values_two');

