function ana()

    data = csvread('20170202_165157.acc');

    time = data(:, 1);
    time = time - time(1);
    time = time / 1000;

    Y = data(:,3);
    Y_raw = Y;
    Y = smoothData(Y, 10);
    
    figure(1);
    title('Acceleration / Velocity / Distance');
    plot(time, Y);
    grid on;
    
    velocity = getVelocity(Y, time);
    
    displacement = getDisplacement(velocity, time);
    display(displacement(length(displacement)));
    
    %figure(2);
    %title('Velocity');
    hold on;
    plot(time, velocity);
    grid on;
    
    hold on;
    plot(time, displacement);
    grid on;
    
    %hold on;
    %plot(time, Y_raw, 'g');
    %grid on;
    
end

% Do a simple integration over the acceleration data to get the velocity.
function velocity = getVelocity(acc, time)
    % Error threshold which tells you how close to 0 the values have to be
    % for the velocity to actually be reset.
    dthreshold = 0.8;    % So it can be +/- d.
    cthreshold = 1; % The foot has to be on the ground for this time (in samples) for it to be considered step end.
    cbuff = 0;  % Increment this.
    vel_index = 2;
    velocity(1) = 0;
    for a=1:length(acc)-1
        % 1Use the average value for the height of the integration step.
        y1 = acc(a);
        y2 = acc(a+1);
        h = (y1 + y2) / 2;
        w = time(a+1) - time(a);
        delta_area = h * w;
        if (abs(h) <= dthreshold)
            % Reset the velocity to 0, since the foot has touched the
            % ground.
            cbuff = cbuff + 1;
            if(cbuff >= cthreshold)
                velocity(vel_index) = 0;
            else
                velocity(vel_index) = velocity(vel_index-1) + delta_area;
            end
        else
            cbuff = 0;
            velocity(vel_index) = velocity(vel_index-1) + delta_area;
        end
        vel_index = vel_index + 1;
    end
end

% Do a simple integration over the acceleration data to get the velocity.
function velocity = getDisplacement(acc, time)
    vel_index = 2;
    velocity(1) = 0;
    for a=1:length(acc)-1
        % 1Use the average value for the height of the integration step.
        y1 = abs(acc(a));
        y2 = abs(acc(a+1));
        h = (y1 + y2) / 2;
        w = time(a+1) - time(a);
        delta_area = h * w;
        velocity(vel_index) = velocity(vel_index-1) + delta_area;
        vel_index = vel_index + 1;
    end
end

% A sliding window filter to smooth data out.
function filteredData = smoothData(data, window)
    filterData(1:window) = 0;
    for a=window+1:length(data)
        filteredData(a) = mean(data(a-window:a));
    end
end