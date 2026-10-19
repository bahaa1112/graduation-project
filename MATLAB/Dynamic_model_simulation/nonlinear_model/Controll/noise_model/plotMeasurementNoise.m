function plotMeasurementNoise(noise)
% =========================================================
% Plot Measurement Noise
%
% Position noise is plotted in deg.
% Velocity noise is plotted in deg/s.
% =========================================================

if nargin < 1 || isempty(noise)
    disp('No noise structure provided.');
    return;
end

if isfield(noise, 'enabled')
    if noise.enabled == false
        disp('Noise is disabled.');
        return;
    end
end

t = noise.time;

qNoise_deg  = rad2deg(noise.qNoise);
dqNoise_deg = rad2deg(noise.dqNoise);

figure;

for i = 1:5

    % -----------------------------
    % Position noise
    % -----------------------------
    subplot(5,2,2*i-1);

    plot(t, qNoise_deg(:,i), 'LineWidth', 1.2);
    grid on;

    xlabel('Time (s)');
    ylabel(['n_q_', num2str(i), ' (deg)']);
    title(['Joint ', num2str(i), ' Position Noise']);

    % -----------------------------
    % Velocity noise
    % -----------------------------
    subplot(5,2,2*i);

    plot(t, dqNoise_deg(:,i), 'LineWidth', 1.2);
    grid on;

    xlabel('Time (s)');
    ylabel(['n_dq_', num2str(i), ' (deg/s)']);
    title(['Joint ', num2str(i), ' Velocity Noise']);

end

end