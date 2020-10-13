%% Monte-Carlo simulation parameters
n_mcarlo_sims = 1e5;
n_sims_to_plot = 5;
max_input_viol_prob = 0.01;
%% CWH system params
umax=0.1;
mean_disturbance = zeros(4,1);
covariance_disturbance = diag([1e-4, 1e-4, 5e-8, 5e-8]);
% Define the CWH (planar) dynamics of the deputy spacecraft relative to the 
% chief spacecraft as a LtiSystem object
sys = getCwhLtiSystem(4,...
                      Polyhedron('lb', -umax*ones(2,1),...
                                 'ub',  umax*ones(2,1)),...
                      RandomVector('Gaussian', mean_disturbance,...
                                covariance_disturbance));
time_horizon=5;          % Stay within a line of sight cone for 4 time steps and 
                         % reach the target at t=5% Safe Set --- LoS cone
%% Safe set definition --- LoS cone |x|<=y and y\in[0,ymax] and |vx|<=vxmax and 
%% |vy|<=vymax
ymax=2;
vxmax=0.5;
vymax=0.5;
A_safe_set = [1, 1, 0, 0;           
             -1, 1, 0, 0; 
              0, -1, 0, 0;
              0, 0, 1,0;
              0, 0,-1,0;
              0, 0, 0,1;
              0, 0, 0,-1];
b_safe_set = [0;
              0;
              ymax;
              vxmax;
              vxmax;
              vymax;
              vymax];
safe_set = Polyhedron(A_safe_set, b_safe_set);

%% Target set --- Box [-0.1,0.1]x[-0.1,0]x[-0.01,0.01]x[-0.01,0.01]
target_set = Polyhedron('lb', [-0.1; -0.1; -0.01; -0.01],...
                        'ub', [0.1; 0; 0.01; 0.01]);
target_tube = Tube('reach-avoid',safe_set, target_set, time_horizon);                    

%% Parameters for MATLAB's Global Optimization Toolbox patternsearch
desired_accuracy = 1e-3;        % Decrease for a more accurate lower 
                                % bound at the cost of higher 
                                % computation time
desired_accuracy_cc_affine = 1e-2;
PSoptions = psoptimset('Display','off');

%% Generate matrices for optimal mean trajectory generation
% Get H and mean_X_sans_input
[Z, H, G] = getConcatMats(sys, time_horizon);
sysnoi = LtvSystem('StateMatrix',sys.state_mat,'DisturbanceMatrix',...
    sys.dist_mat,'Disturbance',sys.dist);
X_sans_input_with_init_state = SReachFwd('concat-stoch', sysnoi, initial_state,...
    time_horizon);
mean_X_sans_input = X_sans_input_with_init_state.mean();
mean_X_sans_input = mean_X_sans_input(sysnoi.state_dim+1:end);

if ft_run
    timer_ft = tic;
    disp('Open-loop controller synthesis: Genz-algorithm+patternsearch');
    options = SReachPointOptions('term','genzps-open');
    [lb_stoch_reach_avoid_ft, optimal_input_vector_ft] = SReachPoint(...
        'term','genzps-open', sys, initial_state, target_tube, options);  
    elapsed_time_ft = toc(timer_ft);
    if lb_stoch_reach_avoid_ft > 0
        % This function returns the concatenated state vector stacked columnwise
        concat_state_realization_ft = generateMonteCarloSims(n_mcarlo_sims,...
            sys, initial_state, time_horizon, optimal_input_vector_ft);
        % Check if the location is within the target_set or not
        mcarlo_result_ft = target_tube.contains(concat_state_realization_ft);
        % Optimal mean trajectory generation                         
        optimal_mean_X_ft = mean_X_sans_input + H * optimal_input_vector_ft;
        optimal_mean_trajectory_ft=reshape(optimal_mean_X_ft,sys.state_dim,[]);                                              
    end
end

%% CC (Linear program approach)     
if cc_open_run
    timer_cc_pwl = tic;
    disp('Open-loop controller synthesis: (convex) risk allocation');
    options = SReachPointOptions('term','chance-open');
    [lb_stoch_reach_avoid_cc_pwl, optimal_input_vector_cc_pwl] = SReachPoint(...
        'term','chance-open', sys, initial_state, target_tube, options);  
    elapsed_time_cc_pwl = toc(timer_cc_pwl);
    if lb_stoch_reach_avoid_cc_pwl > 0
        % This function returns the concatenated state vector stacked columnwise
        concat_state_realization_cc_pwl = generateMonteCarloSims( ...
            n_mcarlo_sims, sys, initial_state, time_horizon,...
            optimal_input_vector_cc_pwl);
        % Check if the location is within the target_set or not
        mcarlo_result_cc_pwl = target_tube.contains( ...
            concat_state_realization_cc_pwl);
        % Optimal mean trajectory generation                         
        optimal_mean_X_cc_pwl = mean_X_sans_input +...
            H * optimal_input_vector_cc_pwl;
        optimal_mean_trajectory_cc_pwl=reshape(optimal_mean_X_cc_pwl,...
            sys.state_dim,[]);
    end
end

%% CC with affine controllers (Second order cone program approach)     
if cc_affine_run
    timer_cc_pwl_closed = tic;
    disp('Affine controller synthesis: (difference-of-convex) risk allocation');
    options = SReachPointOptions('term','chance-affine',...
        'max_input_viol_prob', 0.01, 'verbose', verbose_dc);
    [lb_stoch_reach_avoid_cc_pwl_closed, optimal_input_vector_cc_pwl_closed,...
        optimal_input_gain, risk_alloc_state, risk_alloc_input] = ...
         SReachPoint('term','chance-affine', sys, initial_state, target_tube,...
            options);  
    elapsed_time_cc_pwl_closed = toc(timer_cc_pwl_closed);            
    if lb_stoch_reach_avoid_cc_pwl_closed > 0
        % This function returns the concatenated state vector stacked columnwise
        [concat_state_realization_cc_pwl_closed,...
            concat_disturb_realization_cc_pwl_closed] =...
                generateMonteCarloSims(n_mcarlo_sims, sys, initial_state,...
                    time_horizon,optimal_input_vector_cc_pwl_closed,...
                    optimal_input_gain, 1);

        % Check if the location is within the target_set or not
        mcarlo_result_cc_pwl_closed = target_tube.contains( ...
            concat_state_realization_cc_pwl_closed);
        
        % Check if the input is within the tolerance
        [concat_input_space_A, concat_input_space_b] =...
            sys.getConcatInputSpace(time_horizon);
        mcarlo_result_cc_pwl_closed_input = all(concat_input_space_A *...
            (optimal_input_gain * concat_disturb_realization_cc_pwl_closed +...
             optimal_input_vector_cc_pwl_closed)<=concat_input_space_b + 1e-8);
        fprintf(['Simulated probability of input requiring saturation: ',...
            '%1.3f | Acceptable: < %1.3f\n'], 1 -...
            sum(mcarlo_result_cc_pwl_closed_input)/n_mcarlo_sims,...
            options.max_input_viol_prob); 
        
        % Optimal mean trajectory generation                         
        optimal_mean_X_cc_pwl_closed = mean_X_sans_input + H *...
            optimal_input_vector_cc_pwl_closed;
        optimal_mean_trajectory_cc_pwl_closed =...
            reshape(optimal_mean_X_cc_pwl_closed,sys.state_dim,[]);
    end
end

%% CC with affine controllers (Uniform risk allocation)     
if cc_uni_affine_run
    timer_cc_uni_pwl_closed = tic;
    disp('Affine controller synthesis: uniform risk allocation');
    options = SReachPointOptions('term','chance-affine-uni',...
        'max_input_viol_prob', 0.01, 'verbose', verbose_uni);
    [lb_stoch_reach_avoid_cc_uni_pwl_closed, ...
        optimal_input_vector_cc_uni_pwl_closed,...
        optimal_input_uni_gain] = SReachPoint('term','chance-affine-uni', ...
            sys, initial_state, target_tube, options);  
    elapsed_time_cc_uni_pwl_closed = toc(timer_cc_uni_pwl_closed);            
    if lb_stoch_reach_avoid_cc_uni_pwl_closed > 0
%         % This function returns the concatenated state vector stacked columnwise
%         concat_disturb_realization_cc_uni_pwl_closed = ...
%             sys.dist.concat(time_horizon).getRealizations(n_mcarlo_sims);
%         concat_state_realization_cc_uni_pwl_closed = Z * initial_state + ...
%             (H * optimal_input_uni_gain + G) * ...
%                 concat_disturb_realization_cc_uni_pwl_closed + ...
%             H * optimal_input_vector_cc_uni_pwl_closed;
        [concat_state_realization_cc_uni_pwl_closed,...
            concat_disturb_realization_cc_uni_pwl_closed] =...
                generateMonteCarloSims(n_mcarlo_sims, sys, initial_state,...
                    time_horizon,optimal_input_vector_cc_uni_pwl_closed,...
                    optimal_input_uni_gain, 1);

        % Check if the location is within the target_set or not
%         mcarlo_result_cc_uni_pwl_closed = target_tube.contains( ...
%             [repmat(initial_state, 1, n_mcarlo_sims);
%              concat_state_realization_cc_uni_pwl_closed]);
        mcarlo_result_cc_uni_pwl_closed = target_tube.contains( ...
            concat_state_realization_cc_uni_pwl_closed);
        
        % Check if the input is within the tolerance
        [concat_input_space_A, concat_input_space_b] =...
            sys.getConcatInputSpace(time_horizon);
        mcarlo_result_cc_uni_pwl_closed_input = all(concat_input_space_A *...
            (optimal_input_uni_gain * concat_disturb_realization_cc_uni_pwl_closed +...
             optimal_input_vector_cc_uni_pwl_closed)<=concat_input_space_b + 1e-8);
        fprintf(['Simulated probability of input requiring saturation: ',...
            '%1.3f | Acceptable: < %1.3f\n'], 1 -...
            sum(mcarlo_result_cc_uni_pwl_closed_input)/n_mcarlo_sims,...
            0.01); 
        
        % Optimal mean trajectory generation                         
        optimal_mean_X_cc_uni_pwl_closed = mean_X_sans_input + H *...
            optimal_input_vector_cc_uni_pwl_closed;
        optimal_mean_trajectory_cc_uni_pwl_closed =...
            reshape(optimal_mean_X_cc_uni_pwl_closed,sys.state_dim,[]);
    end
end