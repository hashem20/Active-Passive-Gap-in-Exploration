function out = getKbCharOrClick(window, untilTime)


% Time (in seconds) to wait between "failed" checks, in order to not
% overload the system in realtime mode. 5 msecs seems to be an ok value...
yieldInterval = 0.005;

forWhat = 0;
deviceNumber = -1;

if nargin < 2
    untilTime = inf;
end

if isempty(untilTime)
    untilTime = inf;
end

secs = -inf;
while secs < untilTime
    % check for key press
    [isDown, secs, keyCode, deltaSecs] = KbCheck(deviceNumber);
    ch = keyOutToChar(secs, keyCode);
    % ignore shift keys
    if isempty(ch)
        isDown = 0;
    end
    if (isDown == ~forWhat) || (secs >= untilTime)
        out.what        = 'keyPress';
        out.secs        = secs;
        out.keyCode     = keyCode;
        out.deltaSecs   = deltaSecs;
        out.ch          = ch;
        
        % wait for key to be released
        %while isDown && (secs < untilTime)
        %   [isDown, secs, keyincode] = KbCheck(deviceNumber);
        %    if isDown
        %        %keycode = keycode + keyincode;
        %        WaitSecs('YieldSecs', 0.001);
        %    end
        %end

        return;
    end
    
    % check for mouse click
    [x,y,buttons,focus,valuators,valinfo] = GetMouse(window);
    if any(buttons)
        out.what        = 'click';
        out.secs        = secs;
        out.x           = x;
        out.y           = y;
        out.buttons     = buttons;
        return;
    end
    
    % A tribute to Windows: A useless call to GetMouse to trigger
    % Screen()'s Windows application event queue processing to avoid
    % white-death due to hitting the "Application not responding" timeout:
    if IsWin
        GetMouse;
    end

    % Wait for yieldInterval to prevent system overload.
    secs = WaitSecs('YieldSecs', yieldInterval);
end
