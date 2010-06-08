
% collect information on screen and display
which_screen    = min(Screen('Screens'));
w               = Screen(which_screen, 'OpenWindow');
[width, height] = Screen('WindowSize', w);
ifi_duration    = Screen('GetFlipInterval', w);


black   = BlackIndex(w);
white   = WhiteIndex(w);
gray    = (black + white) /2;

radius      = 100;
x_center    = width/2;
y_center    = height/2;
rect        = [x_center-radius y_center-radius x_center+radius y_center+radius];

try
    
    % make background gray
    Screen('FillRect',w, gray);
    
    % draw the clock
    Screen('FrameOval', window, white, rect);
    vbl = Screen('Flip', w);
    
    t1 = GetSecs;
    
    
    % Animation loop (forever):
    while true
        
        sec = mod(GetSecs-t1, 60);
        phi = (sec / 60) * 2 * pi;
        
        Screen('FillRect',w, gray);
        
        
        % Writes text to the window.
        currentTextRow = 0;
        Screen('DrawText', w, sprintf('new_x = %2.2f, new_y = %2.2f', sin(phi)*radius, cos(phi)*radius), 0, currentTextRow, white);
        currentTextRow = currentTextRow + 20;
        Screen('DrawText', w, sprintf('sec = %2.2f, phi = %2.2f', sec, phi), 0, currentTextRow, white);
        
        Screen('FrameOval', w, white, rect);
        Screen('DrawLine', w, white, x_center, y_center, x_center+cos(phi)*radius, y_center+sin(phi)*radius);
        vbl = Screen('Flip', w, vbl + 1.5 * ifi_duration);
        
        
        % We also abort on keypress...
        if KbCheck
            break;
        end;
    end;
    
    % ---------- Window Cleanup ----------
    
    % Waits for the user to press a key.
    KbWait;
    Screen('CloseAll');
catch
    
    % Closes all windows.
    Screen('CloseAll');
    psychrethrow(psychlasterror);
    
end

