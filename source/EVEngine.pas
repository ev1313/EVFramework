unit EVEngine;

interface

uses
  SysUtils,
  Classes,
  dglOpenGL,
  SDL,
  EVMath,
  EVOpenGLStateCache;

type

  //own Exceptions
  EEVSDLError = class(Exception) end;
  EEVOpenGLError = class(Exception) end;

  TEVObject = class (TObject)
  end;
  
  TEVVertexArray = class (TEVObject)
  public
    fIndices: TEVArrayui;
    fVertices: TEVVectorArray3f;
    constructor Create;
    destructor Destroy; override;
    procedure DrawArrays(_mode,_first,_range: Cardinal);
    procedure DrawElements(_mode,_count: Cardinal);
    procedure DrawRangeElements(_mode,_start,_end,_count: Cardinal);
  end;
  
  TEVEngine = class (TObject)
  private
    FFarClippingPlane: Cardinal;
    FFoV: Cardinal;
    FFPS: NativeUInt;
    fLog: TStringList;
    fLoop: Boolean;
    FMaxFPS: NativeUInt;
    FNearClippingPlane: Cardinal;
    FPerspective: Boolean;
    fSurface: PSDL_Surface;
    procedure CreateWindow(_w,_h: UInt16; _bpp: Byte;_caption: PAnsiChar;
            _resizable,_fullscreen: Boolean);
    function GetFullscreen: Boolean;
    function GetHeight: Cardinal;
    function GetJoystick: Boolean;
    function GetResizable: Boolean;
    function GetWidth: Cardinal;
    procedure HandleEvents;
    procedure SetFarClippingPlane(Value: Cardinal);
    procedure SetFoV(Value: Cardinal);
    procedure SetFullscreen(Value: Boolean);
    procedure SetHeight(Value: Cardinal);
    procedure SetJoystick(Value: Boolean);
    procedure SetNearClippingPlane(Value: Cardinal);
    procedure SetPerspective(Value: Boolean);
    procedure SetResizable(Value: Boolean);
    procedure SetWidth(Value: Cardinal);
  protected
    procedure HandleEvent(_event: TSDL_Event); virtual;
    procedure InitializeOpenGL; virtual;
    procedure OrthogonalMatrix(_w,_h: Cardinal;_near,_far: LongInt);
    procedure PerspectiveMatrix(_w,_h: Cardinal;_near,_far: LongInt);
  public
    timeofframe: Integer;
    constructor Create(_w,_h: UInt16; _bpp: Byte;_caption: PAnsiChar;
            _resizable: Boolean = false;_fullscreen: Boolean = false);
    destructor Destroy; override;
    procedure Log(_string: String);
    procedure OnJoystickAxisMotion(_joystick: Cardinal;_axis,_value: UInt8); 
            virtual;
    procedure OnJoystickBallMotion(_joystick: Cardinal;_ball: UInt8;_xrel,
            _yrel: LongInt); virtual;
    procedure OnJoystickButtonDown(_joystick: Cardinal;_button: UInt8); virtual;
    procedure OnJoystickButtonUp(_joystick: Cardinal;_button: UInt8); virtual;
    procedure OnJoystickHatMotion(_joystick: Cardinal;_hat: UInt8;_value: 
            SInt16); virtual;
    procedure OnKeyDown(_key: TSDL_KeySym); virtual;
    procedure OnKeyUp(_key: TSDL_KeySym); virtual;
    procedure OnMouseDown(_button: Byte; _x,_y: UInt16); virtual;
    procedure OnMouseMove(_x,_y: UInt16;_xrel,_yrel: SInt16); virtual;
    procedure OnMouseUp(_button: Byte;_x,_y: UInt16); virtual;
    procedure Render; virtual; abstract;
    procedure SaveLog(_path: String);
    procedure StartMainLoop;
    property FarClippingPlane: Cardinal read FFarClippingPlane write 
            SetFarClippingPlane;
    property FoV: Cardinal read FFoV write SetFoV;
    property FPS: NativeUInt read FFPS;
    property Fullscreen: Boolean read GetFullscreen write SetFullscreen;
    property Height: Cardinal read GetHeight write SetHeight;
    property Joystick: Boolean read GetJoystick write SetJoystick;
    property MaxFPS: NativeUInt read FMaxFPS write FMaxFPS;
    property NearClippingPlane: Cardinal read FNearClippingPlane write 
            SetNearClippingPlane;
    property Perspective: Boolean read FPerspective write SetPerspective;
    property Resizable: Boolean read GetResizable write SetResizable;
    property Width: Cardinal read GetWidth write SetWidth;
  end;
  

implementation

{
******************************** TEVVertexArray ********************************
}
constructor TEVVertexArray.Create;
begin
  SetLength(fIndices,0);
  SetLength(fVertices,0);
end;

destructor TEVVertexArray.Destroy;
begin
  SetLength(fIndices,0);
  SetLength(fVertices,0);
end;

procedure TEVVertexArray.DrawArrays(_mode,_first,_range: Cardinal);
begin
  if Length(fVertices) = 0 then
    Exit;
  glVertexPointer(3,
                  GL_FLOAT,
                  0,
                  @fVertices[0]);
  glDrawArrays(_mode,
               _first,
               _range);
end;

procedure TEVVertexArray.DrawElements(_mode,_count: Cardinal);
begin
  if (Length(fVertices) = 0) or (Length(fIndices) = 0) then
    Exit;
  glVertexPointer(3,
                  GL_FLOAT,
                  0,
                  @fVertices[0]);
  glDrawElements(_mode,
                 _count,
                 GL_UNSIGNED_INT,
                 @fIndices[0]);
end;

procedure TEVVertexArray.DrawRangeElements(_mode,_start,_end,_count: Cardinal);
begin
  if (Length(fVertices) = 0) or (Length(fIndices) = 0) then
    Exit;
  glVertexPointer(3,
                  GL_FLOAT,
                  0,
                  @fVertices[0]);
  glDrawRangeElements(_mode,
                      _start,
                      _end,
                      _count,
                      GL_UNSIGNED_INT,
                      @fIndices[0]);
end;

{
********************************** TEVEngine ***********************************
}
constructor TEVEngine.Create(_w,_h: UInt16; _bpp: Byte;_caption: PAnsiChar;
        _resizable: Boolean = false;_fullscreen: Boolean = false);
var
  error: AnsiString;
begin
  fLog := TStringList.Create;
  //Init SDL (1)
  if SDL_Init(SDL_INIT_VIDEO) <> 0 then
  begin
    Log('');
    Log('Couldn''t initialize SDL_VIDEO: ');
    error := SDL_GetError;
    Log('');
    Log(error);
    Log('');
    SDL_Quit;
    raise EEVSDLError.Create('SDL-Error: ' + error);
    Exit;
  end;
  Log('');
  Log('Initialized SDL_VIDEO successfully.');
  Log('');
  //Init OpenGL (1)
  SDL_GL_SetAttribute(SDL_GL_RED_SIZE,5);
  SDL_GL_SetAttribute(SDL_GL_GREEN_SIZE,5);
  SDL_GL_SetAttribute(SDL_GL_BLUE_SIZE,5);
  SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE,16);
  SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER,1);
  //Init SDL(2)
  CreateWindow(_w,_h,_bpp,_caption,_resizable,_fullscreen);
  //Init OpenGL (2)
  InitOpenGL;
  ReadExtensions;
  ReadImplementationProperties;
  
  InitializeOpenGL;
end;

destructor TEVEngine.Destroy;
begin
  SDL_Quit;
  fLog.Free;
end;

procedure TEVEngine.CreateWindow(_w,_h: UInt16; _bpp: Byte;_caption: PAnsiChar;
        _resizable,_fullscreen: Boolean);
var
  flags: Cardinal;
  error: string;
begin
  flags := SDL_OpenGL or
           SDL_HWSURFACE or
           SDL_HWACCEL;
  if _resizable then
    flags := flags or SDL_RESIZABLE;
  if _fullscreen then
    flags := flags or SDL_FULLSCREEN;
  
  fSurface := SDL_SetVideoMode(_w,_h,_bpp, flags);
  if fSurface = nil then
  begin
    Log('Couldn''t Set SDL-VideoMode: ');
    error := String(SDL_GetError);
    Log(error);
    Log('Width: ' + IntToStr(_w));
    Log('Height: ' + IntToStr(_h));
    Log('BPP: ' + IntToStr(_bpp));
    Log('Caption: ' + _caption);
    if _resizable then
      Log('Resizable');
    if _fullscreen then
      Log('Fullscreen');
    SDL_Quit;
    raise EEVSDLError.Create('SDL-Error: ' + error);
    Exit;
  end;
  SDL_WM_SetCaption(PAnsiChar(_caption),nil);
  Log('');
  Log('Created SDL-Surface successfully.');
  Log('Width: ' + IntToStr(_w));
  Log('Height: ' + IntToStr(_h));
  Log('BPP: ' + IntToStr(_bpp));
  Log('Caption: ' + _caption);
  if _resizable then
    Log('Resizable');
  if _fullscreen then
    Log('Fullscreen');
  Log('');
end;

function TEVEngine.GetFullscreen: Boolean;
begin
  Result := fSurface.flags = (fSurface.flags or SDL_FULLSCREEN);
end;

function TEVEngine.GetHeight: Cardinal;
begin
  Result := fSurface.h;
end;

function TEVEngine.GetJoystick: Boolean;
begin
  if SDL_WasInit(SDL_INIT_JOYSTICK) <> 0 then
    Result := true
  else
    Result := false;
end;

function TEVEngine.GetResizable: Boolean;
begin
  Result := fSurface.flags = (fSurface.flags or SDL_RESIZABLE);
end;

function TEVEngine.GetWidth: Cardinal;
begin
  Result := fSurface.w;
end;

procedure TEVEngine.HandleEvent(_event: TSDL_Event);
begin
  case _event.type_ of
    SDL_QUITEV:
      fLoop := false;
    SDL_VIDEORESIZE:
    begin
      fSurface.w := _event.resize.w;
      fSurface.h := _event.resize.h;
      if fPerspective then
        PerspectiveMatrix(_event.resize.w,
                          _event.resize.h,
                          fNearClippingPlane,
                          fFarClippingPlane)
      else
        OrthogonalMatrix(_event.resize.w,
                         _event.resize.h,
                         fNearClippingPlane,
                         fFarClippingPlane);
    end;
    SDL_KEYDOWN:
      OnKeyDown(_event.key.keysym);
    SDL_KEYUP:
      OnKeyUp(_event.key.keysym);
    SDL_MOUSEBUTTONDOWN:
      OnMouseDown(_event.button.button,
                  _event.button.x,
                  _event.button.y);
    SDL_MOUSEBUTTONUP:
      OnMouseUp(_event.button.button,
                _event.button.x,
                _event.button.y);
    SDL_MOUSEMOTION:
      OnMouseMove(_event.motion.x,
                  _event.motion.y,
                  _event.motion.xrel,
                  _event.motion.yrel);
    SDL_JOYAXISMOTION:
      OnJoystickAxisMotion(_event.jaxis.which,
                           _event.jaxis.axis,
                           _event.jaxis.value);
    SDL_JOYBALLMOTION:
      OnJoystickBallMotion(_event.jball.which,
                           _event.jball.ball,
                           _event.jball.xrel,
                           _event.jball.yrel);
    SDL_JOYBUTTONDOWN:
      OnJoystickButtonDown(_event.jbutton.which,
                           _event.jbutton.button);
    SDL_JOYBUTTONUP:
      OnJoystickButtonUp(_event.jbutton.which,
                         _event.jbutton.button);
    SDL_JOYHATMOTION:
      OnJoystickHatMotion(_event.jhat.which,
                          _event.jhat.hat,
                          _event.jhat.value);
  end;
end;

procedure TEVEngine.HandleEvents;
var
  event: TSDL_Event;
begin
  while (SDL_PollEvent(@event) = 1) and fLoop do
    HandleEvent(event);
end;

procedure TEVEngine.InitializeOpenGL;
begin
  //some good start-values
  glClearColor(0,0,0,0);
  glClearDepth(1.0);
  statecache.Enable(GL_DEPTH_TEST);
  glDepthFunc(GL_LEQUAL);
  glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
  fNearClippingPlane := 0;
  fFarClippingPlane := 128;
  fFoV := 45;
  Perspective := true;
end;

procedure TEVEngine.Log(_string: String);
begin
  fLog.Add(_string);
  {$IFDEF DEBUG}
    if IsConsole then
      WriteLn(_string);
  {$ENDIF}
end;

procedure TEVEngine.OnJoystickAxisMotion(_joystick: Cardinal;_axis,_value: 
        UInt8);
begin
  //event
end;

procedure TEVEngine.OnJoystickBallMotion(_joystick: Cardinal;_ball: UInt8;_xrel,
        _yrel: LongInt);
begin
  //event
end;

procedure TEVEngine.OnJoystickButtonDown(_joystick: Cardinal;_button: UInt8);
begin
  //event
end;

procedure TEVEngine.OnJoystickButtonUp(_joystick: Cardinal;_button: UInt8);
begin
  //event
end;

procedure TEVEngine.OnJoystickHatMotion(_joystick: Cardinal;_hat: UInt8;_value: 
        SInt16);
begin
  //event
end;

procedure TEVEngine.OnKeyDown(_key: TSDL_KeySym);
begin
  //event
end;

procedure TEVEngine.OnKeyUp(_key: TSDL_KeySym);
begin
  //event
end;

procedure TEVEngine.OnMouseDown(_button: Byte; _x,_y: UInt16);
begin
  //event
end;

procedure TEVEngine.OnMouseMove(_x,_y: UInt16;_xrel,_yrel: SInt16);
begin
  //event
end;

procedure TEVEngine.OnMouseUp(_button: Byte;_x,_y: UInt16);
begin
  //event
end;

procedure TEVEngine.OrthogonalMatrix(_w,_h: Cardinal;_near,_far: LongInt);
begin
  glViewport(0,0,_w,_h);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  glOrtho(0,_w,0,_h,_near,_far);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  Log('');
  Log('Orthogonal-Projection-Matrix: ');
  Log('Width: ' + IntToStr(_w));
  Log('Height: ' + IntToStr(_h));
  Log('Near-Clipping-Plane: ' + IntToStr(_near));
  Log('Far-Clipping-Plane: ' + IntToStr(_far));
  Log('');
end;

procedure TEVEngine.PerspectiveMatrix(_w,_h: Cardinal;_near,_far: LongInt);
begin
  glViewport(0,0,_w,_h);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(fFoV,width/height,_near,_far);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  Log('');
  Log('Perspective-Projection-Matrix: ');
  Log('Width: ' + IntToStr(_w));
  Log('Height: ' + IntToStr(_h));
  Log('Field of View: ' + IntToStr(fFoV));
  Log('Near-Clipping-Plane: ' + IntToStr(_near));
  Log('Far-Clipping-Plane: ' + IntToStr(_far));
  Log('');
end;

procedure TEVEngine.SaveLog(_path: String);
begin
  try
    fLog.SaveToFile(_path);
  except
    Log('Couldn''t save log to: ' + _path);
  end;
end;

procedure TEVEngine.SetFarClippingPlane(Value: Cardinal);
begin
  fFarClippingPlane := Value;
  Log('Far-Clipping-Plane changed to: ' + IntToStr(Value));
end;

procedure TEVEngine.SetFoV(Value: Cardinal);
begin
  fFoV := Value;
  if Perspective then
    PerspectiveMatrix(fSurface.w,
                      fSurface.h,
                      fNearClippingPlane,
                      fFarClippingPlane);
  Log('Field of View changed to: ' + IntToStr(Value));
end;

procedure TEVEngine.SetFullscreen(Value: Boolean);
var
  caption: PAnsiChar;
  temp: PAnsiChar;
begin
  SDL_WM_GetCaption(caption,temp);
  CreateWindow(fSurface.w,
               fSurface.h,
               fSurface.format.BitsPerPixel,
               caption,
               fSurface.flags = (fSurface.flags or SDL_RESIZABLE),
               Value);
end;

procedure TEVEngine.SetHeight(Value: Cardinal);
var
  temp: PAnsiChar;
  caption: PAnsiChar;
begin
  SDL_WM_GetCaption(caption,temp);
  CreateWindow(fSurface.w,
               Value,
               fSurface.format.BitsPerPixel,
               caption,
               fSurface.flags = (fSurface.flags or SDL_RESIZABLE),
               fSurface.flags = (fSurface.flags or SDL_FULLSCREEN));
end;

procedure TEVEngine.SetJoystick(Value: Boolean);
begin
  if Joystick <> Value then
  begin
    if Value then
      SDL_InitSubSystem(SDL_INIT_JOYSTICK)
    else
      SDL_QuitSubSystem(SDL_INIT_JOYSTICK);
  end;
end;

procedure TEVEngine.SetNearClippingPlane(Value: Cardinal);
begin
  fNearClippingPlane := Value;
  Log('Near-Clipping-Plane changed to: ' + IntToStr(Value));
end;

procedure TEVEngine.SetPerspective(Value: Boolean);
begin
  fPerspective := Value;
  
  if Value then
    PerspectiveMatrix(fSurface.w,
                      fSurface.h,
                      fNearClippingPlane,
                      fFarClippingPlane)
  else
    OrthogonalMatrix(fSurface.w,
                     fSurface.h,
                     fNearClippingPlane,
                     fFarClippingPlane);
end;

procedure TEVEngine.SetResizable(Value: Boolean);
var
  temp: PAnsiChar;
  caption: PAnsiChar;
begin
  SDL_WM_GetCaption(caption,temp);
  CreateWindow(fSurface.w,
               fSurface.h,
               fSurface.format.BitsPerPixel,
               caption,
               Value,
               fSurface.flags = (fSurface.flags or SDL_FULLSCREEN));
end;

procedure TEVEngine.SetWidth(Value: Cardinal);
var
  temp: PAnsiChar;
  caption: PAnsiChar;
begin
  SDL_WM_GetCaption(caption,temp);
  CreateWindow(Value,
               fSurface.h,
               fSurface.format.BitsPerPixel,
               caption,
               fSurface.flags = (fSurface.flags or SDL_RESIZABLE),
               fSurface.flags = (fSurface.flags or SDL_FULLSCREEN));
end;

procedure TEVEngine.StartMainLoop;
var
  st: Single;
  t: NativeUInt;
begin
  fLoop := true;
  st := 0;
  repeat
    t := SDL_GetTicks;
    Render;
    HandleEvents;
    //of course only if there's a fps-limit
    if fMaxFPS > 0 then
    begin
      //calculate sleeptime
      //there's no div-by-zero, cause fMaxFPS > 0
      st := (1000 / fMaxFPS - (SDL_GetTicks - t)) + st;
      if st > 0 then
      begin
        SDL_Delay(Trunc(st));
        //added correction
        //minimizes rounding-faults
        st := st - Trunc(st);
      end;
    end;
    //calculate fps
    t := SDL_GetTicks - t;
    timeofframe := t;
    if t > 0 then
      fFPS := Round(1000 / t);
  until not fLoop;
end;


end.
