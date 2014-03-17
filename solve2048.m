% Color codes
% blank     204, 192, 179
%    2      238, 228, 218
%    4      237, 224, 200
%    8      242, 177, 121
%   16      245, 149,  99
%   32      246, 124,  95
%   64      246,  94,  59
%  128      237, 207, 114
%  256      237, 204,  97
%  512      237, 200,  80
% 1024      237, 197,  63
% 2048      204, 192, 179
% 4096      58,  59,   48
% 9192      203, 142, 232

function [] = solve2048()

    global S;
    
    S.ccodes = [204, 192, 179; ...
                238, 228, 218; ...
                237, 224, 200; ...
                242, 177, 121; ...
                245, 149,  99; ...
                246, 124,  95; ...
                246,  94,  59; ...
                237, 207, 114; ...
                237, 204,  97; ...
                237, 200,  80; ...
                237, 197,  63; ... 
                204, 192, 179; ...
                58,  59,  48; ...
                203, 142, 232];
            
    S.dirascii = [30, 31, 28, 29]; %up , down, left, right
    S.dircodes = [0 1; 0 -1; -1 0; 1 0];
    S.dirkeys = [java.awt.event.KeyEvent.VK_UP, ...
                 java.awt.event.KeyEvent.VK_DOWN, ...
                 java.awt.event.KeyEvent.VK_LEFT, ...
                 java.awt.event.KeyEvent.VK_RIGHT];
    
    S.ui_fh = figure('unit', 'pix', 'menu', 'no', 'numbertitle', 'off', 'name', 'solve2048', ...
                     'position', [800, 500, 500, 400],'KeyPressFcn',@keypressed);
    S.ui_dp = cell(4, 4);
    for i = 1:4
        for j = 1:4
            S.ui.dp{i,j} = uicontrol('unit', 'pix', 'style', 'push', 'string', '', 'fontsize', 16, ...
                                     'position',  [(i-1)*100, (4-j)*100, 100, 100]);
        end
    end
    
    S.ui_solve = uicontrol('unit', 'pix', 'style', 'push', 'string', 'solve', 'fontsize', 16, ...
                           'position',  [400, 0, 100, 100], 'callback', @cb_solve);
    S.ui_start = uicontrol('unit', 'pix', 'style', 'push', 'string', 'start', 'fontsize', 16, ...
                           'position',  [400, 200, 100, 200], 'callback', @cb_start);
    S.ui_keybug = uicontrol('unit', 'pix', 'style', 'push', 'string', 'keybug', 'fontsize', 16, ...
                           'position',  [400, 100, 100, 100], 'KeyPressFcn', @keypressed);
                       
    S.map = zeros(4, 4);
        set(S.ui_fh, 'KeyPressFcn', @keypressed);
        set(S.ui_start, 'KeyPressFcn', @keypressed);
    
    S.isstart = 0;
end

function [] = cb_start(varargin)
    global S;
    if S.isstart == 0
        set(S.ui_start, 'string', 'stop'); 
        S.isstart = 1;
        startengine();
        set(S.ui_fh, 'KeyPressFcn', @keypressed);
    else
        set(S.ui_start, 'string', 'start'); 
        S.isstart = 0;
        clearengine();
    end
end

function [] = startengine()
    global S;
    [m,n,num] = getnum();
    S.map(m,n) = num;
    [m,n,num] = getnum();
    S.map(m,n) = num;
    displaymap();
end

function [m,n,num] = getnum()
    global S;
    r2 = randi(10,1);
    if r2 < 10
        num = 1;
    else
        num = 2;
    end
    stop = 1;
    while(stop)
        R = randi(4,1,2);
        if S.map(R(1),R(2)) == 0
            stop = 0;
        end
    end
    m = R(1);
    n = R(2);
end

function [] = displaymap()
    global S;
    for i = 1:4
        for j = 1:4
            if S.map(i,j) ~= 0
                num = S.map(i,j);
                if S.map(i,j) < 4
                    set(S.ui.dp{j,i}, 'string', 2^num, 'ForegroundColor', 'k' , 'BackgroundColor'...
                        ,S.ccodes(num+1,:)/256);
                else
                    set(S.ui.dp{j,i}, 'string', 2^num, 'ForegroundColor', 'w' , 'BackgroundColor'...
                        ,S.ccodes(num+1,:)/256);
                end
            else
                set(S.ui.dp{j,i}, 'string', '' , 'BackgroundColor'...
                ,S.ccodes(1,:)/256);
            end
        end
    end
end

function [] = keypressed(src,evt)
    global S;
    if S.isstart == 1
        if strcmp(evt.Key,'leftarrow')
            if  pressleft()
                [m,n,num] = getnum();
                S.map(m,n) = num;
                displaymap();
            end
        elseif strcmp(evt.Key,'rightarrow')
            if  pressright()
                [m,n,num] = getnum();
                S.map(m,n) = num;
                displaymap();
            end
        elseif strcmp(evt.Key,'uparrow')
            if  pressup()
                [m,n,num] = getnum();
                S.map(m,n) = num;
                displaymap();
            end
        elseif strcmp(evt.Key,'downarrow')
            if  pressdown()
                [m,n,num] = getnum();
                S.map(m,n) = num;
                displaymap();
            end
        end
    end
end


function [ischanged] = ismapchanged(map,tempmap)
    ischanged = 0;
    for i = 1 : size(map,1)
        for j = 1 : size(map,2)
            if map(i,j) ~= tempmap(i,j)
                ischanged = 1;
            end
        end
    end
end

function [isvalid] = pressleft()
    global S;
    tempmap = zeros(size(S.map));
    for i = 1:size(S.map,1)
        for j = 1:size(S.map,2)
            if S.map(i,j) == 0 % 0이면 건너뜀
                continue;
            elseif j ~= size(S.map,2) % 마지막 숫자가 아닌 경우
                put = 0;
                for k = j+1 : size(S.map,2)
                    if S.map(i,j) == S.map(i,k) %다음 숫자와 값이 같은지 비교
                        [tempmap] = puttomap(tempmap,1,i,S.map(i,j)+1);
                        S.map(i,k) = 0; %다음 숫자가 같아서 합쳤으므로 필요없음
                        put = 1;
                        break;
                    elseif S.map(i,k) ~= 0
                        break;
                    end
                end
                if put == 0
                    [tempmap] = puttomap(tempmap,1,i,S.map(i,j));
                end
            else % 마지막 숫자인 경우
                [tempmap] = puttomap(tempmap,1,i,S.map(i,j));
            end
        end
    end
        isvalid = ismapchanged (S.map,tempmap);
    S.map = tempmap;
end


function [isvalid] = pressright()
    global S;
    tempmap = zeros(size(S.map));
    for i = 1:size(S.map,1)
        for j = size(S.map,2): -1 : 1
            if S.map(i,j) == 0 % 0이면 건너뜀
                continue;
            elseif j ~= 1 % 마지막 숫자가 아닌 경우
                put = 0;
                for k = j-1 : -1 : 1
                    if S.map(i,j) == S.map(i,k) %다음 숫자와 값이 같은지 비교
                        [tempmap] = puttomap(tempmap,2,i,S.map(i,j)+1);
                        S.map(i,k) = 0; %다음 숫자가 같아서 합쳤으므로 필요없음
                        put = 1;
                        break;
                    elseif S.map(i,k) ~= 0
                        break;
                    end
                end
                if put == 0
                    [tempmap] = puttomap(tempmap,2,i,S.map(i,j));
                end
            else % 마지막 숫자인 경우
                [tempmap] = puttomap(tempmap,2,i,S.map(i,j));
            end
        end
    end
    isvalid = ismapchanged (S.map,tempmap);
    S.map = tempmap;
end

function [isvalid] = pressup()
    global S;
    tempmap = zeros(size(S.map));
    for i = 1:size(S.map,1)
        for j = 1:size(S.map,2)
            if S.map(j,i) == 0 % 0이면 건너뜀
                continue;
            elseif j ~= size(S.map,2) % 마지막 숫자가 아닌 경우
                put = 0;
                for k = j+1 : size(S.map,2)
                    if S.map(j,i) == S.map(k,i) %다음 숫자와 값이 같은지 비교
                        [tempmap] = puttomap(tempmap,3,i,S.map(j,i)+1);
                        S.map(k,i) = 0; %다음 숫자가 같아서 합쳤으므로 필요없음
                        put = 1;
                        break;
                    elseif S.map(k,i) ~= 0
                        break;
                    end
                end
                if put == 0
                    [tempmap] = puttomap(tempmap,3,i,S.map(j,i));
                end
            else % 마지막 숫자인 경우
                [tempmap] = puttomap(tempmap,3,i,S.map(j,i));
            end
        end
    end
        isvalid = ismapchanged (S.map,tempmap);
    S.map = tempmap;
end

function [isvalid] = pressdown()
    global S;
    tempmap = zeros(size(S.map));
    for i = 1:size(S.map,1)
        for j = size(S.map,2): -1 : 1
            if S.map(j,i) == 0 % 0이면 건너뜀
                continue;
            elseif j ~= 1 % 마지막 숫자가 아닌 경우
                put = 0;
                for k = j-1 : -1 : 1
                    if S.map(j,i) == S.map(k,i) %다음 숫자와 값이 같은지 비교
                        [tempmap] = puttomap(tempmap,4,i,S.map(j,i)+1);
                        S.map(k,i) = 0; %다음 숫자가 같아서 합쳤으므로 필요없음
                        put = 1;
                        break;
                    elseif S.map(k,i) ~= 0
                        break;
                    end
                end
                if put == 0
                    [tempmap] = puttomap(tempmap,4,i,S.map(j,i));
                end
            else % 마지막 숫자인 경우
                [tempmap] = puttomap(tempmap,4,i,S.map(j,i));
            end
        end
    end
        isvalid = ismapchanged (S.map,tempmap);
    S.map = tempmap;
end

% map : input num to this map
% dir : direction (up,down,left,right) = (3,4,1,2)
% rowcol : row or col according to direction
% num : to input num
function [retmap] = puttomap(map,dir,rowcol,num)
    retmap = map;
    place = 0;
    if dir == 1 || dir == 3
        for i = 1 : size(map,1)
            if dir == 1
                if map(rowcol,i) == 0
                    place = i;
                    break;
                end
            elseif dir == 3
                if map(i,rowcol) == 0
                    place = i;
                    break;
                end
            end
        end
    else
        for i = size(map,1) : -1 : 1
            if dir == 2
                if map(rowcol,i) == 0
                    place = i;
                    break;
                end
            elseif dir == 4
                if map(i,rowcol) == 0
                    place = i;
                    break;
                end
            end
        end
    end
    if dir == 1 || dir == 2
        retmap(rowcol,place) = num;
    else
        retmap(place,rowcol) = num;
    end
end

function [] = clearengine()
    global S;
    S.map = zeros(4,4);
    displaymap();
end

function [] = cb_solve(varargin)
    
    global S;
    
    set(S.ui_solve, 'string', 'ready'); 
    pause(2);
    set(S.ui_solve, 'string', 'started'); 

    S.sv_movecnt = 0;
    
    while 1
        while 1
            getscreen();
            if deadpix() > 3 || deadpix() == 0
                break;
            end
            pause(0.001);
        end
        if deadpix() > 3
            break;
        end
        pause(0.001);

        solver();
        S.sv_movecnt = S.sv_movecnt + 1;
        
        
    end

    set(S.ui_solve, 'string', 'solve'); 
    
end

function [] = getscreen()

    global S;
    
    % 해상도 변경 또는 창 위치 변경시 아래 좌표 변경
    p0 = [263, 358];
    dp = 121;
    
    robot = java.awt.Robot;
    tk = java.awt.Toolkit.getDefaultToolkit();
    scrrect = java.awt.Rectangle(tk.getScreenSize());
    scriobj = robot.createScreenCapture(scrrect);
    scridat = scriobj.getData();
    scridat = scridat.getPixels(0,0,scriobj.getWidth(),scriobj.getHeight(),[]);
    scridat = reshape(scridat(:),3,scriobj.getWidth(),scriobj.getHeight());    
    
    for i = 1:4
        for j = 1:4
            cp = p0 + [dp*(i-1) dp*(j-1)];
            
            set(S.ui.dp{i,j}, 'string', '', 'BackgroundColor', [0 0 0]);
            S.map(i, j) = -1;
            for c = 1:size(S.ccodes, 1)
                if  S.ccodes(c,1) == scridat(1, cp(1), cp(2)) && ... 
                    S.ccodes(c,2) == scridat(2, cp(1), cp(2)) && ... 
                    S.ccodes(c,3) == scridat(3, cp(1), cp(2))
               
                    if c == size(S.ccodes, 1)
                        % blank
                        S.map(i, j) = 0;
                        set(S.ui.dp{i,j}, 'string', '');
                    else
                        % not blank
                        S.map(i, j) = c;
                        set(S.ui.dp{i,j}, 'string', num2str(2^c));
                    end
                    set(S.ui.dp{i,j}, 'BackgroundColor', S.ccodes(c, :)/255); 
                    break;
                end
            end
        end
    end
    
end

function cnt = deadpix()
    
    global S;
    
    cnt = 0;
    
    for i = 1:4
        for j = 1:4
            if S.map(i, j) == -1
                cnt = cnt + 1;
            end
        end
    end
    
end

function [] = tilemove(dir)

    global S;

    try
        robot = java.awt.Robot;
        robot.keyPress(S.dirkeys(dir));
    catch
    end
    
end

function [] = solver()

    global S;

% S.sv_movecnt: 현재까지 solver 함수 호출 회수
% S.map(i, j) : 인식 받아온 4x4 맵. 0: 빈칸, 1~10: 숫자 2^(1~10). 
%               i: 가로축 왼쪽부터, j: 세로축 위부터
% tilemove(1) : 위쪽
% tilemove(2) : 아래쪽
% tilemove(3) : 왼쪽
% tilemove(4) : 아래쪽
    
% example 1. fool's method
%     if mod(S.sv_movecnt, 2) == 0
%        tilemove(4);
%     else
%        tilemove(2);
%     end

% example 2. random move
%     tilemove(floor(rand*4)+1)

% example 3. primitive selection
%     vcnt = 0;
%     hcnt = 0;
%     for i = 1:3
%         for j = 1:3
%             if S.map(i, j) ~= 0
%                 if S.map(i, j) == S.map(i+1, j)
%                     hcnt = hcnt + 1;
%                 end
%                 if S.map(i, j) == S.map(i, j+1)
%                     vcnt = vcnt + 1;
%                 end
%             end
%         end
%     end
%     
%     if vcnt > hcnt
%         tilemove(2);
%     elseif hcnt > 0
%         tilemove(4)
%     else
%         tilemove(floor(rand*4)+1);
%     end

    
end


