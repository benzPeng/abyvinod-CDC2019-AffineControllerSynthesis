# abyvinod-CDC2019-AffineControllerSynthesis

| Title      | Affine controller synthesis for stochastic reachability via difference of convex programming |
|------------|----------------------------------------------------------------------------------------------|
| Authors    | Abraham P. Vinod & Meeko M. K. Oishi                                                         |
| Conference | IEEE Conference on Decision and Control, 2019                                                |

# Files included

- FigureX (Reproduces all the figures used in this paper)
    - `Figure1.m`: Produces the variation of the lower bound on the affine
                   controller-based stochastic reachability after discounting
                   for the benefit (if any) from saturation
    - `Figure2.m`: Piecewise-affine overapproxiation normcdfinv in the range 
                   $[0, 0.5]$ for a maximum overapproximation error of {0.001, 1}
    - `Figure4.m`: Demonstration of the affine distubance feedback controller on
                   a spacecraft rendezvous problem, and comparison with
                   open-loop controller synthesis techniques
        - `CWH_example.m` calls the respective functions in
                      SReachTools to perform this analysis
        - `plot_trajs.m` calls the respective functions in
                      SReachTools for visualization of the Monte-Carlo
                      simulation trajectories
- `norminvmonotone.m`: Demonstrates the monotonicity of the Hessian of
                        normcdfinv(1-z)
- SReachTools: Stochastic reachability toolbox, a MATLAB open-source toolbox,
    enables clean and easy-to-read code for this numerical study. The relevant
    codes are:
    - `SReachTools/src/modules/stochReach/pointBased/SReachPointCcA.m`
        * Evaluates (underapproximative) stochastic reachability from a given
          initial state and synthesizes an affine disturbance feedback
          controller based on the results in this paper
        * Difference of convex program (Algorithm 1) based on risk allocation
    - `SReachTools/src/modules/stochReach/pointBased/SReachPointCcO.m`
        * Evaluates (underapproximative) stochastic reachability from a given
          initial state and synthesizes an open-loop controller based on the
          results in this paper
        * Linear program based on risk allocation
    - `SReachTools/src/modules/stochReach/pointBased/
    computeNormCdfInvOverApprox.m`
        * Evaluates a piecewise affine overapproximative of normcdfinv
          (Algorithm 2)
    - `SReachTools/src/modules/stochReach/pointBased/SReachPointGpO.m`
        * Evaluates (underapproximative) stochastic reachability from a given
          initial state and synthesizes an open-loop controller based on the
          results from our previous work,

            A. Vinod and M. Oishi, "[Scalable Underapproximation for Stochastic
            Reach-Avoid Problem for High-Dimensional LTI Systems using Fourier
            Transforms](https://ieeexplore.ieee.org/document/7950904/)," in 
            IEEE Control Systems Letters (L-CSS), 2017.
    - `SReachTools/src/modules/stochReach/pointBased/SReachPoint.m`
        * Implements a wrapper from multiple point-based (underapproximative)
          stochastic reachability and controller synthesis techniques
    - `SReachTools/src/modules/stochReach/pointBased/SReachPointOptions.m`
        * Provides user-tunable options for the implementations
    - `SReachTools/src/helperFunctions/ellipsoidsFromMonteCarloSims.m`
        * Compute tight ellipsoids fitting the Monte-Carlo simulations
          for visualization of the spread
    - `SReachTools/src/helperFunctions/generateMonteCarloSims.m`
        * Generates Monte-Carlo simulation-based trajectories
        * Violation of hard input constraints result in saturation via
          projection

# Execution/Installation instructions

## Quick guide
- `FigureX` will run, if [SReachTools](https://unm-hscl.github.io/SReachTools/) 
   is installed correctly.
- `norminvmonotone` requires MATLAB's Symbolic Toolbox

## Detailed guide (adapted from SReachTools installation instructions)

### Dependencies

You can skip installing the dependencies marked **optional**.
This will disable some of the features of SReachTools or hamper performance.

1. MATLAB (>2017a)
    1. Toolboxes
        1. MATLAB's Statistics and Machine Learning Toolbox
        1. MATLAB's Global Optimization Toolbox
1. MPT3 ([https://www.mpt3.org/](https://www.mpt3.org/))
    1. Copy the MATLAB script [install_mpt3.m](https://www.mpt3.org/Main/Installation?action=download&upname=install_mpt3.m)
       provided by MPT3 from the browser, and run it in MATLAB to automatically
       download MPT3 and its dependencies.
1. CVX v2.1 ([http://cvxr.com/cvx/](http://cvxr.com/cvx/))
    1. Install the CVX (Standard bundle, including Gurobi and/or MOSEK)
    1. Installation instructions are given in [http://cvxr.com/cvx/download/](http://cvxr.com/cvx/download/).
1. (**Optional**) We recommend using Gurobi as the backend solver for the convex
   programs formulated by SReachTools. In practice, we find both CVX and MPT3
   perform much better with Gurobi.
    1. To use Gurobi, a license is required from Gurobi Inc. Note that Gurobi
       offers free academic license. For more details, see
       [http://www.gurobi.com/registration/download-reg](http://www.gurobi.com/registration/download-reg).
    1. MPT3 automatically updates its backend solver to Gurobi, when gurobi is
       in the path and the license is found.
    1. CVX requires a professional license to use Gurobi. CVX Research Inc.
       provides free academic license, which can be requested at
       [http://cvxr.com/cvx/academic/](http://cvxr.com/cvx/academic/).

### Installation

1. Install the necessary dependencies listed above
1. Clone the SReachTools repository (or download the latest zip file from
   [Releases](https://github.com/unm-hscl/SReachTools/releases))
1. Change the MATLAB current working directory to where SReachTools was
   downloaded
1. Run `srtinit` in MATLAB to add the toolbox to the paths and ensure all
   must-have dependencies are properly installed.
   - You can add `cd <path_to_sreachtools_repo>;srtinit` to your MATLAB's
     `startup.m` to automatically have this done in future.
   - (**Optional**) Additional steps:
       - Run `srtinit -t` to run all the unit tests.
       - Run `srtinit -v` to visualize the steps the changes to the path and
         check for recommended dependencies.  
       - Run `srtinit -x` to remove functions of SReachTools from MATLAB's path
         after use.  

### Update

- 2020/10/13: 
    - Tested with CVXv2.2 and Mosek
    - GUROBIv9 is not working well with CVX at this time
