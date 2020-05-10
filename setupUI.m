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
        wallCount = 0;
        currentObj = {};
        currentObjLen = 0;
        objs = {};
        objsLen = 0;
        sNode = {};
        gNode = {};
        
        placeMode = 1;
        axesScale = 10;
        changesMade = false;
        parentUI;
    end
    
    methods (Access = private)
        
        function plotCurrentObj(app)
            if app.currentObjLen > 0
                currentObjPlotArray = cell2mat(app.currentObj);
                plot(app.EnvAxes, currentObjPlotArray(1,:), currentObjPlotArray(2,:), 'ro-', 'LineWidth', 2);
            end
        end
        
        function plotObjs(app)
            hold(app.EnvAxes, 'on');
            for i = 1:app.objsLen
                thisObjPlotArray = app.objs{1, i};
                plot(app.EnvAxes, thisObjPlotArray(1,:), thisObjPlotArray(2,:), 'b-', 'LineWidth', 2);
            end
            hold(app.EnvAxes, 'off');
        end
        
        function plotSNode(app)
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
            app.parentUI = parent;
        end 
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Value changed function: WallButton
        function WallButtonValueChanged(app, event)
            value = app.WallButton.Value;
            if (value)
                app.StartingNodeButton.Value = 0;
                app.GoalNodeButton.Value = 0;
                app.placeMode = 1;
            end
        end

        % Value changed function: StartingNodeButton
        function StartingNodeButtonValueChanged(app, event)
            value = app.StartingNodeButton.Value;
            if (value)
                app.WallButton.Value = 0;
                app.GoalNodeButton.Value = 0;
                app.placeMode = 2;
            end
        end

        % Value changed function: GoalNodeButton
        function GoalNodeButtonValueChanged(app, event)
            value = app.GoalNodeButton.Value;
            if (value)
                app.WallButton.Value = 0;
                app.StartingNodeButton.Value = 0;
                app.placeMode = 3;
            end
        end

        % Button pushed function: FinishObstacleButton
        function FinishObstacleButtonPushed(app, event)
            if app.currentObjLen > 1 
                app.changesMade = true;
                app.objsLen = app.objsLen + 1;
                app.objs{1, app.objsLen} = cell2mat(app.currentObj);
                app.currentObjLen = 0;
                app.currentObj = {};
                app.EnvAxes.cla();
                app.plotObjs();
                app.plotSNode();
                app.plotGNode();
                app.Objects0Label.Text = append('Objects: ',num2str(app.objsLen));
            elseif app.currentObjLen > 0
                app.currentObjLen = 0;
                app.currentObj = {};
                app.EnvAxes.cla();
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
            app.wallCount = 0;
            app.currentObj = {};
            app.currentObjLen = 0;
            app.objs = {};
            app.objsLen = 0;
            app.sNode = {};
            app.gNode = {};
            app.wallCount = 0;
            app.Walls0Label.Text = append('Walls: ',num2str(app.wallCount));
            app.Objects0Label.Text = append('Objects: ',num2str(app.objsLen));
        end

        % Button pushed function: PushButton
        function PushButtonPushed(app, event)
            % Do whatever you need to in order to push
            if app.changesMade
                app.parentUI.setComponents(app.objs, app.sNode, app.wallCount);
                app.parentUI.reset();
            end
            app.delete();
        end

        % Window button down function: UIFigure
        function UIFigureWindowButtonDown(app, event)
            mousePos = get(app.EnvAxes,'CurrentPoint');
            mousePos = mousePos(1, 1:2)';
            
            if mousePos >= 0 & mousePos <= 10
                if app.placeMode == 1 % Wall/obj place mode
                    if app.currentObjLen > 0
                        app.wallCount = app.wallCount + 1;
                        for i = 1:app.currentObjLen
                            thisPoint = cell2mat(app.currentObj);
                            thisPoint = thisPoint(:,i);
                            if sqrt(sum((mousePos - thisPoint).^2)) < app.axesScale * 0.01
                                mousePos = thisPoint;
                                break
                            end
                        end
                    end
                
                    app.currentObjLen = app.currentObjLen + 1;
                    app.currentObj{1, app.currentObjLen} = mousePos;
                elseif app.placeMode == 2
                    app.sNode{1, 1} = mousePos; % Starting Node place mode
                    app.changesMade = true;
                elseif app.placeMode == 3
                    app.gNode{1, 1} = mousePos; % Goal Node place mode
                end
                
                app.EnvAxes.cla();
                app.plotCurrentObj();
                app.plotObjs();
                app.plotSNode();
                app.plotGNode();
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
            app.GoalNodeButton.Text = 'Goal Node';
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
        
        
        function setComponents(app, newList, newSNode, newWallCount)
            app.objs = newList;
            app.sNode = newSNode;
            app.wallCount = newWallCount;
            [~, app.objsLen] = size(app.objs);
            app.plotObjs();
            app.plotSNode();
            app.Walls0Label.Text = append('Walls: ',num2str(app.wallCount));
            app.Objects0Label.Text = append('Objects: ',num2str(app.objsLen));
        end
    end
end
