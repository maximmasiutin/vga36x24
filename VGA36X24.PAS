{$A-,B-,D+,E-,F-,G+,I-,L+,N-,O-,P-,Q-,R-,S-,T-,V-,X+,Y+}
{$M 16384,0,655360}

unit VGA36x24;

interface

type
   TArrOfByte  = array[0..65534] of byte;
   PArrOfByte  = ^TArrOfByte;
   TPoint      = record
		  Y,X : integer;
		 end;
   PPoint      = ^TPoint;
   TArrOfPoint = array[0..16382] of TPoint;
   PArrOfPoint = ^TArrOfPoint;
   TextModes   = (Soft,Hard);
   cModes      = (Normal,Light);
   fFonts      = (Courier,Tiny,MSX,Arcane);
   TPolygon    = array[0..31] of record Y,X : integer end;
   SChar       = Set of Char;

const
	  meMove = $01;
	  meLP   = $02;
	  meLR   = $04;
	  meRP   = $08;
	  meRR   = $10;
	  meCP   = $20;
	  meCR   = $40;

	  On     = True;
	  Off    = False;

	  Dig    : SChar   = ['0'..'9'];
var
	  MouseNumButtons         : byte;
	  MouseFlags              : byte;
	  MouseButtons            : byte;
	  MouseVisibility         : byte;
	  MouseQuLen              : byte;
	  MouseLB                 : boolean;
	  MouseRB                 : boolean;
	  MouseCB                 : boolean;
	  MouseEventOccured       : boolean;
	  MouseBackgrExist        : boolean;
	  MouseVisible            : boolean;
          MouseEnabled            : boolean;
	  MouseQuEnabled          : boolean;
	  MouseCurShift           : word;
	  MouseCurHV              : word;
	  MouseSaveAreaX          : word;
	  MouseSaveAreaY          : word;
          MouseSaveAreaHV         : word;
          MouseHor                : word;
          MouseVert               : word;
	  MouseXShifted           : integer;
	  MouseYShifted           : integer;
	  MouseHorDist            : word;
	  MouseVertDist           : word;
	  MouseEvFlags            : byte;
	  MouseEvX                : word;
	  MouseEvY                : word;
	  MouseCurPtr             : pointer;
	  MousePreserveArea       : array[1..16*16] of byte;
	  WindowsDT               : array[1..16*6] of word;
	  MouseQu                 : array[1..32*5] of byte;

	  c_HV		  	  : Word;
	  c_Ofs                   : Byte;
	  c_Font		  : Pointer;
	  c_XLAT		  : Pointer;
	  c_Spacing		  : Byte;
	  c_Mode		  : Byte;

	  f_Height		  : Integer;
	  f_DefWidth		  : Byte;
          f_InterLine		  : Byte;
	  f_Font,f_Width	  : Pointer;
	  f_MaskExist	          : Boolean;

          SetCourierAddr	  : procedure;
          SetTinyAddr		  : procedure;

	  ImageOffset		  : word;
	  CurColor		  : byte;
	  BackgroundColor	  : byte;
	  CurX			  : Integer;
	  CurY			  : Integer;

	  CurPalette		  : pointer;

	  ScrY2			  : Word;
	  ScrY			  : Word;
	  PageSize		  : Word;

	  LineMode		  : byte;
	  LinePoints		  : PArrOfPoint;
	  LinePointsPos		  : word;

procedure SetVideoMode;

procedure MouseInit;
procedure MouseDone;

procedure MouseQuEnable;
procedure MouseQuDisable;
procedure MouseGetEvent;

procedure MouseSetShape(View:pointer;Bounds,Shift:word);

procedure MouseCenter;
procedure MouseGotoXY(x,y:word);

procedure MouseShow;
procedure MouseHide;

procedure MouseEnable;
procedure MouseDisable;

procedure FullDrawInit;
procedure FullDrawDone;

procedure PartDrawInit;
procedure PartDrawDone;

procedure SetWindowAttr(WNo:byte;RAMAddr:pointer;SizeX,SizeY,PosX,PosY:word);
procedure SetWindowPos(WNo:byte;PosX,PosY:word);         { To avoid troubles }
procedure RefreshWindow(WNo:byte);               { align PosX and SizeX by 4 }

procedure PutBitMap(x,y,h,v:word;p:pointer);      { align X by 4 and h by 8 }
procedure GetBitMap(x,y,h,v:word;p:pointer);      { align X by 4 and h by 8 }

procedure PutTranspBitMap(x,y,h,v:word;p:pointer);{ align X by 4 and h by 8 }
procedure PutLightBitMap(x,y,h,v:word;p:pointer); { align X by 4 and h by 8 }
procedure PutLightTranspBitMap(x,y,h,v:word;p:pointer);        { align **** }

procedure ScreenPutInit;
procedure ScreenPutDone;

function  MouseInWin(x,y:word;h,v:byte) : Boolean;

procedure Draw(const s : String);
procedure DrawXY(x,y : Integer; const s : String);
procedure Cls;
procedure ClearPage(Page:byte);
procedure PageCopy(Page1,Page2:byte);
procedure GPcopy(x,y,w,h:Integer;Page1:Byte;dx,dy:Integer;Page2:Byte);
procedure SetActivePage(Page:byte);
procedure SetVisualPage(Page:byte);
procedure SetVisualOffset(Ofs:Word);
procedure SetAllPalette(Pal:pointer);
procedure AssignPalette(Pal:pointer);
procedure MakeLightTbl(Intensity:byte);
procedure GetLightTbl(Tbl:pointer);
procedure SetLightTbl(Tbl:pointer);
function  FindColor(R,G,B:Byte):Byte;
function  GetLightColor:Byte;
procedure Line(x1,y1,x2,y2 : Integer);
procedure HorizLine(x1,x2,y : Integer);
procedure FullHorLine(y:Integer);
procedure GridHorLine(y:Integer;C1,C2,C3,C4:byte);
procedure VertLine(x,y1,y2 : Integer);
procedure Clipping(x1,y1,x2,y2 : Integer);
procedure PutPixel(x,y : Integer);
procedure PutTPoint(P : TPoint);
procedure PutTruePixel(x,y:Integer;R,G,B:byte);
function  GetPixel(x,y : Integer) : Byte;
procedure Rectangle(x1,y1,x2,y2 : Integer);
procedure Bar(x1,y1,x2,y2 : Integer);
procedure Bar4(x,y,w,h : Integer);
procedure SetCurPos(X,Y:Integer); Inline($8F/$06/CurY/$8F/$06/CurX);
procedure MoveRel(dx,dy : integer);
procedure LineTo(X,Y : Integer);
procedure LineRel(DX,DY : Integer);
procedure Circle(x,y,Rad : Word);
procedure FillCircle(x,y,Rad : Word);
procedure Ellipse(x,y,RadX,RadY : Word);
procedure FillEllipse(x,y,RadX,RadY : Word);
procedure ColorPoly(var Bounds; Num : Integer);
procedure TriAngle(x1,y1,x2,y2,x3,y3 : Word);
procedure FillTriAngle(x1,y1,x2,y2,x3,y3 : Word);
procedure WriteXY(x, y : Integer; TextAttr : Word; s : String);
procedure PrintXY(x, y : Integer; TextAttr : Word; s : String);
procedure TranspText(x, y : Integer; TextAttr : Byte; s : String);
function  TextWidth(const s : String) : Word;
function  TextHeight(const s : String) : Word;
procedure SetMonoTextMode(Mode:TextModes);
procedure SetMonoAddTable(var Table);
procedure cWriteXY(x,y:Integer;s:String);
procedure cTranspText(x,y:Integer;s:String);
procedure cSetSpacing(Spacing:Byte);inline($58/$A2/c_Spacing);
procedure cSetMode(Mode:cModes);inline($58/$A2/c_Mode);
procedure CloseGraph;inline($B8/$03/$00/$CD/$10);
procedure AssignLinePoints(p:pointer);inline($C6/$06/LineMode/$01/
					     $BB/LinePoints/
					     $58/$89/$07/$58/$89/$47/$02/
					     $C7/$06/LinePointsPos/$00/$00);
procedure SetDoubleRetrace;
procedure SetSingleRetrace;

implementation

procedure SetVideoMode;                                              external;
procedure SetDoubleRetrace;                                          external;
procedure SetSingleRetrace;                                          external;

procedure MouseInit;                                                 external;
procedure MouseDone;                                                 external;

procedure MouseQuEnable;                                             external;
procedure MouseQuDisable;                                            external;
procedure MouseGetEvent;                                             external;

procedure MouseSetShape;                                             external;

procedure MouseCenter;                                               external;
procedure MouseGotoXY;                                               external;

procedure MouseShow;                                                 external;
procedure MouseHide;                                                 external;

procedure MouseEnable;                                               external;
procedure MouseDisable;                                              external;

procedure FullDrawInit;                                              external;
procedure FullDrawDone;                                              external;

procedure PartDrawInit;                                              external;
procedure PartDrawDone;                                              external;

procedure SetWindowAttr;                                             external;
procedure SetWindowPos;                                              external;
procedure RefreshWindow;                                             external;

procedure PutBitMap;                                                 external;
procedure GetBitMap;                                                 external;
procedure PutTranspBitMap;                                           external;
procedure PutLightBitMap;                                            external;
procedure PutLightTranspBitMap;                                      external;

procedure ScreenPutInit;                                             external;
procedure ScreenPutDone;                                             external;

procedure Line;     						     external;
procedure HorizLine;                                                 external;
procedure FullHorLine;                                               external;
procedure GridHorLine;						     external;
procedure VertLine;                                                  external;
procedure Clipping;                                                  external;
procedure PutPixel;                                                  external;
procedure PutTPoint;                                                 external;
procedure PutTruePixel;                                              external;
function  GetPixel;                                                  external;
procedure Bar;                                                       external;
procedure Bar4;                                                      external;
procedure InternalEllipse(x,y,RadX,RadY : Word; What : Byte);   near;external;
procedure ColorPoly;						     external;
procedure Cls;							     external;
procedure ClearPage;                                                 external;
procedure PageCopy;                                                  external;
procedure GPCopy;                                                    external;
procedure SetActivePage;                                             external;
procedure SetVisualPage;                                             external;
procedure SetVisualOffset;                                           external;
procedure SetAllPalette;					     external;
function  FindColor;                                                 external;
function  GetLightColor;                                             external;
procedure MakeLightTbl;                                              external;
procedure GetLightTbl;                                               external;
procedure SetLightTbl;                                               external;
procedure WriteXY;                                                   external;
procedure PrintXY;                                                   external;
procedure TranspText;                                                external;
function  TextWidth;                                                 external;
function  TextHeight;						     external;
procedure SetMonoTextMode;                                           external;
procedure SetMonoAddTable;					     external;
procedure cWriteXY;                                                  external;
procedure cTranspText;                                               external;

{$L VGA36x24}

procedure AssignPalette(Pal:pointer);
begin
 CurPalette:=Pal;
end;

procedure Rectangle;
begin
 HorizLine(x1, x2, y1); HorizLine(x1, x2, y2);
 VertLine(x1, y1, y2);  VertLine(x2, y1, y2);
end;

procedure LineTo;
begin
 Line(CurX, CurY, X, Y);
 CurX:=X; CurY:=Y;
end;

procedure MoveRel(dx,dy : integer);
begin Inc(CurX,Dx);Inc(CurY,Dy) end;

procedure LineRel;
begin
 Line(CurX, CurY, CurX+DX, CurY+DY);
 Inc(CurX, DX); Inc(CurY, DY);
end;

procedure Ellipse;
begin InternalEllipse(x,y,RadX,RadY,0); end;

procedure FillEllipse;
begin InternalEllipse(x,y,RadX,RadY,1); end;

procedure InternalCircle(x,y:Integer;R:LongInt;Fill:Byte);
begin
 InternalEllipse(x,y,R,(R*13333) div 15555,Fill);
end;

procedure Circle;
begin
 InternalCircle(x,y,Rad,0);
end;

procedure FillCircle;
begin
 InternalCircle(x,y,Rad,1);
end;

procedure FillTriAngle;
begin ColorPoly(y3,3) end;

procedure TriAngle;
begin
 SetCurPos(x1,y1);
 LineTo(x2,y2); LineTo(x3,y3); LineTo(x1,y1);
end;

function MouseInWin;
begin
 MouseInWin:=(MouseEvX>=x) and (MouseEvX<x+h)
	 and (MouseEvY>=y) and (MouseEvY<y+v);
end;

function GetDig(const s : string; var p : byte):integer;
var q     : string;
    i,j,k : integer;
begin
 getdig:=1;
 if (p>=length(s)) or (not (s[p+1] in dig+['+','-'])) then exit;
 q:='';
 k:=1;
 for i:=1 to 3 do
     if p<byte(s[0]) then
	if s[p+1] in dig+['+','-'] then
	   begin
	    if s[p+1] in dig then q:=q+s[p+1]
			     else k:=2-pos(s[p+1],'+ -');
	    inc(p);
	   end;
 val(q,i,j);
 getdig:=i*k;
end;

procedure draw;
label 1;
var p           : byte;
    dx,dy,x,y,t : integer;
    dr,n,rt     : boolean;
    ds          : byte;
    ox,oy       : Integer;

begin
 p:=1;
 ds:=1;
 dr:=true;
 n:=false;
 rt:=On;
 ox:=CurX;
 oy:=CurY;
 while p<=length(s) do
       begin
1:      dx:=0;dy:=0;
	case UpCase(s[p]) of
	 'B' : begin
		dr:=false;
		if p<byte(s[0]) then inc(p) else exit;
		goto 1;
	       end;
	 'U' : dy:=-getdig(s,p);
	 'D' : dy:=getdig(s,p);
	 'R' : dx:=getdig(s,p);
	 'L' : dx:=-getdig(s,p);
	 'E' : begin
		dx:=getdig(s,p);
		dy:=-dx;
	       end;
	 'F' : begin
                dx:=getdig(s,p);
                dy:=dx;
               end;
         'G' : begin
                dy:=getdig(s,p);
                dx:=-dy;
               end;
         'H' : begin
                dy:=-getdig(s,p);
		dx:=dy;
               end;
	 'C' : CurColor:=getdig(s,p);
         'S' : Ds:=getdig(s,p);
         'M' : begin
                dx:=getdig(s,p);
                inc(p);
                if s[p]=',' then dy:=getdig(s,p)
                            else dec(p);
	       end;
	 'N' : begin
		x:=CurX;
		y:=CurY;
                n:=True;
                inc(p);
		if p<length(S) then GoTo 1 else break;
	       end;
	 'P' : begin
		t:=GetDig(s,p);
		inc(p);
		dy:=CurColor;
		if s[p]=',' then dy:=getdig(s,p)
			    else dec(p);
		{SetFillStyle(t,GetColor);}
		{FloodFill(GetX,GetY,dy);}
                Dr:=false;
               end;
	 'W' : {SetLineStyle(GetDig(s,p))};
	 'O' : begin
                if Dr then LineTo(ox,oy);
		SetCurPos(ox,oy);
		Inc(p);
		if p<length(S) then GoTo 1 else break;
	       end;
	 'Z' : begin
		ox:=CurX;
		oy:=CurY;
	       end;
	 'X' : Exit;
	end;
	if rt then
	   if Ds>0
	      then begin
		    dx:=dx*ds;
		    dy:=dy*ds;
		   end
	      else begin
		    dx:=dx div 2;
		    dy:=dy div 2;
		   end;
	if dr and not ((dx=0) and (dy=0)) then LineRel(dx,dy)
					  else MoveRel(dx,dy);
	if n then SetCurPos(x,y);
	dr:=true;
	n:=false;
        rt:=True;
        inc(p);
       end;
end;

 procedure DrawXY;
 begin
  SetCurPos(x,y);
  Draw(s);
 end;

end.