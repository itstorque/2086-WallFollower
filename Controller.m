classdef Controller

    properties
        robot
        walls
        time
        didCollide
    end

%     methods (Abstract)
%         canDrive = canDrive(obj);
%         path = generatePath(obj);
%         pF = algorithim(obj, robot);
%         DeltaTheta = plant(obj,pF);
%     end

    methods
        function obj = Controller()
            obj.didCollide = false;
            obj.time = 0;
        end

        function [robot,path] = runAlg(obj, robot, walls, path, wallCount, plotBot)

            if ~obj.didCollide
                [left, front, right] = robot.splice(walls);

                if (robot.side == -1)
                    track = left;
                else
                    track = right;
                end

                error = 1 - mean(mink(track, 10));

                % error = error + robot.kfront*mean(mink(front, 10));

                error = error*robot.side;

                v = robot.velocity;
                steering_angle = obj.PID(robot, error);

                head = [v*sin(robot.theta) v*cos(robot.theta)];

                robot.pos = robot.pos + head;
                path = path.addPos(robot.pos);
                robot.theta = robot.theta + v*tan(steering_angle)/robot.size(1);
                head = [v*sin(robot.theta) v*cos(robot.theta)];

                obj.didCollide = false;

            end

        end

        function angle = PID(obj, robot, error)

            error_int = sum(robot.errors(max(1,end-robot.int_lookup):end));

            if (length(robot.errors) > 2)
              error_dv = sum(robot.errors(end) - robot.errors(max(1,end-robot.dv_lookup)))/10;
            else
              error_dv = 0;
            end

            robot.errors = [robot.errors error];

            angle = robot.kp*error + robot.ki*error_int + robot.kd*error_dv;

            if (abs(angle) > 0.25*pi)
              angle = 0.25*pi*sign(angle);
            end

        end

        function didCollide = check_collisions(obj, robot, head, walls)

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
