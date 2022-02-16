clear all
close all
%% TEST CASE
NeedRename = 0;      %rename output to comparable
reducedtounity = 1;  %scale data

TEST = 0;
test4 = 1;

%% GEOMETRY PARAMETERS
asmb = 17;        %assembly size
core = 3;         %core size
moderator = 1;    %surrounding moderator "core"

showplot = 0;     %plot results after reading
showplot2d = 0;
showplot3d = 0;   %plot2d and plot3d cannot be 1 at the same time
showline = 0;     %printing each line on screen



%% OPEN FOLDER
path = cd('TD0\TD0-3');
listing = dir('power');
filename = extractfield(listing,'name');
TS = table2array(readtable('TS_power.xlsx','sheet','TS'));

cd 'power';

if NeedRename == 1 %% rename the output file
    for i = 1 : size(filename,2)
        name = char(filename(i));
        tr1 = strcmp(name,'.');
        tr2 = strcmp(name,'..');
        if tr1 ~= 1 && tr2 ~= 1
            oldname = sprintf('%s', name);
            s = split(oldname, " ");
            newname = sprintf('%s.out', s{3});
            movefile(oldname, newname)
        end
    end
end

datafile = 'TD0-3_p.dat'; % write to this file
wid = fopen(datafile,'w');
if wid < 0 
    disp('failed to open the file to write');
end


%% time steps prepare
if TEST <= 3
% --------------TD0-3--------------
dt = [0, 2, 0.025; 2, 10, 0.05]; %start end dt
zlayer = 1;       %number of layers in z-axial
pt = [0.00,0.25,0.50,0.75,1.00,1.25,1.50,1.75,2.00,2.25,2.50,2.70,3.00, ... 
     4.00,5.00,6.00,7.00,8.00, 9.00, 10.00];
elseif TEST == 4
% --------------TD4--------------
dt = [0, 4, 0.025; 4, 7, 0.05; 7, 8, 0.25; 8, 16, 0.5];
zlayer = 32;       %number of layers in z-axial
if test4 == 1
pt = [0,  0.25,  0.5,  0.75,  1,  1.25,  1.5,  1.75,  2,  2.25, ...
    2.5,  2.75,  3,  3.25,  3.5,  3.75,  4,  4.5,  5,  5.5,  6, ...
    7,  8,  9,  10,  11,  12,  13,  14,  15,  16];
ft = [0.00,  0.50,  1.00,  1.50,  2.00,  2.50,  3.00,  3.50,  4.00, ...
    5.00,  6.00,  7.00,  8.00,  9.00,  10.00,  11.00,  12.00,  13.00, ...
    14.00,  15.00,  16.00];
else
pt = [0.00,  0.25,  0.50,  0.75,  1.00,  1.25,  1.50,  1.75,  2.00,  ...
2.25,  2.50,  2.75,  3.00,  3.25,  3.50,  3.75,  4.00,  4.25,  ...
4.50,  4.75,  5.00,  5.25,  5.50,  5.75,  6.00,  6.25,  6.50,  ...
6.75,  7.00,  7.25,  7.50,  7.75,  8.00,  9.00,  10.00,  11.00, ...
12.00,  13.00,  14.00,  15.00,  16.00];
ft = [0,  0.5,  1,  1.5,  2,  2.5,  3,  3.5,  4,  4.5,  5,  5.5,...
    6,  6.5,  7,  7.5,  8,  9,  10,  11,  12,  13,  14,  15,  16];
end
elseif TEST == 5
% --------------TD5--------------
dt = [0, 4, 0.025; 4, 8, 0.05; 8, 12, 0.5];
zlayer = 32;       %number of layers in z-axial
pt = [0.00,  0.25,  0.50,  0.75,  1.00,  1.25,  1.50,  1.75,  2.00, ...
    2.25,  2.50,  2.75,  3.00,  3.25,  3.50,  3.75,  4.00,  4.25, 4.50, ...
    4.75,  5.00,  5.25,  5.50,  5.75,  6.00,  6.25,  6.50,  6.75,  7.00, ...
    7.25,  7.50,  7.75,  8.00,  9.00,  10.00,  11.00,  12.00]; % assembly fission rate print time
ft = [0.00, 0.50, 1.00, 1.50, 2.00, 2.50, 3.00, 3.50, 4.00, ...
    4.50, 5.00, 6.00, 7.00, 8.00, 9.00, 10.00, 11.00, 12.00];
end

[m,~] = size(dt);
time = dt(1,1) : dt(1,3) : dt(1,2);
for i = 2 : m
    a = dt(i,1)+dt(i,3) : dt(i,3) : dt(i,2);
    time = [time, a];
end
[~, num_file] = size(time);
disp(num_file)

%% Print Power, pcm, betaeff, lifetime
TS_time = TS(:,2);
TS_power = TS(:,3);
TS_pcm = TS(:,4);
TS_beta = TS(:,6);
TS_life = TS(:,7);
To_print_time = TS(:,8);
walltime = TS(1,9);

fprintf(wid, "%s\t%f %s\n", "Wall-time", walltime/3600, "hr");
fprintf(wid, "\n%s\t%s\t%s\t%s\t%s\t%s\n", "TransientTime[s]", "\rho[pcm]",	"kd", "P", "beff","\Gamma[s]");
nt = 1;
for i = 1 : num_file
    if abs(TS_time(i) - To_print_time(nt))<1.0e-6
        fprintf(wid, "%.3f\t%f\t\t%.6e\t%.6e\t%.6e\n", TS_time(i), TS_pcm(i), TS_power(i), TS_beta(i), TS_life(i));
        nt = nt + 1;
    end
end

%% Axial Location
AxialLocation = zeros(zlayer,1); % top and down water/reflector 4 layers each
for i = 1:zlayer
    AxialLocation(i) = (i-4) * 5.355;
end

%% READING
AsmbPowerCoreLayer = zeros(core, core, zlayer, num_file);
NormAssmPowerCore = zeros(core, core, num_file);

pt_t = 1;
ft_t = 1;
scale = 1;
for f = 1 : num_file
    if abs(time(f) - pt(pt_t)) < 1.0e-6
        filename = sprintf('%.5f.out', time(f));
        fprintf('loading/printing file %s --> transient time %f sec\n', filename, time(f));

        fid = fopen(filename,'r'); %change the txt file name if needed
        if fid < 0 
            fprintf('failed to open the file to read %s\n', filename);
        end

        %% READ THE FIRST PART: The Normalized Pin Power in Core
        NormPinPower = zeros(asmb*core, asmb*core);

        tline = fgetl(fid);
        while ischar(tline) && contains(tline, "ID") == 0
            if showline
                disp(tline) %screen print line just read from input
            end
            tline = fgetl(fid);
        end

        if showline
            disp(tline)
        end

        for i = 1:core
            for j = 1:core
                tline = fgetl(fid);
                while contains(tline, "ID") == 1
                   if showline
                       disp(tline)
                   end
                    tline = fgetl(fid);
                end
                a = 1;
                while ischar(tline) && tline ~= ""
                    if showline
                       disp(tline)
                    end
                    t = split(tline);
                    v = str2double(t(end-asmb+1:end));
                    NormPinPower(asmb*(i-1)+a, asmb*(j-1)+1 : asmb*j) = v';
                    a = a + 1;
                    tline = fgetl(fid);
                end
            end
        end

        if showplot
            figure(2)
            colormap jet
            surface(NormPinPower, 'EdgeColor','none')
            title('NormPinPower');
            xlim([1, asmb*core+1]);
            ylim([1, asmb*core+1]);
            colorbar
            pause(1);
        end

        %% READ THE SECOND PART: The Normalized Pin Power Per Layer
        NormPinPowerLayer = zeros(asmb*core, asmb*core, zlayer);
        %AsmbPowerCoreLayer = zeros(core, core, zlayer);

        for z = 1:zlayer
            tline = fgetl(fid);
            while ischar(tline) && contains(tline, "ID") == 0
                if showline
                   disp(tline)
                end
                tline = fgetl(fid);
            end

            for i = 1:core
                for j = 1:core
                    tline = fgetl(fid);
                    while tline == "" || contains(tline, "ID") == 1 || contains(tline, "Layer") == 1
                        if showline
                           disp(tline)
                        end
                        tline = fgetl(fid);
                    end
                    a = 1;
                    while ischar(tline) && tline ~= ""
                        if showline
                           disp(tline)
                        end
                        t = split(tline);
                        v = str2double(t(end-asmb+1:end));
                        NormPinPowerLayer(asmb*(i-1)+a, asmb*(j-1)+1 : asmb*j, z) = v';
                        a = a + 1;
                        tline = fgetl(fid);
                    end
                end
            end

            while tline == "" || contains(tline, "*") == 1
                if showline
                   disp(tline)
               end
                tline = fgetl(fid);
            end
            for i = 1:core
                if showline
                   disp(tline)
               end
                t = split(tline);
                v = str2double(t(end-core+1:end));
                AsmbPowerCoreLayer(i, :, z, f) = v';
                tline = fgetl(fid);
            end
        end

        if showplot3d
            figure(4)
            colormap jet
            diff = double(squeeze(NormPinPowerLayer));
            h = slice(diff, 1:size(diff,2), 1:size(diff,1), 1:size(diff,3));
            set(h, 'EdgeColor','none', 'FaceColor','interp')
            title('NormPinPowerLayer')
            colorbar
            alpha(.1)
            pause(1);

            figure(5)
            colormap jet 
            diff = double(squeeze(AsmbPowerCoreLayer(:,:,:,f)));
            h = slice(diff, 1:size(diff,2), 1:size(diff,1), 1:size(diff,3));
            set(h, 'EdgeColor','none', 'FaceColor','interp')
            title('AsmbPowerCoreLayer')
            alpha(.1)
            colorbar
            pause(1);
        end

        if showplot2d
            figure(4)
            colormap jet
            surface(NormPinPowerLayer, 'EdgeColor','none')
            title('NormPinPowerLayer');
            xlim([1, asmb*core+1]);
            ylim([1, asmb*core+1]);
            colorbar
            pause(1);

            figure(5)
            colormap jet
            surface(AsmbPowerCoreLayer(:,:,:,f), 'EdgeColor','none')
            title('AsmbPowerCoreLayer');
            colorbar
            pause(1);
        end

        %% READ THE THIRD PART: The Normalized Assembly Power for Core
        while tline == "" || contains(tline, "*") == 1
            if showline
               disp(tline)
            end
            tline = fgetl(fid);
        end
        for i = 1:core
            if showline
               disp(tline)
            end
            t = split(tline);
            v = str2double(t(end-core+1:end));
            NormAssmPowerCore(i, :, f) = v';
            tline = fgetl(fid);
        end
        if showplot
            figure(6)
            colormap jet
            surface(NormAssmPowerCore(:,:,f), 'EdgeColor','none'); 
            title('NormAssmPowerCore')
            colorbar
            pause(1);
        end

        %% READ THE FOURTH PART: The Axial Power Distribution for Assembly
        AxialPowerAssm = zeros(core*core, zlayer);

        while tline == "" || contains(tline, "*") == 1 || contains(tline, "Assembly") == 1
            if showline
               disp(tline)
            end
            tline = fgetl(fid);
        end
        for i = zlayer:-1:1
            if showline
               disp(tline)
            end
            t = split(tline);
            v = str2double(t(end-core*core+1:end));
            AxialPowerAssm(:, i) = v';
            tline = fgetl(fid);
        end
        if showplot
            figure(7)
            colormap jet
            surface(AxialPowerAssm', 'EdgeColor','none');
            title('AxialPowerAssm')
            colorbar
            pause(1);
        end

        %% READ THE FIFTH PART: The Axial Power Distribution for Core
        AxialPowerCore = zeros(zlayer, 2);

        while tline == "" || contains(tline, "*") == 1 || contains(tline, "Assembly") == 1
            if showline
               disp(tline)
            end
            tline = fgetl(fid);
        end
        for i = zlayer:-1:1
            if showline
               disp(tline)
            end
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

        %% Organizing data according to template
        % pin fission rate ==> NormPinPowerLayer          
            if TEST <= 3
                if reducedtounity
                    NormPinPowerLayer = NormPinPowerLayer ./ sum(sum(sum(NormPinPowerLayer)));
                    NormPinPowerLayer = NormPinPowerLayer .* TS_power(f);
                end
                fprintf(wid, '%s\t\n', 'PinFissionRate');
                fprintf(wid, '\t%s\t%f','Time[s]', time(f));

                fprintf(wid, '\n%s\t%s\t','Axiallocation[cm]', 'Row\Column');
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
                            fprintf(wid, '%.6e\t', NormPinPowerLayer(j,k,z));
                        end
                        fprintf(wid,'\n');
                    end
                end
            elseif TEST == 4 || TEST == 5
                if abs(ft(ft_t) - pt(pt_t)) < 1.0e-6
                    ft_t = ft_t + 1;
                    if reducedtounity
                        NormPinPowerLayer = NormPinPowerLayer ./ sum(sum(sum(NormPinPowerLayer)));
                        NormPinPowerLayer = NormPinPowerLayer .* TS_power(f);
                    end
                    fprintf(wid, '\n%s\t\n', 'PinFissionRate');
                    fprintf(wid, '\t%s\t%f','Time[s]', time(f)); 
                    for z = zlayer-4:-1:5
                        fprintf(wid, '\n%s\t%s\t','Axiallocation[cm]', 'Row\Column');
                        for j = 1:core-moderator
                            for k = 1: asmb
                                fprintf(wid, '%s\t', int2str((j-1)*asmb+k));
                            end
                        end
                        for j = 1 : (core-moderator)*asmb
                            fprintf(wid, '\n%f\t%s\t', AxialLocation(z), int2str(j));
                            for k = 1 : (core-moderator)*asmb
                                fprintf(wid, '%.6e\t', NormPinPowerLayer(j,k,z));
                            end
                        end      
                    end
                end
            end

        %% CLOSE READ/WRITE FILE
        pt_t = pt_t + 1;
        fclose(fid);
    end
end

% Assembly fission rate ==> AsmbPowerCoreLayer
fprintf(wid, '\n\n%s\t\n', 'AssemblyFissionRate');

if TEST <= 3
    pt_t = 1;
    scale = 1;
    for t = 1:num_file
        if abs(time(t) - pt(pt_t)) < 1.0e-6
            pt_t = pt_t + 1;
            fprintf(wid, '\n\t%s\t%f\t\t','Time[s]', time(t));
            if reducedtounity
                AsmbPowerCoreLayer(:,:,:,t) = AsmbPowerCoreLayer(:,:,:,t) ./ sum(sum(sum(AsmbPowerCoreLayer(:,:,:,t))));
                AsmbPowerCoreLayer(:,:,:,t) = AsmbPowerCoreLayer(:,:,:,t) .* TS_power(t);
            end
            for z = zlayer:-1:1
                fprintf(wid, '\n\t%s\t%s\t%s\t','Row\Column', '1','2');
                for j = 1 : core-moderator
                    fprintf(wid, '\n%f\t%s\t', AxialLocation(z), int2str(j));
                    for i = 1 : core-moderator
                        fprintf(wid, '%.6e\t', AsmbPowerCoreLayer(j,i,z,t));
                    end
                end
            end
            fprintf(wid,'\n');
        end
    end
elseif TEST == 4 || TEST == 5
    pt_t = 1;
    scale = 1;
    for t = 1:num_file
        if abs(time(t) - pt(pt_t)) < 1.0e-6
            pt_t = pt_t + 1;
            fprintf(wid, '\t%s\t%f\t','Time[s]', time(t));
            if reducedtounity
                AsmbPowerCoreLayer(:,:,:,t) = AsmbPowerCoreLayer(:,:,:,t) ./ sum(sum(sum(AsmbPowerCoreLayer(:,:,:,t))));
                AsmbPowerCoreLayer(:,:,:,t) = AsmbPowerCoreLayer(:,:,:,t) .* TS_power(t);
            end
        end
    end
    fprintf(wid, '\n%s\t','Axiallocation[cm]');
    pt_t = 1;
    for t = 1:num_file
        if abs(time(t) - pt(pt_t)) < 1.0e-6
            pt_t = pt_t + 1;
            fprintf(wid, '%s\t%s\t%s\t','Row\Column', '1','2');
        end
    end
    fprintf(wid,'\n');

    for z = zlayer-4:-1:5 
        for j = 1 : core-moderator
            fprintf(wid, '%f\t', AxialLocation(z));
            pt_t = 1;
            for t = 1:num_file
                if abs(time(t) - pt(pt_t)) < 1.0e-6
                    pt_t = pt_t + 1;
                    fprintf(wid, '%s\t', int2str(j));
                    for i = 1 : core-moderator
                        fprintf(wid, '%.6e\t', AsmbPowerCoreLayer(j,i,z,t));
                    end
                end
            end
            fprintf(wid,'\n');
        end
    end
end
%% close files
status = fclose(wid);
%disp(status);
fclose('all');
movefile(datafile, path);
disp("closing/moving files")
disp('All Finished!')