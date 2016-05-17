DrawPoly = 1;
NumRows = 120;
MaxLaneNum = 20; %Max number of lanes to store in 'repository'
ExpLaneNum = 2; %max number of lanes to find in the current frame
Rep_ref = zeros(ExpLaneNum, MaxLaneNum);
Count_ref = zeros(1, MaxLaneNum);
TrackThreshold = 75;

LaneColors = single([0 0 0;1 1 0; 1 1 0; 1 1 1;1 1 1]);

frameFound = 5; %min frames needed for a lane to be 'valid'

frameLost = 20; %allow a relative amount of time for frame to be lost (still within prediction range)

%--- ??? ---

% ??? Rho start values?
startIdxRho_R = 415;
NumRhos_R = 11;

startIdxTheta_R = 1;
NumThetas_R = 21;

startIdxRho_L = 380;
NumRhos_L = 36;

startIdxTheta_L = 146;
NumThetas_L = 21;

offset = int32([0, NumRows, 0, NumRows]);

%--- ??? ---

hVideoSrc = vision.VideoFileReader('viplanedeparture.avi'); % Read video file
% hVideoSrc = vision.VideoFileReader('rawActivity3Video.mp4');

hColorConv1 = vision.ColorSpaceConverter('Conversion', 'RGB to intensity');

hColorConv2 = vision.ColorSpaceConverter('Conversion', 'RGB to YCbCr');

% Supposedly the purpose of this 2D FIR Filter is to help detect edges
% found in the input video
hFilter2D = vision.ImageFilter('Coefficients', [-1 0 1], 'OutputSize', 'Same as first input', 'PaddingMethod', 'Replicate', 'Method', 'Correlation');
%I believe the image filter caters the image to filter out values to a
%fixed value of -1, 0, or 1 depending on the expected output.

% Automatically converts image intensity (grayscale?) into binary imagery
hAutothreshold = vision.Autothresholder;

% Hough Transform supposedly to help define/find lane markers from within
% the image
hHough = vision.HoughTransform('ThetaRhoOutputPort', true, 'OutputDataType', 'single');

% LocalMaximaFinder helps find the 'peaks' from the Hough Transform Output

hLocalMaxFind1 = vision.LocalMaximaFinder( ...
                        'MaximumNumLocalMaxima', ExpLaneNum, ... %max # of maxima's to find
                        'NeighborhoodSize', [301 81], ...%neighborhoodsize for 'zeroing' out values???
                        'Threshold', 1, ... %values the maxima should match or exceed
                        'HoughMatrixInput', true, ... %enabled true if hough matrix was used as the input
                        'IndexDataType', 'uint16'); %data type uint8/16/32, double, or single 
hLocalMaxFind2 = vision.LocalMaximaFinder( ...
                        'MaximumNumLocalMaxima', 1, ...
                        'NeighborhoodSize', [7 7], ...
                        'Threshold', 1, ...
                        'HoughMatrixInput', true, ...
                        'IndexDataType', 'uint16');
hLocalMaxFind3 = vision.LocalMaximaFinder( ...
                        'MaximumNumLocalMaxima', 1, ...
                        'NeighborhoodSize', [7 7], ...
                        'Threshold', 1, ...
                        'HoughMatrixInput', true, ...
                        'IndexDataType', 'uint16');

% Calculates the sines and cos functions of the hough lines?
hHoughLines1 = vision.HoughLines('SineComputation', 'Trigonometric function');
hHoughLines3 = vision.HoughLines('SineComputation', 'Trigonometric function');

% adding warning text for lane departures
warnText = {sprintf('Right\nDeparture'), '', sprintf(' Left\n Departure')};
warnTextLoc = [120 170;-1 -1; 2 170];

lineText = {'', ...
        sprintf('Yellow\nBroken'), sprintf('Yellow\nSolid'), ...
        sprintf('White\nBroken'), sprintf('White\nSolid')};
    
hVideoOut = vision.VideoPlayer;

Frame = 0;
NumNormalDriving = 0;
OutMsg = int8(-1);
OutMsgPre = OutMsg;
Broken = false;

warningTextColors = {[1 0 0], [1 0 0], [0 0 0], [0 0 0]};
while ~isDone(hVideoSrc) || 1 == 1
    RGB = step(hVideoSrc);

    % Select the lower portion of input video (confine field of view)
    Imlow  = RGB(NumRows+1:end, :, :);

    % Edge detection and Hough transform
    Imlow = step(hColorConv1, Imlow); % Convert RGB to intensity
    I = step(hFilter2D, Imlow);
    % Saturate the values to be between 0 and 1
    I(I < 0) = 0;
    I(I > 1) = 1;
    Edge = step(hAutothreshold, I);
    [H, Theta, Rho] = step(hHough, Edge);

    % Peak detection
    H1 = H;
    % Wipe out H matrix with theta < -78 deg and theta >= 78 deg
    H1(:, 1:12) = 0;
    H1(:, end-12:end) = 0;
    Idx1 = step(hLocalMaxFind1, H1);
    Count1 = size(Idx1,1);

    % Select Rhos and Thetas corresponding to peaks
    Line = [Rho(Idx1(:, 2)); Theta(Idx1(:, 1))];
    Enable = [ones(1,Count1) zeros(1, ExpLaneNum-Count1)];

    % Track a set of lane marking lines
    [Rep_ref, Count_ref] = videolanematching(Rep_ref, Count_ref, ...
                                MaxLaneNum, ExpLaneNum, Enable, Line, ...
                                TrackThreshold, frameFound+frameLost);

    % Convert lines from Polar to Cartesian space.
    Pts = step(hHoughLines1, Rep_ref(2,:), Rep_ref(1,:), Imlow);

    % Detect whether there is a left or right lane departure.
    [TwoValidLanes, NumNormalDriving, TwoLanes, OutMsg] = ...
            videodeparturewarning(Pts, Imlow, MaxLaneNum, Count_ref, ...
                                   NumNormalDriving, OutMsg);
    % Meaning of OutMsg: 0 = Right lane departure,
    %                    1 = Normal driving, 2 = Left lane departure

    % Detect the type and color of lane marker lines
    YCbCr  = step(hColorConv2, RGB(NumRows+1:240, :, :));
    ColorAndTypeIdx = videodetectcolorandtype(TwoLanes, YCbCr);
    % Meaning of ColorAndTypeIdx:
    % INVALID_COLOR_OR_TYPE = int8(0);
    % YELLOW_BROKEN = int8(1); YELLOW_SOLID = int8(2);
    % WHITE_BROKEN = int8(3);  WHITE_SOLID = int8(4).

    % Output
    Frame = Frame + 1;
    if Frame >= 5
        TwoLanes1 = TwoLanes + [offset; offset]';
        if DrawPoly && TwoValidLanes
            if TwoLanes(4,1) >= 239
                Templ = TwoLanes1(3:4, 1);
            else
                Templ = [0 239]';
            end
            if TwoLanes(4,2) >= 239
                Tempr = TwoLanes1(3:4, 2);
            else
                Tempr = [359 239]';
            end
            Pts_poly = [TwoLanes1(:,1); Templ; Tempr; ...
                TwoLanes1(3:4,2); TwoLanes1(1:2,2)];

            % Draw Polygon for lane
            RGB = insertShape(RGB,'FilledPolygon',Pts_poly.',...
                              'Color',[0 1 1],'Opacity',0.2);
        end

        % Draw lane marker lines
        RGB = insertShape(RGB,'Line',TwoLanes1',...
            'Color',{'yellow','magenta'});
        % Insert Departure warning text (empty text will not be drawn)
        txt = warnText{OutMsg+1};
        txtLoc = warnTextLoc(OutMsg+1, :);
        txtColor = single(warningTextColors{mod(Frame-1,4)+1});
        RGB = insertText(RGB,txtLoc,txt,'TextColor', txtColor, ...
                            'FontSize',20, 'BoxOpacity', 0);

        % Insert text indicating type and color of left and right lanes
        for ii=1:2
            % empty text will not be drawn
           txtLoc = TwoLanes1([1 2], ii)' + int32([0 -35]);
           lineTxt = lineText{ColorAndTypeIdx(ii)};
           txtColor = LaneColors(ColorAndTypeIdx(ii), :);
           RGB = insertText(RGB,txtLoc,lineTxt,'TextColor',txtColor, ...
                              'FontSize',14, 'BoxOpacity', 0);
        end

        % Draw third lane if needed
        if OutMsgPre ~= OutMsg
            ColorType = ColorAndTypeIdx(2-(OutMsg == 2));
            Broken    = ColorType == 2 || ColorType == 4;
        end
        ShowThirdLane = Broken && (OutMsg~=1);
        if ShowThirdLane
            if OutMsg == 0
                % Find right third lane
                Idx2 = step(hLocalMaxFind2, ...
                       H(startIdxRho_R:startIdxRho_R+NumRhos_R-1, ...
                           startIdxTheta_R:startIdxTheta_R+NumThetas_R-1));
                Rhor = Rho(Idx2(:,2) + startIdxRho_R);
                Thetar = Theta(Idx2(:,1) + startIdxTheta_R);
                ThirdLane = step(hHoughLines3, Thetar, Rhor, Imlow);
            else
                % Find left third lane
                Idx3 = step(hLocalMaxFind3, ...
                       H(startIdxRho_L:startIdxRho_L+NumRhos_L-1 , ...
                           startIdxTheta_L:startIdxTheta_L+NumThetas_L-1));
                Rhol = Rho(Idx3(:,2) + startIdxRho_L);
                Thetal = Theta(Idx3(:,1) + startIdxTheta_L);
                ThirdLane = step(hHoughLines3, Thetal, Rhol, Imlow);
            end

            OutThirdLane = videoexclude3rdlane(ThirdLane, ShowThirdLane,...
                                   TwoLanes, TwoValidLanes, YCbCr);
            OutThirdLane = OutThirdLane(:) + offset(:);
            RGB = insertShape(RGB,'Line',OutThirdLane.','Color','green');
        end
    end
    OutMsgPre = OutMsg;

    step(hVideoOut, RGB);    % Display video
end

release(hVideoSrc);






