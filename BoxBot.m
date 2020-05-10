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
        size;
    end

    methods
        function obj = BoxBot(pos,theta,vel,size)
            obj = obj@Robot(pos,theta,vel,1);
            obj.size = size;
        end

        function obj = drawInit(obj)
            hold on
            rhat = [cos(obj.theta*pi/180),sin(obj.theta*pi/180)];
            xs = zeros(1,5);
            ys = zeros(1,5);
            for i = 1:4
                ri = obj.pos + obj.size*[cos((obj.theta+45+i*90)*pi/180),sin((obj.theta+45+i*90)*pi/180)];
                xs(i) = ri(1);
                ys(i) = ri(2);
            end
            xs(5) = xs(1);
            ys(5) = ys(1);
            obj.internalFigure = plot(xs,ys,'r.-');
            head = obj.pos + obj.arrowScale*obj.velocity*rhat;
            obj.arrow = arrow(obj.pos,head,'Type','line');
            hold off
            disp('Created internal bot figure');
        end

        function obj = drawUpdate(obj)
            xs = zeros(1,5);
            ys = zeros(1,5);
            for i = 1:4
                ri = obj.pos + obj.size*[cos((obj.theta+45+i*90)*pi/180),sin((obj.theta+45+i*90)*pi/180)];
                xs(i) = ri(1);
                ys(i) = ri(2);
            end
            xs(5) = xs(1);
            ys(5) = ys(1);
            set(obj.internalFigure,'xdata',xs,'ydata',ys)
            head = obj.pos + obj.arrowScale*obj.velocity*[cos(obj.theta*pi/180),sin(obj.theta*pi/180)];
            set(obj.arrow,'xdata',[],'ydata',[])
            obj.arrow = arrow(obj.pos,head,'Type','line');
        end

        function [left, center, right] = splice(obj,walls)
            distances = obj.findDistanceCloud(walls);
            len = numel(distances);
            
            center = mean([distances(1:round(len*obj.centerEnd/360)) distances(round(len*obj.centerStart/360):end)]);
            left = mean(distances(round(len*obj.leftStart/360):round(len*obj.leftEnd/360)));
            right = mean(distances(round(len*obj.rightStart/360):round(len*obj.rightEnd/360)));
            
        end
    end
end
