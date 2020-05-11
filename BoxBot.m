classdef BoxBot < Robot
    properties
        leftStart = 30;
        leftEnd = 150;
        rightStart = 210;
        rightEnd = 330;
        centerStart = 330;
        centerEnd = 30;
        arrow;
        arrowScale = 5;
        size = [1, 1];
    end

    methods
        function obj = BoxBot(pos,theta,vel,size,app)
            obj = obj@Robot(pos,theta,vel,1,app);
            obj.size = size;
        end

        function obj = draw(obj)
            hold(obj.app.EnvAxes, 'on')
            rhat = [cos(obj.theta),sin(obj.theta)];
            xs = zeros(1,5);
            ys = zeros(1,5);
            phi = -obj.theta*180/pi;
            for i = 1:4
                ri = obj.pos + obj.size.*[cos((phi+45+i*90)*pi/180),sin((phi+45+i*90)*pi/180)];
                xs(i) = ri(1);
                ys(i) = ri(2);
            end
            xs(5) = xs(1);
            ys(5) = ys(1);
            obj.internalFigure = plot(obj.app.EnvAxes,xs,ys,'r-');
            head = obj.pos + obj.arrowScale*obj.velocity*rhat;
            %obj.arrow = arrow(obj.pos,head,'Type','line');
            hold(obj.app.EnvAxes, 'off');
        end

        function [left, center, right] = splice(obj, walls)
            distances = obj.findDistanceCloud(walls);
            len = numel(distances);

            center = ([distances(round(len*obj.centerStart/360):end) distances(1:round(len*obj.centerEnd/360)) ]);
            left = (distances(round(len*obj.leftStart/360):round(len*obj.leftEnd/360)));
            right = (distances(round(len*obj.rightStart/360):round(len*obj.rightEnd/360)));
        end
    end
end
