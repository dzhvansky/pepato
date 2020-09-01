function emgcord = spinalcord_detailed_sharrard(emg_mean, emg_label)

T=1;    % cycle duration, s

[n_emg, n_points] = size(emg_mean);

% higner segmental discretization for Sharrard chats only        
avegiL21 = zeros([1 n_points]) + 0.001; nL21 = 0;
avegiL22 = zeros([1 n_points]) + 0.001; nL22 = 0;
avegiL23 = zeros([1 n_points]) + 0.001; nL23 = 0;
avegiL24 = zeros([1 n_points]) + 0.001; nL24 = 0;
avegiL25 = zeros([1 n_points]) + 0.001; nL25 = 0;
avegiL26 = zeros([1 n_points]) + 0.001; nL26 = 0;
avegiL31 = zeros([1 n_points]) + 0.001; nL31 = 0;
avegiL32 = zeros([1 n_points]) + 0.001; nL32 = 0;
avegiL33 = zeros([1 n_points]) + 0.001; nL33 = 0;
avegiL34 = zeros([1 n_points]) + 0.001; nL34 = 0;
avegiL35 = zeros([1 n_points]) + 0.001; nL35 = 0;
avegiL36 = zeros([1 n_points]) + 0.001; nL36 = 0;
avegiL41 = zeros([1 n_points]) + 0.001; nL41 = 0;
avegiL42 = zeros([1 n_points]) + 0.001; nL42 = 0;
avegiL43 = zeros([1 n_points]) + 0.001; nL43 = 0;
avegiL44 = zeros([1 n_points]) + 0.001; nL44 = 0;
avegiL45 = zeros([1 n_points]) + 0.001; nL45 = 0;
avegiL46 = zeros([1 n_points]) + 0.001; nL46 = 0;
avegiL51 = zeros([1 n_points]) + 0.001; nL51 = 0;
avegiL52 = zeros([1 n_points]) + 0.001; nL52 = 0;
avegiL53 = zeros([1 n_points]) + 0.001; nL53 = 0;
avegiL54 = zeros([1 n_points]) + 0.001; nL54 = 0;
avegiL55 = zeros([1 n_points]) + 0.001; nL55 = 0;
avegiL56 = zeros([1 n_points]) + 0.001; nL56 = 0;
avegiS11 = zeros([1 n_points]) + 0.001; nS11 = 0;
avegiS12 = zeros([1 n_points]) + 0.001; nS12 = 0;
avegiS13 = zeros([1 n_points]) + 0.001; nS13 = 0;
avegiS14 = zeros([1 n_points]) + 0.001; nS14 = 0;
avegiS15 = zeros([1 n_points]) + 0.001; nS15 = 0;
avegiS16 = zeros([1 n_points]) + 0.001; nS16 = 0;
avegiS21 = zeros([1 n_points]) + 0.001; nS21 = 0;
avegiS22 = zeros([1 n_points]) + 0.001; nS22 = 0;
avegiS23 = zeros([1 n_points]) + 0.001; nS23 = 0;
avegiS24 = zeros([1 n_points]) + 0.001; nS24 = 0;
avegiS25 = zeros([1 n_points]) + 0.001; nS25 = 0;
avegiS26 = zeros([1 n_points]) + 0.001; nS26 = 0;

v = 50;   % mean nerve conduction velocity, m/s

for i = 1 : n_emg
    switch char(emg_label(i))   % detailed Sharrard
        % (each segment consists of 6 subsegments: 1-6,
        % 1 corresponds to the most proximal (rostral) point of the segment
        % L - nerve length in cm,
        % d - time innervation delay, in number of points on a normalized 1:n_points scale
        case 'ReFe',   L = 0.40;  d = round((L/v)/T*100*(n_points/100));
            nInnEMG(i) = 16; 
            avegiL23=avegiL23+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL23=nL23+(1/nInnEMG(i));
            avegiL24=avegiL24+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL24=nL24+(1/nInnEMG(i));
            avegiL25=avegiL25+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL25=nL25+(1/nInnEMG(i));
            avegiL26=avegiL26+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL26=nL26+(1/nInnEMG(i));

            avegiL31=avegiL31+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL31=nL31+(1/nInnEMG(i));
            avegiL32=avegiL32+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL32=nL32+(1/nInnEMG(i));
            avegiL33=avegiL33+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL33=nL33+(1/nInnEMG(i));
            avegiL34=avegiL34+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL34=nL34+(1/nInnEMG(i));
            avegiL35=avegiL35+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL35=nL35+(1/nInnEMG(i));
            avegiL36=avegiL36+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL36=nL36+(1/nInnEMG(i));

            avegiL41=avegiL41+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL41=nL41+(1/nInnEMG(i));
            avegiL42=avegiL42+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL42=nL42+(1/nInnEMG(i));
            avegiL43=avegiL43+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL43=nL43+(1/nInnEMG(i));
            avegiL44=avegiL44+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL44=nL44+(1/nInnEMG(i));
            avegiL45=avegiL45+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL45=nL45+(1/nInnEMG(i));
            avegiL46=avegiL46+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL46=nL46+(1/nInnEMG(i));
        case 'VaLa',   L = 0.58;  d = round((L/v)/T*100*(n_points/100));
            nInnEMG(i) = 16; 
            avegiL23=avegiL23+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL23=nL23+(1/nInnEMG(i));
            avegiL24=avegiL24+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL24=nL24+(1/nInnEMG(i));
            avegiL25=avegiL25+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL25=nL25+(1/nInnEMG(i));
            avegiL26=avegiL26+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL26=nL26+(1/nInnEMG(i));

            avegiL31=avegiL31+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL31=nL31+(1/nInnEMG(i));
            avegiL32=avegiL32+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL32=nL32+(1/nInnEMG(i));
            avegiL33=avegiL33+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL33=nL33+(1/nInnEMG(i));
            avegiL34=avegiL34+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL34=nL34+(1/nInnEMG(i));
            avegiL35=avegiL35+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL35=nL35+(1/nInnEMG(i));
            avegiL36=avegiL36+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL36=nL36+(1/nInnEMG(i));

            avegiL41=avegiL41+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL41=nL41+(1/nInnEMG(i));
            avegiL42=avegiL42+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL42=nL42+(1/nInnEMG(i));
            avegiL43=avegiL43+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL43=nL43+(1/nInnEMG(i));
            avegiL44=avegiL44+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL44=nL44+(1/nInnEMG(i));
            avegiL45=avegiL45+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL45=nL45+(1/nInnEMG(i));
            avegiL46=avegiL46+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL46=nL46+(1/nInnEMG(i));
        case 'VaMe',   L = 0.58;  d = round((L/v)/T*100*(n_points/100));
            nInnEMG(i) = 16; 
            avegiL23=avegiL23+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL23=nL23+(1/nInnEMG(i));
            avegiL24=avegiL24+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL24=nL24+(1/nInnEMG(i));
            avegiL25=avegiL25+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL25=nL25+(1/nInnEMG(i));
            avegiL26=avegiL26+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL26=nL26+(1/nInnEMG(i));

            avegiL31=avegiL31+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL31=nL31+(1/nInnEMG(i));
            avegiL32=avegiL32+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL32=nL32+(1/nInnEMG(i));
            avegiL33=avegiL33+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL33=nL33+(1/nInnEMG(i));
            avegiL34=avegiL34+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL34=nL34+(1/nInnEMG(i));
            avegiL35=avegiL35+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL35=nL35+(1/nInnEMG(i));
            avegiL36=avegiL36+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL36=nL36+(1/nInnEMG(i));

            avegiL41=avegiL41+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL41=nL41+(1/nInnEMG(i));
            avegiL42=avegiL42+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL42=nL42+(1/nInnEMG(i));
            avegiL43=avegiL43+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL43=nL43+(1/nInnEMG(i));
            avegiL44=avegiL44+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL44=nL44+(1/nInnEMG(i));
            avegiL45=avegiL45+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL45=nL45+(1/nInnEMG(i));
            avegiL46=avegiL46+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL46=nL46+(1/nInnEMG(i));
        case 'TeFa',  L = 0.25;  d = round((L/v)/T*100*(n_points/100));
            nInnEMG(i) = 10; 
            avegiL45=avegiL45+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL45=nL45+(1/nInnEMG(i));
            avegiL46=avegiL46+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL46=nL46+(1/nInnEMG(i));

            avegiL51=avegiL51+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL51=nL51+(1/nInnEMG(i));
            avegiL52=avegiL52+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL52=nL52+(1/nInnEMG(i));
            avegiL53=avegiL53+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL53=nL53+(1/nInnEMG(i));
            avegiL54=avegiL54+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL54=nL54+(1/nInnEMG(i));
            avegiL55=avegiL55+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL55=nL55+(1/nInnEMG(i));
            avegiL56=avegiL56+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL56=nL56+(1/nInnEMG(i));

            avegiS11=avegiS11+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS11=nS11+(1/nInnEMG(i));
            avegiS12=avegiS12+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS12=nS12+(1/nInnEMG(i));
        case 'TiAn',   L = 0.85;  d = round((L/v)/T*100*(n_points/100));
            nInnEMG(i) = 8; 
            avegiL41=avegiL41+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL41=nL41+(1/nInnEMG(i));
            avegiL42=avegiL42+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL42=nL42+(1/nInnEMG(i));
            avegiL43=avegiL43+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL43=nL43+(1/nInnEMG(i));
            avegiL44=avegiL44+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL44=nL44+(1/nInnEMG(i));
            avegiL45=avegiL45+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL45=nL45+(1/nInnEMG(i));
            avegiL46=avegiL46+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL46=nL46+(1/nInnEMG(i));

            avegiL51=avegiL51+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL51=nL51+(1/nInnEMG(i));
            avegiL52=avegiL52+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL52=nL52+(1/nInnEMG(i));
        case 'Sol',  L = 0.90;  d = round((L/v)/T*100*(n_points/100));
            nInnEMG(i) = 15; 
            avegiL55=avegiL55+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL55=nL55+(1/nInnEMG(i));
            avegiL56=avegiL56+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL56=nL56+(1/nInnEMG(i));

            avegiS11=avegiS11+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS11=nS11+(1/nInnEMG(i));
            avegiS12=avegiS12+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS12=nS12+(1/nInnEMG(i));
            avegiS13=avegiS13+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS13=nS13+(1/nInnEMG(i));
            avegiS14=avegiS14+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS14=nS14+(1/nInnEMG(i));
            avegiS15=avegiS15+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS15=nS15+(1/nInnEMG(i));
            avegiS16=avegiS16+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS16=nS16+(1/nInnEMG(i));

            avegiS21=avegiS21+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS21=nS21+(1/nInnEMG(i));
            avegiS22=avegiS22+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS22=nS22+(1/nInnEMG(i));
            avegiS23=avegiS23+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS23=nS23+(1/nInnEMG(i));
            avegiS24=avegiS24+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS24=nS24+(1/nInnEMG(i));
            avegiS25=avegiS25+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS25=nS25+(1/nInnEMG(i));
            avegiS26=avegiS26+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS26=nS26+(1/nInnEMG(i));
        case 'PeLo', L = 0.72;  d = round((L/v)/T*100*(n_points/100));
            nInnEMG(i) = 12; 
            avegiL53=avegiL53+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL53=nL53+(1/nInnEMG(i));
            avegiL54=avegiL54+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL54=nL54+(1/nInnEMG(i));
            avegiL55=avegiL55+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL55=nL55+(1/nInnEMG(i));
            avegiL56=avegiL56+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL56=nL56+(1/nInnEMG(i));

            avegiS11=avegiS11+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS11=nS11+(1/nInnEMG(i));
            avegiS12=avegiS12+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS12=nS12+(1/nInnEMG(i));
            avegiS13=avegiS13+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS13=nS13+(1/nInnEMG(i));
            avegiS14=avegiS14+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS14=nS14+(1/nInnEMG(i));
            avegiS15=avegiS15+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS15=nS15+(1/nInnEMG(i));
            avegiS16=avegiS16+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS16=nS16+(1/nInnEMG(i));

            avegiS21=avegiS21+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS21=nS21+(1/nInnEMG(i));
            avegiS22=avegiS22+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS22=nS22+(1/nInnEMG(i));
        case 'GaLa',   L = 0.80;  d = round((L/v)/T*100*(n_points/100));
            nInnEMG(i) = 8; 
            avegiL55=avegiL55+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL55=nL55+(1/nInnEMG(i));
            avegiL56=avegiL56+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL56=nL56+(1/nInnEMG(i));

            avegiS11=avegiS11+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS11=nS11+(1/nInnEMG(i));
            avegiS12=avegiS12+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS12=nS12+(1/nInnEMG(i));
            avegiS13=avegiS13+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS13=nS13+(1/nInnEMG(i));
            avegiS14=avegiS14+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS14=nS14+(1/nInnEMG(i));
            avegiS15=avegiS15+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS15=nS15+(1/nInnEMG(i));
            avegiS16=avegiS16+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS16=nS16+(1/nInnEMG(i));
        case 'GaMe',   L = 0.80;  d = round((L/v)/T*100*(n_points/100));
            nInnEMG(i) = 8; 
            avegiL55=avegiL55+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL55=nL55+(1/nInnEMG(i));
            avegiL56=avegiL56+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL56=nL56+(1/nInnEMG(i));

            avegiS11=avegiS11+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS11=nS11+(1/nInnEMG(i));
            avegiS12=avegiS12+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS12=nS12+(1/nInnEMG(i));
            avegiS13=avegiS13+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS13=nS13+(1/nInnEMG(i));
            avegiS14=avegiS14+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS14=nS14+(1/nInnEMG(i));
            avegiS15=avegiS15+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS15=nS15+(1/nInnEMG(i));
            avegiS16=avegiS16+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS16=nS16+(1/nInnEMG(i));
        case 'SeTe', L = 0.41;  d = round((L/v)/T*100*(n_points/100));
            nInnEMG(i) = 15; 
            avegiL45=avegiL45+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL45=nL45+(1/nInnEMG(i));
            avegiL46=avegiL46+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL46=nL46+(1/nInnEMG(i));

            avegiL51=avegiL51+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL51=nL51+(1/nInnEMG(i));
            avegiL52=avegiL52+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL52=nL52+(1/nInnEMG(i));
            avegiL53=avegiL53+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL53=nL53+(1/nInnEMG(i));
            avegiL54=avegiL54+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL54=nL54+(1/nInnEMG(i));
            avegiL55=avegiL55+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL55=nL55+(1/nInnEMG(i));
            avegiL56=avegiL56+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL56=nL56+(1/nInnEMG(i));

            avegiS11=avegiS11+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS11=nS11+(1/nInnEMG(i));
            avegiS12=avegiS12+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS12=nS12+(1/nInnEMG(i));
            avegiS13=avegiS13+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS13=nS13+(1/nInnEMG(i));
            avegiS14=avegiS14+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS14=nS14+(1/nInnEMG(i));
            avegiS15=avegiS15+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS15=nS15+(1/nInnEMG(i));
            avegiS16=avegiS16+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS16=nS16+(1/nInnEMG(i));

            avegiS21=avegiS21+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS21=nS21+(1/nInnEMG(i));
        case 'BiFe',   L = 0.42;  d = round((L/v)/T*100*(n_points/100));
            nInnEMG(i) = 15; %giovanni
            avegiL55=avegiL55+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL55=nL55+(1/nInnEMG(i));
            avegiL56=avegiL56+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL56=nL56+(1/nInnEMG(i));

            avegiS11=avegiS11+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS11=nS11+(1/nInnEMG(i));
            avegiS12=avegiS12+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS12=nS12+(1/nInnEMG(i));
            avegiS13=avegiS13+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS13=nS13+(1/nInnEMG(i));
            avegiS14=avegiS14+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS14=nS14+(1/nInnEMG(i));
            avegiS15=avegiS15+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS15=nS15+(1/nInnEMG(i));
            avegiS16=avegiS16+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS16=nS16+(1/nInnEMG(i));

            avegiS21=avegiS21+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS21=nS21+(1/nInnEMG(i));
            avegiS22=avegiS22+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS22=nS22+(1/nInnEMG(i));
            avegiS23=avegiS23+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS23=nS23+(1/nInnEMG(i));
            avegiS24=avegiS24+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS24=nS24+(1/nInnEMG(i));
            avegiS25=avegiS25+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS25=nS25+(1/nInnEMG(i));
            avegiS26=avegiS26+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS26=nS26+(1/nInnEMG(i));
        case 'GlMa',   L = 0.20;  d = round((L/v)/T*100*(n_points/100));
            nInnEMG(i) = 14; 
            avegiL55=avegiL55+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL55=nL55+(1/nInnEMG(i));
            avegiL56=avegiL56+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nL56=nL56+(1/nInnEMG(i));

            avegiS11=avegiS11+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS11=nS11+(1/nInnEMG(i));
            avegiS12=avegiS12+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS12=nS12+(1/nInnEMG(i));
            avegiS13=avegiS13+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS13=nS13+(1/nInnEMG(i));
            avegiS14=avegiS14+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS14=nS14+(1/nInnEMG(i));
            avegiS15=avegiS15+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS15=nS15+(1/nInnEMG(i));
            avegiS16=avegiS16+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS16=nS16+(1/nInnEMG(i));

            avegiS21=avegiS21+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS21=nS21+(1/nInnEMG(i));
            avegiS22=avegiS22+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS22=nS22+(1/nInnEMG(i));
            avegiS23=avegiS23+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS23=nS23+(1/nInnEMG(i));
            avegiS24=avegiS24+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS24=nS24+(1/nInnEMG(i));
            avegiS25=avegiS25+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS25=nS25+(1/nInnEMG(i));
            avegiS26=avegiS26+(circshift(emg_mean(i,:)',-d)')/nInnEMG(i); nS26=nS26+(1/nInnEMG(i));
    end
end


% higher segmental discretization for Sharrard 
if nL21>0, avegiL21=avegiL21/nL21; end
if nL22>0, avegiL22=avegiL22/nL22; end
if nL23>0, avegiL23=avegiL23/nL23; end
if nL24>0, avegiL24=avegiL24/nL24; end
if nL25>0, avegiL25=avegiL25/nL25; end
if nL26>0, avegiL26=avegiL26/nL26; end
if nL31>0, avegiL31=avegiL31/nL31; end
if nL32>0, avegiL32=avegiL32/nL32; end
if nL33>0, avegiL33=avegiL33/nL33; end
if nL34>0, avegiL34=avegiL34/nL34; end
if nL35>0, avegiL35=avegiL35/nL35; end
if nL36>0, avegiL36=avegiL36/nL36; end
if nL41>0, avegiL41=avegiL41/nL41; end
if nL42>0, avegiL42=avegiL42/nL42; end
if nL43>0, avegiL43=avegiL43/nL43; end
if nL44>0, avegiL44=avegiL44/nL44; end
if nL45>0, avegiL45=avegiL45/nL45; end
if nL46>0, avegiL46=avegiL46/nL46; end
if nL51>0, avegiL51=avegiL51/nL51; end
if nL52>0, avegiL52=avegiL52/nL52; end
if nL53>0, avegiL53=avegiL53/nL53; end
if nL54>0, avegiL54=avegiL54/nL54; end
if nL55>0, avegiL55=avegiL55/nL55; end
if nL56>0, avegiL56=avegiL56/nL56; end
if nS11>0, avegiS11=avegiS11/nS11; end
if nS12>0, avegiS12=avegiS12/nS12; end
if nS13>0, avegiS13=avegiS13/nS13; end
if nS14>0, avegiS14=avegiS14/nS14; end
if nS15>0, avegiS15=avegiS15/nS15; end
if nS16>0, avegiS16=avegiS16/nS16; end
if nS21>0, avegiS21=avegiS21/nS21; end
if nS22>0, avegiS22=avegiS22/nS22; end
if nS23>0, avegiS23=avegiS23/nS23; end
if nS24>0, avegiS24=avegiS24/nS24; end
if nS25>0, avegiS25=avegiS25/nS25; end
if nS26>0, avegiS26=avegiS26/nS26; end

emgcord_LS = [avegiS26' avegiS25' avegiS24' avegiS23' avegiS22' avegiS21' ...
    avegiS16' avegiS15' avegiS14' avegiS13' avegiS12' avegiS11' ...
    avegiL56' avegiL55' avegiL54' avegiL53' avegiL52' avegiL51' ...
    avegiL46' avegiL45' avegiL44' avegiL43' avegiL42' avegiL41' ...
    avegiL36' avegiL35' avegiL34' avegiL33' avegiL32' avegiL31' ...
    avegiL26' avegiL25' avegiL24' avegiL23' avegiL22' avegiL21' ]';   % lumbar enlargment

emgcord = emgcord_LS;


return % end of function spinalcord