function [q_meas, dq_meas, q_noise, dq_noise] = addMeasurementNoise(t, q, dq, noise)
% =========================================================
% Add Measurement Noise
%
% q_meas  = q  + q_noise
% dq_meas = dq + dq_noise
%
% The real plant remains noise-free.
% Noise is added only to measured signals.
% =========================================================

q  = q(:);
dq = dq(:);

% Default: no noise
q_noise  = zeros(5,1);
dq_noise = zeros(5,1);

q_meas  = q;
dq_meas = dq;

% Check noise settings
if nargin < 4 || isempty(noise)
    return;
end

if isfield(noise, 'enabled')
    if noise.enabled == false
        return;
    end
end

% -----------------------------
% Interpolate pre-generated noise
% -----------------------------
q_noise = interp1( ...
    noise.time, ...
    noise.qNoise, ...
    t, ...
    'linear', ...
    'extrap' ...
)';

dq_noise = interp1( ...
    noise.time, ...
    noise.dqNoise, ...
    t, ...
    'linear', ...
    'extrap' ...
)';

% -----------------------------
% Add noise to measurements
% -----------------------------
q_meas  = q  + q_noise;
dq_meas = dq + dq_noise;

end