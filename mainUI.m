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
        UIFigure                  matlab.ui.Figure
        GridLayout                matlab.ui.container.GridLayout
        LeftPanel                 matlab.ui.container.Panel
        RunButton                 matlab.ui.control.Button
        ConfugureObstaclesButton  matlab.ui.control.StateButton
        Panel                     matlab.ui.container.Panel
        InformationLabel          matlab.ui.control.Label
        XLabel                    matlab.ui.control.Label
        YLabel                    matlab.ui.control.Label
        ThetaLabel_2              matlab.ui.control.Label
        TimeLabel_2               matlab.ui.control.Label
        ResetButton               matlab.ui.control.Button
        RightPanel                matlab.ui.container.Panel
        EnvAxes                   matlab.ui.control.UIAxes
        
        running
        paused
        configureModeActive
    end

    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Value changed function: ConfugureObstaclesButton
        function ConfugureObstaclesButtonValueChanged(app, event)
            active = app.ConfugureObstaclesButton.Value;
            if active
                % WHAT DO TO WHEN CONFIGURE_OBSTACLES MODE IS ACTIVE 
            end
        end

        % Button pushed function: RunButton
        function RunButtonPushed(app, event)
            
            if (app.running)
                app.running = false;
                app.RunButton.BackgroundColor = [0.5608 1 0.5608];
                app.RunButton.Text = 'Run';
            else
                app.running = true;
                app.RunButton.BackgroundColor = [1 0.4608 0.4608];
                app.RunButton.Text = 'Pause';
            end
            
        end

        % Button pushed function: ResetButton
        function ResetButtonPushed(app, event)
            % WHAT TO DO WHEN THE RESET BUTTON IS PRESSED
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

            % Create ConfugureObstaclesButton
            app.ConfugureObstaclesButton = uibutton(app.LeftPanel, 'state');
            app.ConfugureObstaclesButton.ValueChangedFcn = createCallbackFcn(app, @ConfugureObstaclesButtonValueChanged, true);
            app.ConfugureObstaclesButton.Text = 'Confugure Obstacles';
            app.ConfugureObstaclesButton.BackgroundColor = [0.902 0.902 0.902];
            app.ConfugureObstaclesButton.Position = [16 102 172 29];

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

            % Create ThetaLabel_2
            app.ThetaLabel_2 = uilabel(app.Panel);
            app.ThetaLabel_2.FontSize = 16;
            app.ThetaLabel_2.Position = [15 159 141 33];
            app.ThetaLabel_2.Text = 'Theta:';

            % Create TimeLabel_2
            app.TimeLabel_2 = uilabel(app.Panel);
            app.TimeLabel_2.FontSize = 16;
            app.TimeLabel_2.Position = [15 127 141 33];
            app.TimeLabel_2.Text = 'Time:';

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
            app.EnvAxes.BoxStyle = 'full';
            app.EnvAxes.XMinorTick = 'on';
            app.EnvAxes.YMinorTick = 'on';
            app.EnvAxes.Position = [6 7 473 475];

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
        end
    end
    
    % Functions for getting data/updating various displays on the UI
    methods (Access = public)
        
        function setXText(app,text)
            app.XLabel.Text = text;
        end
        
        
        function setYText(app,text)
            app.YLabel.Text = text;
        end
        
        
        function setTimeText(app,text)
            app.TimeLabel.Text = text;
        end
        
        
        function setThetaText(app,text)
            app.ThetaLabel.Text = text;
        end
        
        
        function pos = getMousePosOverFigure(app)
            
        end
    end
end