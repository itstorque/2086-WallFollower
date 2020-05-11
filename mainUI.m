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

        running;
        paused;
        configureModeActive;
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
                app.sg = setupUI;
                app.sg.setParentUI(app);
                app.sg.setComponents(app.objs, app.sNode, app.gNode, app.wallCount);
                app.configureModeActive = true;
                app.pause();
            end
            % This should reset the sim
        end

        % Button pushed function: RunButton
        function RunButtonPushed(app, event)

            if (app.running)
                app.pause();
            else
                app.run();
            end

        end

        % Button pushed function: ResetButton
        function ResetButtonPushed(app, event)
            app.reset();
        end

        % Changes arrangement of the app based on UIFigure width
        function updateAppLayout(app, event)
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

            app.tDelay = 0.5; % 0.05 sec.
            app.t = timer('Period', app.tDelay, 'ExecutionMode', 'fixedRate');
            app.t.TimerFcn = @(~, ~) app.loopFcn;

            app.clock = 0;

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
            stop(app.t);
            delete(app.t);
        end
    end

    % Functions for getting data/updating various displays on the UI
    methods (Access = public)

        function setXText(app,text)
            app.XLabel.Text = ['X: ', text];
        end


        function setYText(app,text)
            app.YLabel.Text = ['Y: ', text];
        end


        function setTimeText(app,text)
            app.TimeLabel.Text = ['Time: ', text, 's'];
        end


        function setThetaText(app,text)
            app.ThetaLabel.Text = ['Theta: ', text, ' rad'];
        end

        function run(app)
            % Do not delete:
            app.running = true;
            app.RunButton.BackgroundColor = [1 0.4608 0.4608];
            app.RunButton.Text = 'Pause';
            start(app.t);

            % Any other necessary run functionality goes here:

        end


        function pause(app)
            % Do not delete:
            app.running = false;
            app.RunButton.BackgroundColor = [0.5608 1 0.5608];
            app.RunButton.Text = 'Run';
            stop(app.t);
            % Any other necessary pause functionality goes here:

        end


        function reset(app)
            % Do not delete:
            cla(app.EnvAxes);
            app.pause();
            app.clock = 0;
            app.setTimeText(num2str(round(app.clock)));
            app.plotObjs(); % FIELDOBJ PLOTTING FUNCTIONS GO HERE
            app.plotSNode(); % Keep this
            app.plotGNode();
            app.setupController();
            app.robot.draw();
            app.path.draw();

            % Any other necessary reset functionality goes here:

        end


        function loopFcn(app, ~, ~)
            % Whatever we need to loop while running = true goes here
            cla(app.EnvAxes);
            app.plotObjs(); % FIELDOBJ PLOTTING FUNCTIONS GO HERE
            app.plotSNode(); % Keep this
            app.plotGNode();

            app.robot.draw();
            app.path.draw();

            app.clock = app.clock + get(app.t, 'Period');

            app.setTimeText(num2str(round(app.clock)));
            app.setThetaText(num2str(round(app.robot.theta, 3)));
            [app.robot,app.path] = app.controller.runAlg(app.robot, app.wallFieldObjs, app.path,app.wallCount);
        end

        function setComponents(app, newList, newSNode, newGNode, newWallCount)
            % This function is called whenever a new environment is pushed
            % to the main UI from the environment configuration menu
            app.objs = newList;
            app.sNode = newSNode;
            app.gNode = newGNode;
            app.wallCount = newWallCount;
            app.generateFieldObjs();
        end

        function setupController(app)
            app.start_pos = cell2mat(app.sNode);
            app.end_pos   = cell2mat(app.gNode);
            if (size(app.start_pos) == [0 0] | size(app.end_pos) == [0 0])
              'configure the environment'
            else
                v = app.end_pos - app.start_pos;
                app.robot = BoxBot(app.start_pos', angle(v(1)+1i*v(2)), 1, [1 1], app);
                app.path = Path(app.robot.pos,app);
                app.controller = Controller;

                app.robot.app = app;
                app.robot.draw();
                app.path.app = app;
                app.path.draw();
            end
        end


        function plotObjs(app)
            hold(app.EnvAxes, 'on');
            [~, objsLen] = size(app.objs);
            for i = 1:objsLen
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


        function generateFieldObjs(app)
            % Generate wall fieldObjects
            [~, objsLen] = size(app.objs);
            indx = 1;
            for i = 1:objsLen
                thisObj = app.objs{1, i};
                [~, thisLen] = size(thisObj);
                for j = 1:thisLen - 1
                    p1 = thisObj(:, j);
                    p2 = thisObj(:, j + 1);
                    app.wallFieldObjs{1, indx} = Wall(p1(1), p1(2), p2(1), p2(2),app);
                    indx = indx + 1;
                end
            end
            % Put the robot at sNode
        end
    end
end
