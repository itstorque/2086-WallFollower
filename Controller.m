classdef (Abstract) Controller
    
    properties
        robot
        walls
        time
        didCollide
    end
    
    methods (Abstract)
        canDrive = canDrive(obj);
        path = generatePath(obj);
        pF = algorithim(obj, robot);
        DeltaTheta = plant(obj,pF);
    end
    
    methods
        function obj = Controller()
            obj.didCollide = false;
            obj.time = 0;
        end
        
        function [robot, walls, path, didCollide, figure, obj] = run(obj, robot, wall, time, doDraw)
            robot = obj.robot;
            walls = obj.walls;
            didCollide = obj.didCollide;
            obj.time = 0;
            
            if ~didCollide

                walls = [[2.5,7.5, 7.5,2.5];];

                coords = [0, 0, pi/4];%[x, y, theta]
                v = 0.1;
                head = [v*sin(robot.theta) v*cos(robot.theta)];

%                 k = plot(robot.pos(1), robot.pos(2), 'ro');
%                 hold on

%                 for wall_idx = 1:size(walls, 1)
% 
%                     wall = walls(wall_idx, :);
% 
%                     plot(wall([1 3]), wall([2 4]), 'b-')
% 
%                 end

%                 h = quiver(robot.pos(1),robot.pos(2),head(1),head(2), 'MaxHeadSize', 5);
%                 axis([-10  10    -10  10], 'square')
                
                robot.pos = robot.pos + head;
                robot.theta = robot.theta + robot.ackerman_noise(pi/90);
                head = [v*sin(robot.theta) v*cos(robot.theta)];
%                 set(h,'xdata',robot.pos(1),'ydata',robot.pos(2),'udata',head(1),'vdata',head(2),'AutoScale','on', 'AutoScaleFactor', 10)
%                 set(k,'xdata',robot.pos(1),'ydata',robot.pos(2))
%                 pause(0.1)
            
            end

        end
        
        function [robot, walls, path, didCollide, figure, obj] = check_collisions(obj, robot, head, walls)
            
            walls = obj.walls;

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