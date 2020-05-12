classdef mainUI < matlab.apps.AppBase

% Notes:

% - Creating an instance of the UI (g = mainUI) immedeately opens and runs
% the window

% - When specifying internalFigure in the FieldObject class, declare it as
% g.EnvAxes. Use hold(g.EnvAxes, 'on')/hold(g.EnvAxes, 'off') instead of hold
% on/off

% - The various interface functions are located at the bottom of the class


    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                    matlab.ui.Figure
        GridLayout                  matlab.ui.container.GridLayout
        LeftPanel                   matlab.ui.container.Panel
        RunButton                   matlab.ui.control.Button
        ConfigureEnvironmentButton  matlab.ui.control.Button
        Panel                       matlab.ui.container.Panel
        InformationLabel            matlab.ui.control.Label
        XLabel                      matlab.ui.control.Label
        YLabel                      matlab.ui.control.Label
        ThetaLabel                  matlab.ui.control.Label
        TimeLabel                   matlab.ui.control.Label
        ResetButton                 matlab.ui.control.Button
        RightPanel                  matlab.ui.container.Panel
        EnvAxes                     matlab.ui.control.UIAxes

        % Booleans for the main UI's various functionality modes 
        running;
        paused;
        configureModeActive;
        
        % Clock, child UI, and fieldObjects to be used throughout the program
        sg;
        tDelay;
        t;
        clock;
        objs;
        sNode;
        gNode;
        wallCount;
        wallFieldObjs;
        robot;
        path;
        axesScale = 10;

        % Controller params and definition
        start_pos;
        end_pos;
        controller;
    end

    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Value changed function: ConfigureEnvironmentButton
        function ConfigureEnvironmentButtonPushed(app, event)
            if (~app.configureModeActive)
                % What to do when the Configure Environment Button is pressed
                app.sg = setupUI; % Create setupUI instance
                app.sg.setParentUI(app);
                app.sg.setComponents(app.objs, app.sNode, app.gNode, app.wallCount); % Pass the current state of the environment to setupUI
                app.configureModeActive = true;
                app.pause();
            end
        end

        % Button pushed function: RunButton
        function RunButtonPushed(app, event)
            % What to do when the Run button is pressed
            if (app.running)
                app.pause();
            else
                app.run();
            end
        end

        % Button pushed function: ResetButton
        function ResetButtonPushed(app, event)
            % What to do when the Reset button is pressed
            app.reset();
        end

        % Changes arrangement of the app based on UIFigure width
        function updateAppLayout(app, event)
            % Controls how the UI layout changes when it is resized
            currentFigureWidth = app.UIFigure.Position(3);
            if(currentFigureWidth <= app.onePanelWidth)
                % Change to a 2x1 grid
                app.GridLayout.RowHeight = {488, 488};
                app.GridLayout.ColumnWidth = {'1x'};
                app.RightPanel.Layout.Row = 2;
                app.RightPanel.Layout.Column = 1;
            else
                % Change to a 1x2 grid
                app.GridLayout.RowHeight = {'1x'};
                app.GridLayout.ColumnWidth = {204, '1x'};
                app.RightPanel.Layout.Row = 1;
                app.RightPanel.Layout.Column = 2;
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.Position = [100 100 699 488];
            app.UIFigure.Name = 'UI Figure';
            app.UIFigure.Resize = 'off';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {204, '1x'};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.Scrollable = 'on';

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;

            % Create RunButton
            app.RunButton = uibutton(app.LeftPanel, 'push');
            app.RunButton.ButtonPushedFcn = createCallbackFcn(app, @RunButtonPushed, true);
            app.RunButton.BackgroundColor = [0.5608 1 0.5608];
            app.RunButton.FontSize = 20;
            app.RunButton.Position = [16 16 79 74];
            app.RunButton.Text = 'Run';

            % Create ConfigureEnvironmentButton
            app.ConfigureEnvironmentButton = uibutton(app.LeftPanel, 'push');
            app.ConfigureEnvironmentButton.ButtonPushedFcn = createCallbackFcn(app, @ConfigureEnvironmentButtonPushed, true);
            app.ConfigureEnvironmentButton.Text = 'Configure Environment';
            app.ConfigureEnvironmentButton.BackgroundColor = [0.902 0.902 0.902];
            app.ConfigureEnvironmentButton.Position = [16 102 172 29];

            % Create Panel
            app.Panel = uipanel(app.LeftPanel);
            app.Panel.Position = [16 152 172 310];

            % Create InformationLabel
            app.InformationLabel = uilabel(app.Panel);
            app.InformationLabel.FontSize = 18;
            app.InformationLabel.FontWeight = 'bold';
            app.InformationLabel.Position = [15 263 127 33];
            app.InformationLabel.Text = 'Information';

            % Create XLabel
            app.XLabel = uilabel(app.Panel);
            app.XLabel.FontSize = 16;
            app.XLabel.Position = [15 223 141 33];
            app.XLabel.Text = 'X:';

            % Create YLabel
            app.YLabel = uilabel(app.Panel);
            app.YLabel.FontSize = 16;
            app.YLabel.Position = [15 191 141 33];
            app.YLabel.Text = 'Y:';

            % Create ThetaLabel
            app.ThetaLabel = uilabel(app.Panel);
            app.ThetaLabel.FontSize = 16;
            app.ThetaLabel.Position = [15 159 141 33];
            app.ThetaLabel.Text = 'Theta: 0 rad';

            % Create TimeLabel
            app.TimeLabel = uilabel(app.Panel);
            app.TimeLabel.FontSize = 16;
            app.TimeLabel.Position = [15 127 141 33];
            app.TimeLabel.Text = 'Time: 0s';

            % Create KP editor
            kplbl = uilabel(app.Panel);
            kplbl.FontSize = 16;
            kplbl.Position = [15 95 40 33];
            kplbl.Text = 'KP:';
            kptxt = uieditfield(app.Panel, 'Position', [60 97 100 30]);%'ValueChangedFcn', @(txt,event) app.changeConstant(app.robot.kp, txt)
            kptxt.ValueChangedFcn = createCallbackFcn(app, @(app, value) changeConstant(app, value, 'kp'), true);
            kptxt.Value = '0.8';

            % Create KI editor
            kplbl = uilabel(app.Panel);
            kplbl.FontSize = 16;
            kplbl.Position = [15 63 40 33];
            kplbl.Text = 'KI:';
            kptxt = uieditfield(app.Panel, 'Position', [60 66 100 30]);%'ValueChangedFcn', @(txt,event) app.changeConstant(app.robot.kp, txt)
            kptxt.ValueChangedFcn = createCallbackFcn(app, @(app, value) changeConstant(app, value, 'ki'), true);
            kptxt.Value = '0.001';

            % Create KD editor
            kplbl = uilabel(app.Panel);
            kplbl.FontSize = 16;
            kplbl.Position = [15 31 40 33];
            kplbl.Text = 'KD:';
            kptxt = uieditfield(app.Panel, 'Position', [60 35 100 30]);%'ValueChangedFcn', @(txt,event) app.changeConstant(app.robot.kp, txt)
            kptxt.ValueChangedFcn = createCallbackFcn(app, @(app, value) changeConstant(app, value, 'kd'), true);
            kptxt.Value = '0.2';

            % Create KFront editor
            kplbl = uilabel(app.Panel);
            kplbl.FontSize = 16;
            kplbl.Position = [15 0 40 33];
            kplbl.Text = 'KF:';
            kptxt = uieditfield(app.Panel, 'Position', [60 2 100 30]);%'ValueChangedFcn', @(txt,event) app.changeConstant(app.robot.kp, txt)
            kptxt.ValueChangedFcn = createCallbackFcn(app, @(app, value) changeConstant(app, value, 'kfront'), true);
            kptxt.Value = '0.5';

            % Create ResetButton
            app.ResetButton = uibutton(app.LeftPanel, 'push');
            app.ResetButton.ButtonPushedFcn = createCallbackFcn(app, @ResetButtonPushed, true);
            app.ResetButton.BackgroundColor = [1 1 0.5608];
            app.ResetButton.FontSize = 20;
            app.ResetButton.Position = [109 16 79 74];
            app.ResetButton.Text = 'Reset';

            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;

            % Create EnvAxes
            app.EnvAxes = uiaxes(app.RightPanel);
            title(app.EnvAxes, '')
            xlabel(app.EnvAxes, 'X')
            ylabel(app.EnvAxes, 'Y')
            app.EnvAxes.PlotBoxAspectRatio = [1 1 1];
            app.EnvAxes.XLim = [0 app.axesScale];
            app.EnvAxes.YLim = [0 app.axesScale];
            app.EnvAxes.Box = 'on';
            app.EnvAxes.XGrid = 'on';
            app.EnvAxes.YGrid = 'on';
            app.EnvAxes.Position = [12 7 473 475];
            app.EnvAxes.Toolbar.Visible = 'off';
            app.EnvAxes.Visible = 'on';
            disableDefaultInteractivity(app.EnvAxes);

            % Initialize timer object, which controls the UI's background loop
            app.tDelay = 0.5; % 0.05 sec.
            app.t = timer('Period', app.tDelay, 'ExecutionMode', 'fixedRate');
            app.t.TimerFcn = @(~, ~) app.loopFcn;

            % Initialize clock, which tracks time elapsed since the beginning of the current run
            app.clock = 0;

            % Initialize environment component lists as empty
            app.objs = {};
            app.sNode = {};
            app.gNode = {};
            app.wallCount = 0;

            app.wallFieldObjs = {};
            vInit = 0; % Feel free to change
            dThetaInit = 1; % Feel free to change
            % app.robot; % Init robot
            app.setupController();

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
            
            % Initialize UI/loop state
            app.running = false;
            app.paused = false;
            app.configureModeActive = false;
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = mainUI

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
            delete(app.sg)
            % Stop and delete the timer when the app is deleted (neglecting to do so will result in unpleasant behavior)
            stop(app.t);
            delete(app.t);
        end
    end

    % Functions for getting data/updating various displays on the UI
    methods (Access = public)

        function setXText(app,text)
            % Update the text that displays the robot's x-coordinate
            app.XLabel.Text = ['X: ', text];
        end


        function setYText(app,text)
            % Update the text that displays the robot's y-coordinate
            app.YLabel.Text = ['Y: ', text];
        end


        function setTimeText(app,text)
            % Update the text that displays the current time elapsed
            app.TimeLabel.Text = ['Time: ', text, 's'];
        end


        function setThetaText(app,text)
            % Update the text that displays the angle that the robot is facing
            app.ThetaLabel.Text = ['Theta: ', text, ' rad'];
        end

        function run(app)
            % What to do when the Run button is pressed
            app.running = true; % Update UI state
            app.RunButton.BackgroundColor = [1 0.4608 0.4608]; % Change the color/text of the run button
            app.RunButton.Text = 'Pause';
            start(app.t); % Start the timer
        end


        function pause(app)
            % What to do when the Pause button is pressed
            app.running = false; % Update UI state
            app.RunButton.BackgroundColor = [0.5608 1 0.5608]; % Change the color/text of the pause button
            app.RunButton.Text = 'Run';
            stop(app.t); % Stop the timer
        end


        function reset(app)
            % What to do when the Reset button is pressed
            cla(app.EnvAxes); % Clear the axes
            app.pause(); % Pause the simulation
            app.clock = 0; % Reset clock
            app.setTimeText(num2str(round(app.clock)));
            app.plotObjs(); % Plot walls
            app.plotSNode(); % Plot starting node
            app.plotGNode(); % Plot goal node

            % Resetting configurations manually
            app.start_pos = cell2mat(app.sNode);
            app.end_pos   = cell2mat(app.gNode);
            v = app.end_pos - app.start_pos;
            app.robot.pos = app.start_pos';
            app.robot.theta = angle(v(2)+1i*v(1));
            app.path = Path(app.robot.pos,app);

            app.robot.draw();
            app.path.draw();

            % Any other necessary reset functionality goes here:
        end


        function loopFcn(app, ~, ~)
            % Whatever we need to loop while running = true goes here
            cla(app.EnvAxes);
            app.plotObjs(); % Plot walls
            app.plotSNode(); % Plot starting node
            app.plotGNode(); % Plot goal node

            % Redraw robot and path
            app.robot.draw();
            app.path.draw();

            % Add the time elapsed since the last clock update to clock
            app.clock = app.clock + get(app.t, 'Period');

            % Update data displays
            app.setTimeText(num2str(round(app.clock)));
            app.setThetaText(num2str(round(app.robot.theta, 3)));
            [app.robot,app.path] = app.controller.runAlg(app.robot, app.wallFieldObjs, app.path,app.wallCount); % Run the robot controller
        end

        function setComponents(app, newList, newSNode, newGNode, newWallCount)
            % This function is called whenever a new environment is pushed
            % to the main UI from the environment configuration menu
            
            % Update current environment state
            app.objs = newList;
            app.sNode = newSNode;
            app.gNode = newGNode;
            app.wallCount = newWallCount;
            app.generateFieldObjs(); % Creates new wall fieldObjects based on the new environment, and updates sNode and gNode as needed
        end

        function setupController(app)
            app.start_pos = cell2mat(app.sNode);
            app.end_pos   = cell2mat(app.gNode);
            if (size(app.start_pos) == [0 0] | size(app.end_pos) == [0 0])
                v = 0;
                % Get robot and path
                app.robot = BoxBot([-10 -10], 0, 1, [0.5, 0.5], app);
                app.path = Path(app.robot.pos,app);
                app.controller = Controller;

                % Send the main UI to the fieldObjects so they can be plotted on the UI's axes
                app.robot.app = app;
                app.robot.draw();
                app.path.app = app;
                app.path.draw();
            else
                v = app.end_pos - app.start_pos;
                % Get robot and path
                app.robot = BoxBot(app.start_pos', angle(v(2)+1i*v(1)), 1, [0.5, 0.5], app);
                app.path = Path(app.robot.pos,app);
                app.controller = Controller;

                % Send the main UI to the fieldObjects so they can be plotted on the UI's axes
                app.robot.app = app;
                app.robot.draw();
                app.path.app = app;
                app.path.draw();
            end
        end


        function plotObjs(app)
            % Plot each object in objs
            hold(app.EnvAxes, 'on');
            [~, objsLen] = size(app.objs);
            for i = 1:objsLen
                % Each object in app.objs is a 2 x K matrix of points, where the jth and (j+1)th elements are connected by a line (forming a wall)
                thisObjPlotArray = app.objs{1, i};
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


        function generateFieldObjs(app)
            % Generate wall fieldObjects
            [~, objsLen] = size(app.objs);
            indx = 1;
            for i = 1:objsLen
                thisObj = app.objs{1, i};
                [~, thisLen] = size(thisObj);
                for j = 1:thisLen - 1
                    % Each object in app.objs is a 2 x K matrix of points, where the jth and (j+1)th elements are connected by a line (forming a wall)
                    % This loop iterates through objs, taking one matrix, and generating a wall fieldObject for each of the connections detailed above
                    % (A matrix of K points creates K-1 field objects, since if the described object is a closed polygon, the starting point/ending point 
                    % appears both at the beginning and end of the matrix)
                    p1 = thisObj(:, j); 
                    p2 = thisObj(:, j + 1);
                    app.wallFieldObjs{1, indx} = Wall(p1(1), p1(2), p2(1), p2(2),app);
                    indx = indx + 1;
                end
            end
            % Put the robot at sNode
        end


        % Method for changing constants
        function changeConstant(app, value, constantName)
            evalstr = strcat('app.robot.', constantName, '=', value.Value, ';');
            eval(evalstr);

            app.robot
        end

    end
end
