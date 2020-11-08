%%  Starts program 
    function F7_ChristopherBingham_JamieSkipperReed_DanielVipond
    
%       Removes unneccessary warnings
        warning('off','all');   
%       Sets up the GUI figure for the menu
        createFigure;
    end

%%  Creates GUI figure for the menu and loads default parameters                                                                          
    function createFigure 
    
%       Create and then hide the UI as it is being constructed
        f = figure('Resize', 'off', 'Visible','off','Position',[360,500,450,285], 'Color', 'White'); 
%       Assign the a name to appear in the window title
        f.Name = 'ENGI218 Electronics 2 Computing Project'; 
%       Move the window to the center of the screen
        movegui(f,'center')          
%       Make the window visible
        f.Visible = 'on';         
%       Set version to '1' for Atlas 500 by default
        version = 1;
%       NOTE: '2' for Atlas 400 and '3' for Atlas HLV 

%       Read and load names and variables relating to Atlas 500
%       Reference: United Launch Alliance (2010) 'Atlas V Launch Services User's Guide'
        [~, variables] = xlsread('Variables.xlsx', 'Sheet1', 'A1:A31');
        values = xlsread('Variables.xlsx', 'Sheet1', 'B1:B31');

%       Load menu
        displayMenu(f, values, variables, version);                 
    end
  
%%  Constructs components for GUI figure and sets up their callback functions              
    function displayMenu(f, values, variables, version) 
    
%       Adds a picture of the Atlas rocket, varies depending on version
        title = uicontrol(f,'Style','text','String','','BackgroundColor','white','Position',[90, 260, 120,15]);
        pic = axes('Units','pixels','Position',[50,60,210,195]);
%       Reference: United Launch Alliance (2010) 'Atlas V Launch Services User's Guide'
        if version == 1
            title.String = 'Atlas V 500';
            imshow('500.jpg');
        elseif version == 2
            title.String = 'Atlas V 400';
            imshow('400.jpg');
        elseif version == 3
            title.String = 'Atlas V HLV';
            imshow('HLV.jpg');
        end      
%       Adds a 'Launch' button 
        results = uicontrol('Style','pushbutton','String','Launch','BackgroundColor','green','Position',[315,220,70,25], 'Callback',@initialiseResults);        
%       Adds an option to display a video as 'launch' is clicked
        check = uicontrol(f,'Style','checkbox', 'String','Show video on launch','BackgroundColor','white','Position',[280,190,150,25],'Value',0);     
%       Adds push-buttion to give access to the excel spreadsheet which determines the variables 
        o = uicontrol('Style','pushbutton','String','Open sheet','Position',[315,130,70,25],'Callback',@loadSheet);
%       Adds 'Settings' push button to access ability to change parameter settings
        parameterSettings = uicontrol('Style','pushbutton', 'String','Settings','Position',[315,100,70,25], 'Callback',@initialiseSystemParameterSettings);         
%       Adds a pop-up menu to change between versions of Atlas rocket
        text = uicontrol(f,'Style','popupmenu','Position',[100, 30, 120,15],'Callback', @setVersion);
        text.String = {'Atlas V 500','Atlas V 400','Atlas V HLV'};
%       Add an 'Exit' push button to end program
        exit = uicontrol('Style','pushbutton','BackgroundColor','red','String','Exit','Position',[315,60,70,25],'Callback',@exitProgram);
        components = [pic, parameterSettings, results, exit, text, title, check, o];

%       NESTED FUNCTIONS: Push button callbacks
%       Called when 'Launch' push-button is pressed
        function initialiseResults(~,~) 
%           Load launch video if check-box is ticked
            if  check.Value == 1
%               Loads video file and auto plays in set position
%               Reference: https://www.youtube.com/watch?v=CkZ4xBecBig, 'GOES-S launch by Atlas V 541,' [online] Last accessed 03/11/18
                vid = implay('vid.mp4');
                play(vid.DataSource.Controls);
                set(findall(0,'tag','spcui_scope_framework'),'position',[300 250 855 505]);
%               Sets length of video
                pause(3);
                close(vid);
            end    
%           Generates the data for plotting
            results = performCals(values, version);    
                if results(size(results, 1), size(results, 2)) == 0 
                else
%               Clear the menu by deleting components and call the method to display results     
                delete(components);
                displayResults(values, variables, version, results, f);
                end
        end 
%       Called when 'Settings' push-button is pressed
        function initialiseSystemParameterSettings(~,~) 
%           Clear menu and display settings  
            delete(components);
            systemParameterSettings(f, values, variables, version);
        end  
%       Called when 'Open sheet' push-button is pressed 
        function loadSheet(~,~) 
            winopen('Variables.xlsx');  
            delete(components);
            displayMenu(f, values, variables, version);
        end 
%       Called when 'Exit' push-bustion is pressed
        function exitProgram(~,~) 
%           End program
            f.Visible = 'off';
        end
%       Called to switch between rocket versions
        function setVersion(~,~) 
%           Load new version rocket title and picture
%           Reference: United Launch Alliance (2010) 'Atlas V Launch Services User's Guide'
            version = text.Value;
            switch (version)
                case {1}
                    [~, variables] = xlsread('Variables.xlsx', 'Sheet1', 'A1:A31');
                    values = xlsread('Variables.xlsx', 'Sheet1', 'B1:B31');
                    title.String = 'Atlas V 500';
                    imshow('500.jpg');
                case {2}
                    [~, variables] = xlsread('Variables.xlsx', 'Sheet1', 'D1:D26');
                    values = xlsread('Variables.xlsx', 'Sheet1', 'E1:E26');
                    title.String = 'Atlas V 400';
                    imshow('400.jpg');
                case {3}
                    [~, variables] = xlsread('Variables.xlsx', 'Sheet1', 'G1:G30');
                    values = xlsread('Variables.xlsx', 'Sheet1', 'H1:H30');
                    title.String = 'Atlas V HLV';
                    imshow('HLV.jpg');
            end     
        end     
    end
 
%%  Sets up a results menu and displays the results of the rocket launch
    function displayResults(values, variables, version, results, f) 
    
%       Adds a panel
        p = uipanel('Title','Results','ForegroundColor','black','BackgroundColor','green','Position',[.61, .3, .36, .6]);            
%       Adds a pop-up menu to change between results
        ylabels = {'Altitude (m)', 'Velocity (m/s)', 'Acceleration (g)', 'Throttle (%)', 'Angle (rad)', 'Thrust (N)', 'Weight (N)', 'Drag (N)',...
                   'Mach Number', 'Air temperature (K)', 'Air density (kgm^-3)', 'Dynamic Pressure (Pa)', 'Atmospheric Pressure (Pa)', ...
                   'Drag area (m^2)', 'Horizontal distance (m)', 'Total distance (m)'};
        c = uicontrol(f,'Style','popupmenu','String',ylabels,'Position',[290,210,130,25],'Callback',@selection);  
%       Adds a static text displaying the current value under the 'x' marker in the graph
        v_value = results(1, 2);
        v =  uicontrol(f,'Style','text','String', v_value,'BackgroundColor','white','Position',[315,195,70,15]);
%       Adds a static text displaying 'Time (s)'
        text_t = uicontrol(f,'Style','text','String','Time (s)','BackgroundColor','white','Position',[315,150,70,15]);
%       Adds a static text displaying the current time
        t_value = values(3);
        t =  uicontrol(f,'Style','text','String',t_value,'BackgroundColor','white','Position',[315,130,70,15]);
%       Adds a slider to control the 'x' marker in the graph
        s = uicontrol('Style','slider','Min',values(3),'Max',values(2), ...
                      'Value',values(3),'BackgroundColor','white','Position',[280,100,150,10],...
                      'Callback',@(numfld, event) updateGraph(numfld));
%       Adds a pushbutton labelled 'Menu' to allow return
        menu = uicontrol('Style','pushbutton','String','Menu','Position',[315,50,70,25], 'Callback',@returnMenu);
%       Adds a pushbutton giving ablity to access all results on excel spreadsheet
        r = uicontrol('Style','pushbutton','String','Export sheet','Position',[315, 20,70,25],'Callback',@loadResults);
%       Adds a graph 
        ha = axes('Units','pixels','Position',[50,60,200,185]); 
        plot(results(:,1), results(:,2));
        xlabel('Time (s)');
        ylabel('Altitude (m)'); 
        components = [p, ha, c, s, text_t, t, v, r, menu];

%       NESTED FUNCTIONS: Push button callbacks
%       Called when a results type in the pop-up menu is selected
        function selection(~,~)
            hold off
            components(6).String = '';
            components(7).String = '';
            for i = 1: 1: size(results, 2)
                if i == c.Value
                    plot(results(:,1), results(:,(c.Value+1)));
                    axis tight;
                    xlabel('Time (s)');
                    ylabel(ylabels{c.Value});    
                end
            end
        end
%       Called when the slidebar is moved
        function updateGraph(numfld)
             hold off
             t_value = numfld.Value; 
             components(6).Value = t_value;
             components(6).String = t_value;
             dt = values(3);
             cell = round(t_value/dt);         
             for i = 1: 1: size(results, 2)
                if i == c.Value
                    plot(results(:,1), results(:,(c.Value+1)));
                    axis tight;
                    xlabel('Time (s)');
                    ylabel(ylabels{c.Value}); 
                    v_value = results(cell, (c.Value+1));
                end
             end
             components(7).String = v_value;
             hold on      
             plot(t_value, v_value,'rx')
        end
%       Called when 'Load sheets' pushbutton is pressed
        function loadResults(~,~)  
            filename = 'Results.xlsx';
            headers = ['Time (s)', ylabels];
            cellRefs = {'A2', 'B2', 'C2', 'D2', 'E2', 'F2', 'G2', 'H2', 'I2', 'J2', 'K2', 'L2', 'M2', 'N2', 'O2', 'P2', 'Q2'};
            xlswrite(filename, headers,  1, 'A1');
            for i = 1: 1: size(results, 2)
                xlswrite(filename, results(:,i), 1, cellRefs{i});
            end
            winopen(filename);
        end
%       Called when 'Menu' pushbutton is pressed       
        function returnMenu(~, ~)
            delete(components);
            displayMenu(f, values, variables, version);
        end
    end 

%%  Sets up a settings menu, displays the parameters of the program, and gives ability to change parameters
    function systemParameterSettings(f, values, variables, version) 
%       Sets up data
        n = size(values);
        myData(n:2) = {0}; 
        myVariables(n) = {''};
        for cse = 1: 1: n
            myData{cse, 1} = variables{cse};
            myData{cse, 2} = values(cse);
            myVariables{cse} = myData{cse, 1};
        end

%       Adds a pop-menu to select type of variable to change value
        c = uicontrol(f,'Style','popupmenu','Position',[130,50,125,25],'Callback',@selection);
        c.String = myVariables;
%       Adds an editable text field to enter values for selected variable
        ed = uicontrol(f,'Style','edit','String','','Position',[160,15,65,25],'Callback',@(numfld, event) inputChanged(numfld));
%       Adds a table displaying all the parameters of the rocket and program
        tb = uitable(f,'Data',myData,'Position',[10,90,270,170]);
        tb.ColumnName = {'Variable','Value'};
        tb.ColumnWidth = {165, 53};
%       Adds an exploded diagram of the rocket version with parameter labels
        pic = axes('Units','pixels','Position',[230,5,260,280]);
        if version == 1
            imshow('500s.jpg');
        elseif version == 2
            imshow('400s.jpg');
        elseif version == 3
            imshow('HLVs.jpg');
        end      
%       Adds push-button to return to the menu
        m = uicontrol('Style','pushbutton','String','Menu','Position',[30,50,70,25],'Callback',@returnMenu);
        components = [c, ed, tb, pic, m];

%       NESTED FUNCTIONS: Push button callbacks
%       Called when a parameter in the pop-up menu is selected
        function selection(~, ~)
            ed.String = '';
        end
%       Called when a value in the editable text field is entered
        function inputChanged(numfld) 
%           Limits for number of SRB, Payload, Max angle, Jettison and Flight time
            if eq(c.Value, 4) && ((version == 1 && str2double(numfld.String) > 5)|| (version == 2 && str2double(numfld.String) > 3)) || ...
               eq(c.Value, 6) && (str2double(numfld.String) > 30000) || ...
               eq(c.Value, size(values, 1)) && (str2double(numfld.String) > 90) || ...
               eq(c.Value, 1) && (str2double(numfld.String) > 115) || ...              
               eq(c.Value, 2) && ((version == 1 || version == 2) && str2double(numfld.String) > 250) || (version ==  3 && str2double(numfld.String) > 375)
               warndlg('Parameter limit exceeded', 'Warning');
            else
                values(c.Value) = str2double(numfld.String);
                myData{c.Value, 2} = values(c.Value);
                tb.Data =  myData;
            end 
        end
%       Called when 'Menu' is pressed
        function returnMenu(~,~)
            delete(components);
            displayMenu(f, values, variables, version);        
        end                
    end
 
%%  Calculates properties of the rocket with time 
    function results = performCals(values, version) 

%       Calling initial parameter functions 
        [t_jettison, t_end, dt, h, v, ang, temp_stored, pressure_stored, throttle_stored, LRB_throttle_stored, k] = Parameters(values);
        [liquid_rocket_booster_inert, end_mass, propellant, booster_inert_mass, rocket_booster] = Mass(values, version);
        [atlas_booster_force, rb_force, no_RB] = Boosters(values, version);
        [max_angle] = MaxAngle(values, version);
        [altitudes, observedDensityValues, observedTemperatureValues, observedDragCoefficients, machNumbers] = ImportData;

%       Creates initial arrays of correct size         
        results = zeros(t_end/dt, 17);

%       Creates loadbar
        percentage = 0;
        load = waitbar(percentage, 'Loading your data', 'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');   
        setappdata(load, 'canceling', 0);

        index = 1;      
%       For loop starts iteration whereby dt is the step
        for t=0:dt:t_end 

%           Calling functions of parameters and calculation of forces that change with time
%           Calculation of Drag 
            [airDensity, airTemperature, airPressure, temp_stored] = AirDensityTemperaturePressure(h, dt, altitudes, observedDensityValues, observedTemperatureValues, temp_stored);
            [speedOfSound] = SpeedOfSound(airTemperature);
            [dragCoefficient, machSpeed] = DragCoefficient(machNumbers, speedOfSound, v, observedDragCoefficients);
            [cos_ang_stored, sin_ang_stored, ang] = Angle(values, max_angle, t_end, t, dt, ang);
            [total_area, nozzle_area] = Areas(values, cos_ang_stored, sin_ang_stored, no_RB, t, t_jettison);
            [drag, dynamPressure] = DragForce(v, dragCoefficient, airDensity, total_area);
%           Calculation of Thrust         
            [thrustIncrease, pressure_stored] = AmbientAirPressure(nozzle_area, airPressure, pressure_stored);
            [throttle_stored, LRB_throttle_stored, k] = Throttling(values, version, throttle_stored, LRB_throttle_stored, t, dt, t_end, k);
            [thrust] = Thrust(version, atlas_booster_force, thrustIncrease, throttle_stored, LRB_throttle_stored, no_RB, rb_force, t, t_jettison);
%           Calculation of Weight   
            [weight, mass] = Weight(version, h, liquid_rocket_booster_inert, end_mass, propellant, booster_inert_mass, rocket_booster, no_RB, t, t_end, t_jettison);

%           Summing forces and calculating acceleration, velocity and altitude at each slice of time 
            F_sum = thrust - weight - drag;
            a = F_sum/mass;
            v = v + a*dt;   
            h = h + v*dt;
%           Obtaining results and storing in array
            resultsParams = [t,  (h*cos_ang_stored), v, (a/9.81), (100*throttle_stored), ang, thrust, weight, drag, ...
                             machSpeed, airTemperature, airDensity, dynamPressure, airPressure, total_area, (h*sin_ang_stored), h];
            for i = 1 : 1 : size(results, 2)
                results(index, i) = resultsParams(i);
            end
            index = index + 1;

%           Updating load progress
            percentage = (t/t_end);
            waitbar(percentage, load, 'Loading your data');  
            if getappdata(load,'canceling')
                break
            end  
        end
%       Closes load bar    
        delete(load);
    end
   
%%  Initial parameters    
    function [t_jettison, t_end, dt, h, v, ang, temp_stored, pressure_stored, throttle_stored, LRB_throttle_stored, k] = Parameters(values) 
%       Obtains values for jettison time of rocket boosters, end time and time step from spreadsheet        
        t_jettison = values(1);
        t_end = values(2);
        dt = values(3);
%       Set initial parameters
        h = 0;
        v = 0;
        ang = 0;
        temp_stored = 198.5;
        pressure_stored = 0;
        throttle_stored = 0;
        LRB_throttle_stored = 0;
        k = 1;
    end
 
%%  Initial mass of each component (Kg)
    function [liquid_rocket_booster_inert, end_mass, propellant, booster_inert_mass, rocket_booster] = Mass(values, version) 
        payload_fairing = values(5);
        payload = values(6);
        adapter_1 = values(7);
        adapter_2 = values(8); 
        common_centaur_propellant = values(9);
        cc_inert_mass = values(10);
        cflr = 0;
        liquid_rocket_booster_inert = 0;
%       If version is Atlas 500, cflr mass is assigned value        
        if version == 1
            cflr = values(23);       
%       If version is HLV, inert mass of liquid rocket boosters has to be included 
        elseif version == 3
            liquid_rocket_booster_inert = values(23);
        end
        common_centaur = common_centaur_propellant + cflr + cc_inert_mass;
%       Mass of Atlas rocket at end of simulation
        end_mass = payload_fairing + payload + adapter_1 + adapter_2 + common_centaur;
        propellant = values(11);
        booster_inert_mass = values(12);
%       Solid rocket boosters in Atlas 500 and 400, liquid in HLV       
        rocket_booster = values(13); 
    end
 
%%  Initial number and force (N) of boosters
    function [atlas_booster_force, rb_force, no_RB] = Boosters(values, version) 
        atlas_booster_force = values(15);
%       No solid rocket boosters in HLV
        if version == 3
            rb_force = 0;
            no_RB = 0;
%       In other versions number of solid rocket boosters and SRB force are assigned values
        else
            rb_force = values(14);
            no_RB = values(4); 
        end
    end
 
%%  Max angle of curvature for each Atlas version  
    function [max_angle] = MaxAngle(values, version) 
%       40 degrees for Atlas 500    
        if version == 1
            max_angle = values(31);
%       30 degrees for Atlas 400             
        elseif version == 2 
            max_angle = values(26);
%       40 degrees for Atlas HLV     
        else
            max_angle = values(30); 
        end
    end
 
%%  Import lists of data from spreadsheet
    function [altitudes, observedDensityValues, observedTemperatureValues, observedDragCoefficients, machNumbers] = ImportData 
%       Observed data values for density, temperature, drag coefficient and mach number in relation to altitude   
%       Reference: https://www.engineeringtoolbox.com/standard-atmosphere-d_604.html, 'The Engineering ToolBox,' [online] Last accessed 03/11/18
        altitudes = xlsread('Variables.xlsx', 'Sheet1', 'A37:A47');
        observedTemperatureValues = xlsread('Variables.xlsx', 'Sheet1', 'B37:B47');
        observedDensityValues = xlsread('Variables.xlsx', 'Sheet1', 'C37:C47');         
%       Reference: https://web.archive.org/web/20170313142729/http://www.braeunig.us/apollo/saturnV.htm, 'Saturn V Launch Simulation' [online] Last accessed 03/11/18
        observedDragCoefficients = xlsread('Variables.xlsx', 'Sheet1', 'A50:A64');
        machNumbers = xlsread('Variables.xlsx', 'Sheet1', 'B50:B64');
    end
     
%%  Air density (kgm^-3), air temperature (K) and air pressure (Pa)
    function [airDensity, airTemperature, airPressure, temp_stored] = AirDensityTemperaturePressure(h, dt, altitudes, observedDensityValues, observedTemperatureValues, temp_stored) 
%       Round altitude to the nearest integer so it can be used to compare to an equally sized, relevant array and obtain data in relation to array index
        compAltitude = round(h/100)*100;
        if  eq(compAltitude, 0)
            airDensity = 1.225;
            airTemperature = 288; 
        else
            tick = 0;
            exit_flag = 0;
            while(exit_flag == 0)
                if  (eq(tick, compAltitude))
%                   Polynomial regression to model a fit through observed density and temperature data values with altitude
                    c = polyfit(altitudes, observedDensityValues, 7);
                    d = polyfit(altitudes, observedTemperatureValues, 3);
%                   Create an array obtaining estimated temperatures and densities for every 100m up to 70km altitude
                    hFit = 0 : 100 : 70000;            
                    densityValues = polyval(c, hFit);
                    temperatureValues = polyval(d, hFit);
%                   For given altitude, convert to equilvalent index, e.g. 100m = [1], and obtain temperature and density at that altitude
                    cell = tick/100;
                    airDensity = densityValues(cell);
                    airTemperature = temperatureValues(cell);
                    exit_flag = 1; 
                elseif (compAltitude > 70000)
%                   After 70km, the air density is kept near 0 and temperature decreases iteratively down to 0
                    airDensity = 0.00001;
                    airTemperature = temp_stored - (198.5/(240/dt));
                    temp_stored = airTemperature;
                    exit_flag = 1;
                else
                    tick = tick + 100;
                end
            end 
        end  
        airPressure = airDensity*airTemperature*287.24;
    end
 
%%  Speed of Sound (ms^-1)
    function [speedOfSound] = SpeedOfSound(airTemperature) 
         speedOfSound = (1.4*287.24*airTemperature)^0.5;
    end
 
%%  Drag Coefficient
    function [dragCoefficient, machSpeed] = DragCoefficient(machNumbers, speedOfSound, v, observedDragCoefficients) 
%        Find mach number at given altitude and round to nearest tenth       
         machSpeed = round(v/speedOfSound, 1);
%        Factor mach number to the nearest integer so it can be used as an index within a relevant array
         compMachSpeed = machSpeed*10;
         dragCoefficient = 0;
         if eq(machSpeed, 0)
            dragCoefficient = 0.3;
         else 
            tick = 0;
            exit_flag = 0;
            while(exit_flag == 0)
                if (eq(tick, compMachSpeed))
%                   Polynomial regression to model a fit through mach number and drag coefficient data values  
                    c = polyfit(machNumbers, observedDragCoefficients, 4);
%                   Create an array obtaining estimated drag coefficients for every mach 0.1 up to mach 7
                    xFit = 0 : 0.1: 7;
                    dragCoefficients = polyval(c, xFit); 
                    dragCoefficient = dragCoefficients(tick);
                    exit_flag = 1; 
                elseif (compMachSpeed > 70)
                    dragCoefficient = 0.25;
                    exit_flag = 1;
                else
                    tick = tick + 1;
                end
            end    
         end
    end
 
%%  Angle of curvature
    function [cos_ang_stored, sin_ang_stored, ang] = Angle(values, max_angle, t_end, t, dt, ang) 
%       converts max angle to radians         
        max_angle_rad = (max_angle/360)*2*pi; 
%       Increases angle linearly with time 
        if t < values(22)
            ang = 0;
        else
        ang = ang + ((max_angle_rad)/((t_end-values(22))/dt));
        end
%       Calculates and stores sine and cosine of angle        
        cos_ang_stored = cos(ang); 
        sin_ang_stored = sin(ang); 
    end
 
%%  Areas (m^2) 
    function [total_area, nozzle_area] = Areas(values, cos_ang_stored, sin_ang_stored, no_RB, t, t_jettison) 
%       Cross sectional areas of payload and rocket boosters
        payload_area = values(17);        
        rb_cs_area = values(18);
        nozzle_area = values(20);
%       Side areas of solid and liquid rocket boosters
        if version == 3
            srb_side_area = 0;
            lrb_side_area = values(19);
        else
            srb_side_area = values(19);
            lrb_side_area = 0;
        end
        side_area_main = values(21);
%       Total area of Atlas HLV        
        if version == 3
%           Before jettison, area of liquid rocket boosters are included
            if t<t_jettison
                total_area = (payload_area + (2*rb_cs_area))*cos_ang_stored + (side_area_main+ (2*lrb_side_area))*sin_ang_stored;
            else
%               Total vertical area is calculated by considering angle rocket is rotated through
                total_area = payload_area*cos_ang_stored + side_area_main*sin_ang_stored;
            end
%       Total area of Atlas 500 and 400    
        else
%           Before jettison, area of solid rocket boosters are included
            if t<t_jettison
                total_area = (payload_area + (no_RB*rb_cs_area))*cos_ang_stored + (side_area_main + (no_RB*srb_side_area))*sin_ang_stored;
            else
                total_area = payload_area*cos_ang_stored + side_area_main*sin_ang_stored;
            end
        end
    end
 
%%  Drag force (N)
    function [drag, dynamPressure] = DragForce(v, dragCoefficient, airDensity, total_area) 
%       Dynamic pressure (Pa) calculated from air density and velocity of rocket
        dynamPressure = 0.5*airDensity*(v^2);
%       Drag force (N) calculated from dynamic pressure, drag coefficient and total area
        drag = abs(dynamPressure*dragCoefficient*total_area);
    end
 
%%  Thrust increase (N)
    function [thrustIncrease, pressure_stored] = AmbientAirPressure(nozzle_area, airPressure, pressure_stored) 
%        Air Pressure change to thrust increase (Pa) 
         airPressureChange = pressure_stored - airPressure;
         thrustIncrease = abs(airPressureChange*nozzle_area);
    end

%%  Throttling of boosters
    function [throttle_stored, LRB_throttle_stored, k] = Throttling(values, version, throttle_stored, LRB_throttle_stored, t, dt, t_end, k) 
       if version == 1
            times = [values(24), values(25), values(26), values(27), values(28), values(29), values(30)]; 
            throttles = [0.92, 1.00, 0.95, 0.65, 0.57, 0.80, (throttle_stored - (0.40/((t_end-values(30))/dt)))];
            lrb_throttles = zeros(7);
        elseif version == 2
            times = [values(23), values(24), values(25)];
            throttles = [0.95, (throttle_stored - (0.20/((values(25)-values(24))/dt))), (throttle_stored - (0.30/((t_end-values(25))/dt)))];
            lrb_throttles = zeros(3);
        elseif version == 3
            times = [values(24), values(25), values(26), values(27), values(28), values(29)];
            throttles = [0.45, 0.45, 0.45, 0.45, 1.00, (throttle_stored - (0.40/((t_end-values(29))/dt)))];
            lrb_throttles = [1.00, 1.00, 0.90, (LRB_throttle_stored - 0.10/(15/dt)), 0.45, 0.00, 0.00];
        end  
%       Atlas booster is throttled between time values according to spreadsheet (data taken from throttling graphs)
        if t <= times(1)
            throttle = 1;
            LRB_throttle = 1;
        elseif t > times(k) && t <= times(k+1)
            throttle = throttles(k);
            LRB_throttle = lrb_throttles(k);
        elseif t > times(end)
%           After certain value of t, throttling becomes negligible
            throttle = throttles(end);
            LRB_throttle = lrb_throttles(end);
        else
            k = k + 1;
            throttle = throttles(k);
            LRB_throttle = lrb_throttles(k);
        end  
        throttle_stored = throttle;
        LRB_throttle_stored = LRB_throttle;
    end

%%  Thrust (N)
    function [thrust] = Thrust(version, atlas_booster_force, thrustIncrease, throttle_stored, LRB_throttle_stored, no_RB, rb_force, t, t_jettison)
%       Factor thrust increase to the booster
        atlas_booster_force = atlas_booster_force + thrustIncrease;
%       Thrust for Atlas HLV
        if version == 3
            atlas_thrust = atlas_booster_force;
%           No solid rocket boosters so zero SRB thrust
            SRB_thrust = 0;
            if t <= t_jettison
%               One liquid rocket booster has the same thrust as one atlas booster 
                LRB_thrust = 2*atlas_booster_force;
            elseif t > t_jettison
                LRB_thrust = 0;
            end
%       Thrust for Atlas 500 and 400             
        else
            atlas_thrust = atlas_booster_force;
%           No liquid rocket boosters so zero LRB thrust
            LRB_thrust = 0;
            if t <= t_jettison
%               SRB thrust is equal to number of rocket boosters multiplied by rocket booster force 
                SRB_thrust = no_RB*rb_force;
            elseif t > t_jettison
                SRB_thrust = 0;
            end
        end
        thrust = atlas_thrust*throttle_stored + LRB_thrust*LRB_throttle_stored + SRB_thrust;
    end
    
%%  Weight (N)
    function [weight, mass] = Weight(version, h, liquid_rocket_booster_inert, end_mass, propellant, booster_inert_mass, rocket_booster, no_RB, t, t_end, t_jettison) 
        if t <= t_jettison
%           Calculates mass of propellant left as fuel is used over time
            propellant_stored =  propellant*(1-(t/t_end));
%           Calculates mass of fuel left in rocket boosters depending on whether solid or liquid rocket boosters are used
            if version == 3
                rocket_booster_stored = (2*rocket_booster)*(1-(t/t_jettison));
                mass = propellant_stored + end_mass + booster_inert_mass + rocket_booster_stored + 2*liquid_rocket_booster_inert;  
            else
                rocket_booster_stored = (no_RB*rocket_booster)*(1-(t/t_jettison));
                mass = propellant_stored + end_mass + booster_inert_mass + rocket_booster_stored; 
            end
        elseif t > t_jettison
            propellant_stored =  propellant*(1-(t/t_end));
%           Summing mass to get total
            mass = propellant_stored + end_mass + booster_inert_mass;
        end
%       Calculation of new g, since gravitational field strength gets weaker the further from the surface of the earth 
        g = 9.81*((6.4e+6)/((6.4e+6) + h))^2;
        weight = mass*g;
    end
