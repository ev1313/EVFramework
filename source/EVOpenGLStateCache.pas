unit EVOpenGLStateCache;

interface

uses
  dglOpenGL;

type
  TEVOpenGLStateCache = class (TObject)
  private
    fClient: GLEnum;
    fServer: GLEnum;
  public
    constructor Create;
    procedure Disable(cap: GLEnum);
    procedure DisableClientState(_array: GLEnum);
    procedure Enable(cap: GLEnum);
    procedure EnableClientState(_array: GLEnum);
    function IsEnabled(cap: GLEnum): Boolean;
  end;
  

var
  statecache: TEVOpenGLStateCache;

implementation

{
***************************** TEVOpenGLStateCache ******************************
}
constructor TEVOpenGLStateCache.Create;
begin
  fServer := GL_DITHER or GL_MULTISAMPLE;
end;

procedure TEVOpenGLStateCache.Disable(cap: GLEnum);
begin
  if fServer <> (fServer xor cap) then
  begin
    glDisable(cap);
    fServer := fServer xor cap;
  end;
end;

procedure TEVOpenGLStateCache.DisableClientState(_array: GLEnum);
begin
  if fClient <> (fClient xor _array) then
  begin
    glDisable(_array);
    fClient := fClient xor _array;
  end;
end;

procedure TEVOpenGLStateCache.Enable(cap: GLEnum);
begin
  if fServer <> (fServer or cap) then
  begin
    glEnable(cap);
    fServer := fServer or cap;
  end;
end;

procedure TEVOpenGLStateCache.EnableClientState(_array: GLEnum);
begin
  if fClient <> (fClient or _array) then
  begin
    glEnable(_array);
    fClient := fClient or _array;
  end;
end;

function TEVOpenGLStateCache.IsEnabled(cap: GLEnum): Boolean;
begin
  if fServer = (fServer or cap) then
    Result := true
  else
    Result := false;
end;


initialization
  statecache := TEVOpenGLStateCache.Create;  
finalization
  statecache.Free;
end.
