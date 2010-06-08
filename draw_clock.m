function draw_clock(w, color, rect, radius, x_center, y_center, tick_size)

% draw background and clock
Screen('FrameOval', w, color, rect);
for i=1:12
    phi = (i/12)*2*pi;
    Screen('DrawLine', w, color, x_center+cos(phi)*(radius-tick_size), ...
        y_center+sin(phi)*(radius-tick_size), x_center+cos(phi)*(radius+tick_size) ...
        , y_center+sin(phi)*(radius+tick_size),2);
end
