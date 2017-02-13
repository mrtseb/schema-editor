unit schema_utils;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls;

type
   TDevice = record
     Name : string;
     broches : integer;
   end;
  Tentry = record
     num:integer;
     X:integer;
     Y:integer;
     device:string;
     broches : integer;
     _broches : integer;
  end;
  Tlink = record
     de:integer;
     a:integer;

  end;
  Tschema = class(Tobject)

       procedure create;
       procedure add_entry(l:Tlist;entry:Tentry);
       function trouve_composant(l:Tlist;X,Y:integer):string;
       function trouve_composant_node(l:Tlist;X,Y:integer):string;
       function trouve_composant_node2(l:Tlist;X,Y:integer):integer;
       function show_entries(l:Tlist):TstringList;
       function show_entry(e:Tentry; s:TMemo):TstringList;
       function dejala(l:Tlist;X,Y:integer):boolean;
       function trouve_by_id(l:Tlist;id:integer):Tentry;
       function dejala2(cx:Tlist;deb,fin:integer):boolean;
       procedure add_link(cx:Tlist;lk:Tlink);
       function donne_cx(l:Tlist;num:integer):string;
       function trouve_cx(cx:Tlist;num:integer):string;

  end;

PEntry = ^TEntry;
Plink = ^Tlink;
const
   Devices : array[0..8] of TDevice =
   (
     (Name : 'P'; broches : 1),
     (Name : 'N'; broches : 1),
     (Name : 'NF0'; broches : 2),
     (Name : 'NO0'; broches : 2),
     (Name : 'LMP0'; broches : 2),
     (Name : 'VV0G'; broches : 3),
     (Name : 'VV0D'; broches : 3),
     (Name : 'VV1G'; broches : 3),
     (Name : 'VV1D'; broches : 3)
   ) ;

procedure Split(Delimiter: Char; Str: string; ListOfStrings: TStrings) ;

implementation

procedure Split(Delimiter: Char; Str: string; ListOfStrings: TStrings) ;
begin
   ListOfStrings.Clear;
   ListOfStrings.Delimiter       := Delimiter;
   ListOfStrings.StrictDelimiter := True; // Requires D2006 or newer.
   ListOfStrings.DelimitedText   := Str;
end;

procedure Tschema.create;
begin

end;

procedure Tschema.add_link(cx:Tlist;lk:Tlink);
var p:Plink;
begin
    if self.dejala2(cx,lk.de,lk.a) then exit;
    if self.dejala2(cx,lk.a,lk.de) then exit;
    new(p);
    p^:=lk;
    cx.Add(p);
end;

function Tschema.show_entries(l:Tlist):TstringList;
var p : Pentry;
    i:integer;
    res:TstringList;
begin
   res:=TstringList.create;
   for i:=0 to l.Count-1 do begin
      new(p);
      p:=l.Items[i];
      res.Add(inttostr(p^.X)+':'+inttostr(p^.Y)+':'+p^.device+':'+inttostr(p^._broches));
   end;
   result:=res;
end;
function Tschema.dejala(l:Tlist;X,Y:integer):boolean;
var res:boolean;
    p : Pentry;
    i:integer;
begin
 res:=false;
 for i:=0 to l.Count-1 do begin
      new(p);
      p:=l.Items[i];
      if (p^.X =X) and (p^.Y =Y) then
      begin
          res:=true;
          break;
      end;
 end;
 result:=res;
end;

function Tschema.dejala2(cx:Tlist;deb,fin:integer):boolean;
var res:boolean;
    p : Plink;
    i:integer;
begin
 res:=false;
 for i:=0 to cx.Count-1 do begin
      new(p);
      p:=cx.Items[i];
      if ((p^.de =deb) and (p^.a =fin)) or ((p^.de =fin) and (p^.a =deb)) then
      begin
          res:=true;
          break;
      end;
 end;
 result:=res;
end;

procedure Tschema.add_entry(l:Tlist;entry:Tentry);
var p : Pentry;
begin
   if self.dejala(l,entry.X,entry.Y) then exit;
   new(p);
   p^:=entry;
   p^.num:=l.Count;

   l.Add(p);


end;
function Tschema.trouve_by_id(l:Tlist;id:integer):Tentry;
var i:integer;
    p:Pentry;
begin
 new(p);
 p:=l.Items[id];
 result:=p^;
end;


function Tschema.trouve_composant_node2(l:Tlist;X,Y:integer):integer;
var i:integer;
    p:Pentry;
    res:integer;
begin
   res := -1;
   for i:=0 to l.count-1 do begin
      //new(p);
      p:=l.Items[i];
      if (p^.X = X) and (p^.Y = Y) then
      begin
          res:= p^.num;
      end;
   end;

   result:= res;

end;

function Tschema.trouve_composant_node(l:Tlist;X,Y:integer):string;
var i:integer;
    p:Pentry;
    res:string;
begin
   res := '-';
   for i:=0 to l.count-1 do begin
      //new(p);
      p:=l.Items[i];
      if (p^.X = X) and (p^.Y = Y) then
      begin
          res:= inttostr(p^.num);
      end;
   end;

   result:= res;

end;

function Tschema.donne_cx(l:Tlist;num:integer):string;
var res:string;
    p:Pentry;
    i:integer;

begin
  res:='';
  p:=l.Items[num];
  for i :=  (p^._broches-p^.broches+1) to  (p^._broches) do
   res :=res+':'+inttostr(i);

  result:=res;



end;

function Tschema.trouve_cx(cx:Tlist;num:integer):string;
var res:string;
    p:Plink;
    i:integer;

begin
  res:='';

  for i := 0 to cx.count-1 do begin
     p:=cx.items[i];
     if p^.de = num then res := res+':'+ inttostr(p^.a);
     if p^.a = num then res := res+':'+ inttostr(p^.de);
  end;

  result:=res;



end;

function Tschema.trouve_composant(l:Tlist;X,Y:integer):string;
var i:integer;
    p:Pentry;
    res:string;
begin

   for i:=0 to l.count-1 do begin
      //new(p);
      p:=l.Items[i];
      if (p^.X = X) and (p^.Y = Y) then
      begin
          res:= p^.device+'-'+inttostr(p^.num);
      end;
   end;
   if res ='' then res:='-';
   result:= res;

end;
function Tschema.show_entry(e:Tentry; s:TMemo):TstringList;
begin
   s.Lines.Add(inttostr(e.X)+':'+inttostr(e.Y)+':'+e.device);
end;


end.

