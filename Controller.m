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
        
        function [robot, walls, didCollide, figure, obj] = run(obj, robot, wall, time, doDraw)
            robot = obj.robot;
            walls = obj.walls;
            didCollide = obj.didCollide;
            obj.time = 0;
        end
            
    end
end

