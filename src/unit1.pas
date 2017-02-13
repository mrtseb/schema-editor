unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Menus,
  ExtCtrls, Buttons, StdCtrls, schema_utils, math;

type

  { TForm1 }

  TForm1 = class(TForm)

    ImageList1: TImageList;
    MainMenu1: TMainMenu;
    Memo2: TMemo;
    Memo3: TMemo;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    Panel1: TPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);


    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    { private declarations }

    isPlacing, isBinding,isSimulate:boolean;
    choix:integer;
    schema:TSchema;
    function ext(dev:integer;e:integer):integer;

  public
    { public declarations }
    max_links:integer;
    voltages:array[1..500] of integer;
    nb_noeuds:integer;
    procedure relie(a,b:string);
    procedure analyse;
    procedure analyse2;
    procedure gere_int;
    procedure equipotentielles;
    procedure gere_lamp;

  end;

var
  Form1: TForm1;
  l, cx:Tlist;
  deb,fin:string;


implementation

{$R *.lfm}

{ TForm1 }
function Tform1.ext(dev:integer;e:integer):integer;
var s:string;
t:TStringList;
begin
        t:=TstringList.create;
        s:=schema.donne_cx(l,dev);
        Split(':',s,t);
        result:=strtoint(t.strings[e]);
        t.free;
end;

procedure Tform1.equipotentielles;
var i:integer;
    p:Plink;
    p2,p3:pentry;
    x,y:integer;

begin
    for i:=0 to cx.Count-1 do begin
      p:=cx.Items[i];
      p2:=l.Items[p^.de];
      if p2^.device='P' then continue;
      if p2^.device='N' then continue;
      p3:=l.Items[p^.a];
      if p3^.device='P' then continue;
      if p3^.device='N' then continue;

      x:= ext(p^.de,2);
      y:= ext(p^.a,1);

      if x>y then begin
      x:= ext(p^.de,1);
      y:= ext(p^.a,2);
      end;

      //memo1.lines.add(inttostr(x)+inttostr(y)) ;
      if voltages[x] = 5 then voltages[y] := 5 else if voltages[y] = 5 then voltages[x] := 5;
      if voltages[x] = -5 then voltages[y] := -5 else if voltages[y] = -5 then voltages[x] := -5;
      if voltages[x] = 0 then voltages[y] := 0 else if voltages[y] = 0 then voltages[x] := 0;

    end;
end;

procedure Tform1.gere_int;
var i:integer;
    p:pentry;
    p2:plink;
    s:string;
    t:TstringList;
    x,y:integer;
begin
  t:=TstringList.create;
  //memo1.Clear;
  for i:=0 to l.Count-1 do begin

    p:=l.Items[i];

    if (p^.device ='NO1') or (p^.device ='NF0') then begin
        x:=ext(i,1);
        y:=ext(i,2);
        if voltages[x] = 5 then voltages[y] := 5;
        if voltages[y] = 5 then voltages[x] := 5;
        if voltages[x] = -5 then voltages[y] := -5;
        if voltages[y] = -5 then voltages[x] := -5;

    end;

    if (p^.device ='NO0') or (p^.device ='NF1') then begin
        x:=ext(i,1);
        y:=ext(i,2);
        if ((voltages[x] = 5) or (voltages[x] = -5)) then voltages[y] := 0;
        if ((voltages[y] = 5) or (voltages[y] = -5)) then voltages[x] := 0;


    end;

  equipotentielles;

  end;



  memo3.clear;
  for i:= 1 to max_links do memo3.Lines.Add(inttostr(voltages[i]));
  t.free;

end;

procedure Tform1.gere_lamp;
   var i:integer;
       p:pEntry;
       x,y:integer;
       bmp:Tbitmap;
begin
  bmp:=Tbitmap.create;
   for i := 0 to l.count-1 do begin
       p:=l.Items[i];
       if p^.device='LMP0' then begin
       x:= ext(p^.num,1);
       y:= ext(p^.num,2);
       if ((voltages[x]=5) and (voltages[y]=-5)) or ((voltages[x]=5) and (voltages[y]=-5)) then begin
            p^.device:='LMP1';
            bmp.Width:=33;
            bmp.Height:=33;
            bmp.Canvas.Brush.Color:=form1.Color;
            bmp.Canvas.FillRect(0,0,33,33);
            form1.Canvas.Draw(p^.X,p^.Y,bmp);
            bmp.loadfromFile(extractfilepath(Application.exename)+'img\LMP1.bmp');
            bmp.Transparent :=true;
            bmp.TransparentColor:=clFuchsia;
            form1.Canvas.Draw(p^.X,p^.Y,bmp);

       end;
       end;

       if p^.device='LMP1' then begin
       x:= ext(p^.num,1);
       y:= ext(p^.num,2);
       if ((voltages[x]=0) or (voltages[y]=0))  then begin
            p^.device:='LMP0';
            bmp.Width:=33;
            bmp.Height:=33;
            bmp.Canvas.Brush.Color:=form1.Color;
            bmp.Canvas.FillRect(0,0,33,33);
            form1.Canvas.Draw(p^.X,p^.Y,bmp);
            bmp.loadfromFile(extractfilepath(Application.exename)+'img\LMP0.bmp');
            bmp.Transparent :=true;
            bmp.TransparentColor:=clFuchsia;
            form1.Canvas.Draw(p^.X,p^.Y,bmp);

       end;
       end;

   end;
   bmp.free;
end;

procedure Tform1.analyse2;
var i:integer;
    p:plink;
    p2:pentry;
    p3:pentry;
    s:string;
begin
  //associe les P et N aux broches liees
  for i:=0 to cx.Count-1 do begin
      p:= cx.Items[i];
      p2:= l.items[p^.de];
      p3:= l.items[p^.a];
      if p2^.device='P' then  voltages[p3^._broches-p3^.broches+1]:=5;
      if p3^.device='P' then  voltages[p2^._broches-p2^.broches+1]:=5;
      if p2^.device='N' then  voltages[p3^._broches-p3^.broches+2]:=-5;
      if p3^.device='N' then  voltages[p2^._broches-p2^.broches+2]:=-5;
     end;

   memo2.clear;
   memo2.Lines := schema.show_entries(l);

   memo3.clear;
   for i:= 1 to max_links do memo3.Lines.Add(inttostr(voltages[i]));
   gere_int;
   gere_lamp;

end;

procedure Tform1.analyse;
var i,j,k:integer;
    p:PEntry;
    p2:plink;
    etat:string;
begin
    k:=0;

    for i:=0 to l.count-1 do begin
      new(p);
      new(p2);
      p:=l.Items[i];
      etat:='0';

      for j:=1 to p^.broches do begin
        if (p^.device='P') and (j=1) then etat :='5';
        if (p^.device='N') and (j=1) then etat:='-5';
        k:=k+1;
        voltages[k]:=strtoint(etat);
      end;

    end;
    analyse2;

end;



procedure Tform1.relie(a,b:string);
var id_deb,id_fin:integer;

    t:Tstringlist;
    x1,y1,x2,y2, z1:integer;
    lien:Tlink;
    s:string;
    p:Pentry;

begin
  t:=TstringList.create;

  if a='' then exit;
  if a='-' then exit;
  if b='' then exit;
  if b='-' then exit;


  id_deb:=strtoint(a);
  id_fin:=strtoint(b);


  x1:=schema.trouve_by_id(l,id_deb).X;
  y1:=schema.trouve_by_id(l,id_deb).Y+33 div 2;
  x2:=schema.trouve_by_id(l,id_fin).X;
  y2:=schema.trouve_by_id(l,id_fin).Y+33 div 2;

  if x1>x2 then begin
      z1:=x2;  x2:=x1;  x1:=z1;
      z1:=y2;  y2:=y1;  y1:=z1;
  end;

  lien.de:=id_deb;
  lien.a:=id_fin;

  if not schema.dejala2(cx,id_deb,id_fin) then schema.add_link(cx,lien);

  form1.canvas.moveto(x1+33,y1);
  form1.canvas.Pen.Color:=clBlack;

  if schema.trouve_by_id(l,id_deb).device='P' then form1.canvas.Pen.Color:=clRed;
  if schema.trouve_by_id(l,id_deb).device='N' then form1.canvas.Pen.Color:=clBlue;
  if schema.trouve_by_id(l,id_fin).device='P' then form1.canvas.Pen.Color:=clRed;
  if schema.trouve_by_id(l,id_fin).device='N' then form1.canvas.Pen.Color:=clBlue;

  form1.canvas.lineto(x1+33,y2);
  form1.canvas.lineto(x2,y2);

  t.free;


end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
begin
      isPlacing:=true;
      choix:=(sender as TspeedButton).tag;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  Bmp: TBitmap;
  i:integer;


begin
  l:=Tlist.create;
  cx:=Tlist.create;

  memo2.clear;
  Bmp := TBitmap.Create;
  try
    for i:=1 to imagelist1.Count do begin
      ImageList1.GetBitmap(i-1, Bmp);
      (Findcomponent('Speedbutton'+IntToStr(i)) as TSpeedButton).Glyph.Assign(bmp);
    end;

  finally
    Bmp.Free;
  end;

end;

procedure TForm1.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
   var
   Bmp: TBitmap;
   e:Tentry;
   p:pEntry;
   s:string;

   begin
  try
    Bmp:=Tbitmap.create;

     X := (X div 50) * 50;
     Y := (Y div 50) * 50;

    if isSimulate then begin
        s:=schema.trouve_composant_node(l,X,Y);
        if s='-' then exit;
        p:=l.Items[strtoint(s)];
        if p^.device ='P' then exit;
        if p^.device ='N' then exit;
        if p^.device ='LMP0' then exit;

        if p^.device ='NO0' then begin
            p^.device:='NO1';
            bmp.Width:=33;
            bmp.Height:=33;
            bmp.Canvas.Brush.Color:=form1.Color;
            bmp.Canvas.FillRect(0,0,33,33);
            form1.Canvas.Draw(p^.X,p^.Y,bmp);
            bmp.loadfromFile(extractfilepath(Application.exename)+'img\NO1.bmp');
            bmp.Transparent :=true;
            bmp.TransparentColor:=clFuchsia;
            form1.Canvas.Draw(p^.X,p^.Y,bmp);
            analyse;
            exit;
        end;
        if p^.device ='NO1' then begin
            p^.device:='NO0';
            bmp.Width:=33;
            bmp.Height:=33;
            bmp.Canvas.Brush.Color:=form1.Color;
            bmp.Canvas.FillRect(0,0,33,33);
            form1.Canvas.Draw(p^.X,p^.Y,bmp);
            bmp.loadfromFile(extractfilepath(Application.exename)+'img\NO0.bmp');
            bmp.Transparent :=true;
            bmp.TransparentColor:=clFuchsia;
            form1.Canvas.Draw(p^.X,p^.Y,bmp);
            analyse;
            exit;
        end;
        if p^.device ='NF0' then begin
            p^.device:='NF1';
            bmp.Width:=33;
            bmp.Height:=33;
            bmp.Canvas.Brush.Color:=form1.Color;
            bmp.Canvas.FillRect(0,0,33,33);
            form1.Canvas.Draw(p^.X,p^.Y,bmp);
            bmp.loadfromFile(extractfilepath(Application.exename)+'img\NF1.bmp');
            bmp.Transparent :=true;
            bmp.TransparentColor:=clFuchsia;
            form1.Canvas.Draw(p^.X,p^.Y,bmp);
            analyse;

            exit;
        end;
        if p^.device ='NF1' then begin
            p^.device:='NF0';
            bmp.Width:=33;
            bmp.Height:=33;
            bmp.Canvas.Brush.Color:=form1.Color;
            bmp.Canvas.FillRect(0,0,33,33);
            form1.Canvas.Draw(p^.X,p^.Y,bmp);
            bmp.loadfromFile(extractfilepath(Application.exename)+'img\NF0.bmp');
            bmp.Transparent :=true;
            bmp.TransparentColor:=clFuchsia;
            form1.Canvas.Draw(p^.X,p^.Y,bmp);
            analyse;
            exit;
        end;
        exit;
    end;

    if isPlacing then begin
        //if (choix<>7) then if (X < 100) then exit;
        if schema.dejala(l,X,Y)then exit;
        ImageList1.GetBitmap(choix, Bmp);
        form1.Canvas.Draw(X,Y,bmp);
        nb_noeuds := nb_noeuds +  devices[choix].broches;

        e.X:=X;
        e.Y:=Y;
        e.device:=devices[choix].name;
        e.broches := devices[choix].broches;
        e._broches := nb_noeuds;

        schema.add_entry(l,e);
        max_links:=e._broches;
        memo2.Lines := schema.show_entries(l);

        exit;
  end;
  //binding
  isBinding:=true;
  deb:=schema.trouve_composant_node(l,X,Y);
  //memo2.Lines.Add();

  finally begin
    bmp.free;
    isPlacing:=false;
  end;
    end;
  end;

procedure TForm1.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   X := (X div 50) * 50;
   Y := (Y div 50) * 50;

   if isSimulate then begin
       deb:='-';
       fin:='-';
        exit;
    end;

  if isplacing then else isBinding:=false;


  if deb='-' then exit;
  if deb='' then exit;

  fin:=schema.trouve_composant_node(l,X,Y);
  //self.caption := fin;
  if deb=fin then exit;
  if fin='-' then exit;

  self.relie(deb,fin);
  analyse;
  deb:='-';
  fin:='-'
end;



procedure TForm1.MenuItem3Click(Sender: TObject);
begin
isSimulate:=true;
self.caption:='simulation';
end;

procedure TForm1.MenuItem4Click(Sender: TObject);
begin
  isSimulate:=false;
  self.caption:='edition';
end;


end.

