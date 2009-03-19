function spectrha(logName)
%SPECTRHA   Spectral Harmonic Analysis
%   SPECTRHA(LOGNAME)
%
%   default LOGNAME='log.dat'
%
%   Martinho Marta Almeida, Jul-2003
%   Physics Department
%   Aveiro University
%   Portugal
%   martinho@fis.ua.pt
%
%   12-2004: work under M_PACK
%
%   See also M_PACK, SPECTRHA2

%   Department of Physics
%   University of Aveiro, Portugal

global FGRID FSTA LOOK FLOAD ELLIPSE ETC HANDLES MENU INFO
S_init_global % init global vars
S_init_info   % init global var INFO
S_settings    % init global settings

if nargin >= 1 & isstr(logName)
  ETC.logname=logName;
else
  ETC.logname=[pwd,filesep,ETC.logname];
end

status = S_init_log(ETC.logname);
if isequal(status,'error');
  disp(' ');
  disp('# error creating SpectrHA log file...');
  disp('  maybe you dont have enough permissions to create it');
  disp('  please, call spectrha with the logName argument, example: ');
  disp('  spectrha(''/tmp/logfile.txt'')');
  disp(' ');
  return
end

%---------------------------------------------------------------------
% figure:
HANDLES.fig=figure;
set(gcf,'numbertitle','off','name',INFO.label);
set(gcf,'closerequestfcn','S_close;');
set(gcf,'position',[75 115 815 577]);
%---------------------------------------------------------------------

%output text:
if strcmpi(computer,'PCWIN')
  callback='S_restore_txt';
  style='edit';
else
  callback='';
  style='text';
end
HANDLES.txt_head=uicontrol('units','normalized',...
  'string','','style',style,'callback',callback);
HANDLES.output=uicontrol('units','normalized',...
  'string','','callback','S_plotit;',...
  'style','listbox');

%spetrum axes:
HANDLES.spectrum_axes=axes('units','normalized','box','on',...
  'xminortick','on','yminortick','on');

%radio buttons:
HANDLES.radio_is_ell=uicontrol('units','normalized',...
  'string','ellipse','style','radiobutton',...
  'callback','S_choose;'); 
HANDLES.radio_is_serie=uicontrol('units','normalized',...
  'string','serie','style','radiobutton',...
  'callback','S_choose;');   
HANDLES.radio_is_station=uicontrol('units','normalized',...
  'string','station','style','radiobutton',....
  'callback','S_choose;'); 
HANDLES.radio_is_file=uicontrol('units','normalized',...
  'string','file','style','radiobutton',...
  'callback','S_choose;'); 

%spectrum axes's controls:
%xlim:
val=ETC.default_xlim;
HANDLES.xlim_i=uicontrol('units','normalized',...
  'style','edit',...
  'string',num2str(val(1)),'callback','S_xlim');
HANDLES.xlim=uicontrol('units','normalized',...
  'string',[num2str(val(1)),':',num2str(val(2))],'callback','S_xlim');
HANDLES.xlim_e=uicontrol('units','normalized',...
  'style','edit',...
  'string',num2str(val(2)),'callback','S_xlim');
%grids, zoom & hold:
HANDLES.add_grids_spect=uicontrol('units','normalized',...
  'string','grids','callback','S_grids');
HANDLES.hold_spect=uicontrol('units','normalized',...
  'style','checkbox',...
  'string','hold on','callback','S_hold');
HANDLES.zoom=uicontrol('units','normalized',...
  'style','togglebutton',...
  'string','zoom','callback','S_zoom;');

%frames:
HANDLES.frame_predic=uicontrol('style','frame','units','normalized');
HANDLES.frame_analysis=uicontrol('style','frame','units','normalized');
HANDLES.frame_loadMat=uicontrol('style','frame','units','normalized');

%load external data (mat files) and plot them:
HANDLES.load_file=uicontrol('units','normalized',...
  'string','file','callback','S_load;');
HANDLES.plot_file=uicontrol('units','normalized',...
  'string','> plot','callback','S_plot;');
HANDLES.load_struc=uicontrol('units','normalized',...
  'string','struct','callback','S_load_ellipse;');         
HANDLES.plot_struc=uicontrol('units','normalized',...
  'string','> plot',...
  'callback','S_plot_ellipse;');

%analysis:
HANDLES.plot_data=uicontrol('units','normalized',...
  'string','data',...
  'callback','S_plot_data;');
HANDLES.fsa=uicontrol('units','normalized',...
  'string','FSA','callback','S_fsa;'); 
HANDLES.lsf=uicontrol('units','normalized',...
  'string','LSF','callback','S_lsf;'); 
HANDLES.t_tide=uicontrol('units','normalized',...
  'string','t_tide',...
  'callback','S_t_tide;');
HANDLES.xout=uicontrol('units','normalized',...
  'string','xout','style','checkbox');

%t_predic:  
HANDLES.datenum_s=uicontrol('units','normalized',...
  'string','datenum','style','edit',...
  'callback','S_datenum(''s'');');
HANDLES.datenum_e=uicontrol('units','normalized',...
  'string','datenum','style','edit',...
  'callback','S_datenum(''e'');');
HANDLES.datenum_dt=uicontrol('units','normalized',...
  'string','datenum','style','edit',...
  'callback','S_datenum(''dt'');');
HANDLES.predic=uicontrol('units','normalized',...
  'string','t_predic',...
  'callback','S_predic;');           

%---------------------------------------------------------------------

%grid axes:
HANDLES.grid_axes=axes('units','normalized','box','on');

%buttons under grid: load, select, field,...
HANDLES.load_grid=uicontrol('units','normalized',...
  'string','grid','callback','S_load_grid;');
HANDLES.load_station=uicontrol('units','normalized',...
  'string','station','callback','S_load_station;');
HANDLES.contours=uicontrol('units','normalized',...
  'string','contours','style','edit',...
  'callback','S_contour;');
HANDLES.label=uicontrol('units','normalized',...
  'string','clabel','callback','S_clabel');
HANDLES.axes_equal=uicontrol('units','normalized',...
  'string','axis equal','callback','S_ax_equal;');
HANDLES.add_grids_grid=uicontrol('units','normalized',...
  'string','grids','callback','S_grids');
HANDLES.select=uicontrol('units','normalized',...
  'string','select','callback','S_select;');
HANDLES.selectN=uicontrol('units','normalized',...
  'style','edit',...
  'string','sta#','callback','S_staNumber;');
HANDLES.vars=uicontrol('units','normalized',...
  'string',['ZETA';'Ubar';'Vbar';'U   ';'V   '],...
  'style','popupmenu','callback','S_check_levels');
HANDLES.vlevels=uicontrol('units','normalized',...
  'string','1','style','popupmenu');  
HANDLES.zlevel=uicontrol('units','normalized',...
  'string','z','style','edit');
HANDLES.zcheck=uicontrol('units','normalized',...
  'string','','style','checkbox');

%---------------------------------------------------------------------

% objects positions:
S_obj_positions

%---------------------------------------------------------------------

%menus
str=['[ ',INFO.label,' ]'];
MENU.main=uimenu('label',str);

MENU.files=uimenu('parent',MENU.main,'label','current files');
MENU.grid=uimenu('parent',MENU.files,'label','grid:');
MENU.stations=uimenu('parent',MENU.files,'label','stations:');
MENU.file=uimenu('parent',MENU.files,'label','file:');
  MENU.file_interval=uimenu('parent',MENU.file,'label','interval:');
  MENU.file_dim=uimenu('parent',MENU.file,'label','dim:');
  MENU.file_start_time=uimenu('parent',MENU.file,'label','start time::');
MENU.struc=uimenu('parent',MENU.files,'label','struc:');

MENU.release=uimenu('parent',MENU.main,'label','release','separator','on');
MENU.release_grid=uimenu('parent',MENU.release,'label','grid',...
  'callback','S_release_grid;');
MENU.release_mask_rho=uimenu('parent',MENU.release,'label','mask_rho',...
  'separator','off','callback','S_release_mask');
MENU.release_LonLatMask=uimenu('parent',MENU.release,'label','lon,lat,mask_rho',...
  'separator','off','callback','S_release_llmask');
MENU.release_h3d=uimenu('parent',MENU.release,'label','bathy 3d',...
  'separator','off','callback','S_release_bathy');
MENU.release_spectrum=uimenu('parent',MENU.release,'label','spectrum',...
  'separator','on','callback','S_release_spectrum');
MENU.release_slevels=uimenu('parent',MENU.release,'label','s-levels (t=0, j)',...
  'separator','on','callback','S_release_slevels(''j'');');
MENU.release_slevels=uimenu('parent',MENU.release,'label','s-levels (t=0, i)',...
  'separator','off','callback','S_release_slevels(''i'');');
MENU.release_slevels=uimenu('parent',MENU.release,'label','s-levels (t=all)',...
  'separator','off','callback','S_release_slevels(''t'');');
MENU.overlay=uimenu('parent',MENU.main,'label','overlay ',...
  'separator','off');
MENU.overlay_coast=uimenu('parent',MENU.overlay,'label','coastline',...
  'callback','S_overlay','separator','off');

MENU.current_axis=uimenu('parent',MENU.main,'label','current axis',...
  'separator','off');
MENU.current_axis_normal=uimenu('parent',MENU.current_axis,'label','normal',...
  'separator','off','callback','S_spaxis(''normal'')');
MENU.current_axis_equal=uimenu('parent',MENU.current_axis,'label','equal',...
  'separator','off','callback','S_spaxis(''equal'')');
MENU.current_axis_auto=uimenu('parent',MENU.current_axis,'label','auto',...
  'separator','off','callback','S_spaxis(''auto'')');

MENU.config=uimenu('parent',MENU.main,'label','config',...
  'separator','on','callback','');
MENU.config_lsf=uimenu('parent',MENU.config,'label','LSF',...
  'separator','off','callback','edit S_config_LSF');    
MENU.config_t_tide=uimenu('parent',MENU.config,'label','T_TIDE',...
  'separator','off','callback','edit S_config_T_TIDE');  

MENU.t_tide_str=uimenu('parent',MENU.main,'label','t_tide str',...
  'separator','off','callback','');
MENU.str_t_tide=uimenu('parent',MENU.t_tide_str,'label','t_tide not exec. yet',...
  'separator','off','callback','');

MENU.phases_t_tide=uimenu('parent',MENU.main,'label','phases (t_tide)',...
  'separator','off','callback','');
MENU.phases_atCenter=uimenu('parent',MENU.phases_t_tide,'label','default ',...
  'separator','off','callback','S_check_displace(''default'')','checked','off');
MENU.phases_atStart=uimenu('parent',MENU.phases_t_tide,'label','at t=0',...
  'separator','off','callback','S_check_displace(''start'')','checked','on');              

MENU.about=uimenu('parent',MENU.main,'label','about',...
  'callback','S_about','separator','on');
MENU.help=uimenu('parent',MENU.main,'label','help',...
  'callback','S_help','separator','off');
MENU.www=uimenu('parent',MENU.main,'label','www',...
  'callback','S_www','separator','off');

MENU.preferences=uimenu('parent',MENU.main,'label','preferences','separator','on');
MENU.theme=uimenu('parent',MENU.preferences,'label','theme');
MENU.theme_c=uimenu('parent',MENU.theme,'label','default ','checked','on',...
  'callback','S_theme(''default'');');
MENU.theme_k=uimenu('parent',MENU.theme,'label','b/w','checked','off',...
  'callback','S_theme(''black'')');

MENU.close=uimenu('parent',MENU.main,'label','close',...
  'callback','S_close','separator','on');

%---------------------------------------------------------------------
%initialization of some stuff:
% radio buttons:
S_choose('serie');
S_choose('station');

%axis properties
axes(HANDLES.spectrum_axes);
S_axes_prop                % properties of spectrum_axes
axes(HANDLES.grid_axes);
S_axes_prop                % properties of grid_axes

% default spectrum xlim:
set(HANDLES.spectrum_axes,'xlim',ETC.default_xlim);

% init datenum
S_datenum('init')       % put current date in datenum handle 

% theme:
S_theme('default');
%keep logname, cos S_theme runs S_settings, restoring all defaults!
if exist('logName')
  ETC.logname=logName;
end

% check requirements:
% netcdf; done in S_get_ncvar
% t_tide
if ~exist('t_tide')
  warndlg('t_tide not detected...','missing...','modal');
  set(HANDLES.t_tide,'enable','off');
  set(HANDLES.predic,'enable','off');
  set(HANDLES.datenum_s,'enable','off');
  set(HANDLES.datenum_e,'enable','off');
  set(HANDLES.datenum_dt,'enable','off');
end

return
