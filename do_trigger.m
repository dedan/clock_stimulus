function do_trigger(dio, side, delay)
% do_trigger(dio, side, delay)
% dio: io handle
% side: 0=none 2=left 16=right

if dio == -1
    return;
end
if (nargin < 3)
    echo "Error: Usage: do_trigger(dio, side, delay)"
    return;
end;

%%% IMPORTANT!!! DELAY HAS TO BE DIVIDED BY 1000 TO HAVE S INSTEAD OF MS
putvalue(dio, side);
pause(delay/1000);
putvalue(dio, 0);