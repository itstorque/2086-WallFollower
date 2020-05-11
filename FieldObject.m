%The generalized field object method. Every element on the field - robots,
%obstacles, even the trajectory of the robot will implement this.
%Note the subclass of Heterogeneous - this let's us have heterogenous
% matrices of FieldObjects
classdef FieldObject < matlab.mixin.Heterogeneous

    properties
        pos; %The position of this field object
        internalFigure; %The figure object this field object uses to draw itself
        app; %A copy of the pointer for the app this field object is being drawn in
    end

    methods
        %Basic constructor
        function obj = FieldObject(app)
            obj.app = app;
        end
    end

    methods (Abstract)
        obj = draw(obj); %The abstract method every FeildObject will implement to draw itself
    end
end
