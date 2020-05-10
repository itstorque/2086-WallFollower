classdef Path < FieldObject
 
    properties
        positions;
    end
    
    methods
        function obj = Path(pos,app)
            obj = obj@FieldObject(app);
            obj.positions = [pos];
        end
        
        function obj = addPos(obj,pos)
            a = obj.positions;
            obj.positions = [a; pos];
        end
        
        function obj = drawInit(obj)
            hold(obj.app.EnvAxes, 'on');
            obj.internalFigure = plot(obj.app.EnvAxes,obj.positions(:,1),obj.positions(:,2),"g","LineWidth",1.3);
            hold(obj.app.EnvAxes, 'off');
        end
        
        function obj = drawUpdate(obj)
            hold(obj.app.EnvAxes, 'on');
            set(obj.internalFigure,'xdata',obj.positions(:,1),'ydata',obj.positions(:,2))
            hold(obj.app.EnvAxes, 'off');
        end
        
    end
end

