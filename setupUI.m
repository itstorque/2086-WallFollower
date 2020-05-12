classdef setupUI < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure              matlab.ui.Figure
        Panel                 matlab.ui.container.Panel
        WallButton            matlab.ui.control.StateButton
        StartingNodeButton    matlab.ui.control.StateButton
        GoalNodeButton        matlab.ui.control.StateButton
        FinishObstacleButton  matlab.ui.control.Button
        ClearButton           matlab.ui.control.Button
        PushButton            matlab.ui.control.Button
        Panel_3               matlab.ui.container.Panel
        Walls0Label           matlab.ui.control.Label
        Objects0Label         matlab.ui.control.Label
        Panel_2               matlab.ui.container.Panel
        EnvAxes               matlab.ui.control.UIAxes
    end


    properties (Access = private)
        % Initialize variables that track properties of various environment components
        wallCount = 0;
        currentObj = {};
        currentObjLen = 0;
        objs = {};
        objsLen = 0;
        sNode = {};
        gNode = {};

        % Initialize variables that describe the state of the setup UI 
        placeMode = 1;
        axesScale = 10;
        changesMade = false;
        parentUI;
    end

    methods (Access = private)

        function plotCurrentObj(app)
            % Each object is defined by a 2 x K matrix that stores that objects vertices
            % The ith and (i+1)th vertices within an object's defining matrix are connected 
            % by a line which denotes a wall
            if app.currentObjLen > 0
                currentObjPlotArray = cell2mat(app.currentObj);
                % Plot each object in currentObj, which stores the object currently being edited
                plot(app.EnvAxes, currentObjPlotArray(1,:), currentObjPlotArray(2,:), 'ro-', 'LineWidth', 2);
            end
        end

        function plotObjs(app)
            % Each object is defined by a 2 x K matrix that stores that objects vertices
            % The ith and (i+1)th vertices within an object's defining matrix are connected 
            % by a line which denotes a wall
            hold(app.EnvAxes, 'on');
            for i = 1:app.objsLen
                thisObjPlotArray = app.objs{1, i};
                % Plot each object in objs, which stores all previously completed objects
                plot(app.EnvAxes, thisObjPlotArray(1,:), thisObjPlotArray(2,:), 'b-', 'LineWidth', 2);
            end
            hold(app.EnvAxes, 'off');
        end

        function plotSNode(app)
            % Plot the starting node
            sz = size(app.sNode);
            r = app.axesScale*0.05;
            mr = r/1.5;
            if sz(2) > 0
                pos = cell2mat(app.sNode);
                hold(app.EnvAxes, 'on')
                plot(app.EnvAxes, pos(1), pos(2), 'r*', 'MarkerSize', 15, 'LineWidth', 2)
                rectangle(app.EnvAxes,'Position',[pos(1) - r, pos(2) - r, 2*r, 2*r], ...
                    'Curvature',[1, 1],'EdgeColor','b', 'LineWidth', 2)
                rectangle(app.EnvAxes,'Position',[pos(1) - mr, pos(2) - mr, 2*mr, 2*mr], ...
                    'Curvature',[1, 1],'EdgeColor','b', 'LineWidth', 2)
                hold(app.EnvAxes, 'off')
            end
        end

        function plotGNode(app)
            % Plot the goal node
            sz = size(app.gNode);
            r = app.axesScale*0.05;
            mr = r/1.5;
            if sz(2) > 0
                pos = cell2mat(app.gNode);
                hold(app.EnvAxes, 'on')
                plot(app.EnvAxes, pos(1), pos(2), 'r.', 'MarkerSize', 15, 'LineWidth', 2)
                rectangle(app.EnvAxes,'Position',[pos(1) - r, pos(2) - r, 2*r, 2*r], ...
                    'Curvature',[1, 1],'EdgeColor','k', 'LineWidth', 2)
                rectangle(app.EnvAxes,'Position',[pos(1) - mr, pos(2) - mr, 2*mr, 2*mr], ...
                    'Curvature',[1, 1],'EdgeColor','k', 'LineWidth', 2)
                hold(app.EnvAxes, 'off')
            end
        end
    end

    methods (Access = public)

        function setParentUI(app, parent)
            % Set this parent UI of this instance of setup UI, so that the push button can 
            % return the newly configured envirnoment when the user is done editing
            app.parentUI = parent;
        end
    end


    % Callbacks that handle component events
    methods (Access = private)

        % Value changed function: WallButton
        function WallButtonValueChanged(app, event)
            % What to do when the wall button is selected
            value = app.WallButton.Value;
            if (value)
                % The first two lines set the states of the other two buttons to false, since
                % the user can only place one type of object at a time
                app.StartingNodeButton.Value = 0;
                app.GoalNodeButton.Value = 0;
                app.placeMode = 1; % placeMode 1 = place wall vertices on mouse click
            end
        end

        % Value changed function: StartingNodeButton
        function StartingNodeButtonValueChanged(app, event)
            % What to do when the starting node button is selected
            value = app.StartingNodeButton.Value;
            if (value)
                % The first two lines set the states of the other two buttons to false, since
                % the user can only place one type of object at a time
                app.WallButton.Value = 0;
                app.GoalNodeButton.Value = 0;
                app.placeMode = 2; % placeMode 2 = place starting node on mouse click
            end
        end

        % Value changed function: GoalNodeButton
        function GoalNodeButtonValueChanged(app, event)
            % What to do when the goal node button is selected
            value = app.GoalNodeButton.Value;
            if (value)
                % The first two lines set the states of the other two buttons to false, since
                % the user can only place one type of object at a time
                app.WallButton.Value = 0;
                app.StartingNodeButton.Value = 0;
                app.placeMode = 3; % placeMode 3 = place goal node on mouse click
            end
        end

        % Button pushed function: FinishObstacleButton
        function FinishObstacleButtonPushed(app, event)
            % What to do when the finish obstacle button is pressed
            % Clicking this button finalizes the current object that the user is working on,
            % and pushes it into objs (the list of all completed objects). currentObj will 
            % then be reset to an empty state, so that the user can construct a new object
            if app.currentObjLen > 1
                app.changesMade = true; 
                app.objsLen = app.objsLen + 1; 
                app.objs{1, app.objsLen} = cell2mat(app.currentObj); % Add the current object to the list of completed objects
                app.currentObjLen = 0;
                app.currentObj = {}; % Clear currentObj
                app.EnvAxes.cla(); % Clear the axes so that the updated environment can be replotted
                % Replot all components
                app.plotObjs();
                app.plotSNode();
                app.plotGNode();
                app.Objects0Label.Text = append('Objects: ',num2str(app.objsLen)); % Update the current number of objects
            elseif app.currentObjLen > 0
                % This code can only be reached when currentObjLen = 1, i.e. when the current object is composed
                % of exactly one point. This object is meaningless, since it cannot form a wall (or take up any space
                % at all, for that matter), and therefore, instead of being added to the list of completed objects, the
                % current object is simply deleted.
                app.currentObjLen = 0;
                app.currentObj = {}; % Clear currentObj
                app.EnvAxes.cla(); % Clear the axes so that the updated environment can be replotted
                % Replot all components
                app.plotObjs();
                app.plotSNode();
                app.plotGNode();
            end
        end

        % Button pushed function: ClearButton
        function ClearButtonPushed(app, event)
            app.EnvAxes.cla();
            if app.objsLen > 0
                app.changesMade = true;
            end
            % Delete all current/completed objects and components
            app.wallCount = 0;
            app.currentObj = {};
            app.currentObjLen = 0;
            app.objs = {};
            app.objsLen = 0;
            app.sNode = {};
            app.gNode = {};
            app.wallCount = 0;
            % Update wall and object count displays to reflect the above changes
            app.Walls0Label.Text = append('Walls: ',num2str(app.wallCount));
            app.Objects0Label.Text = append('Objects: ',num2str(app.objsLen));
        end

        % Button pushed function: PushButton
        function PushButtonPushed(app, event)
            if app.changesMade
                % If changes are made to the environment, then the parent UI's (aka the main UI) environment 
                % is updated and the simulation in the parent UI reset. If not, then nothing happens, and 
                % the setup UI is closed below
                app.parentUI.setComponents(app.objs, app.sNode, app.gNode, app.wallCount); % Pass new component data to the parent UI
                app.parentUI.reset();
            end
            app.delete(); % Close the setup UI once the new changes are pushed to main
        end

        % Window button down function: UIFigure
        function UIFigureWindowButtonDown(app, event)
            % What to do when the left mouse button is pressed (mouse click event callback)
            mousePos = get(app.EnvAxes,'CurrentPoint'); % Get mouse position with respect to EnvAxes
            mousePos = mousePos(1, 1:2)'; % Consider only the x and y coordinates of the mouse press

            if mousePos >= 0 & mousePos <= 10
                if app.placeMode == 1 % Wall/obj place mode
                    if app.currentObjLen > 0
                        app.wallCount = app.wallCount + 1; % Walls need two points to be defined, therefore we only 
                        % update the number of walls if we aleady have at least one point in the current object
                        for i = 1:app.currentObjLen
                            % If there exist any vertices in the current object, we iterate through them
                            thisPoint = cell2mat(app.currentObj);
                            thisPoint = thisPoint(:,i);
                            if sqrt(sum((mousePos - thisPoint).^2)) < app.axesScale * 0.01
                                % For each point, determine if the mouse position at the moment of the click event
                                % was within R units of point i , where R =  0.01 * (the width of the EnvAxes)
                                mousePos = thisPoint; % If the above is true, we "snap" the new point to the position
                                % of point i by setting mousePos to the coordinates of point i (since the new point 
                                % that will be added to the current object will be placed at mousePos. 
                                
                                % The purpose of this check is to allow the user to easily create closed objects
                                break % Break the loop, since we found a point that the mousePos could "snap" to
                            end
                        end
                    end

                    app.currentObjLen = app.currentObjLen + 1; % Update the length of currentObj to reflect a new point being added
                    app.currentObj{1, app.currentObjLen} = mousePos; % Add a new point to currentObj, located at mousePos
                elseif app.placeMode == 2
                    app.sNode{1, 1} = mousePos; % Starting Node place mode
                    app.changesMade = true;
                elseif app.placeMode == 3
                    app.gNode{1, 1} = mousePos; % Goal Node place mode
                    app.changesMade = true;
                end

                app.EnvAxes.cla(); % Clear the axes so that the updated environment can be replotted
                % Replot all components
                app.plotCurrentObj();
                app.plotObjs();
                app.plotSNode();
                app.plotGNode();
                % Update wall and object count displays to reflect the above changes
                app.Walls0Label.Text = append('Walls: ',num2str(app.wallCount));
                app.Objects0Label.Text = append('Objects: ',num2str(app.objsLen));
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 643 479];
            app.UIFigure.Name = 'UI Figure';
            app.UIFigure.WindowButtonDownFcn = createCallbackFcn(app, @UIFigureWindowButtonDown, true);

            % Create Panel
            app.Panel = uipanel(app.UIFigure);
            app.Panel.Position = [1 1 154 479];

            % Create WallButton
            app.WallButton = uibutton(app.Panel, 'state');
            app.WallButton.ValueChangedFcn = createCallbackFcn(app, @WallButtonValueChanged, true);
            app.WallButton.Text = {'Wall'; ''};
            app.WallButton.BackgroundColor = [0.902 0.902 0.902];
            app.WallButton.Position = [15 433 127 30];
            app.WallButton.Value = true;

            % Create StartingNodeButton
            app.StartingNodeButton = uibutton(app.Panel, 'state');
            app.StartingNodeButton.ValueChangedFcn = createCallbackFcn(app, @StartingNodeButtonValueChanged, true);
            app.StartingNodeButton.Text = 'Starting Node';
            app.StartingNodeButton.BackgroundColor = [0.902 0.902 0.902];
            app.StartingNodeButton.Position = [15 388 127 30];

            % Create GoalNodeButton
            app.GoalNodeButton = uibutton(app.Panel, 'state');
            app.GoalNodeButton.ValueChangedFcn = createCallbackFcn(app, @GoalNodeButtonValueChanged, true);
            app.GoalNodeButton.Text = 'Initial Pose Node';
            app.GoalNodeButton.BackgroundColor = [0.902 0.902 0.902];
            app.GoalNodeButton.Position = [15 343 127 30];

            % Create FinishObstacleButton
            app.FinishObstacleButton = uibutton(app.Panel, 'push');
            app.FinishObstacleButton.ButtonPushedFcn = createCallbackFcn(app, @FinishObstacleButtonPushed, true);
            app.FinishObstacleButton.BackgroundColor = [0.902 0.902 0.902];
            app.FinishObstacleButton.Position = [15 298 127 30];
            app.FinishObstacleButton.Text = 'Finish Obstacle';

            % Create ClearButton
            app.ClearButton = uibutton(app.Panel, 'push');
            app.ClearButton.ButtonPushedFcn = createCallbackFcn(app, @ClearButtonPushed, true);
            app.ClearButton.BackgroundColor = [0.902 0.902 0.902];
            app.ClearButton.Position = [15 253 127 30];
            app.ClearButton.Text = 'Clear';

            % Create PushButton
            app.PushButton = uibutton(app.Panel, 'push');
            app.PushButton.ButtonPushedFcn = createCallbackFcn(app, @PushButtonPushed, true);
            app.PushButton.FontSize = 18;
            app.PushButton.Position = [14 13 127 127];
            app.PushButton.Text = 'Push';

            % Create Panel_3
            app.Panel_3 = uipanel(app.Panel);
            app.Panel_3.Position = [0 153 155 87];

            % Create Walls0Label
            app.Walls0Label = uilabel(app.Panel_3);
            app.Walls0Label.FontSize = 14;
            app.Walls0Label.FontWeight = 'bold';
            app.Walls0Label.Position = [15 41 127 45];
            app.Walls0Label.Text = 'Walls: 0';

            % Create Objects0Label
            app.Objects0Label = uilabel(app.Panel_3);
            app.Objects0Label.FontSize = 14;
            app.Objects0Label.FontWeight = 'bold';
            app.Objects0Label.Position = [15 13 127 29];
            app.Objects0Label.Text = {'Objects: 0'; ''};

            % Create Panel_2
            app.Panel_2 = uipanel(app.UIFigure);
            app.Panel_2.Position = [155 1 489 479];

            % Create EnvAxes
            app.EnvAxes = uiaxes(app.Panel_2);
            title(app.EnvAxes, '')
            xlabel(app.EnvAxes, 'X')
            ylabel(app.EnvAxes, 'Y')
            app.EnvAxes.PlotBoxAspectRatio = [1.0034965034965 1 1];
            app.EnvAxes.XLim = [0 app.axesScale];
            app.EnvAxes.YLim = [0 app.axesScale];
            app.EnvAxes.Box = 'on';
            app.EnvAxes.XGrid = 'on';
            app.EnvAxes.YGrid = 'on';
            app.EnvAxes.Position = [8 3 475 473];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = setupUI

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
            app.parentUI.configureModeActive = false;
        end

        function setComponents(app, newList, newSNode, newGNode, newWallCount)
            % This function is called by the parent UI when an instance of setup UI is created
            
            % Pass in the current state of the parent UI's environment
            app.objs = newList;
            app.sNode = newSNode;
            app.gNode = newGNode;
            % Update wall and object counts to reflect the above changes
            app.wallCount = newWallCount;
            [~, app.objsLen] = size(app.objs);
            % Plot the environment
            app.plotObjs();
            app.plotSNode();
            app.plotGNode();
            % Update wall and object count displays to reflect the above changes
            app.Walls0Label.Text = append('Walls: ',num2str(app.wallCount));
            app.Objects0Label.Text = append('Objects: ',num2str(app.objsLen));
        end
    end
end
