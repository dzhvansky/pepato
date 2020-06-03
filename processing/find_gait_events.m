function events = find_gait_events(cycle_separator, point_framerate, gait_freq)

[~, events] = findpeaks(cycle_separator, 'minpeakdistance', round(point_framerate/(gait_freq*1.2)));
events = events / point_framerate; %sec

end