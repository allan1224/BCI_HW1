clear all;
clc
close all;


%% Load
% Signal is a single channel EEG data 
% Ampltiude of EEG (uV) over time
% Triggers are markers/cues done in the expirment to prepare the subject to
% initiate a task
% In our case, it's timepoints -> the signal samples at which the trigger
% occurs
% The last trigger is less than the max value of the number of samples of
% the signal -> within range of signal
% Only 1 vector so there's only one kind of trigger -> therefore only 90
% trials. The trials last until the next trigger

load eeg.mat
fs = 250

%% Plot
figure;
plot((1:length(signal))./fs,signal);
xlabel('Seconds')
ylabel('Amplitude')
hold on;
stem(trigger./fs,ones(length(trigger),1).*10)
title("Single channel signal with event triggeers")


%% Pre-processing

% Remove noise, remove DC component
% We want to focus on a specific subband of EEG, because useeful
% information is contained there and not spread all over across the
% spectrum
% Alpha 9 11, Beta 18 22
% Power is reduced cause we're only taking one small component of the whole
% signal -> we're only keeping the power on that freq band compared to the
% whole band

% Increase and decrease in poweer rythms are a result of synch and desynch

% When you have abrupt oscillations you can see when the power increases
% but it's hard to interpret short oscillations
% When you smooth the data w/ moving average, you can start to inrepret what is going on in
% analysis -> but do not do this in real time applications

% Observing common phenonmenon among all the trials. Will not have exact
% copies bc it's biological signals
% Reboud is more prominent in beta frequency band -> strong
% resynchronization that is very short. beta rebound
% Strong desynchronization in alpha . cannot see rebound in alpha when
% grand average
% Not all synchronization is rebound synchronization


% Simple bandpass filtering
filter_alpha = [9 11]; % alpha band
filter_beta = [18 22]; % beta band
N = 5; % filter order

% alpha 
[B, A] = butter(N, [filter_alpha(1) filter_alpha(2)]*2 /fs);
filteredSignal_alpha = filter(B, A, signal);

% beta
[B, A] = butter(N, [filter_beta(1) filter_beta(2)]*2 /fs);
filteredSignal_beta = filter(B, A, signal);

figure;
plot((1:length(signal))./fs,signal);
hold on;
plot((1:length(filteredSignal_alpha))./fs,filteredSignal_alpha);
hold on;
plot((1:length(filteredSignal_beta))./fs,filteredSignal_beta);
xlabel('Seconds')
ylabel('Amplitude (uV)^2')
title("Filtered vs Raw signal")
legend('Raw','Alpha','Beta')

% Power
power = (signal).^2;
hold on; 
plot((1:length(power))./fs,power);

%% 
figure;
power = (filteredSignal_alpha).^2;
hold on; 
plot((1:length(power))./fs,power);

power = (filteredSignal_beta).^2;
hold on; 
plot((1:length(power))./fs,power);
legend('PowerAlpha', 'PowerBeta')
xlabel('Seconds')
ylabel('Amplitude (uV)^2')
title("Power of filtered signals")


%% Moving Average Filter

% What is moving average? WHy to apply it? 


avg = 1; % average window
% The smaller the window, the more close each value is to another, the
% lower the amplitude because all sampels are growing closer to the
% average- data is more smooth, less noticeable peaks  

alpha_mavg = (filter(ones(1, avg*fs)/avg/fs, 1, filteredSignal_alpha));
beta_mavg = (filter(ones(1, avg*fs)/avg/fs, 1, filteredSignal_beta));

figure;
plot((1:length(alpha_mavg))./fs,alpha_mavg);
hold on;
plot((1:length(beta_mavg))./fs,beta_mavg);
xlabel('Seconds')
ylabel('Amplitude (uV)')
title("Smoothed Alpha and Beta")
legend('Alpha','Beta')



%% Single trial plots 

trial_id = [55 56 74 77];
trial_timing = [-2 6];

% Sample at which trial # occurs in signal:
for trial = 1:length(trial_id)
    
    sampleLoc(trial) = trigger(trial_id(trial));
    
end

% Plot single trial raw signal
for trial =  1:length(sampleLoc)

    start = sampleLoc(trial) + fs*trial_timing(1);
    fin = sampleLoc(trial) + fs*trial_timing(2);
    
    subplot(4,1,trial);
    
    % -2 shift to the signal so trial can start at 0 sec
    plot(((1:length(start:fin))./fs)-2,signal(start:fin));
    
    title("Trial",trial_id(trial));
    xlabel('Seconds')
    ylabel('Amplitude (uV)')
    
end 
sgtitle("Raw signal")

figure;

% Plot single trial alpha signal
for trial =  1:length(sampleLoc)

    start = sampleLoc(trial) + fs*trial_timing(1);
    fin = sampleLoc(trial) + fs*trial_timing(2);
    
    subplot(4,1,trial);
    
    % -2 shift to the signal so trial can start at 0 sec
    plot(((1:length(start:fin))./fs)-2,filteredSignal_alpha(start:fin));
    
    title("Trial",trial_id(trial));
    xlabel('Seconds')
    ylabel('Amplitude (uV)')
    
end 
sgtitle("Alpha band")

figure;

% Plot single trial beta signal
for trial =  1:length(sampleLoc)

    start = sampleLoc(trial) + fs*trial_timing(1);
    fin = sampleLoc(trial) + fs*trial_timing(2);
    
    subplot(4,1,trial);
    
    % -2 shift to the signal so trial can start at 0 sec
    plot(((1:length(start:fin))./fs)-2,filteredSignal_beta(start:fin));
    
    title("Trial",trial_id(trial));
    xlabel('Seconds')
    ylabel('Amplitude (uV)')
    
end 
sgtitle("Beta band")

 
%% Grand average

trial_timing = [-2 6];

% Plot averaged trials alpha signal
for trial =  1:length(trigger)

    start = trigger(trial) + fs*trial_timing(1);
    fin = trigger(trial) + fs*trial_timing(2);
    
    trialAlpha(trial,:) = (filteredSignal_alpha(start:fin));
    trialBeta(trial,:) = (filteredSignal_beta(start:fin));
    
    grandAVGAlpha = mean(trialAlpha);
    grandAVGBeta = mean(trialBeta);
    
  

end 


figure;
plot((1:length(grandAVGAlpha))./fs,grandAVGAlpha);
title("Grand AVG alpha");
xlabel('Seconds')
ylabel('Amplitude (uV)')

figure;
plot((1:length(grandAVGBeta))./fs,grandAVGBeta);
title("Grand AVG beta");
xlabel('Seconds')
ylabel('Amplitude (uV)')

