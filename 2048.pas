PROGRAM Game_2048_____By_Fallen_Breath;

{$M 100000000,0,maxlongint}
{$inline on}

USES Crt,Dos,SysUtils,Math,BetterInput;

CONST
/////////////////////////Program Information/////////////////////////

      AppName                  = '2048';
      Version                  = 'Beta 1.0.0';
      Date                     = '2014.6.8';

/////////////////////////Main Constant/////////////////////////

      arrmaxx                  = 10;
      arrmaxy                  = 10;
      maxblocktype             = 105;
      maxcolor                 = 11;
      maxfx                    = 4;


/////////////////////////Graph Constant/////////////////////////

      blockwide=3;
      blockhigh=3;
      blockcolor:array[1..maxcolor] of longint      = (0,0,0,7,7,15,15,8,0,0,0);
      blockbackground:array[1..maxcolor] of longint = (7,7,7,1,1,3 ,4 ,5,6,6,6);

/////////////////////////Other Constant/////////////////////////

      gox:array[0..maxfx-1] of longint=(0 ,1 ,0 ,-1);
      goy:array[0..maxfx-1] of longint=(-1,0 ,1 ,0 );
      minlengthofusernam       = 1;
      maxlengthofusernam       = 20;
      minlengthofpassword      = 6;
      maxfindfilesres          = 1000;
      maxqueue                 = 10000;

TYPE Tblock=record
              id:longint;
              st:string;
            end;
     Tpos=record
            x,y:longint;
          end;
     Ttime=record
             hour,minute,second,s100,oldday:word;
             year,month,day,wday:word;
             sum:longint;
           end;
     Tsave=record
             maxscore:longint;
           end;

VAR maxx             : longint=4;
    maxy             : longint=4;
    blocknum         : array[1..maxblocktype] of string;
    noblock          : Tblock;

VAR map,oldmap                          : array[1..arrmaxx,1..arrmaxy] of Tblock;
    gamewin,gamelose                    : boolean;
    logged                              : boolean;
    savedata                            : Tsave;
    choose                              : longint;
    step,score                          : longint;


procedure F4;
begin
  write('Press F4 here!');
end;

function random(x:longint):longint;inline;
var i:longint;
    a:array[1..100] of longint;

   function rnd(n:longint):longint;
   begin
     exit(trunc(system.random*n));
   end;

begin
  for i:=1 to 100 do
    a[i]:=rnd(x);
  exit(a[rnd(100)+1]);
end;

procedure gt(var n:Ttime);inline;
begin
  with n do
  begin
    dos.getdate(year,month,day,wday);
    dos.gettime(hour,minute,second,s100);
    sum:=hour*360000+minute*6000+second*100+s100;
  end;
end;


function getastr(len:longint):string;
var i:longint;
begin
  getastr:='';
  for i:=1 to len do
    getastr:=getastr+chr(random(256));
end;

operator =(a,b:Tblock)ans:boolean;
begin
  ans:=a.id=b.id;
end;

function inmap(x,y:longint):boolean;
begin
  if (x<1) or (x>maxx) or (y<1) or (y>maxy) then exit(false);
  exit(true);
end;
function inmap(zb:Tpos):boolean;
begin
  exit(inmap(zb.x,zb.y));
end;

function can(x,y:longint):boolean;
var i:longint;
begin
  if inmap(x,y)=false then exit(false);
  with map[x,y] do
  begin
    if id=0 then exit(true);
    exit(false);
  end;
end;
function can(zb:Tpos):boolean;
begin
  exit(can(zb.x,zb.y));
end;

procedure block_inc(var block:Tblock);
begin
  with block do
  begin
    if id=0 then exit;
    system.inc(id);
    st:=inttostr(strtoint(st)*2);
    inc(score,strtoint(st));
  end;
end;

procedure print_block(x,y:longint);
begin
  with map[x,y] do
  begin
    if id<>0 then tb(blockbackground[(id-1) mod maxcolor+1])
     else tb(0);
    drawwindow(1+(blockwide+1)*2*(x-1)+2,(blockhigh+1)*(y-1)+2,
               (blockwide+1)*2*x,(blockhigh+1)*y);

    if id=0 then exit;
    gotoxy(1+(blockwide+1)*2*(x-1)+2+blockwide div 2+1-length(st) div 2,
             (blockhigh+1)*(y-1)+2+blockhigh div 2);
    tc(blockcolor[(id-1) mod maxcolor+1]);
    write(st);
  end;
end;
procedure print_block(pos:Tpos);
begin
  print_block(pos.x,pos.y);
end;

procedure print_game_info;
var i:longint;
    s:string;
begin
  s:='������'+inttostr(step);
  gotoxy(windmaxx-15,5);tb(0);tc(7);write(s);
  s:='������'+inttostr(score);
  gotoxy(windmaxx-15,6);tb(0);tc(7);write(s);
end;

procedure print_map;
var i,j:longint;
begin
  for i:=1 to maxx do
   for j:=1 to maxy do
    if (map[i,j]=oldmap[i,j])=false then
    begin
      print_block(i,j);
      oldmap[i,j]:=map[i,j];
    end;
end;

procedure print_all;
begin
  print_map;
  print_game_info;
end;

procedure print_program_info;
var i,j:longint;
begin
  gotoxy(windmaxx-length('����汾:'+Version)+1,windmaxy-1);                 tc(7);  write('����汾:',Version);
  gotoxy(windmaxx-15,windmaxy);                                              tc(8);  write('By ');  tc(15);  write('Fallen_Breath');
end;

function check_gamewin:boolean;
var i,j:longint;
begin
  for i:=1 to maxx do
   for j:=1 to maxy do
    with map[i,j] do
    begin
      if id>=11 then exit(true);
    end;
  exit(false);
end;

function check_gamelose:boolean;
var i,j,fx,xx,yy:longint;
begin
  for i:=1 to maxx do
   for j:=1 to maxy do
    with map[i,j] do
    begin
      if id=0 then exit(false);
      for fx:=0 to maxfx-1 do
      begin
        xx:=i+gox[fx];
        yy:=j+goy[fx];
        if inmap(xx,yy)=false then continue;
        if map[xx,yy].id=map[i,j].id then exit(false);
      end; //end for fx
    end;//end with
  exit(true);
end;

function new_block:Tpos;
var x,y:longint;
begin
  new_block.x:=-1;new_block.y:=-1;
  if check_gamelose then exit;
  repeat
    x:=random(maxx)+1;
    y:=random(maxy)+1;
  until can(x,y);
  with map[x,y] do
  begin
    if random(4)<>0 then id:=1
     else id:=2;
    case id of
      1:st:='2';
      2:st:='4';
    end;//end case
  end;
  new_block.x:=x;new_block.y:=y;
end;

procedure init_game;
var i,j:longint;
begin
  clrscr;
  drawwindow(1,1,((blockwide+1)*maxx+1)*2,(blockhigh+1)*maxy+1,2);
  for i:=1 to arrmaxx do
   for j:=1 to arrmaxy do
   begin
     map[i,j]:=noblock;
     oldmap[i,j].id:=-1;
   end;
  step:=0;
  gamewin:=false;
  gamelose:=false;
  for i:=1 to 2 do new_block;
  print_all;
end;

procedure init_program;
var i,j:longint;

   procedure change_program;
   var f:text;
   begin
     assign(f,'game.bat');
     rewrite(f);
     writeln(f,'@echo off');
     writeln(f,'@chcp 936');
     writeln(f,'@title 2048');
     writeln(f,'mode con COLS=',((blockwide+1)*maxx+1)*2+20,' LINES=',(blockhigh+1)*maxy+1+2);
     writeln(f,'@del game.bat');
     close(f);
     exec('game.bat','');
   end;

begin
  cursoroff;
  randomize;
  windmaxx:=((blockwide+1)*maxx+1)*2+20;
  windmaxy:=(blockhigh+1)*maxy+1+2;
  tb(0);tc(15);clrscr;
  gotoxy_mid('Loading...',1);write('Loading...');
  change_program;
  print_program_info;
  dec(windmaxy,2);

  with noblock do
  begin
    id:=0;
    st:='';
  end;
end;

function move(fx:longint):boolean;
var x,y,xx,yy,i,j,t:longint;
    composed:array[1..arrmaxx,1..arrmaxy] of boolean;

   procedure swap(var a,b:Tblock);
   var c:Tblock;
   begin
     c:=a;a:=b;b:=c;
   end;

begin
  move:=false;
  fillchar(composed,sizeof(composed),false);
  case fx of
    0:begin
        for x:=1 to maxx do
        begin
          for y:=1 to maxy do
           if map[x,y]=noblock then
           begin
             for i:=y+1 to maxy do
              if (map[x,i]=noblock)=false then
              begin
                swap(map[x,y],map[x,i]);
                move:=true;
                 break;
              end; //end for i
           end; //end for y
          for y:=1 to maxy-1 do
           if (composed[x,y]=false) and (map[x,y]=map[x,y+1]) and ((map[x,y]=noblock)=false) then
           begin
             composed[x,y]:=true;
             block_inc(map[x,y]);
             for i:=y+1 to maxy-1 do
               map[x,i]:=map[x,i+1];
             map[x,maxy]:=noblock;
           end;//end for y
        end;//end for x
      end;//end case
    1:begin
        for y:=1 to maxy do
        begin
          for x:=maxx downto 1 do
           if map[x,y]=noblock then
           begin
             for i:=x-1 downto 1 do
              if (map[i,y]=noblock)=false then
              begin
                swap(map[x,y],map[i,y]);
                move:=true;
                break;
              end; //end for i
           end; //end for y
          for x:=maxx downto 2 do
           if (composed[x,y]=false) and (map[x,y]=map[x-1,y]) and ((map[x,y]=noblock)=false) then
           begin
             composed[x,y]:=true;
             block_inc(map[x,y]);
             for i:=x-1 downto 2 do
               map[i,y]:=map[i-1,y];
             map[1,y]:=noblock;
           end;//end for y
        end;//end for x
      end;//end case
    2:begin
        for x:=1 to maxx do
        begin
          for y:=maxy downto 1 do
           if map[x,y]=noblock then
           begin
             for i:=y-1 downto 1 do
              if (map[x,i]=noblock)=false then
              begin
                swap(map[x,y],map[x,i]);
                move:=true;
                break;
              end; //end for i
           end; //end for y
          for y:=maxy downto 2 do
           if (composed[x,y]=false) and (map[x,y]=map[x,y-1]) and ((map[x,y]=noblock)=false) then
           begin
             composed[x,y]:=true;
             block_inc(map[x,y]);
             for i:=y-1 downto 2 do
               map[x,i]:=map[x,i-1];
             map[x,1]:=noblock;
           end;//end for y
        end;//end for x
      end;//end case
    3:begin
        for y:=1 to maxy do
        begin
          for x:=1 to maxx do
           if map[x,y]=noblock then
           begin
             for i:=x+1 to maxx do
              if (map[i,y]=noblock)=false then
              begin
                swap(map[x,y],map[i,y]);
                move:=true;
                break;
              end; //end for i
           end; //end for y
          for x:=1 to maxx-1 do
           if (composed[x,y]=false) and (map[x,y]=map[x+1,y]) and ((map[x,y]=noblock)=false) then
           begin
             composed[x,y]:=true;
             block_inc(map[x,y]);
             for i:=x+1 to maxx do
               map[i,y]:=map[i+1,y];
             map[maxx,y]:=noblock;
           end;//end for y
        end;//end for x
      end;
  end;
end;

function play:longint;
var kp:char;
    movesucc:boolean;
begin
  repeat
    print_map;
    print_game_info;
    kp:=upcase(readkey);
    case kp of
      'W':movesucc:=move(0);
      'A':movesucc:=move(3);
      'S':movesucc:=move(2);
      'D':movesucc:=move(1);
      #0:begin
           kp:=readkey;
           case kp of
             #72:movesucc:=move(0);
             #75:movesucc:=move(3);
             #80:movesucc:=move(2);
             #77:movesucc:=move(1);
             #27:begin
                   if gamewin then exit(1)
                    else exit(2);
                 end; //end case #27
           end; //end case
         end; //end case #0
      else movesucc:=false;
    end; //end case
    gamewin:=check_gamewin;
    gamelose:=check_gamelose;
    if gamelose then break;
    if movesucc then
    begin
      inc(step);
      new_block;
    end;
  until false;
  if gamewin then exit(1)
   else exit(0);
end;

procedure clear_game;
begin
end;

procedure work_game;
var playexit:longint;
begin
  init_game;
  playexit:=play;
  clear_game;

  gotoxy(windmaxx-12,2);
  case playexit of
    0:begin
        tc(10);write('ʧ��');
      end;
    1:begin
        tc(12);write('ʤ��');
      end;
    2:exit;
  end;
  delay(1000);
  while keypressed do readkey;
  readkey;
  tb(0);clrscr;
end;

procedure work_main;
var choose:longint;
begin
  repeat
    clrscr;
    gotoxy_mid(getastr(length('��ʼ��Ϸ')+6),1);
    choose:=chooseone('��ʼ��Ϸ'+ln+
                      '�˳�');
    case choose of
      1:work_game;
      2:break;
    end;
  until false;
end;

BEGIN
  init_program;
  work_main;
END.