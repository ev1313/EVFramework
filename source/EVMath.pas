unit EVMath;

{$I jedi-sdl.inc}

interface

uses
  dglOpenGL,
  Math,
  SysUtils;

type
  
  {$IFNDEF Has_UInt64}
    UInt64 = 0..High(Int64);
  {$ENDIF}
  
  {$IFNDEF Has_Native}
    //Native-types
    {$IFDEF WIN64}
      NativeInt = Int64;
      NativeUInt = UInt64; 
    {$ELSE}
      NativeInt = LongInt; 
      NativeUInt = Cardinal;
    {$ENDIF}
  {$ENDIF}

  //Single <=> Float  
  TEVVector1f = record x      : Single; end;
  TEVVector2f = record x,y    : Single; end;
  TEVVector3f = record x,y,z  : Single; end;
  TEVVector4f = record x,y,z,w: Single; end;
  
  PEVVector1f = ^TEVVector1f;
  PEVVector2f = ^TEVVector2f;
  PEVVector3f = ^TEVVector3f;
  PEVVector4f = ^TEVVector4f;
  
  TEVVector1i = record x      : LongInt; end; 
  TEVVector2i = record x,y    : LongInt; end;
  TEVVector3i = record x,y,z  : LongInt; end;
  TEVVector4i = record x,y,z,w: LongInt; end;

  PEVVector1i = ^TEVVector1i;
  PEVVector2i = ^TEVVector2i;
  PEVVector3i = ^TEVVector3i;
  PEVVector4i = ^TEVVector4i;
  
  TEVVector1ui = record x      : Cardinal; end;
  TEVVector2ui = record x,y    : Cardinal; end;
  TEVVector3ui = record x,y,z  : Cardinal; end;
  TEVVector4ui = record x,y,z,w: Cardinal; end;
  
  PEVVector1ui = ^TEVVector1ui;
  PEVVector2ui = ^TEVVector2ui;
  PEVVector3ui = ^TEVVector3ui;
  PEVVector4ui = ^TEVVector4ui;
  
  //GLUByte <=> Byte
  TEVVector1ub = record x      : Byte; end;
  TEVVector2ub = record x,y    : Byte; end;
  TEVVector3ub = record x,y,z  : Byte; end;
  TEVVector4ub = record x,y,z,w: Byte; end;
  
  PEVVector1ub = ^TEVVector1ub;
  PEVVector2ub = ^TEVVector2ub;
  PEVVector3ub = ^TEVVector3ub;
  PEVVector4ub = ^TEVVector4ub;
  
  TEVVector   = TEVVector3f; //basic type
  PEVVector   = ^TEVVector;
  
  TEVArrayf = array of Single;
  PEVArrayf = ^TEVArrayf;
  
  TEVArrayi = array of LongInt;
  PEVArrayi = ^TEVArrayi;
  
  TEVArrayui = array of Cardinal;
  PEVArrayui = ^TEVArrayui;
  
  TEVArrayub = array of Byte;
  PEVArrayub = ^TEVArrayub;
  
  TEVVectorArray1f = array of TEVVector1f;
  TEVVectorArray2f = array of TEVVector2f;
  TEVVectorArray3f = array of TEVVector3f;
  TEVVectorArray4f = array of TEVVector4f;
  
  PEVVectorArray1f = ^TEVVectorArray1f;
  PEVVectorArray2f = ^TEVVectorArray2f;
  PEVVectorArray3f = ^TEVVectorArray3f;
  PEVVectorArray4f = ^TEVVectorArray4f;
  
  TEVVectorArray1i = array of TEVVector1i;
  TEVVectorArray2i = array of TEVVector2i;
  TEVVectorArray3i = array of TEVVector3i;
  TEVVectorArray4i = array of TEVVector4i;
  
  PEVVectorArray1i = ^TEVVectorArray1i;
  PEVVectorArray2i = ^TEVVectorArray2i;
  PEVVectorArray3i = ^TEVVectorArray3i;
  PEVVectorArray4i = ^TEVVectorArray4i;
  
  TEVVectorArray1ui = array of TEVVector1ui;
  TEVVectorArray2ui = array of TEVVector2ui;
  TEVVectorArray3ui = array of TEVVector3ui;
  TEVVectorArray4ui = array of TEVVector4ui;
  
  PEVVectorArray1ui = ^TEVVectorArray1ui;
  PEVVectorArray2ui = ^TEVVectorArray2ui;
  PEVVectorArray3ui = ^TEVVectorArray3ui;
  PEVVectorArray4ui = ^TEVVectorArray4ui;
  
  TEVVectorArray1ub = array of TEVVector1ub;
  TEVVectorArray2ub = array of TEVVector2ub;
  TEVVectorArray3ub = array of TEVVector3ub;
  TEVVectorArray4ub = array of TEVVector4ub;
  
  PEVVectorArray1ub = ^TEVVectorArray1ub;
  PEVVectorArray2ub = ^TEVVectorArray2ub;
  PEVVectorArray3ub = ^TEVVectorArray3ub;
  PEVVectorArray4ub = ^TEVVectorArray4ub;
  
  TEVVectorArray = TEVVectorArray3f;
  PEVVectorArray = ^TEVVectorArray;

implementation


end.
