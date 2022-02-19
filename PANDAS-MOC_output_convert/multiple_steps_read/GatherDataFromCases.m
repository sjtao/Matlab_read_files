% =====================================================
% Coder: Shunjiang Tao
% Date : Feb. 17, 2022
% This file gathers the TS results from subcase folders
% Prerequsite:
% The TS subcase results are prepared in an Excel sheet 
% named "TS_power.xlsx", which shall be already ready
% while running the format_convert.m script to organize
% data for the OECD template
% Warning: 
% since the writematrix function don't have options to 
% selection precision, there will be some digits lost 
% at the decimal places, but it won't affect the data 
% analysis if only checking the trend
% Further improvement awaiting for the print part
% =====================================================

clear all
close all

%% warning
disp('==================warning======================')
disp('=====This may lost digits due to precision=====')
disp('==================warning======================')

%% input test & case number
test = 5;
subcase = 4;

%% reading data
path = sprintf(['TD' num2str(test)]);
cd(path)
disp(pwd)
for i = 1 : subcase
    nextpath = sprintf([path '-' num2str(i)]);
    cd(nextpath)
    ts = table2array(readtable('TS_power.xlsx','sheet','TS'));
    j = 2 * (i-1)+1;
    power(:,j)  = ts(:,2);
    power(:,j+1) = ts(:,3);
    pcm(:,j)  = ts(:,2);
    pcm(:,j+1)   = ts(:,4);
    doll(:,j)  = ts(:,2);
    doll(:,j+1)  = ts(:,5);
    beta(:,j)  = ts(:,2);
    beta(:,j+1)  = ts(:,6);
    life(:,j)  = ts(:,2);
    life(:,j+1)  = ts(:,7);
    runtime(:,i) = ts(:,9);
    col_header(j) = "time";
    col_header(j+1) = sprintf(['TD' num2str(test) '-' num2str(i)]);
    colhead(i) = col_header(j+1);
    cd ..
end

Power = [col_header; power];
Pcm = [col_header; pcm];
Doll = [col_header; doll];
Beta = [col_header; beta];
Life = [col_header; life];
Runtime = [colhead; runtime];

%% printing to excel
filename = sprintf(['TSResults-TD' num2str(test) '.xlsx']);
writematrix(Power,filename,'Sheet','Power');
writematrix(Pcm,filename,'Sheet','pcm');
writematrix(Doll,filename,'Sheet','dollar');
writematrix(Beta,filename,'Sheet','betaeff');
writematrix(Life,filename,'Sheet','lifetime');
writematrix(Runtime,filename,'Sheet','runtime');



