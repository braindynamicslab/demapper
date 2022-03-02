close all;
basefolder  = split(pwd, 'demapper');
basefolder  = [basefolder{1}, 'demapper'];
codefolder  = [basefolder,'/sim'];
addpath(genpath(codefolder));

TRs_total = 1200;
states = [0, 0.5, 1];
state_transition_TRs = 30;
SNR = 30;
oscillators = [0.02, 0.03];
oscillators_gain = [0.1, 0.1];
RepetitionTime = 0.72;

opts = struct;
opts.TRANSITION_TYPE = "constant"; % Either 'prob' or 'constant' or 'none'
% TODO: make transition specific to destination
opts.PROB_TO_TRANSITION = [0.03, 0.03, 0.03];
opts.MINIMUM_STATE_STEPS = 50;
opts.TRANSITION_FUNC = 'sigmoid'; % Either line or sigmoid

current_sid = 1;
in_transition = false;
transition_step = 0; transition_steps = [];
TRs = ones(1, TRs_total) * -1;
time_in_state = 0;
for i=1:TRs_total
    if in_transition
        TR = transition_steps(transition_step); % + noise
        transition_step = transition_step+1;
        if transition_step > state_transition_TRs
            in_transition = false;
        end
    else
        TR = states(current_sid); % + noise
        time_in_state = time_in_state+1;
        [should_transition, next_sid] = transition(current_sid, states, ...
            time_in_state, opts);
        if should_transition
            transition_step = 1;
            transition_steps = transition_function(...
                states(current_sid), states(next_sid), state_transition_TRs, opts);
            in_transition = true;
            current_sid = next_sid;
            time_in_state = 1;
        end
    end
    TRs(i) = TR;
end

figure;
plot(TRs);
ylim([-0.1, 1.1])

for i = 1:length(oscillators)
    rep_cycle = (1 / oscillators(i)) / RepetitionTime;
    wave = oscillator('Sinusoid', 1, TRs_total / rep_cycle, 0, 0, TRs_total);
    TRs = TRs + wave' * oscillators_gain(i);
end

figure;
plot(TRs);


TRs_noise = awgn(TRs, SNR, 'measured');
figure;
plot(TRs_noise);



function steps = transition_function(state1, state2, n_steps, opts)
switch opts.TRANSITION_FUNC
    case 'line'
        steps = linspace(state1, state2, n_steps);
    case 'sigmoid'
        reversed = state1 > state2;
        s1 = min(state1, state2);
        s2 = max(state1, state2);

        X = linspace(-6, 6, n_steps);
        S = sigmoid(dlarray(X));
        steps = normalize(extractdata(S), 'range', [s1, s2]);
        if reversed
            steps = flip(steps);
        end
end
end

function [should_transition, next_sid] = transition( ...
    current_sid, states, time_in_state, opts)

    if time_in_state < opts.MINIMUM_STATE_STEPS
        should_transition = false;
        next_sid = current_sid;
    else
        switch opts.TRANSITION_TYPE
            case 'none'
                should_transition = false;
                next_sid = current_sid;
            case 'prob'
                r = rand(1,1,'double');
                should_transition = r < opts.PROB_TO_TRANSITION(current_sid);
                if should_transition
                    possible_sids = horzcat(1:current_sid-1, current_sid+1:length(states));
                    next_sid = randsample(possible_sids, 1);
                else
                    next_sid = current_sid;
                end
            case 'constant'
                should_transition = true;
                if current_sid == length(states)
                    next_sid = 1;
                else
                    next_sid = current_sid+1;
                end
        end
    end
end