function noise = createNoiseConfig(tspan)
% =========================================================
% Create Noise Configuration
%
% Noise type:
% Additive Band-Limited Gaussian Measurement Noise
%
% The noise is generated once before simulation and then
% interpolated during ode45.
% =========================================================
if nargin < 1
    tspan = [0 20];
end
% -----------------------------
% Basic settings
% -----------------------------
noise.enabled = true;

noise.type = 'Additive Band-Limited Gaussian Measurement Noise';

% Number of joints
noise.nJoints = 5;

% Sampling time of noise signal
noise.sampleTime = 0.001;   % seconds

% Cutoff frequency for band limitation
noise.cutoffFreq = 20;      % Hz

% Random seed for repeatable results
noise.seed = 10;

% -----------------------------
% Noise standard deviations
% -----------------------------
% Position measurement noise
noise.qStd = deg2rad([2; 2; 2; 2; 2]);      % rad

% Velocity measurement noise
noise.dqStd = deg2rad([10; 10; 10; 10; 10]);                % rad/s

% -----------------------------
% Time vector
% -----------------------------
noise.time = (tspan(1):noise.sampleTime:tspan(end))';

if noise.time(end) < tspan(end)
    noise.time(end+1) = tspan(end);
end

% -----------------------------
% Generate band-limited Gaussian noise
% -----------------------------
rng(noise.seed);

noise.qNoise = generateBandLimitedGaussianNoise( ...
    noise.time, noise.qStd, noise.cutoffFreq);

noise.dqNoise = generateBandLimitedGaussianNoise( ...
    noise.time, noise.dqStd, noise.cutoffFreq);

end

% =========================================================
% Local function
% =========================================================
function y = generateBandLimitedGaussianNoise(time, stdVec, cutoffFreq)

N = length(time);
n = length(stdVec);

y = zeros(N,n);

dt = mean(diff(time));

% First-order low-pass filter approximation
tau = 1/(2*pi*cutoffFreq);
alpha = dt/(tau + dt);

for j = 1:n

    whiteNoise = randn(N,1);
    filteredNoise = zeros(N,1);

    for k = 2:N
        filteredNoise(k) = filteredNoise(k-1) + ...
            alpha*(whiteNoise(k) - filteredNoise(k-1));
    end

    % Remove mean
    filteredNoise = filteredNoise - mean(filteredNoise);

    % Normalize standard deviation
    if std(filteredNoise) > 0
        filteredNoise = filteredNoise / std(filteredNoise);
    end

    % Scale to required standard deviation
    y(:,j) = stdVec(j) * filteredNoise;

end

end