classdef Wall < FieldObject

    properties
        %Instance properties of each wall.
        point1
        point2
        x1
        x2
        y1
        y2
    end

    methods
        %Constructor given two points and the app
        function obj = Wall(x1,y1,x2,y2,app)
            obj = obj@FieldObject(app);
            obj.pos = 0.5*[(x1+x2),(y1+y2)];
            %Saves points as vector and individual coordiantes for
            %convenience
            obj.point1 = [x1,y1];
            obj.point2 = [x2,y2];
            obj.x1 = x1;
            obj.x2 = x2;
            obj.y1 = y1;
            obj.y2 = y2;
        end

        %Draws the wall in the right figure by plotting a line segment
        function obj = draw(obj)
            hold(obj.app.EnvAxes, 'on')
            obj.internalFigure = plot([obj.x1 obj.x2],[obj.y1 obj.y2],'b-');
            hold(obj.app.EnvAxes, 'off')
        end
    end
end
