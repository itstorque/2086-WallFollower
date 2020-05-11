classdef Controller

    % This class is responsible for simulating the physics of the robot driving,
    % namely the Ackerman steering geometry. It also contains the code used for
    % PID algorithm and the preprocessing required.

    properties
        robot
        walls
        time
        didCollide
    end

    methods
        function obj = Controller()
            obj.didCollide = false;
            obj.time = 0;
        end

        function [robot,path] = runAlg(obj, robot, walls, path, wallCount, plotBot)
            % This method is called every timestep and updates the steering angle
            % and the robots 3 degrees of freedom in the field.

            if ~obj.didCollide
                % Get the spliced LIDAR information from the BoxBot class
                [left, front, right] = robot.splice(walls);

                % Based on the side the robot is tracking, choose the LIDAR
                % cloud spliced that corresponds to that wall
                if (robot.side == 1)
                    track = left;
                else
                    track = right;
                end

                % Offset the desired position to be 1 coordinate away from the
                % wall, st. the robot ideally has 0 error moving along a straight
                % line away from the object.
                error = 1 - mean(mink(track, 10));

                front_dist = mean(mink(front, 10));

                if (front_dist < 2)
                    % account for some error when colliding perpendicular to a wall
                    % this also has its own tuning parameter KF.
                    error = error + robot.kfront*(2 - front_dist);
                end

                % make sure the angle aligns with the side the robot is following
                error = error*robot.side;

                v = robot.velocity;
                [steering_angle, error] = obj.PID(robot, error); % call PID

                robot.errors = [robot.errors error]; % save the error for dv and int components

                % calculate the change in the x, y and theta degrees of freedom
                % based on the Ackerman Goemetry, see paper for more details.
                head = [v*sin(robot.theta) v*cos(robot.theta)];
                robot.pos = robot.pos + head;

                robot.theta = robot.theta + v*tan(steering_angle)/robot.size(1);
                head = [v*sin(robot.theta) v*cos(robot.theta)];

                path = path.addPos(robot.pos); %update path

                % always false so we can get always gat a path even post a collision
                obj.didCollide = false;

            end

        end

        function [angle, error] = PID(obj, robot, error)

            % calculate the integral error over the past int_lookup errors
            error_int = sum(robot.errors(max(1,end-robot.int_lookup):end));

            % calculate the derrivative error over the past dv_lookup errors
            if (length(robot.errors) > 2)
              error_dv = sum(robot.errors(end) - robot.errors(max(1,end-robot.dv_lookup)))/10;
            else
              error_dv = 0;
            end

            % The linear error formula with parameter modifications
            error = robot.kp*error + robot.ki*error_int + robot.kd*error_dv;

            % we define the angle the robot moves at to be the same as the error,
            % since velocity is constant, the robot really has one degree of freedom.
            angle = error;

            % Max steering angle for the car, for more realistic physics
            if (abs(angle) > 0.25*pi)
              angle = 0.25*pi*sign(angle);
            end

        end

        function didCollide = check_collisions(obj, robot, head, walls)
            % this checks collisions with walls, and is supposed to update the
            % ~controller~.didCollide method, however, we decided to keep it
            % false all the time, so this method is not in use currently.

            for wall_idx = 1:size(walls, 1)

                wall = walls(wall_idx, :);

                v1 = [head(1)-robot.pos(1), head(2)-robot.pos(2)];
                v2 = [wall(3)-wall(1), wall(4)-wall(2)];

                cross_prod = cross([v1, 0], [v2, 0]);

                if (cross_prod(3) ~= 0)

                    dp = wall(1:2)-robot.pos;

                    lambda1 = cross([dp, 0], [v2, 0]) / cross_prod;
                    lambda2 = cross([dp, 0], [v1, 0]) / cross_prod;

                    collide = all([lambda1 >= 0, lambda1 <= 1, lambda2 >= 0, lambda2 <= 1]);

                end

            end

            if collide == true
                'COLLISION DETECTED'
                obj.didCollide = true;
            end

        end

    end
end
