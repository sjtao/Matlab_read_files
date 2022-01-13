clear all
close all
%% GEOMETRY PARAMETERS
asmb = 17;    %assembly size
core = 3;     %core size
moderator = 1; %surrounding moderator "core"
zlayer = 32;  %number of layers in z-axial

tstep = 1;    %number of time steps printed in this file
timestep = 0.25;

showintermediate = 0; %plot results while reading
showplot = 1;         %plot results after reading

%% OPEN TXT FILE
fid = fopen('TDW2b.txt','r'); %change the txt file name if needed
if fid < 0 
    disp('failed to open the file to read');
end

datafilename = 'TDW2b_Data.dat'; % write to this file
wid = fopen(datafilename,'w');
if wid < 0 
    disp('failed to open the file to write');
end
%% READ THE FIRST PART: The Normalized Pin Power in Core
NormPinPower = zeros(asmb*core, asmb*core);

tline = fgetl(fid);
while ischar(tline) && contains(tline, "ID") == 0
    disp(tline) %screen print line just read from input
    tline = fgetl(fid);
end

disp(tline)

for i = 1:core
    for j = 1:core
        tline = fgetl(fid);
        while contains(tline, "ID") == 1
            disp(tline)
            tline = fgetl(fid);
        end
        a = 1;
        while ischar(tline) && tline ~= ""
            disp(tline)
            t = split(tline);
            v = str2double(t(end-asmb+1:end));
            NormPinPower(asmb*(i-1)+a, asmb*(j-1)+1 : asmb*j) = v';
            if showintermediate
                figure(1)
                surface(NormPinPower, 'EdgeColor','none'); 
                xlim([1, asmb*core+1]);
                ylim([1, asmb*core+1]);
                colorbar
                pause(0.001);
            end
            a = a + 1;
            tline = fgetl(fid);
        end
    end
end

if showplot
    figure(2)
    colormap jet
    surface(NormPinPower, 'EdgeColor','none')
    xlim([1, asmb*core+1]);
    ylim([1, asmb*core+1]);
    colorbar
    pause(1);
end

%% READ THE SECOND PART: The Normalized Pin Power Per Layer
NormPinPowerLayer = zeros(zlayer, asmb*core, asmb*core);
AsmbPowerCoreLayer = zeros(zlayer, core, core);

for z = 1:zlayer
    tline = fgetl(fid);
    while ischar(tline) && contains(tline, "ID") == 0
        disp(tline)
        tline = fgetl(fid);
    end
    
    for i = 1:core
        for j = 1:core
            tline = fgetl(fid);
            while tline == "" || contains(tline, "ID") == 1 || contains(tline, "Layer") == 1
                disp(tline)
                tline = fgetl(fid);
            end
            a = 1;
            while ischar(tline) && tline ~= ""
                disp(tline)
                t = split(tline);
                v = str2double(t(end-asmb+1:end));
                NormPinPowerLayer(z, asmb*(i-1)+a, asmb*(j-1)+1 : asmb*j) = v';
                if showintermediate
                    figure(3)
                    temp1(:,:) = NormPinPowerLayer(z,:,:);
                    surface(temp1, 'EdgeColor','none'); 
                    xlim([1, asmb*core+1]);
                    ylim([1, asmb*core+1]);
                    colorbar
                    pause(0.001);
                end
                a = a + 1;
                tline = fgetl(fid);
            end
        end
    end
    
    %tline = fgetl(fid);
    while tline == "" || contains(tline, "*") == 1
        disp(tline)
        tline = fgetl(fid);
    end
    for i = 1:core
        disp(tline)
        t = split(tline);
        v = str2double(t(end-core+1:end));
        AsmbPowerCoreLayer(z, i, :) = v';
        tline = fgetl(fid);
    end
    if showintermediate
        figure(4)
        temp2(:,:) = AsmbPowerCoreLayer(z,:,:);
        surface(temp2, 'EdgeColor','none'); 
        colorbar
        pause(1);
    end
end

if showplot
    figure(5)
    isosurface(AsmbPowerCoreLayer,'EdgeColor','none'); 
    pause(1);
end

%% READ THE THIRD PART: The Normalized Assembly Power for Core
NormAssmPowerCore = zeros(core, core);

while tline == "" || contains(tline, "*") == 1
    disp(tline)
    tline = fgetl(fid);
end
for i = 1:core
    disp(tline)
    t = split(tline);
    v = str2double(t(end-core+1:end));
    NormAssmPowerCore(i, :) = v';
    tline = fgetl(fid);
end
if showplot
    figure(6)
    colormap jet
    surface(NormAssmPowerCore, 'EdgeColor','none'); 
    colorbar
    pause(1);
end

%% READ THE FOURTH PART: The Axial Power Distribution for Assembly
AxialPowerAssm = zeros(zlayer, core*core);

while tline == "" || contains(tline, "*") == 1 || contains(tline, "Assembly") == 1
    disp(tline)
    tline = fgetl(fid);
end
for i = zlayer:-1:1
    disp(tline)
    t = split(tline);
    v = str2double(t(end-core*core+1:end));
    AxialPowerAssm(i, :) = v';
    tline = fgetl(fid);
end
if showplot
    zlay =linspace(1,zlayer,zlayer);
    figure(7)
    for i = 1 : core*core
        subplot(3, 3, i)
        plot(zlay, AxialPowerAssm(:,i),'r', 'LineWidth',1.2)
        view(90,-90)
    end
    pause(1);
end

%% READ THE FIFTH PART: The Axial Power Distribution for Core
AxialPowerCore = zeros(zlayer, 2);

while tline == "" || contains(tline, "*") == 1 || contains(tline, "Assembly") == 1
    disp(tline)
    tline = fgetl(fid);
end
for i = zlayer:-1:1
    disp(tline)
    t = split(tline);
    v = str2double(t(end));
    AxialPowerCore(i, 1) = i;
    AxialPowerCore(i, 2) = v;
    tline = fgetl(fid);
end
if showplot
    figure(8)
    plot(AxialPowerCore(:,1), AxialPowerCore(:,2),'r', 'LineWidth',1.2)
    xlabel('axial layer')
    ylabel('Axial Power Distribution')
    view(90,-90)
    pause(1);
end

disp("finish reading")

%% Axial Location
AxialLocation = zeros(zlayer,1); % top and down water/reflector are set as zero
for i = 1:zlayer-8
    AxialLocation(i+4) = i * 5.355;
end

%% Organizing data according to template
% Assembly fission rate ==> AsmbPowerCoreLayer
fprintf(wid, '%s\t\n', 'Assembly fission rate');
for i = 1:tstep
    time = (i-1) * timestep;
    fprintf(wid, '\t%s\t%f','Time [s]', time);
end
fprintf(wid, '\n%s\t','Axial location [cm]');
for i = 1:tstep
    fprintf(wid, '%s\t%s\t%s\t','Row\Column', '1','2');
end
for z = zlayer:-1:1 
    for j = 1 : core-moderator
        fprintf(wid, '%f\t', AxialLocation(z));
        for t = 1:tstep
            fprintf(wid, '%s\t', int2str(j));
            for i = 1 : core-moderator
                fprintf(wid, '%f\t', AsmbPowerCoreLayer(z,j,i));
            end
        end
        fprintf(wid,'\n');
    end
end
% pin fission rate ==> NormPinPowerLayer
fprintf(wid, '%s\t\n', 'pin fission rate');
for t = 1:tstep
    time = (t-1) * timestep;
    fprintf(wid, '\t%s\t%f','Time [s]', time);
    
    fprintf(wid, '\n%s\t%s\t','Axial location [cm]', 'Row\Column');
    for j = 1:core-moderator
        for k = 1: asmb
            fprintf(wid, '%s\t', int2str((j-1)*asmb+k));
        end
    end
    fprintf(wid, '\n');
    for z = zlayer:-1:1 
        for j = 1 : (core-moderator)*asmb
            fprintf(wid, '%f\t%s\t', AxialLocation(z), int2str(j));
            for k = 1 : (core-moderator)*asmb
                fprintf(wid, '%f\t', NormPinPowerLayer(z,j,k));
            end
            fprintf(wid,'\n');
        end
    end
end
disp("finish writing")
%% CLOSE READ/WRITE FILE
fclose(fid);
fclose(wid);
disp("finish closing files")