function [N, R2] = compute_n_synergies(emg_normalized, n_points, n_max, replicates, stop_criterion)

n_emg = size(emg_normalized, 2);
if nargin < 2    
    n_points = 200; n_max = 8; replicates = 10; stop_criterion = 'N=4';
elseif nargin < 3
    n_max = 8; replicates = 10; stop_criterion = 'N=4';
elseif nargin < 4
    replicates = 10; stop_criterion = 'N=4';
end

if iscell(stop_criterion)
    stop_criterion = stop_criterion{:};
end

n_max = max([n_max, n_emg]);

R2 = NaN(n_max, n_emg+1);
for i = 1:n_max
%     disp(int2str(i)); disp(datestr(now, 0));
%     sprintf('%s -- %s', int2str(i), datestr(now, 0));
    [~, ~, R2(i, :)] = nmf_emg(emg_normalized, i, n_points, replicates);
end


switch stop_criterion(1:2)
    case 'N='
        parsed = strsplit(stop_criterion, '=');
        N = str2double(parsed(end));
        
    case 'R2'
        parsed = strsplit(stop_criterion, '=');
        R2max = str2double(parsed(end));
        N = find(R2(:, 1) >= R2max, 1, 'first');
        
    case 'BL'        
        N = [];
        %for er = 1e-5:1e-5:1e-3
        N1 = 1;
        MSE = 1;
        while MSE > 1e-4 && N1 <= n_max %er
            MSE = mse_r2(R2(N1:end,1)');
            N1 = N1 + 1;
        end
        N = [N N1-1];
        %end
end

% R2tot = R2(:, 1);

end