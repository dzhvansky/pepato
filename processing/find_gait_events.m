function events = find_gait_events(cycle_separator, point_framerate, gait_freq)

[~, events] = findpeaks(cycle_separator, 'minpeakdistance', round(point_framerate/(gait_freq*1.2)));
% first timestamp equals to 0.0, but index starts with 1
events = (events-1) / point_framerate; %sec

end