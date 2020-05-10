classdef Wall < FieldObject

    properties
        point1
        point2
        x1
        x2
        y1
        y2
    end

    methods
        function obj = Wall(x1,y1,x2,y2,app)
            obj = obj@FieldObject(app);
            obj.pos = 0.5*[(x1+x2),(y1+y2)];
            obj.point1 = [x1,y1];
            obj.point2 = [x2,y2];
            obj.x1 = x1;
            obj.x2 = x2;
            obj.y1 = y1;
            obj.y2 = y2;
        end

        function obj = drawInit(obj)
            hold(obj.app.EnvAxes, 'on')
            obj.internalFigure = plot([obj.x1 obj.x2],[obj.y1 obj.y2],'b-');
            hold(obj.app.EnvAxes, 'off')
            disp('Created internal wall figure');
        end

        function obj = drawUpdate(obj)
        end
    end
end
