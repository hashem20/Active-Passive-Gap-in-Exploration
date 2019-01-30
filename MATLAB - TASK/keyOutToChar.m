function ch = keyOutToChar(secs, keycode)

shiftkeys = [];
if isempty(shiftkeys)
    shiftkeys = [KbName('LeftShift'), KbName('RightShift')];
end

% Get keypress, KbCheck style:
% secs = out.secs;
% keycode = out.keyCode;
down = 1;

% Force keycode to 0 or 1:
keycode(keycode > 0) = 1;

% Shift pressed?
if any(keycode(shiftkeys))
    shift = 2;
else
    shift = 1;
end

% Remove shift keys:
keycode(shiftkeys) = 0;
% keycode(shiftkeys) = 1;

% Translate to ascii style:
ch = KbName(keycode);

% If multiple keys pressed, only use 1st one:
if iscell(ch)
    ch = ch{1};
end

% Decode 1st or 2nd char, depending if shift key was pressed:
if length(ch) == 1
    if shift > 1 && ismember(ch, 'abcdefghijklmnopqrstuvwxyz')
        ch = upper(ch);
    end
elseif length(ch) == 2
    ch = ch(shift);
elseif length(ch) > 2
    if strcmpi(ch, 'Return')
        ch = char(13);
    end
    if strcmpi(ch, 'ENTER')
        ch = char(13);
    end
    if strcmpi(ch, 'space')
        ch = char(32);
    end
    if strcmpi(ch, 'DELETE') || strcmpi(ch, 'BackSpace')
        ch = char(8);
    end
    
    % Catch otherwise unhandled special keys:
    if length(ch) > 1
        % Call ourselves recursively, thereby discarding this unmanageable
        % result.
        fprintf('GetKbChar: Warning: Received keypress for key %s. Don''t really know what to do with it.\n', ch);
        fprintf('Maybe you should check for stuck or invalid keys?\n');
        ch = [];
        return;
    end
end
