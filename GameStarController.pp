{ Written by Heavyy-c }
{ GNU GPLv3.0 }

unit GameStarController;

interface
uses crt;

type
	StarData = record
		X, Y: integer;
		Simbol: char;
	end;

procedure Star_SetSimbol(var Star: StarData; Simbol: char);
procedure Star_SetRandom(var Star: StarData);
procedure Star_Hide(var Star: StarData);
procedure Star_Show(var Star: StarData);

implementation

procedure Star_SetSimbol(var Star: StarData; Simbol: char);
begin
	Star.Simbol := Simbol
end;

procedure Star_SetRandom(var Star: StarData);
begin
	repeat
		Star.X := random(ScreenWidth) + 1;
		Star.Y := random(ScreenHeight) + 1;
	until (Star.X <> ScreenWidth) and (Star.Y <> ScreenHeight)
end;

procedure WriteSimbolXY(X, Y: integer; Simbol: char);
var
	CursorX, CursorY: integer;
begin
	CursorX := WhereX;
	CursorY := WhereY;
	GotoXY(X, Y);
	write(Simbol);
	GotoXY(CursorX, CursorY)
end;

procedure Star_Hide(var Star: StarData);
begin
	WriteSimbolXY(Star.X, Star.Y, ' ');
end;

procedure Star_Show(var Star: StarData);
begin
	WriteSimbolXY(Star.X, Star.Y, Star.Simbol);
end;

end.
