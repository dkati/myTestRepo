close all
opengl hardwarebasic
clear % clean the workspace.

addpath('./Classes');
%addpath('./Google');
addpath('./Grid');

%==============Global settings==============
Prefs=Prefs();
Prefs.showGraphs = false;
Prefs.showArrows = false;
Prefs.showEdges = true;
%===========================================

startPoint=[39.427346,22.794407];
endPoint=[39.42944,22.793248];
obstacles = {Obstacle(39.428589,22.793730,3) Obstacle(39.428622,22.793508,3)};

%=======================GPS EDITS=======================
mycell = {[39.429251,22.793047],[39.429285,22.793134],[39.429369,22.793197],[39.429441,22.793248];  %top edges
    [100,100],[100,100],[100,100],[100,100];                                                        %middle
    [39.427330,22.794427],[39.427391,22.794482],[39.427454,22.794552],[39.427530,22.794656]         %bottom
    };
%=======================================================
%save('gps.mat','mycell');
%load('gps.mat');
[rowCount,colCount]=size(mycell);
trackLines=mycell;

% replace all '[]' with NULL string.this is needed for cleaning up the
% input data, coming from the drone
for i=1:colCount
    for j=1:rowCount
        if ( isempty(trackLines{j,i} ))
            trackLines{j,i}='NULL';
        end
    end
end

% filtering:
% try to find the very first and the very last coordinate in order to
% create a 3row matrix.our algorythm requires that.fill the 2nd row
% with null
% create an array with all object-lines
LineObjects = [];
firstindex=-1;
table = [];
k=1;
for i=1:colCount
    for j=1:rowCount
        if ((~strcmp(trackLines{j,i},'NULL')) && (firstindex == -1))
            table{1,k} = trackLines{j,i};
            table{3,k} = trackLines{j,i};
            firstindex=j;
        end
        if (~strcmp(trackLines{j,i},'NULL') && (firstindex ~= j))
            table{3,k} = trackLines{j,i};
        end
        table{2,k}='NULL';
    end
    LineObjects{i}=Line(table{1,k}(1),table{1,k}(2),table{3,k}(1),table{3,k}(2),i); % create an array of all lines
    k=k+1;
    firstindex=-1;
    
end

LinesWithObstacles = [];
for i=1:colCount
    for v=1:length(obstacles)
        x=LineObjects{i}.isObstacleInLine(obstacles{v}.x,obstacles{v}.y,obstacles{v}.radius); %thats 3m obstacle radius
        if (x==1)
            % LinesWithObstacles[WHICH_LINE OBS_X OBS_Y;]
            % the semicolon means that each line of this array is 1 obstacle
            LinesWithObstacles=[LinesWithObstacles ;i obstacles{v}.x obstacles{v}.y;];
        end
    end
end

indexedObs=Functions.getObstacleIndexes(LinesWithObstacles,LineObjects);
tracks = 1 + (0:colCount-1);

indexedStart = Functions.getGlobalIndex(startPoint(1),startPoint(2),table);
indexedEnd = Functions.getGlobalIndex(endPoint(1),endPoint(2),table);
[isPossible, dSP, sp, E, V] = ShortestPath(tracks, indexedObs, indexedStart, indexedEnd);

if ( ~isPossible )
    disp('--------------')
    disp('NO PATH FOUND!')
    disp('EXITING...')
    disp('--------------')
    close all
    return
end

% creation of spare matrix DG
[a,b]=size(E);
WeightMATRIX=ones(1,a);
Node1MATRIX=E(:,1);
Node2MATRIX=E(:,2);

if (Prefs.showGraphs == true)
    DG = sparse(Node1MATRIX,Node2MATRIX,WeightMATRIX);
    bg = biograph(DG,[],'ShowWeights','on');
    h2 = view(bg);
    set(h2.Nodes(sp),'Color',[1 0.4 0.4])
    edges = getedgesbynodeid(h2,get(h2.Nodes(sp),'ID'));
    set(edges,'LineColor',[1 0 0])
    set(edges,'LineWidth',1.5)
end
