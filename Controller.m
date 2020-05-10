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

        function runAlg(obj, robot, walls, wallCount)

            if ~obj.didCollide

                cloud = robot.findDistanceCloud(walls, wallCount);

                [left, front, right] = robot.splice(cloud);

                if (robot.side == -1)
                    track = left;
                else
                    track = right;
                end

                error = average(mink(track, 10));

                error = error + robot.kfront*mink(front, 10);

                error = error*robot.side;

                v = 0.1;
                steering_angle = obj.PID(robot, error);

                head = [v*sin(robot.theta) v*cos(robot.theta)];

                robot.pos = robot.pos + head
                robot.theta = robot.theta + v*tan(steering_angle)/robot.length;
                head = [v*sin(robot.theta) v*cos(robot.theta)];

                obj.didCollide = false;
                pause(0.1)

            end

        end

        function angle = PID(obj, robot, error)

            error_int = sum(robot.errors(end-robot.int_lookup:end));

            error_dv = sum(robot.errors(end) - robot.errors(end-robot.dv_lookup));

            obj.errors = [robot.errors error];

            angle = kp*error + ki*error_int + kd*error_dv;

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
