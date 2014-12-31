%
% function MRMotion(action, varargin)
%
% A work in progress
%
function MRMotion(action, varargin)

if nargin<1,
   action='InitializeMRMotion';
end;

feval(action,varargin{:});
return;

%%%
%%%  Sub-function - InitializeMRMotion
%%%
function InitializeMRMotion()

% SET GRAY SCALE RESOLUTION
screenD = get(0, 'ScreenDepth');
if screenD>8
   grayres=256;
else
   grayres=128;
end
 
% CREATE FIGURE 
MRMotionFig = figure( ...
   'Name','MR Motion', ...
   'NumberTitle','off', 'HandleVisibility', 'on', ...
   'tag', 'MR Motion', ...
   'Visible','on', 'Resize', 'off',...
   'BusyAction','Queue','Interruptible','off', ...
   'Color', [.8 .8 .8], 'Pointer', 'watch',...
   'IntegerHandle', 'off', ...
   'Colormap', gray(grayres) );

Width = 256;
Height = 256;
btnHt = 26;
btnWt = 50;
txtHt = 18;
txtWt = 8;
menuHt = 26;
menuWt = 100;
editHt = 21;
% Spacing
space = 25;

% Adjust the size of the figure window
FigWidth = 1024-2*space;
FigHeight = 768;
FigBottomLeftX = 20;
FigBottomLeftY = 20;
figpos = [FigBottomLeftX FigBottomLeftY FigWidth FigHeight];
set(MRMotionFig,'Position',figpos);

PlotWidth = 330;
PlotHeight = FigHeight/4;

% Setting A Commonly Used Variable
Std.Interruptible = 'on';
Std.BusyAction = 'queue';    

% Defaults for image axes
Ax = Std;
Ax.Units = 'Pixels';
Ax.Parent = MRMotionFig;
Ax.ydir = 'reverse';
Ax.XLim = [.5 256.5];
Ax.YLim = [.5 256.5];
Ax.CLim = [0 1];
Ax.XTick = [];
Ax.YTick = [];

Img = Std;
Img.CData = [];
Img.Xdata = [1 256];
Img.Ydata = [1 256];
Img.CDataMapping = 'Scaled';
%Img.Erasemode = 'none';

Ctl = Std;
Ctl.Units = 'Pixels';
Ctl.Parent = MRMotionFig;

Btn = Ctl;
Btn.Parent = MRMotionFig;
Btn.Style = 'pushbutton';
Btn.Enable = 'off';

% Colors
bgcolor = [0.45 0.45 0.45];  % Background color for frames
wdcolor = [.8 .8 .8];  % Window color
fgcolor = [1 1 1];  % For text
   
%================================                           
% Elements of Userdata Structure
%================================                           
ud.OriginalImageFilename = '{NOTHING OPENED}';
ud.CorruptedImageFilename = '{NOT SAVED}';
ud.MotionFilename = '{NOTHING OPENED/SAVED}';
ud.PrintFilename = '{NOT PRINTED}';

ud.Sizex = 256;
ud.Sizey = 256;
ud.NumViews = ud.Sizey ;

ud.OriginalImage = rand(ud.Sizex,ud.Sizey);
ud.OriginalImageKSP = fft2(ud.OriginalImage);
ud.CorruptedImage = rand(ud.Sizex,ud.Sizey);      
ud.CorruptedImageKSP = fft2(ud.CorruptedImage);
ud.GradientOriginalImage  = diff( abs(ud.OriginalImage),1,1);
ud.GradientCorruptedImage = diff( abs(ud.CorruptedImage),1,1);

ud.PhaseMot = zeros(ud.NumViews,1);
ud.FrequencyMot = zeros(ud.NumViews,1);
ud.UNDOPhaseMot = zeros(ud.NumViews,1);
ud.UNDOFrequencyMot = zeros(ud.NumViews,1);

ud.ViewRangeStart = 1;
ud.ViewRangeStop = ud.NumViews;
ud.MotionMagnitude = 1.0;
ud.MotionFrequency = 10.0;

ud.OriginalImageEntropy = entropy( abs(ud.OriginalImage) );
ud.CorruptedImageEntropy = entropy( abs(ud.CorruptedImage) );
ud.EntropyChange = 0 ; 

ud.GradientOriginalImageEntropy = entropy( abs(ud.GradientOriginalImage) );
ud.GradientCorruptedImageEntropy = entropy( abs(ud.GradientCorruptedImage) );
ud.GradientEntropyChange = 0 ; 

ud.MaxMag = max(max( abs(ud.OriginalImage) ));
ud.maxW = 256;
ud.minW = 0;
ud.maxL = 257;
ud.minL = 1;

ud.ROIon = 0;
ud.ROIx1 = 1;
ud.ROIy1 = 1;
ud.ROIx2 = ud.Sizex;
ud.ROIy2 = ud.Sizey;

ud.OriginalImageROIEntropy = entropy( abs(ud.OriginalImage(ud.ROIx1:ud.ROIx2,ud.ROIy1:ud.ROIy2)) );
ud.CorruptedImageROIEntropy = entropy( abs(ud.CorruptedImage(ud.ROIx1:ud.ROIx2,ud.ROIy1:ud.ROIy2)) );
ud.ROIEntropyChange = 0 ; 

ud.GradientOriginalImageROIEntropy = entropy( abs(ud.GradientOriginalImage(ud.ROIx1:min(ud.ROIx2,ud.Sizex-1),ud.ROIy1:ud.ROIy2)) );
ud.GradientCorruptedImageROIEntropy = entropy( abs(ud.GradientCorruptedImage(ud.ROIx1:min(ud.ROIx2,ud.Sizex-1),ud.ROIy1:ud.ROIy2)) );
ud.GradientROIEntropyChange = 0 ; 


%================================
% Object Positions
%================================

OriginalPosition =  [space 6*space+Height Width Height];
CorruptedPosition = [space+Width+space 6*space+Height Width Height];

PhaseEncodePostion =     [4*space+2*Width 3*space+1*(2*space+PlotHeight) PlotWidth PlotHeight];
FrequencyEncodePostion = [4*space+2*Width 3*space+0*(2*space+PlotHeight) PlotWidth PlotHeight];

% Original Controls Positions
% LEFT MEANS RIGHT
OriginalControlsTopLeftX = OriginalPosition(1) + OriginalPosition(3) + space;
OriginalControlsTopLeftY = OriginalPosition(2) + OriginalPosition(4) - space - Height;


LoadNewImageButtonPosition = [	OriginalControlsTopLeftX - Width ...
							OriginalControlsTopLeftY - btnHt ...
							btnWt ...
							btnHt];
%----------------------
% ROI BUTTON POSITION
%----------------------
ROIButtonpos = [OriginalControlsTopLeftX - Width + btnWt ...
		OriginalControlsTopLeftY - btnHt ...
		btnWt ...
		btnHt];


DomainOriginalMenuPosition = [	OriginalControlsTopLeftX - Width ...
							OriginalControlsTopLeftY - btnHt - space ...
							menuWt ...
							menuHt];

ViewOriginalMenuPosition = [	OriginalControlsTopLeftX - Width + menuWt...
						OriginalControlsTopLeftY - btnHt - space ...
						menuWt ...
						menuHt];

ChopXOriginalButtonPosition = [	OriginalControlsTopLeftX - Width + menuWt ...
							OriginalControlsTopLeftY - btnHt ...
							menuWt/2 ...
							btnHt];

ChopYOriginalButtonPosition = [	OriginalControlsTopLeftX - Width + 1.5*menuWt...
							OriginalControlsTopLeftY - btnHt  ...
							menuWt/2 ...
							btnHt];

% Corrupted Controls Positions
CorruptedControlsTopLeftX = CorruptedPosition(1) + CorruptedPosition(3) + space;
CorruptedControlsTopLeftY = CorruptedPosition(2) + CorruptedPosition(4) - space - Height;


SaveCorruptedImageButtonPosition = [	CorruptedControlsTopLeftX - Width ...
								CorruptedControlsTopLeftY - btnHt ...
								btnWt ...
								btnHt];
%----------------------
% TIFF BUTTON POSITION
%----------------------
TIFFButtonpos = [	CorruptedControlsTopLeftX - Width + btnWt ...
			CorruptedControlsTopLeftY - btnHt ...
			btnWt ...
			btnHt];

DomainCorruptedMenuPosition = [	CorruptedControlsTopLeftX - Width ...
							CorruptedControlsTopLeftY - btnHt - space ...
							menuWt ...
							menuHt];

ViewCorruptedMenuPosition = [	CorruptedControlsTopLeftX - Width + menuWt...
						CorruptedControlsTopLeftY - btnHt - space ...
						menuWt ...
						menuHt];

ChopXCorruptedButtonPosition = [	CorruptedControlsTopLeftX - Width + menuWt ...
							CorruptedControlsTopLeftY - btnHt ...
							menuWt/2 ...
							btnHt];

ChopYCorruptedButtonPosition = [	CorruptedControlsTopLeftX - Width + 1.5*menuWt...
							CorruptedControlsTopLeftY - btnHt  ...
							menuWt/2 ...
							btnHt];

%--------------------------------------------------------------------------------------------------
% Motion Editor Controls Positions
%--------------------------------------------------------------------------------------------------
MotionEditorTopLeftX = PhaseEncodePostion(1)-space;
MotionEditorTopLeftY = PhaseEncodePostion(2) + PhaseEncodePostion(4) + 180;

MotionEditorTitlePosition = 	[ 	MotionEditorTopLeftX  ...
                                 	MotionEditorTopLeftY - menuHt ...
				              	txtWt*15 ...
                                 	btnHt ];
   
MotionEditorMotionMenuPosition = 	[ 	MotionEditorTopLeftX  + txtWt*15 ...
						MotionEditorTopLeftY - menuHt...
				                1.4*menuWt ...
                                 		menuHt ];
                           
MotionEditorMotionTypeMenuPosition = 	[ 	MotionEditorTopLeftX  + txtWt*15 + 1.4*menuWt ...
						MotionEditorTopLeftY - menuHt...
				                0.6*menuWt ...
                                 		menuHt ];

MotionEditorViewRangeText1Position = 	[ 	MotionEditorTopLeftX ...
									MotionEditorTopLeftY - 2*menuHt ...
				                 		txtWt*15 ...
                                 			menuHt ];

ViewRangeTextField1Position = 	[ 	MotionEditorTopLeftX + txtWt*15 ...
										MotionEditorTopLeftY - 2*menuHt ...
				                 			txtWt*5 ...
                                 				menuHt ];


MotionEditorViewRangeText2Position = 	[ 	MotionEditorTopLeftX + txtWt*20 ...
									MotionEditorTopLeftY - 2*menuHt ...
				                 		txtWt*5 ...
                                 			menuHt ];

    
ViewRangeTextField2Position = 	[ 	MotionEditorTopLeftX + txtWt*25 ...
										MotionEditorTopLeftY - 2*menuHt ...
				                 			txtWt*5 ...
                                 				btnHt ];

MotionEditorMagnitudeTextPosition = 	[ 	MotionEditorTopLeftX  ...
									MotionEditorTopLeftY - 3*menuHt ...
				                 		txtWt*15 ...
                                 			btnHt ];

    
MotionEditorMagnitudeTextFieldPosition = 	[ 	MotionEditorTopLeftX + txtWt*15 ...
										MotionEditorTopLeftY - 3*menuHt ...
				                 			txtWt*5 ...
                                 				btnHt ];

MotionEditorFrequencyTextPosition = 	[ 	MotionEditorTopLeftX + txtWt*20 ...
									MotionEditorTopLeftY - 3*menuHt ...
				                 		txtWt*15 ...
                                 			btnHt ];

    
MotionEditorFrequencyTextFieldPosition = 	[ 	MotionEditorTopLeftX + txtWt*35 ...
										MotionEditorTopLeftY - 3*menuHt ...
				                 			txtWt*5 ...
                                 				btnHt ];

MotionEditorZEROButtonPosition = 	[ 	MotionEditorTopLeftX + 1*btnWt ...
						MotionEditorTopLeftY - 4*menuHt...
				                btnWt ...
                                 		btnHt ]; 
       
MotionEditorADDButtonPosition = 	[ 	MotionEditorTopLeftX + 2*btnWt ...
						MotionEditorTopLeftY - 4*menuHt...
				                btnWt ...
                                 		btnHt ];

MotionEditorMULButtonPosition = 	[ 	MotionEditorTopLeftX + 2*btnWt ...
						MotionEditorTopLeftY - 5*menuHt ...
				                btnWt ...
                                 		btnHt ];

MotionEditorOVERButtonPosition = 	[ 	MotionEditorTopLeftX + 3*btnWt  ...
						MotionEditorTopLeftY - 4*menuHt ...
				                btnWt ...
                                 		btnHt ];

MotionEditorUNDOButtonPosition = 	[ 	MotionEditorTopLeftX + 3*btnWt ...
						MotionEditorTopLeftY - 5*menuHt ...
				                btnWt ...
                                 		btnHt ];

MotionEditorLOADButtonPosition = 	[ 	MotionEditorTopLeftX + 4*btnWt ...
						MotionEditorTopLeftY - 4*menuHt ...
				                btnWt ...
                                 		btnHt ];
MotionEditorSAVEButtonPosition = 	[ 	MotionEditorTopLeftX + 4*btnWt ...
						MotionEditorTopLeftY - 5*menuHt ...
				                btnWt ...
                                 		btnHt ];

PrintButtonPosition = [	OriginalControlsTopLeftX-Width-space ...
					OriginalControlsTopLeftY+Height+3*space ...
					txtWt*7 ...
					btnHt];

StatusBarPosition = [	space ...
			space ...
			txtWt*50 ...
			btnHt];

InfoListBoxPosition = [	space ...
			space + btnHt...
			txtWt*65 ...
			140];

Y = 250;
TextWpos =		[ space Y txtWt*10 btnHt ];
SliderWpos =		[ space+txtWt*11 Y 100 btnHt ];
EditWpos = 		[ space+txtWt*11+100 Y txtWt*5 btnHt];


TextLpos =		[ space Y-btnHt txtWt*10 btnHt ];
SliderLpos =		[ space+txtWt*11 Y-btnHt 100 btnHt ];
EditLpos = 		[ space+txtWt*11+100 Y-btnHt txtWt*5 btnHt];

ud.hCmapAxes = axes(Ax,'Position', [space+txtWt*11+100+txtWt*10 Y-btnHt 3*btnHt 3*btnHt]);
title('Color Mapping');
ud.hColorbar1Ax = axes(Ax, 'Position', [space+txtWt*11+100+txtWt*10 Y-btnHt-10 3*btnHt 10]);
image(Img, 'Parent', ud.hColorbar1Ax, 'Cdata', repmat(uint8(0:255),[1,1,3]));

%======================================
% Axes for Histogram of original Image
%======================================
ud.hOriginalHist = axes(Ax, ...
   'Position', [space+txtWt*11+100+txtWt*10+3*btnHt+5 Y-btnHt 3*btnHt 3*btnHt]);
title('Histogram');
ud.hColorbar2Ax = axes(Ax, 'Position', [space+txtWt*11+100+txtWt*10+3*btnHt+5 Y-btnHt-10 3*btnHt 10]);
image(Img, 'Parent', ud.hColorbar2Ax, 'Cdata', repmat(uint8(0:255),[1,1,3]));
xlabel('Original');

%======================================
% Axes for Histogram of corrupted Image
%======================================
ud.hCorruptedHist = axes(Ax, ...
   'Position', [space+txtWt*11+100+txtWt*10+6*btnHt+10 Y-btnHt 3*btnHt 3*btnHt]);
title('Histogram');
ud.hColorbar3Ax = axes(Ax, 'Position', [space+txtWt*11+100+txtWt*10+6*btnHt+10 Y-btnHt-10 3*btnHt 10]);
image(Img, 'Parent', ud.hColorbar3Ax, 'Cdata', repmat(uint8(0:255),[1,1,3]));
xlabel('Corrupted');

%================================
% Image Positions 
%================================
ud.hOriginalAxes = axes(Ax, 'Position',OriginalPosition);
ud.hOriginalImage = image(Img, ...
   'Parent', ud.hOriginalAxes);
set(ud.hOriginalAxes,'Userdata',ud.hOriginalImage);

ud.hCorruptedAxes = axes(Ax,'Position', CorruptedPosition);
ud.hCorruptedImage = image(Img, ...
   'Parent', ud.hCorruptedAxes);
set(ud.hCorruptedAxes,'Userdata',ud.hCorruptedImage);

%================================
% Axes Positions
%================================
ud.hPhaseEncode = axes(Ax, 'Position',PhaseEncodePostion );
ud.hFrequencyEncode = axes(Ax, 'Position', FrequencyEncodePostion);


%================================
% PRINT Button
%================================
ud.hPrintButton = uicontrol(Ctl, ...
   'Position',PrintButtonPosition, ...
   'Enable','on', ...
   'String','Print', ...
   'Tag','Print',...
   'Callback','MRMotion(''Print'')');
%================================
% Status Bar
%================================
uicontrol( Std, ...
   'Parent', MRMotionFig, ...
   'Style','text', ...
   'Units','pixels', ...
   'Position', StatusBarPosition, ...
   'Tag','Status',...
   'Horiz','left', ...
   'Background',wdcolor, ...
   'String','');
%================================
% InfoListBox
%================================
ud.hInfoListBox = uicontrol( Std, ...
   'Parent', MRMotionFig, ...
   'Style','listbox', ...
   'Units','pixels', ...
   'Position', InfoListBoxPosition, ...
   'Tag','InfoListBox',...
   'Horiz','left', ...
   'Background',wdcolor, ...
   'String','MRMotion Information:');

%*************************
% ORIGINAL IMAGE CONTROLS
%*************************
%================================
% Load New Image Button
%================================
ud.hLoadNewImageButton = uicontrol(Ctl, ...
   'Position',LoadNewImageButtonPosition, ...
   'Enable','on', ...
   'String','Load', ...
   'Tag','LoadNewImageButton',...
   'Callback','MRMotion(''LoadNewImage'')');
%================================
% Select ROI Button
%================================
ud.hROIButton = uicontrol(Ctl, ...
   'Position',ROIButtonpos, ...
   'Enable','on', ...
   'String','ROI', ...
   'Tag','ROIButton',...
   'Callback','MRMotion(''SelectROI'')');
%================================
% Original Image Domain Menu
%================================
ud.hDomainOriginalMenu = uicontrol(Ctl, ...
   'Style','Popupmenu',...
   'Position',DomainOriginalMenuPosition, ...
   'Enable','on', ...
   'String','Spatial|K Space|Gradient', ...
   'Tag','DomainOriginalMenu',...
   'Callback','MRMotion(''ShowImages'',1)');
%================================
% Original View Menu
%================================
ud.hOriginalViewMenu = uicontrol(Ctl, ...
   'Style','Popupmenu',...
   'Position',ViewOriginalMenuPosition, ...
   'Enable','on', ...
   'String','Magnitude|Phase|Real|Imaginary', ...
   'Tag','OriginalViewMenu',...
   'Callback','MRMotion(''ShowImages'',1)');
%================================
% Chop X Original Button
%================================
ud.hChopXOriginalButton = uicontrol(Ctl, ...
   'Position',ChopXOriginalButtonPosition, ...
   'Enable','on', ...
   'String','Chop X', ...
   'Tag','ChopXOriginalButton',...
   'Callback','MRMotion(''Chop'',1,1)');
%================================
% Chop Y Original Button
%================================
ud.hChopYOriginalButton = uicontrol(Ctl, ...
   'Position',ChopYOriginalButtonPosition, ...
   'Enable','on', ...
   'String','Chop Y', ...
   'Tag','ChopYOriginalButton',...
   'Callback','MRMotion(''Chop'',1,2)');
%*************************
% CORRUPTED IMAGE CONTROLS
%*************************
%================================
% Save Corrupted Image Button
%================================
ud.hSaveCorruptedImageButton = uicontrol(Ctl, ...
   'Position',SaveCorruptedImageButtonPosition, ...
   'Enable','on', ...
   'String','Save', ...
   'Tag','SaveCorruptedImageButton',...
   'Callback','MRMotion(''SaveCorrupted'')');
%================================
% Make TIFF Button
%================================
ud.hTIFFButton = uicontrol(Ctl, ...
   'Position',TIFFButtonpos, ...
   'Enable','on', ...
   'String','TIFF', ...
   'Tag','TIFFButton',...
   'Callback','MRMotion(''MakeTIFF'')');
%================================
% Corrupted Image Domain Menu
%================================
ud.hDomainCorruptedMenu = uicontrol(Ctl, ...
   'Style','Popupmenu',...
   'Position',DomainCorruptedMenuPosition, ...
   'Enable','on', ...
   'String','Spatial|K Space|Gradient', ...
   'Tag','DomainCorruptedMenu',...
   'Callback','MRMotion(''ShowImages'',2)');

%================================
% Corrupted View Menu
%================================
ud.hCorruptedViewMenu = uicontrol(Ctl, ...
   'Style','Popupmenu',...
   'Position',ViewCorruptedMenuPosition, ...
   'Enable','on', ...
   'String','Magnitude|Phase|Real|Imaginary', ...
   'Tag','CorruptedViewMenu',...
   'Callback','MRMotion(''ShowImages'',2)');

%================================
% Chop X Corrupted Button
%================================
ud.hChopXCorruptedButton = uicontrol(Ctl, ...
   'Position',ChopXCorruptedButtonPosition, ...
   'Enable','on', ...
   'String','Chop X', ...
   'Tag','ChopXCorruptedButton',...
   'Callback','MRMotion(''Chop'',2,1)');

%================================
% Chop Y CorruptedButton
%================================
ud.hChopYCorruptedButton = uicontrol(Ctl, ...
   'Position',ChopYCorruptedButtonPosition, ...
   'Enable','on', ...
   'String','Chop Y', ...
   'Tag','ChopYCorruptedButton',...
   'Callback','MRMotion(''Chop'',2,2)');

%************************************
% MOTION EDITOR CONTROLS
%************************************
%================================
% MOTION EDITOR TITLE TEXT
%================================
uicontrol( Std, ...
   'Parent', MRMotionFig, ...
   'Style','text', ...
   'Units','pixels', ...
   'Position', MotionEditorTitlePosition, ...
   'Horiz','center', ...
   'Background',wdcolor, ...
   'String','MOTION EDITOR');
%================================
% MOTION EDITOR MOTION MENU
%================================
ud.hMotionEditorMotionMenu = uicontrol(Ctl, ...
   'Style','Popupmenu',...
   'Position',MotionEditorMotionMenuPosition, ...
   'Enable','on', ...
   'String','Phase Encode|Frequency Encode', ...
   'Tag','MotionEditorMotionMenu',...
   'Callback','');
%================================
% MOTION EDITOR MOTION TYPE MENU
%================================
ud.hMotionEditorMotionTypeMenu = uicontrol(Ctl, ...
   'Style','Popupmenu',...
   'Position',MotionEditorMotionTypeMenuPosition, ...
   'Enable','on', ...
   'String','Sine|Ramp|Step|Rand', ...
   'Tag','MotionEditorMotionTypeMenu',...
   'Callback','');
%================================
% MOTION EDITOR VIEW RANGE TEXT1
%================================
uicontrol( Std, ...
   'Parent', MRMotionFig, ...
   'Style','text', ...
   'Units','pixels', ...
   'Position', MotionEditorViewRangeText1Position, ...
   'Horiz','center', ...
   'Background',wdcolor, ...
   'String','VIEW RANGE: ');
%====================================
% MOTION EDITOR VIEW RANGE TEXTFIELD1
%====================================
ud.hViewRangeTextField1 = uicontrol( Std, ...
   'Parent', MRMotionFig, ...
   'Style','edit', ...
   'Units','pixels', ...
   'Position', ViewRangeTextField1Position, ...
   'Tag','ViewRangeTextField1',...
   'Horiz','right', ...
   'Background',wdcolor, ...
   'String', sprintf('%d',ud.ViewRangeStart), ...
   'callback','MRMotion(''UpdateViewRangeStart'')');
%================================
% MOTION EDITOR VIEW RANGE TEXT2
%================================
uicontrol( Std, ...
   'Parent', MRMotionFig, ...
   'Style','text', ...
   'Units','pixels', ...
   'Position', MotionEditorViewRangeText2Position, ...
   'Horiz','center', ...
   'Background',wdcolor, ...
   'String',' TO ');
%====================================
% MOTION EDITOR VIEW RANGE TEXTFIELD2
%====================================
ud.hViewRangeTextField2 = uicontrol( Std, ...
   'Parent', MRMotionFig, ...
   'Style','edit', ...
   'Units','pixels', ...
   'Position', ViewRangeTextField2Position, ...
   'Tag','ViewRangeTextField2',...
   'Horiz','right', ...
   'Background',wdcolor, ...
   'String', sprintf('%d',ud.ViewRangeStop), ...
   'callback','MRMotion(''UpdateViewRangeStop'')');
%================================
% MOTION EDITOR MAGNITUDE TEXT
%================================
uicontrol( Std, ...
   'Parent', MRMotionFig, ...
   'Style','text', ...
   'Units','pixels', ...
   'Position', MotionEditorMagnitudeTextPosition, ...
   'Horiz','center', ...
   'Background',wdcolor, ...
   'String','MAGNITUDE: ');
%====================================
% MOTION EDITOR MAGNITUDE TEXTFIELD
%====================================
ud.hMotionEditorMagnitudeTextField = uicontrol( Std, ...
   'Parent', MRMotionFig, ...
   'Style','edit', ...
   'Units','pixels', ...
   'Position', MotionEditorMagnitudeTextFieldPosition, ...
   'Tag','MotionEditorMagnitudeTextField',...
   'Horiz','right', ...
   'Background',wdcolor, ...
   'String', sprintf('%.2f',ud.MotionMagnitude), ...
   'callback','MRMotion(''UpdateMagnitude'')');
%================================
% MOTION EDITOR FREQUENCY TEXT
%================================
uicontrol( Std, ...
   'Parent', MRMotionFig, ...
   'Style','text', ...
   'Units','pixels', ...
   'Position', MotionEditorFrequencyTextPosition, ...
   'Horiz','center', ...
   'Background',wdcolor, ...
   'String','FREQUENCY: ');
%====================================
% MOTION EDITOR FREQUENCY TEXTFIELD
%====================================
ud.hMotionEditorFrequencyTextField = uicontrol( Std, ...
   'Parent', MRMotionFig, ...
   'Style','edit', ...
   'Units','pixels', ...
   'Position', MotionEditorFrequencyTextFieldPosition, ...
   'Tag','MotionEditorFrequencyTextField',...
   'Horiz','right', ...
   'Background',wdcolor, ...
   'String', sprintf('%.2f',ud.MotionFrequency), ...
   'callback','MRMotion(''UpdateFrequency'')');
%================================
% MOTION EDITOR ADD BUTTON
%================================
ud.hMotionEditorADDButton = uicontrol(Ctl, ...
   'Position',MotionEditorADDButtonPosition, ...
   'Enable','on', ...
   'String','ADD', ...
   'Tag','MotionEditorADDButton',...
   'Callback','MRMotion(''EditMotion'',1)');
%================================
% MOTION EDITOR MUL BUTTON
%================================
ud.hMotionEditorMULButton = uicontrol(Ctl, ...
   'Position',MotionEditorMULButtonPosition, ...
   'Enable','on', ...
   'String','MUL', ...
   'Tag','MotionEditorMULButton',...
   'Callback','MRMotion(''EditMotion'',2)');
%================================
% MOTION EDITOR OVER BUTTON
%================================
ud.hMotionEditorOVERButton = uicontrol(Ctl, ...
   'Position',MotionEditorOVERButtonPosition, ...
   'Enable','on', ...
   'String','OVER', ...
   'Tag','MotionEditorOVERButton',...
   'Callback','MRMotion(''EditMotion'',3)');
%================================
% MOTION EDITOR UNDO BUTTON
%================================
ud.hMotionEditorUNDOButton = uicontrol(Ctl, ...
   'Position',MotionEditorUNDOButtonPosition, ...
   'Enable','on', ...
   'String','UNDO', ...
   'Tag','MotionEditorUNDOButton',...
   'Callback','MRMotion(''EditMotion'',4)');
%================================
% MOTION EDITOR ZERO BUTTON
%================================
ud.hMotionEditorZEROButton = uicontrol(Ctl, ...
   'Position',MotionEditorZEROButtonPosition, ...
   'Enable','on', ...
   'String','ZERO', ...
   'Tag','MotionEditorADDButton',...
   'Callback','MRMotion(''EditMotion'',5)');
%================================
% MOTION EDITOR SAVE BUTTON
%================================
ud.hMotionEditorSAVEButton = uicontrol(Ctl, ...
   'Position',MotionEditorSAVEButtonPosition, ...
   'Enable','on', ...
   'String','SAVE', ...
   'Tag','MotionEditorSAVEButton',...
   'Callback','MRMotion(''SaveMotion'')');
%================================
% MOTION EDITOR LOAD BUTTON
%================================
ud.hMotionEditorLOADButton = uicontrol(Ctl, ...
   'Position',MotionEditorLOADButtonPosition, ...
   'Enable','on', ...
   'String','LOAD', ...
   'Tag','MotionEditorLOADButton',...
   'Callback','MRMotion(''LoadMotion'')');
%================================
% WINDOW TEXT
%================================
uicontrol( Std, ...
   'Parent', MRMotionFig, ...
   'Style','text', ...
   'Units','pixels', ...
   'Position', TextWpos, ...
   'Horiz','center', ...
   'Background',wdcolor, ...
   'String','WINDOW');
%================================
% LEVEL TEXT
%================================
uicontrol( Std, ...
   'Parent', MRMotionFig, ...
   'Style','text', ...
   'Units','pixels', ...
   'Position', TextLpos, ...
   'Horiz','center', ...
   'Background',wdcolor, ...
   'String','LEVEL');
%================================
% WINDOW SLIDER
%================================
ud.hSliderW = uicontrol('CallBack', 'MRMotion(''WindowLevelAction'',1)', ...
                     	'Max', ud.maxW, 'Min', ud.minW, 'value', ud.maxW, ...
                     	'Units','pixels', 'Position',SliderWpos, ...
                     	'Style','slider');
%================================
% LEVEL SLIDER
%================================
ud.hSliderL = uicontrol('CallBack','MRMotion(''WindowLevelAction'',2)', ...
                        'Max',ud.maxL, 'Min', ud.minL, 'value', ud.minL , ...
                     	'Units','pixels', 'Position',SliderLpos, ...
                     	'Style','slider');
%================================
% WINDOW EDITBOX
%================================
ud.hEditW = uicontrol(	'style','edit','horizontalalignment','right',...
					'Units','pixels', ...
      				'position',EditWpos,...
      				'string', sprintf('%.0f',ud.maxW) ,...
      				'backgroundcolor','w',...
      				'max',1,...
      				'callback','MRMotion(''WindowLevelAction'',3)');
%================================
% LEVEL EDITBOX
%================================
ud.hEditL = uicontrol(	'style','edit','horizontalalignment','right',...
					'Units','pixels', ...
      				'position',EditLpos,...
      				'string', sprintf('%.0f',ud.minL),...
      				'backgroundcolor','w',...
      				'max',1,...
      				'callback','MRMotion(''WindowLevelAction'',4)');

W = get(ud.hSliderW,'value');
L = get(ud.hSliderL,'value');
ud.cmap = WindowLevel(W,L);
axes(ud.hOriginalAxes);
colormap(ud.cmap);
axes(ud.hCorruptedAxes);
colormap(ud.cmap);
axes(ud.hCmapAxes);
plot(1:256,ud.cmap(:,1));
title('Color Mapping');
set(ud.hCmapAxes, 'Xtick', []);
axis([1 256 -0.05 1.05]);

set(MRMotionFig, 'UserData', ud, 'Visible','on');
MRMotion('ShowImages',1,MRMotionFig);
MRMotion('ShowImages',2,MRMotionFig);
MRMotion('PlotMotions',1,MRMotionFig);
MRMotion('PlotMotions',2,MRMotionFig);
MRMotion('UpdateInfoBox',MRMotionFig);
set(MRMotionFig,'Pointer','arrow','HandleVisibility', 'on');

% TURN ON THE ZOOM!
zoom on;

return

%%%++++++++++++++++++++++++++++++++++
%%%  Sub-Function - LoadNewImage
%%%++++++++++++++++++++++++++++++++++
function LoadNewImage()

MRMotionFig = gcbf;
ud=get(MRMotionFig,'Userdata');
s = openfile('.','*.ksp, *.img, *.cimg, *.bef, *.aft, *.mat');

if isempty(s),
  	setstatus(MRMotionFig, ['Unable to load image!']);
	drawnow;
 	return;
else
	temp = find(s=='/');
	name = sprintf('%s', s( (temp(length(temp))+1):length(s) ) );
	setstatus(MRMotionFig, ['Loading image ' name ' ...']);
	drawnow;
	ud.OriginalImage = LoadMRimage(s, ud.Sizex, ud.Sizey);
	if isempty(ud.OriginalImage),
	 	setstatus(MRMotionFig, ['Image contains no data']);
		return;
	end
	ud.OriginalImageFilename = name;
	ud.OriginalImageEntropy = entropy( abs(ud.OriginalImage) );
	ud.OriginalImageROIEntropy = entropy( abs(ud.OriginalImage(ud.ROIx1:ud.ROIx2,ud.ROIy1:ud.ROIy2)) );
	ud.GradientOriginalImage  = diff(abs(ud.OriginalImage),1,1);
	ud.GradientOriginalImageEntropy = entropy( abs(ud.GradientOriginalImage) );
	ud.GradientOriginalImageROIEntropy = entropy( abs(ud.GradientOriginalImage(ud.ROIx1:min(ud.ROIx2,ud.Sizex-1),ud.ROIy1:ud.ROIy2)) );
	ud.MaxMag = max(max( abs(ud.OriginalImage) ));
	ud.OriginalImageKSP = fft2(ud.OriginalImage);
	set(MRMotionFig,'Userdata',ud);
	MRMotion('ShowImages',1,MRMotionFig);
	MRMotion('ApplyMotion',MRMotionFig);
	MRMotion('ShowImages',2,MRMotionFig);
	setstatus(MRMotionFig,'');
	UpdateInfoBox(MRMotionFig);
end

return

%%%++++++++++++++++++++++++++++++++++
%%%  Sub-Function - ShowImages
%%%++++++++++++++++++++++++++++++++++
function ShowImages(ImageNum, MRMotionFig)

if nargin<2,
  MRMotionFig = gcbf;
end

ud = get(MRMotionFig,'Userdata');

switch ImageNum
case 1

Domain = get(ud.hDomainOriginalMenu,'value');
View = get(ud.hOriginalViewMenu,'value');

switch Domain,
case 1,
   img = ud.OriginalImage ; 
   s1 = '';
case 2,
   img = ud.OriginalImageKSP ;
   s1 = 'Spectrum';
case 3,
   img = ud.GradientOriginalImage;
   s1 = 'Gradient (P.E.)';
   View = 1;
end

switch View,
case 1,
   img = abs(img); 
   s2 = 'Magnitude';
case 2,
   img = ( angle(img) );
   s2 = 'Phase';
case 3,
   img = real(img);
   s2 = 'Real';
case 4,
   img = imag(img); 
   s2 = 'Imag';
end

if View~=1,
   % Make img all positive for imageadjustment to work
   img = img - min(min(img));
end

if strcmp(s1,'Spectrum') & ~strcmp(s2,'Phase'),
   %img = dB(img);
   img = 10*log10(abs(img)+eps);
end

if ~strcmp(s1,'Spectrum') & strcmp(s2,'Magnitude'),
  img = img/ud.MaxMag;
else
  img=img/max(max(img));
end

if ud.ROIon==1 & Domain==2,
  set(ud.ROIlh(1:4),'visible','off');
elseif ud.ROIon==1,
  set(ud.ROIlh(1:4),'visible','on');
end

MRMotionDoHist(img,ud.hOriginalHist);
set(ud.hOriginalImage,'Cdata',img);
set(MRMotionFig,'Userdata',ud);
s = sprintf('Original Image %s (%s)', s1, s2);
axes(ud.hOriginalAxes);
title(s)
drawnow

case 2

Domain = get(ud.hDomainCorruptedMenu,'value');
View = get(ud.hCorruptedViewMenu,'value');

switch Domain,
case 1,
   img = ud.CorruptedImage ;
   s1 = '';
case 2,
   img = ud.CorruptedImageKSP ;
   s1 = 'Spectrum';
case 3,
   img = ud.GradientCorruptedImage;
   s1 = 'Gradient (P.E.)';
   View = 1;   
end

switch View,
case 1,
   img = abs(img);
   s2 = 'Magnitude';
case 2,
   img = ( angle(img) );
   s2 = 'Phase';
case 3,
   img = real(img);
   s2 = 'Real';
case 4,
   img = imag(img); 
   s2 = 'Imag';
end

if View~=1,
   % Make img all positive for imageadjustment to work
   img = img - min(min(img));
end

if strcmp(s1,'Spectrum') & ~strcmp(s2,'Phase'),
   %img = dB(img);
   img = 10*log10(abs(img)+eps);
end

if ~strcmp(s1,'Spectrum') & strcmp(s2,'Magnitude'),
  img = img/ud.MaxMag;
else
  img=img/max(max(img));
end

if ud.ROIon==1 & Domain==2,
  set(ud.ROIlh(5:8),'visible','off');
elseif ud.ROIon==1,
  set(ud.ROIlh(5:8),'visible','on');
end

MRMotionDoHist(img, ud.hCorruptedHist);
set(ud.hCorruptedImage,'Cdata',img);
set(MRMotionFig,'Userdata',ud);
s = sprintf('Corrupted Image %s (%s)', s1, s2);
axes(ud.hCorruptedAxes);
title(s);
drawnow

end

return
%%%++++++++++++++++++++++++++++++++++
%%%  Sub-Function - Chop
%%%++++++++++++++++++++++++++++++++++
function Chop(ImageNum, ChopType, MRMotionFig)

if nargin<3,
  MRMotionFig = gcbf;
end

ud = get(MRMotionFig,'Userdata');

switch ImageNum
case 1
[sizeX sizeY] = size(ud.OriginalImageKSP);
	switch ChopType
	case 1	
	half = floor( (sizeY + 1)/2 );
	temp = ud.OriginalImageKSP(:,1:half);
	ud.OriginalImageKSP(:,1:half) = ud.OriginalImageKSP(:,(half+1):sizeY);
	ud.OriginalImageKSP(:,(half+1):sizeY) = temp;
	ud.OriginalImage = ifft2(ud.OriginalImageKSP);
	case 2
	half = floor( (sizeX + 1)/2 );
	temp = ud.OriginalImageKSP(1:half,:);
	ud.OriginalImageKSP(1:half,:) = ud.OriginalImageKSP((half+1):sizeX,:);
	ud.OriginalImageKSP((half+1):sizeX,:) = temp;
	ud.OriginalImage = ifft2(ud.OriginalImageKSP);
	end
	set(MRMotionFig,'Userdata',ud);
	MRMotion('ShowImages',1,MRMotionFig);
case 2
[sizeX sizeY] = size(ud.CorruptedImageKSP);
	switch ChopType
	case 1	
	half = floor( (sizeY + 1)/2 );
	temp = ud.CorruptedImageKSP(:,1:half);
	ud.CorruptedImageKSP(:,1:half) = ud.CorruptedImageKSP(:,(half+1):sizeY);
	ud.CorruptedImageKSP(:,(half+1):sizeY) = temp;
	ud.CorruptedImage = ifft2(ud.CorruptedImageKSP);
	case 2
	half = floor( (sizeX + 1)/2 );
	temp = ud.CorruptedImageKSP(1:half,:);
	ud.CorruptedImageKSP(1:half,:) = ud.CorruptedImageKSP((half+1):sizeX,:);
	ud.CorruptedImageKSP((half+1):sizeX,:) = temp;
	ud.CorruptedImage = ifft2(ud.CorruptedImageKSP);
	end
	set(MRMotionFig,'Userdata',ud);
	MRMotion('ShowImages',2,MRMotionFig);
end

%%%++++++++++++++++++++++++++++++++++
%%%  Sub-Function - PlotMotions
%%%++++++++++++++++++++++++++++++++++
function PlotMotions(MotionNum, MRMotionFig)

if nargin<2,
  MRMotionFig = gcbf;
end

ud = get(MRMotionFig,'Userdata');

switch MotionNum

case 1

axes(ud.hPhaseEncode);
color = 'r';
yl = 'Pixels';
xl = '';
t = 'Phase Encode';
y = ud.PhaseMot;
x = 1:length(y);
plot(x,y,color);
grid on;
if min(y)~=max(y),
  range = abs(max(y)-min(y));
  axis([min(x) max(x) min(y)-0.1*range max(y)+0.1*range]);
else
  axis([min(x) max(x) -1 1]);
end
xlabel(xl);
ylabel(yl);
title(t);

case 2

axes(ud.hFrequencyEncode);
color = 'b';
yl = 'Pixels';
xl = sprintf('K Space View Number (DC=%d)', ud.Sizex/2);
t = 'Frequency Encode';
y = ud.FrequencyMot;
x = 1:length(y);
plot(x,y,color);
grid on;
if min(y)~=max(y),
  range = abs(max(y)-min(y));
  axis([min(x) max(x) min(y)-0.1*range max(y)+0.1*range]);
else
  axis([min(x) max(x) -1 1]);
end
xlabel(xl);
ylabel(yl);
title(t);

end

drawnow

return

%%%++++++++++++++++++++++++++++++++++
%%%  Sub-Function - EditMotion
%%%++++++++++++++++++++++++++++++++++
function EditMotion(EditType,MRMotionFig)

if nargin<2,
  MRMotionFig = gcbf;
end

ud = get(MRMotionFig,'Userdata');
 
motion = ud.ViewRangeStart:1:ud.ViewRangeStop;

switch get(ud.hMotionEditorMotionTypeMenu,'value');
case 1
% SINE
motion = ud.MotionMagnitude*sin(2*pi/ud.MotionFrequency*motion);
motion = motion';
case 2
% Ramp
inc = ud.MotionMagnitude/length(motion) ;

if inc==0,
  motion = 0*motion;
elseif inc>0,
  motion = 0:inc:(ud.MotionMagnitude-inc);
else
  motion = abs(ud.MotionMagnitude-inc):inc:0;
end
motion = motion';
case 3
% Step
motion = ud.MotionMagnitude*ones(length(motion),1);
case 4
% RANDOM
motion = ud.MotionMagnitude*rand(length(motion),1);
end

switch get(ud.hMotionEditorMotionMenu,'value')
case 1
	% Phase Encode
	temp = ud.PhaseMot;

	switch EditType
	case 1 % ADD
	ud.PhaseMot(ud.ViewRangeStart:ud.ViewRangeStop) = ...
	ud.PhaseMot(ud.ViewRangeStart:ud.ViewRangeStop) + motion;
	case 2 % MULTIPLY
	ud.PhaseMot(ud.ViewRangeStart:ud.ViewRangeStop) = ...
	ud.PhaseMot(ud.ViewRangeStart:ud.ViewRangeStop) .* motion;
	case 3 % OVERWRITE
	ud.PhaseMot(ud.ViewRangeStart:ud.ViewRangeStop) = motion;
	case 4 % UNDO
	ud.PhaseMot = ud.UNDOPhaseMot;
	case 5 % ZERO
	ud.PhaseMot = 0*ud.PhaseMot;	
	end

	ud.UNDOPhaseMot = temp;
	set(MRMotionFig,'Userdata',ud);
	MRMotion('PlotMotions',1,MRMotionFig);
case 2
	% Frequency Encode
	temp = ud.FrequencyMot;
	switch EditType
	case 1 % ADD
	ud.FrequencyMot(ud.ViewRangeStart:ud.ViewRangeStop) = ...
	ud.FrequencyMot(ud.ViewRangeStart:ud.ViewRangeStop) + motion;
	case 2 % MULTIPLY
	ud.FrequencyMot(ud.ViewRangeStart:ud.ViewRangeStop) = ...
	ud.FrequencyMot(ud.ViewRangeStart:ud.ViewRangeStop) .* motion;
	case 3 % OVERWRITE
	ud.FrequencyMot(ud.ViewRangeStart:ud.ViewRangeStop) = motion;
	case 4 % UNDO
	ud.FrequencyMot = ud.UNDOFrequencyMot;
	case 5 % ZERO
	ud.FrequencyMot = 0*ud.FrequencyMot;
	end
	ud.UNDOFrequencyMot = temp;
	set(MRMotionFig,'Userdata',ud);
	MRMotion('PlotMotions',2,MRMotionFig);
case 3
	% Rotation
	temp = ud.RotationMot;
	switch EditType
	case 1 % ADD
	ud.RotationMot(ud.ViewRangeStart:ud.ViewRangeStop) = ...
	ud.RotationMot(ud.ViewRangeStart:ud.ViewRangeStop) + motion;
	case 2 % MULTIPLY
	ud.RotationMot(ud.ViewRangeStart:ud.ViewRangeStop) = ...
	ud.RotationMot(ud.ViewRangeStart:ud.ViewRangeStop) .* motion;
	case 3 % OVERWRITE
	ud.RotationMot(ud.ViewRangeStart:ud.ViewRangeStop) = motion;
	case 4 % UNDO
	ud.RotationMot = ud.UNDORotationMot;
	end
	ud.UNDORotationMot = temp;
	set(MRMotionFig,'Userdata',ud);
	MRMotion('PlotMotions',3,MRMotionFig);
end

MRMotion('ApplyMotion',MRMotionFig);
MRMotion('ShowImages',2,MRMotionFig);
MRMotion('UpdateInfoBox',MRMotionFig);

return

%%%++++++++++++++++++++++++++++++++++
%%%  Sub-Function - ApplyMotion
%%%++++++++++++++++++++++++++++++++++
function ApplyMotion(MRMotionFig)

if nargin<1,
  MRMotionFig = gcbf;
end

setstatus(MRMotionFig,'Applying Motion Corruption ...');
ud = get(MRMotionFig,'Userdata');
ud.CorruptedImageKSP = ApplyMotionCorruption(ud.OriginalImageKSP,ud.PhaseMot,ud.FrequencyMot);
ud.CorruptedImage = ifft2(ud.CorruptedImageKSP);
ud.CorruptedImageEntropy = entropy( abs(ud.CorruptedImage) );
ud.CorruptedImageROIEntropy = entropy( abs(ud.CorruptedImage(ud.ROIx1:ud.ROIx2,ud.ROIy1:ud.ROIy2)) );
ud.GradientCorruptedImage = diff(abs(ud.CorruptedImage),1,1);
ud.GradientCorruptedImageEntropy = entropy( abs(ud.GradientCorruptedImage) );
ud.GradientCorruptedImageROIEntropy = entropy( abs(ud.GradientCorruptedImage(ud.ROIx1:min(ud.ROIx2,ud.Sizex-1),ud.ROIy1:ud.ROIy2)) );
ud.EntropyChange =  (ud.CorruptedImageEntropy - ud.OriginalImageEntropy)/ud.OriginalImageEntropy;
ud.ROIEntropyChange = (ud.CorruptedImageROIEntropy - ud.OriginalImageROIEntropy)/...
				ud.OriginalImageROIEntropy; 
ud.GradientEntropyChange =  (ud.GradientCorruptedImageEntropy - ud.GradientOriginalImageEntropy)/ud.GradientOriginalImageEntropy;
ud.GradientROIEntropyChange = (ud.GradientCorruptedImageROIEntropy - ud.GradientOriginalImageROIEntropy)/...
				ud.GradientOriginalImageROIEntropy; 
set(MRMotionFig,'Userdata', ud);
setstatus(MRMotionFig,'');

return
%%%++++++++++++++++++++++++++++++++++++++++++++++++++++++
%%%  Sub-Function - UpdateViewRangeStart
%%%++++++++++++++++++++++++++++++++++++++++++++++++++++++
function UpdateViewRangeStart(MRMotionFig)

if nargin<1,
  MRMotionFig = gcbf;
end

ud = get(MRMotionFig,'Userdata');
Entered = str2num( get(ud.hViewRangeTextField1,'String') );

if isempty(Entered),
  Entered = ud.ViewRangeStart;
elseif Entered<1,
  Entered = ud.ViewRangeStart;
else
  ud.ViewRangeStart = Entered;
  set(MRMotionFig,'Userdata',ud);
end

set( ud.hViewRangeTextField1,'String', sprintf('%d',Entered) );

return
%%%++++++++++++++++++++++++++++++++++++++++++++++++++++++
%%%  Sub-Function - UpdateViewRangeStop
%%%++++++++++++++++++++++++++++++++++++++++++++++++++++++
function UpdateViewRangeStop(MRMotionFig)

if nargin<1,
  MRMotionFig = gcbf;
end

ud = get(MRMotionFig,'Userdata');
Entered = str2num( get(ud.hViewRangeTextField2,'String') );

if isempty(Entered),
  Entered = ud.ViewRangeStop;
elseif (Entered<ud.ViewRangeStart) | (Entered > ud.NumViews),
  Entered = ud.ViewRangeStop;
else
  ud.ViewRangeStop = Entered;
  set(MRMotionFig,'Userdata',ud);
end

set( ud.hViewRangeTextField2,'String', sprintf('%d',Entered) );

return
%%%++++++++++++++++++++++++++++++++++++++++++++++++++++++
%%%  Sub-Function - UpdateMagnitude
%%%++++++++++++++++++++++++++++++++++++++++++++++++++++++
function UpdateMagnitude(MRMotionFig)

if nargin<1,
  MRMotionFig = gcbf;
end

ud = get(MRMotionFig,'Userdata');
Entered = str2num( get(ud.hMotionEditorMagnitudeTextField,'String') );
if isempty(Entered),
  Entered = ud.MotionMagnitude;
else
  ud.MotionMagnitude = Entered;
  set(MRMotionFig,'Userdata',ud);
end
set( ud.hMotionEditorMagnitudeTextField,'String', sprintf('%.2f',Entered) );

return
%%%++++++++++++++++++++++++++++++++++++++++++++++++++++++
%%%  Sub-Function - UpdateFrequency
%%%++++++++++++++++++++++++++++++++++++++++++++++++++++++
function UpdateFrequency(MRMotionFig)

if nargin<1,
  MRMotionFig = gcbf;
end

ud = get(MRMotionFig,'Userdata');
Entered = str2num( get(ud.hMotionEditorFrequencyTextField,'String') );
if isempty(Entered),
  Entered = ud.MotionFrequency;
else
  ud.MotionFrequency = Entered;
  set(MRMotionFig,'Userdata',ud);
end
set( ud.hMotionEditorFrequencyTextField,'String', sprintf('%.2f',Entered) );

return
%%%++++++++++++++++++++++++++++++++++++++++++++++++++++++
%%%  Sub-Function - Print
%%%++++++++++++++++++++++++++++++++++++++++++++++++++++++
function Print(MRMotionFig)

if nargin<1,
  MRMotionFig = gcbf;
end

ud = get(MRMotionFig,'UserData');

set(MRMotionFig,'PaperUnits','points','PaperOrientation','landscape');
figpos = get(MRMotionFig,'Position');
set(MRMotionFig,'PaperPosition',[0 0 figpos(3) figpos(4)]);
setstatus(MRMotionFig,datestr(now));

s = savefile('.','*.eps');

if isempty(s)
  setstatus(MRMotion,'Nothing Printed');
else
  printcommand = sprintf('print -deps %s', s);
  eval(printcommand);
  setstatus(MRMotionFig,'');
  temp = find(s=='/');
  name = sprintf('%s', s( (temp(length(temp))+1):length(s) ) );
  ud.PrintFilename = name;
  set(MRMotionFig,'Userdata',ud);
  UpdateInfoBox(MRMotionFig);
end

return

%%%+++++++++++++++++++++++++++++++++++++
%%%  Sub-Function - SaveCorrupted
%%%+++++++++++++++++++++++++++++++++++++
function SaveCorrupted(MRMotionFig)

if nargin<1,
  MRMotionFig = gcbf;
end

ud = get(MRMotionFig,'Userdata');

s = savefile('.','*.ksp, *.img, *.cimg, *.tif');
temp = find(s=='/');
name = sprintf('%s', s( (temp(length(temp))+1):length(s) ) );

success = SaveMRimage(ud.CorruptedImage, s);
if success==1,
  setstatus(MRMotionFig,['Successfully saved file: ' name]);
  ud.CorruptedImageFilename = name;
  set(MRMotionFig,'Userdata',ud);
  UpdateInfoBox(MRMotionFig);
else
  setstatus(MRMotionFig,['Cannot save file']);
end

return

%%%+++++++++++++++++++++++++++++++++++++
%%%  Sub-Function - SaveMotion
%%%+++++++++++++++++++++++++++++++++++++
function SaveMotion(MRMotionFig)

if nargin<1,
  MRMotionFig = gcbf;
end

ud = get(MRMotionFig,'Userdata');

s = savefile('.','*.mot');
temp = find(s=='/');
name = sprintf('%s', s( (temp(length(temp))+1):length(s) ) );

motions(:,1) = ud.PhaseMot;
motions(:,2) = ud.FrequencyMot;
fid = fopen(s,'w');

if fid==-1,
  setstatus(MRMotionFig,['Cannot save file']);
  return;
else
 fprintf(fid,'%5.5f    %5.5f\n',motions');
end

if fclose(fid)==0,
  setstatus(MRMotionFig,['Successfully saved file: ' name]);
  ud.MotionFilename = name;
  set(MRMotionFig,'Userdata',ud);
  UpdateInfoBox(MRMotionFig);
else
  setstatus(MRMotionFig,['Cannot save file']);
end

return

%%%+++++++++++++++++++++++++++++++++++++
%%%  Sub-Function - LoadMotion
%%%+++++++++++++++++++++++++++++++++++++
function LoadMotion()

MRMotionFig = gcbf;
ud=get(MRMotionFig,'Userdata');
s = openfile('.','*.mot');

if isempty(s),
  	setstatus(MRMotionFig, ['Unable to load motion file!']);
	drawnow;
 	return;
else
	temp = find(s=='/');
	name = sprintf('%s', s( (temp(length(temp))+1):length(s) ) );
	setstatus(MRMotionFig, ['Loading motion file: ' name ' ...']);
	drawnow;
	motions = load(s);
	if isempty(motions),
	 	setstatus(MRMotionFig, ['Motion file contains no data']);
		return;
	else
		ud.MotionFilename = name;
		if size(motions,2)==2,
			ud.PhaseMot = motions(:,1);
			ud.FrequencyMot = motions(:,2);
		else
			ud.PhaseMot = motions(:,1);
			ud.FrequencyMot =zeros(ud.Sizey,1);
		end

		set(MRMotionFig,'Userdata',ud);
		MRMotion('PlotMotions',1,MRMotionFig);
		MRMotion('PlotMotions',2,MRMotionFig);
		MRMotion('ApplyMotion',MRMotionFig);
		MRMotion('ShowImages',2,MRMotionFig);
		setstatus(MRMotionFig,'');
		UpdateInfoBox(MRMotionFig);
	end
end

return

%%%+++++++++++++++++++++++++++++++++++++
%%%  Sub-Function - UpdateInfoBox
%%%+++++++++++++++++++++++++++++++++++++
function UpdateInfoBox(MRMotionFig)

ud = get(MRMotionFig,'Userdata');

s1 = sprintf('%-20s  %-25s%-14s%-25s','Original:',  ud.OriginalImageFilename,  'Motions:',  ud.MotionFilename);
s2 = sprintf('%-20s%-25s     %-15s%-25s','Corrupted:', ud.CorruptedImageFilename, 'Printout:', ud.PrintFilename);
s3 = sprintf('%s','');
s4 = sprintf('%+50s %30s  (%d,%d)->(%d,%d)','Entire Image',' ROI :', ud.ROIx1, ud.ROIy1, ud.ROIx2, ud.ROIy2);
s5 = sprintf('%15s%14s%16s%26s%16s','Cost Function','Original','Corruption','Original','Corruption');
s6 = sprintf('%+18s%12.3f%12.3f  (%5.1f%%)   %12.3f%12.3f  (%5.1f%%)', 'Entropy', ...
		ud.OriginalImageEntropy, ud.CorruptedImageEntropy, ud.EntropyChange*100, ... 
		ud.OriginalImageROIEntropy, ud.CorruptedImageROIEntropy, ud.ROIEntropyChange*100 );
s7 = sprintf('%+16s%12.3f%12.3f  (%5.1f%%)   %12.3f%12.3f  (%5.1f%%)', 'Grad. Entropy', ...
		ud.GradientOriginalImageEntropy, ud.GradientCorruptedImageEntropy, ud.GradientEntropyChange*100, ...
		ud.GradientOriginalImageROIEntropy, ud.GradientCorruptedImageROIEntropy, ud.GradientROIEntropyChange*100 );
s8 = sprintf('%s','X-Axis Vertical, (1,1) at top left');

info = {s1 s2 s3 s4 s5 s6 s7 s8};
set(ud.hInfoListBox,'String',info);

return


%%%+++++++++++++++++++++++++++++++++++++
%%%  Sub-Function - WindowLevelAction
%%%+++++++++++++++++++++++++++++++++++++
function WindowLevelAction(action,MRMotionFig)

if nargin<2,
  MRMotionFig=gcbf;
end

ud = get(MRMotionFig,'Userdata');

switch action,
case 1

value = get(ud.hSliderW,'value');
value = round(value);
set(ud.hSliderW,'value',value);
set(ud.hEditW,'string',sprintf('%0.f',value));

case 2

value = get(ud.hSliderL,'value');
value = round(value);
set(ud.hSliderL,'value',value);
set(ud.hEditL,'string',sprintf('%0.f',value));

case 3

value = str2num( get(ud.hEditW,'string') );
value = round(value);

if value>=ud.minW & value<=ud.maxW,
	set(ud.hSliderW,'value',value);
	set(ud.hEditW,'string', sprintf('%.0f',value) );
else
	value = get(ud.hSliderW,'value');
	set(ud.hSliderW,'value',value);
	set(ud.hEditW,'string', sprintf('%.0f',value));
end

case 4

value = str2num( get(ud.hEditL,'string') );
value = round(value);

if value>=ud.minL & value<=ud.maxL,
	set(ud.hSliderL,'value',value);
	set(ud.hEditL,'string', sprintf('%0.f',value) );
else
	value = get(ud.hSliderL,'value');
	set(ud.hSliderL,'value',value);
	set(ud.hEditL,'string', sprintf('%0.f',value));
end


end

W = get(ud.hSliderW,'value');
L = get(ud.hSliderL,'value');
ud.cmap = WindowLevel(W,L);
axes(ud.hOriginalAxes);
colormap(ud.cmap);
axes(ud.hCorruptedAxes);
colormap(ud.cmap);
axes(ud.hCmapAxes);
plot(1:256,ud.cmap(:,1));
title('Color Mapping');
set(ud.hCmapAxes, 'Xtick', []);
axis([1 256 -0.05 1.05]);

set(MRMotionFig,'Userdata',ud);

return


%%%
%%%  Sub-function - MRMotionDoHist
%%%

function MRMotionDoHist(img, ax)

% Using 64 bins plots well in this demo, but imhist is optimized
% for 256 bins; it can be 20 times faster.  So call imhist with
% 256 bins and then cut the result down to 64.
[cnts,bins]=imhist(img,256);
cnts = reshape(cnts,4,64);
cnts = sum(cnts);
cnts = cnts(:);
n = 64;
bins = (1:n)';
axes(ax)
stem(bins,cnts);
h = get(ax,'children');
delete(findobj(h,'flat','Marker','o')) % Remove 'o's from stem plot
limits = axis;
limits(1) = 0.5;
limits(2) = n+0.5;
var = sqrt(cnts'*cnts/length(cnts));
limits(4) = 2.5*var;
axis(limits);
set(ax, 'Xtick', [], 'Ytick', []);
title('Histogram');

return

%%%
%%%  Sub-function - SelectROI
%%%

function SelectROI(MRMotionFig)

if nargin<1,
  MRMotionFig = gcbf;
end

ud = get(MRMotionFig,'Userdata');

% Disable any widowbutton down functions
wbdnfcn=get(MRMotionFig,'windowbuttondownfcn');
set(MRMotionFig,'windowbuttondownfcn',' ') ;

%figure(MRMotionFig);
% Get ROI box
setstatus('Select Region for ROI')  ;
% axes(ud.hOriginalAxes);
waitforbuttonpress            ;
pnt = get(gcf,'currentpoint'); 
xy1 = get(gca,'currentpoint'); 
rbbox([pnt 0 0],pnt);         
xy2 = get(gca,'currentpoint'); 

% Clean up data
xy1 = round( xy1(1,1:2) ) ;
xy2 = round( xy2(1,1:2) ) ;
xx  = sort( [xy1(1) xy2(1)] ) ;
yy  = sort( [xy1(2) xy2(2)] ) ;

% IF ROI ALREADY DRAWN, DELETE THOSE LINES
if ud.ROIon==1,
  delete(ud.ROIlh);
end

% DRAW ROI BOX IN BOTH AXES
axes(ud.hOriginalAxes);
% Vertical lines
ud.ROIlh(1) = line([1 1]*min(xx),[max(yy) min(yy)]) ;
ud.ROIlh(2) = line([1 1]*max(xx),[max(yy) min(yy)]) ;
% Horizontal lines
ud.ROIlh(3) = line([max(xx) min(xx)],[1 1]*min(yy)) ;
ud.ROIlh(4) = line([max(xx) min(xx)],[1 1]*max(yy)) ;
axes(ud.hCorruptedAxes);
ud.ROIlh(5) = line([1 1]*min(xx),[max(yy) min(yy)]) ;
ud.ROIlh(6) = line([1 1]*max(xx),[max(yy) min(yy)]) ;
% Horizontal lines
ud.ROIlh(7) = line([max(xx) min(xx)],[1 1]*min(yy)) ;
ud.ROIlh(8) = line([max(xx) min(xx)],[1 1]*max(yy)) ;
% Set colors
set(ud.ROIlh,'color','red') ;

ud.ROIon=1;
% AXES X DIRECTION IS UP DOWN SO THE (x,y) IS REALLY (y,x) 
% FOR THE IMAGE MATRICES SO ASSIGN Y VAlUE TO X and VICE VERSA
ud.ROIx1=yy(1);
ud.ROIy1=xx(1);
ud.ROIx2=yy(2);
ud.ROIy2=xx(2);

ud.OriginalImageROIEntropy = entropy( abs(ud.OriginalImage(ud.ROIx1:ud.ROIx2,ud.ROIy1:ud.ROIy2)) );
ud.CorruptedImageROIEntropy = entropy( abs(ud.CorruptedImage(ud.ROIx1:ud.ROIx2,ud.ROIy1:ud.ROIy2)) );
ud.GradientOriginalImageROIEntropy = entropy( abs(ud.GradientOriginalImage(ud.ROIx1:min(ud.ROIx2,ud.Sizex-1),ud.ROIy1:ud.ROIy2)) );
ud.GradientCorruptedImageROIEntropy = entropy( abs(ud.GradientCorruptedImage(ud.ROIx1:min(ud.ROIx2,ud.Sizex-1),ud.ROIy1:ud.ROIy2)) );

ud.ROIEntropyChange = (ud.CorruptedImageROIEntropy - ud.OriginalImageROIEntropy)/...
				ud.OriginalImageROIEntropy; 
ud.GradientROIEntropyChange = (ud.GradientCorruptedImageROIEntropy - ud.GradientOriginalImageROIEntropy)/...
				ud.GradientOriginalImageROIEntropy; 

% CHECK TO MAKE SURE ROI IS THE REGION I THINK IT IS
% myimageshow( abs(ud.OriginalImage(ud.ROIx1:ud.ROIx2,ud.ROIy1:ud.ROIy2)), 10);

set(MRMotionFig,'Userdata',ud);
set(MRMotionFig,'windowbuttondownfcn',wbdnfcn) ;
setstatus( sprintf('Accepted ROI: (%.0f,%.0f) -> (%.0f,%.0f)', ud.ROIx1, ud.ROIy1, ud.ROIx2, ud.ROIy2) );
MRMotion('UpdateInfoBox',MRMotionFig);

return


%%%+++++++++++++++++++++++++++++++++++++
%%%  Sub-Function - MakeTIFF
%%%+++++++++++++++++++++++++++++++++++++
function MakeTIFF(MRMotionFig)


if nargin<1,
  MRMotionFig = gcbf;
end

ud = get(MRMotionFig,'Userdata');
s = savefile('.','*.tif, *.tiff');

if isempty(s),
  setstatus(MRMotionFig,['Empty Filename, TIFF image not created']);
  return
end

temp = find(s=='/');
name = sprintf('%s', s( (temp(length(temp))+1):length(s) ) );

  % [frame1, map] = getframe(ud.hOriginalAxes);
  frame2 = getframe(ud.hCorruptedAxes);
  
  imwrite( frame2im(frame2), s, 'TIFF', 'Compression', 'none');

setstatus(MRMotionFig,['Successfully saved TIFF image file: ' name]);
 
return
