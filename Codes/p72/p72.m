% Robot motion mastered by PD controller.
close all;clear all;clc;
path(path, genpath('..\..\robotcourse'));
cd ..\p72;
%%
constVel  = 2;     % the velocity of the vehicle
wheelbase = 4;       % the length of wheelbase
dt        = 0.1;    % time interval
rob       = [0  -wheelbase  -wheelbase;   
            0        -1.3           1.3  ];
n         = 500;
pos       = [0, -8, 0]';
target    = 1;
tauP      = 0.07;
tauD      = 0.5;
%%
steerDrift = degtorad(0);
%%
paraStr   = sprintf('p=%.2f+d=%.2f+drift=%.2f', ...
    tauP, tauD, radtodeg(steerDrift));
paraTex   = sprintf('$\\tau_p=%.2f$, $\\tau_d=%.2f$, $Drift=%.1f^o$)',...
        tauP, tauD, radtodeg(steerDrift));

%%
enableVis = 1;
makeVideo = 0;
%%
if enableVis == 0
   makeVideo = 0; 
end
%% Initialize figure
if enableVis
    figPos    = get(0, 'ScreenSize'); % [left, bottom, width, height]
    figPos(3) = figPos(3) - 100;
    h = figure('name', 'Motion with PD controller',...
           'position', figPos,...
           'color', 'w', 'Menu', 'none');
    hold on; box on; grid minor;
    plot([-100, 100], [target, target], 'g-', 'linewidth', 2);
    pathPlot  = plot (0, 0, 'r-', 'linewidth', 2, 'erasemode','normal');
    robPlot   = patch(0, 0, 'b', 'erasemode', 'normal');
    xlabel('X(m)');
    ylabel('Y(m)');
    axis equal;
    axis([-5  100  -10  10]);
    title(['PD controller ', paraTex],...
        'interpreter', 'latex', 'fontsize', 10, ...
        'fontweight', 'bold');
end
if makeVideo
    videoObj           = VideoWriter([paraStr, '.avi']);
    videoObj.FrameRate = 5;
    videoObj.Quality   = 50;
    open(videoObj);
end
%%
path = zeros(3,n);
steers = zeros(n,1);
preErr = pos(2) - target;
%%
for i = 1 : n
    %% ================= PD controller ===============
    err = pos(2) - target;
    diffErr = err - preErr;
    preErr = err;
    steer = -tauP * err - tauD * diffErr / dt;
    pos = moveRob(pos, constVel, steer + steerDrift, dt, wheelbase);
    %% ==============================================
    robBody = compound(pos,rob);
    path(:, i) = pos;
    steers(i, 1) = steer;
    if enableVis
        set(pathPlot, 'xdata', path(1, 1:i), 'ydata', path(2, 1:i));
        set(robPlot,  'xdata', robBody(1, :), 'ydata', robBody(2, :)); 
        drawnow;
    end
    if mod(i, 5) == 0 && makeVideo 
        writeVideo(videoObj, getframe(h));
    end
end
if makeVideo
    close(videoObj);
end
%%
if enableVis
    print('-dpng', [paraStr, '.png']);
    figure('name', 'Steerings with PD controller')
    plot(1 : n, radtodeg(steers),  'b-', 'linewidth', 1);
    xlabel('Step');
    ylabel('Steering (Deg)');
    box on; grid minor;
    title(['Steering with PD controller ', paraTex],...
        'interpreter', 'latex', 'fontsize', 10, ...
        'fontweight', 'bold');
    xlim([1, 350]);
    print('-dpng', ['steer_', paraStr, '.png']);
end
