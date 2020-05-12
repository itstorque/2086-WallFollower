%An early implmentation of robot, drawing itself only as a point
classdef PointBot < Robot
    properties

    end

    methods
        %Constructor, simply calls superclass constructor
        function obj = PointBot(pos,theta,vel,app)
            obj = obj@Robot(pos,theta,vel,1,app);
        end

        function obj = draw(obj) %Plots a point in the apropriate location
            hold(obj.app.EnvAxes, 'on')
            obj.internalFigure = plot(obj.pos(1),obj.pos(2),'r.o');
            hold(obj.app.EnvAxes, 'off')
        end

        %Basic splice, taking the average value in the three sectors (i.e.
        %returning three scalars instead of three vectors)
        function [left, center, right] = splice(distances)
            center = mean([distances(1:30) distances(331:360)]);
            left = mean(distances(31:150));
            right = mean(distances(211:330));
        end
    end
end
