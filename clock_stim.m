clear
try
    
    % trial settings
    one_circle      = 2.56;
    stim_interval   = [2.5 8.5];
    stop_interval   = [1.5 2.5];
    increment       = 0.1;

    % clock settings
    clock_hand  = 12;           % in mm on display
    tick_size   = 2;            % in pixels
    debug       = 1;

    % psycho settings
    ListenChar(2)               % Matlab: please don't listen to the keys!
    KbName('UnifyKeyNames');    % unified mode of KbName for usage on all operating systems

    
    
    
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
    
    
    % static things to compute and draw
    t_stim      = stim_interval(1) + rand*diff(stim_interval);              % time of stimulus (TMS)
    t_stop      = t_stim + stop_interval(1) + rand * diff(stop_interval);   % end of trial time
    x_center    = width_p/2;                                                % center of clock
    y_center    = height_p/2;
    radius      = (height_p/height_m) * clock_hand;                         % radius in mm on display
    rect        = [x_center-radius y_center-radius x_center+radius y_center+radius];    % circle for clock

    
    % draw background and clock
    Screen('FillRect',w, gray);
    draw_clock(w, white, rect, radius, x_center, y_center, tick_size)
    
    % initialize clock hand at random position and draw it
    t_offset = rand * one_circle;
    phi      = (t_offset / one_circle) * 2 * pi;      % angle in radians
    Screen('DrawLine', w, white, x_center, y_center, x_center+cos(phi)*radius, y_center+sin(phi)*radius);

    % initial flip
    Screen('DrawText', w, 'Press any key to start', 0, 0, white);
    vbl = Screen('Flip', w);
    
    
    % Waits for keypress to start
    WaitSecs(0.2);                          % neglect starting keypress
    KbWait;
    t_start = GetSecs;                      % remember start time
    t_now   = GetSecs - t_start;

    stimulated = false;
    
    % Animation and stimulation loop (until keypress or trial end)
    while t_now < t_stop
        
        t_now = GetSecs - t_start;
        % stimulus
        if (t_now > t_stim) && (~stimulated)
            stimulated = true;
            beep;
            Screen('FillRect',w, white, [700 700 750 750]);
            stim_angle = t_now;
        end
        
        % draw background and clock
        Screen('FillRect',w, gray, [0 0 700 700]);
        draw_clock(w, white, rect, radius, x_center, y_center, tick_size)
        
        sec = mod(t_now + t_offset, one_circle);        % time in seconds
        phi = (sec / one_circle) * 2 * pi;              % angle in radians
        
        % draw clock hand
        Screen('DrawLine', w, white, x_center, y_center, x_center+cos(phi)*radius, y_center+sin(phi)*radius);
                
        % debugging
        if debug
            currentTextRow = 0;
            Screen('DrawText', w, sprintf('new_x = %2.2f, new_y = %2.2f', sin(phi)*radius, cos(phi)*radius), 0, currentTextRow, white);
            currentTextRow = currentTextRow + 20;
            Screen('DrawText', w, sprintf('t_now = %2.2f, phi = %2.2f', t_now, phi), 0, currentTextRow, white);
            currentTextRow = currentTextRow + 20;
            Screen('DrawText', w, sprintf('t_stim = %2.2f, t_stop = %2.2f', t_stim, t_stop), 0, currentTextRow, white);
        end
        
        % write text
        currentTextRow = currentTextRow + 20;
        Screen('DrawText', w, 'Press ESCAPE to stop', 0, currentTextRow, white);

        % show buffer
        vbl = Screen('Flip', w, vbl + 1.5 * ifi_duration);
        
        % abort on keypress
        [~, ~, keyCode] = KbCheck();
         if keyCode(KbName('ESCAPE'))
             break;
        end;
    end;
    
    
    phi         = pi/2;                         % initialize to six o'clock
    right_key   = KbName('RightArrow');         % get key numbers
    left_key    = KbName('LeftArrow');
    stop_key    = KbName('Space');
    
    % until angle chosen with space
    while true
        
        [keyIsDown, seconds, keyCode ] = KbCheck;
        
        if keyIsDown
            if keyCode(right_key)
                phi = mod(phi + increment, 2*pi);
            elseif keyCode(left_key)
                phi = mod(phi - increment, 2*pi);
            elseif keyCode(stop_key)
                break;
            end
        end
        
        % draw background and clock
        Screen('FillRect',w, gray, [0 0 700 700]);
        draw_clock(w, white, rect, radius, x_center, y_center, tick_size)
        
        % draw text
        currentTextRow = 0;
        Screen('DrawText', w, 'Press SPACE to select angle', 0, currentTextRow, white);
        
        % draw clock hand
        Screen('DrawLine', w, white, x_center, y_center, x_center+cos(phi)*radius, y_center+sin(phi)*radius);
        
        vbl = Screen('Flip', w, vbl + 1.5 * ifi_duration);
        
    end
    
    % clean up
    Screen('CloseAll');
    ShowCursor;
    ListenChar(0)
    
    
    % if something went wrong -> clean up
catch err
    
    Screen('CloseAll');
    ShowCursor;
    ListenChar(0)
    psychrethrow(psychlasterror);
    disp(err)
    
end

