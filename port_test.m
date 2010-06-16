%%%% test parallel port
direction = 'out';
switch get(handles.pport_check,'checked')
    case 'on'
        try
            dio = digitalio('parallel', 'LPT1'); % OUTPUT
            if strcmp(direction, 'out')
                addline(dio, 0:7, direction);
                putvalue(dio, 0);
            elseif strcmp(direction, 'in')
                addline(dio, [11,8,9,10,12], 'in')
            end
        catch
            dio = -1;
            answ = questdlg('Failed to initialize parallel port! Continue?');
            if answ(1,1) ~= 'Y'
                return;
            end
        end
    otherwise
        dio = -1;
end
