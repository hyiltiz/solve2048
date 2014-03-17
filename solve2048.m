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

function [] = solve2048()

    global S;
    
    S.ccodes = [238, 228, 218; ...
                237, 224, 200; ...
                242, 177, 121; ...
                245, 149,  99; ...
                246, 124,  95; ...
                246,  94,  59; ...
                237, 207, 114; ...
                237, 204,  97; ...
                237, 200,  80; ...
                237, 197,  63; ... 
                204, 192, 179];
            
    S.dircodes = [0 1; 0 -1; -1 0; 1 0];
    S.dirkeys = [java.awt.event.KeyEvent.VK_UP, ...
                 java.awt.event.KeyEvent.VK_DOWN, ...
                 java.awt.event.KeyEvent.VK_LEFT, ...
                 java.awt.event.KeyEvent.VK_RIGHT];
    
    S.ui_fh = figure('unit', 'pix', 'menu', 'no', 'numbertitle', 'off', 'name', 'solve2048', ...
                     'position', [1200, 500, 500, 400]);
    S.ui_dp = cell(4, 4);
    for i = 1:4
        for j = 1:4
            S.ui.dp{i,j} = uicontrol('unit', 'pix', 'style', 'push', 'string', '', 'fontsize', 16, ...
                                     'position',  [(i-1)*100, (4-j)*100, 100, 100]);
        end
    end
    
    S.ui_solve = uicontrol('unit', 'pix', 'style', 'push', 'string', 'solve', 'fontsize', 16, ...
                           'position',  [400, 0, 100, 400], 'callback', @cb_solve);
    S.map = zeros(4, 4);

    
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


