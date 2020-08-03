function events = find_gait_events(heel_x, heel_y, point_framerate, gait_freq)

[~, events] = findpeaks(heel_x, 'minpeakdistance', round(point_framerate/(gait_freq*1.2)));
window = round(0.1 * point_framerate); % 100 ms +- heel_x events

for i = 1:length(events)
    e = events(i);
    [~, add_idx] = min(heel_y(e : min([e + window, length(heel_y)])));
    events(i) = e - 1 + add_idx;
end

% first timestamp equals to 0.0, but index starts with 1
events = (events-1) / point_framerate; %sec

end