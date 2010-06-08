clear
try
    
    
    % clock settings
    clock_hand  = 12;           % in mm on display
    one_circle  = 2.56;
    tick_size   = 2;
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
    x_center    = width_p/2;
    y_center    = height_p/2;

    
    radius  = (height_p/height_m) * clock_hand;                     % radius in mm on display
    rect    = [x_center-radius y_center-radius x_center+radius y_center+radius];

    
    % draw background and clock
    Screen('FillRect',w, gray);
    Screen('FrameOval', w, white, rect);
    for i=1:12
        phi = (i/12)*2*pi;
        Screen('DrawLine', w, white, x_center+cos(phi)*(radius-tick_size), ...
            y_center+sin(phi)*(radius-tick_size), x_center+cos(phi)*(radius+tick_size) ...
            , y_center+sin(phi)*(radius+tick_size),2);
    end

    % initial flip
    Screen('DrawText', w, 'Press any key to start', 0, 0, white);
    vbl = Screen('Flip', w);
    
    % Waits for the user to press a key.
    WaitSecs(0.2);
    KbWait;
     
    % remember starting time
    t1 = GetSecs;
    % initialize hand at random position
    t1 = t1 + rand*one_circle;

    
    % Animation loop (until keypress):
    while true
        
        % draw background and clock
        Screen('FillRect',w, gray);
        Screen('FrameOval', w, white, rect);
        for i=1:12
            phi = (i/12)*2*pi;
            Screen('DrawLine', w, white, x_center+cos(phi)*(radius-tick_size), ...
                y_center+sin(phi)*(radius-tick_size), x_center+cos(phi)*(radius+tick_size) ...
                , y_center+sin(phi)*(radius+tick_size),2);
        end
        
        sec = mod(GetSecs-t1, one_circle);      % time in seconds
        phi = (sec / one_circle) * 2 * pi;      % angle in radians
        
        % draw clock hand
        Screen('DrawLine', w, white, x_center, y_center, x_center+cos(phi)*radius, y_center+sin(phi)*radius);
        
        % debugging
        if debug
            currentTextRow = 0;
            Screen('DrawText', w, sprintf('new_x = %2.2f, new_y = %2.2f', sin(phi)*radius, cos(phi)*radius), 0, currentTextRow, white);
            currentTextRow = currentTextRow + 20;
            Screen('DrawText', w, sprintf('sec = %2.2f, phi = %2.2f', sec, phi), 0, currentTextRow, white);
        end
        currentTextRow = currentTextRow + 20;
        Screen('DrawText', w, 'Press ESCAPE to stop', 0, currentTextRow, white);
        
        
        % show buffer
        vbl = Screen('Flip', w, vbl + 1.5 * ifi_duration);
        
        
        % We also abort on keypress...
        
        [~, ~, keyCode] = KbCheck();
        disp(keyCode)
        if keyCode(KbName('ESCAPE'))
             break;
        end;
    end;
    
    % close windows
    Screen('CloseAll');
    ShowCursor;
    
    
    % if something went wrong -> clean up
catch err
    
    %  	ShowCursor;
    Screen('CloseAll');
    psychrethrow(psychlasterror);
    disp(err)
    
end

