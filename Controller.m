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

    methods ( Static )
        function obj = Controller()
            obj.didCollide = false;
            obj.time = 0;
        end

        function run(obj, robot, walls)
            obj.time = 0;

            if ~obj.didCollide

                [left, front, right] = robot.splice(robot.findDistanceCloud(obj.robot, walls));

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

                k = plot(robot.pos(1), robot.pos(2), 'ro');

                for wall_idx = 1:size(walls, 1)

                    wall = walls(wall_idx, :);

                    plot(wall([1 3]), wall([2 4]), 'b-')

                end

                % h = quiver(robot.pos(1),robot.pos(2),head(1),head(2), 'MaxHeadSize', 5);
                % axis([-10  10    -10  10], 'square')

                robot.pos = robot.pos + head;
                robot.theta = robot.theta + v*tan(steering_angle)/robot.length%robot.theta + robot.ackerman_noise(pi/90);
                head = [v*sin(robot.theta) v*cos(robot.theta)];
                % set(h,'xdata',robot.pos(1),'ydata',robot.pos(2),'udata',head(1),'vdata',head(2),'AutoScale','on', 'AutoScaleFactor', 10)
                % set(k,'xdata',robot.pos(1),'ydata',robot.pos(2))

                obj.didCollide = obj.check_collisions(robot, head, walls);
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
