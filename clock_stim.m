

% clock settings
clock_hand  = 12;           % in mm on display
debug       = 1;


% collect information on screen and display
which_screen        = min(Screen('Screens'));                   % get main monitor
w                   = Screen(which_screen, 'OpenWindow');       % handle on main monitor
[width_p, height_p] = Screen('WindowSize', w);                  % window size in pixels
[width_m, height_m] = Screen('DisplaySize', w);                 % window size in mm
ifi_duration        = Screen('GetFlipInterval', w);             % monitor flip interval


% get colors
black   = BlackIndex(w);
white   = WhiteIndex(w);
gray    = (black + white) /2;

% static objects to compute and draw
x_center    = width/2;
y_center    = height/2;

radius  = (height_p/height_m) * clock_hand;                     % radius in mm on display
rect    = [x_center-radius y_center-radius x_center+radius y_center+radius];

try
    
    % make background gray and draw the clock + initial flip
    Screen('FillRect',w, gray);
    Screen('FrameOval', window, white, rect);
    vbl = Screen('Flip', w);
    
    % remember starting time
    t1 = GetSecs;
    
    % Animation loop (until keypress):
    while true
        
        sec = mod(GetSecs-t1, 60);          % time in seconds
        phi = (sec / 60) * 2 * pi;          % angle in radians
        
        % draw background and clock
        Screen('FillRect',w, gray);
        Screen('FrameOval', w, white, rect);
        
        % draw clock hand
        Screen('DrawLine', w, white, x_center, y_center, x_center+cos(phi)*radius, y_center+sin(phi)*radius);

        % debugging
        if debug
            currentTextRow = 0;
            Screen('DrawText', w, sprintf('new_x = %2.2f, new_y = %2.2f', sin(phi)*radius, cos(phi)*radius), 0, currentTextRow, white);
            currentTextRow = currentTextRow + 20;
            Screen('DrawText', w, sprintf('sec = %2.2f, phi = %2.2f', sec, phi), 0, currentTextRow, white);
        end
        
        % show buffer
        vbl = Screen('Flip', w, vbl + 1.5 * ifi_duration);
        
        
        % We also abort on keypress...
        if KbCheck
            break;
        end;
    end;
    
    % close windows
    Screen('CloseAll');
    
% if something went wrong -> clean up
catch err     
    
    % Closes all windows.
    Screen('CloseAll');
    psychrethrow(psychlasterror);
    
end

