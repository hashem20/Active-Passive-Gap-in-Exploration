classdef soundObject < handle
    
    properties
        
        sound
        
        pahandle
        sampleRate
        nrchannels
        reqlatencyclass
        
    end
    
    methods
        
        function obj = soundObject(pahandle, sampleRate)
            
            obj.pahandle = pahandle;
            
            % Sampling rate. Must set this. 96khz, 48khz, 44.1khz.
            if exist('sampleRate') ~= 1
                obj.sampleRate = 44100;
            else
                obj.sampleRate = sampleRate;
            end
            
            % Open the default audio device [], with default mode []
            % (==Only playback), and a required latencyclass of zero
            % 0 == no
            % low-latency mode, as well as a frequency of freq and
            % nrchannels sound channels.  This returns a handle to the
            % audio device:
            obj.nrchannels = 2;
            
            % Request latency mode 2, which used to be the best one in
            % our measurement: classes 3 and 4 didn't yield any
            % improvements, sometimes they even caused problems.
            % class 2 empirically the best, 3 & 4 == 2
            obj.reqlatencyclass = 2;
            
            
        end
        
        function setSound(obj, sound)
            obj.sound = sound;
        end
        
        function [soundOn, soundOff] = playSound(obj, onTime)
            
            reqlatencyclass = obj.reqlatencyclass;
            sampleRate      = obj.sampleRate;
            nrchannels      = obj.nrchannels;
            pahandle        = obj.pahandle;
            
            % Fill buffer with data:
            PsychPortAudio('FillBuffer', pahandle, obj.sound);
            
            % Start the playback engine with an infinite start
            % deadline, i.e., start hardware, but don't play sound:
            PsychPortAudio('Start', pahandle, 1, inf, 0);
            
            % Play sound
            PsychPortAudio('RescheduleStart', pahandle, onTime, 0);
            
            % Stop playback - NOT NECESSARY
            [soundOn, SoundEndPosSecs, SoundXruns, soundOff] ...
                = PsychPortAudio('Stop', pahandle, 1);
            
        end
        
    end
    
end

