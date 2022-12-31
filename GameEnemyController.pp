{ Written by Heavyy-c }
{ GNU GPLv3.0 }

unit GameEnemyController;

interface
uses crt;
type
	EnemyTypes = (EnemyType_Frame, {EnemyType_Diagonal,}
			EnemyType_Row, EnemyType_Colomn);
	EnemyStates = (EnemyState_Blink, EnemyState_Alive, EnemyState_Dead);
	EnemyData = record
		FramesBeforeSpawn: integer;
		FramesAlive: integer;
		FG_Color, BG_Color: integer;
		Simbol: char;
		EnemyType: EnemyTypes;
		State: EnemyStates;
		YCoordLine, XCoordLine: integer; {For Row and Colomn type}
	end;

const
	Enemy_CountOfEnemyTypes = 3;
	Enemy_CountOfEnemyStates = 3;
var
	Enemy_ArrayOfEnemyTypes: array[1..Enemy_CountOfEnemyTypes]
		of EnemyTypes =
			(EnemyType_Frame, EnemyType_Row, EnemyType_Colomn);
	Enemy_ArrayOfEnemyStates: array[1..Enemy_CountOfEnemyStates] 
		of EnemyStates = 
			(EnemyState_Blink, EnemyState_Alive, EnemyState_Dead);

procedure Enemy_Spawn(var Enemy: EnemyData);
procedure Enemy_SpawnBlink(var Enemy: EnemyData);
procedure Enemy_Destroy(var Enemy: EnemyData);

procedure Enemy_SetFGColor(var Enemy: EnemyData; Color: integer);
procedure Enemy_SetBGColor(var Enemy: EnemyData; Color: integer);
procedure Enemy_SetSimbol(var Enemy: EnemyData; Simbol: char);
procedure Enemy_SetXCoordLine(var Enemy: EnemyData; XCoord: integer);
procedure Enemy_SetYCoordLine(var Enemy: EnemyData; YCoord: integer);

procedure Enemy_SetRandomType(var Enemy: EnemyData);
procedure Enemy_SetRandomFramesBeforeSpawn(var Enemy: EnemyData;
					FramesMin, FramesMax: integer);
procedure Enemy_SetRandomFramesAlive(var Enemy: EnemyData;
					FramesMin, FramesMax: integer);
procedure Enemy_SetRandomCoordsLine(var Enemy: EnemyData);

procedure Enemy_DecrementFramesBeforeSpawn(var Enemy: EnemyData);
procedure Enemy_DecrementFramesAlive(var Enemy: EnemyData);

function Enemy_IsTimeToSpawn(Enemy: EnemyData): boolean;
function Enemy_IsLifeTimeOut(Enemy: EnemyData): boolean;
function Enemy_IsEnemyBlink(Enemy: EnemyData): boolean;
function Enemy_IsEnemyAlive(Enemy: EnemyData): boolean;
function Enemy_IsEnemyDead(Enemy: EnemyData): boolean;

implementation

procedure DrawHorizontalLine(Simbol: char; StartX, EndX, Y: integer);
var
	i: integer;
	CursorX, CursorY: integer;
begin
	CursorX := WhereX;
	CursorY := WhereY;
	for i := StartX to EndX do
	begin
		GotoXY(i, Y);
		write(Simbol)
	end;
	GotoXY(CursorX, CursorY)
end;

procedure DrawVerticalLine(Simbol: char; StartY, EndY, X: integer);
var
	i: integer;
	CursorX, CursorY: integer;
begin
	CursorX := WhereX;
	CursorY := WhereY;
	for i := StartY to EndY do
	begin
		GotoXY(X, i);
		write(Simbol)
	end;
	GotoXY(CursorX, CursorY)
end;


procedure SpawnFrameEnemy(Enemy: EnemyData);
var
	ColorSettings: integer;
begin
	ColorSettings := TextAttr;
	TextBackground(Enemy.BG_Color);
	TextColor(Enemy.FG_Color);
	DrawHorizontalLine(Enemy.Simbol, 1, ScreenWidth, 1);
	DrawHorizontalLine(Enemy.Simbol, 1, ScreenWidth-1, ScreenHeight);
	DrawVerticalLine(Enemy.Simbol, 1, ScreenHeight, 1);
	DrawVerticalLine(Enemy.Simbol, 1, ScreenHeight-1, ScreenWidth);
	TextAttr := ColorSettings
end;

procedure SpawnRowEnemy(Enemy: EnemyData);
var
	EndCoordLine: integer;
	ColorSettings: integer;
begin
	ColorSettings := TextAttr;
	TextBackground(Enemy.BG_Color);
	TextColor(Enemy.FG_Color);
	if Enemy.YCoordLine = ScreenHeight then
		EndCoordLine := ScreenWidth-1
	else
		EndCoordLine := ScreenWidth;
	DrawHorizontalLine(Enemy.Simbol, 1, EndCoordLine, Enemy.YCoordLine);
	TextAttr := ColorSettings
end;

procedure SpawnColomnEnemy(Enemy: EnemyData);
var
	EndCoordLine: integer;
	ColorSettings: integer;
begin
	ColorSettings := TextAttr;
	TextBackground(Enemy.BG_Color);
	TextColor(Enemy.FG_Color);
	if Enemy.XCoordLine = ScreenWidth then
		EndCoordLine := ScreenHeight-1
	else
		EndCoordLine := ScreenHeight;
	DrawVerticalLine(Enemy.Simbol, 1, EndCoordLine, Enemy.XCoordLine);
	TextAttr := ColorSettings
end;

procedure Enemy_Spawn(var Enemy: EnemyData);
begin
	case Enemy.EnemyType of
	EnemyType_Frame:
		SpawnFrameEnemy(Enemy);
	EnemyType_Row:
		SpawnRowEnemy(Enemy);
	EnemyType_Colomn:
		SpawnColomnEnemy(Enemy);
	end;
	Enemy.State := EnemyState_Alive
end;

procedure Enemy_SpawnBlink(var Enemy: EnemyData);
var
	TmpEnemyVar: EnemyData;
begin
	TmpEnemyVar := Enemy;
	TmpEnemyVar.FG_Color := TmpEnemyVar.FG_Color or Blink;
	TmpEnemyVar.BG_Color := TmpEnemyVar.BG_Color or Blink;
	Enemy_Spawn(TmpEnemyVar);
	Enemy.State := EnemyState_Blink
end;

procedure Enemy_Destroy(var Enemy: EnemyData);
var
	TmpVar: EnemyData;
begin
	TmpVar := Enemy;
	TmpVar.Simbol := ' ';
	TmpVar.FG_Color := TextAttr and 31;
	TmpVar.BG_Color := (TextAttr and 127) and (not 31);
	Enemy_Spawn(TmpVar);
	Enemy.State := EnemyState_Dead
end;

procedure Enemy_SetFGColor(var Enemy: EnemyData; Color: integer);
begin
	Enemy.FG_Color := Color
end;

procedure Enemy_SetBGColor(var Enemy: EnemyData; Color: integer);
begin
	Enemy.BG_Color := Color
end;

procedure Enemy_SetSimbol(var Enemy: EnemyData; Simbol: char);
begin
	Enemy.Simbol := Simbol
end;

procedure Enemy_SetXCoordLine(var Enemy: EnemyData; XCoord: integer);
begin
	Enemy.XCoordLine := XCoord
end;

procedure Enemy_SetYCoordLine(var Enemy: EnemyData; YCoord: integer);
begin
	Enemy.YCoordLine := YCoord
end;

procedure Enemy_SetRandomType(var Enemy: EnemyData);
var
	res: integer;
begin
	res := random(Enemy_CountOfEnemyTypes) + 1;
	Enemy.EnemyType := Enemy_ArrayOfEnemyTypes[res]
end;

procedure Enemy_SetRandomFramesBeforeSpawn(var Enemy: EnemyData;
					FramesMin, FramesMax: integer);
begin
	Enemy.FramesBeforeSpawn := random(FramesMax) + FramesMin + 1;
end;

procedure Enemy_SetRandomFramesAlive(var Enemy: EnemyData;
					FramesMin, FramesMax: integer);
begin
	Enemy.FramesAlive := random(FramesMax) + FramesMin + 1;
end;

procedure Enemy_SetRandomCoordsLine(var Enemy: EnemyData);
begin
	repeat
		Enemy.XCoordLine := random(ScreenWidth) + 1;
		Enemy.YCoordLine := random(ScreenHeight) + 1;
	until (Enemy.XCoordLine <> ScreenWidth) and
		(Enemy.YCoordLine <> ScreenHeight);
end;

procedure Enemy_DecrementFramesBeforeSpawn(var Enemy: EnemyData);
begin
	Dec(Enemy.FramesBeforeSpawn)
end;

procedure Enemy_DecrementFramesAlive(var Enemy: EnemyData);
begin
	Dec(Enemy.FramesAlive)
end;

function Enemy_IsTimeToSpawn(Enemy: EnemyData): boolean;
begin
	Enemy_IsTimeToSpawn := Enemy.FramesBeforeSpawn = 0
end;

function Enemy_IsLifeTimeOut(Enemy: EnemyData): boolean;
begin
	Enemy_IsLifeTimeOut := Enemy.FramesAlive = 0
end;

function Enemy_IsEnemyBlink(Enemy: EnemyData): boolean;
begin
	Enemy_IsEnemyBlink := Enemy.State = EnemyState_Blink
end;

function Enemy_IsEnemyAlive(Enemy: EnemyData): boolean;
begin
	Enemy_IsEnemyAlive := Enemy.State = EnemyState_Alive
end;

function Enemy_IsEnemyDead(Enemy: EnemyData): boolean;
begin
	Enemy_IsEnemyDead := Enemy.State = EnemyState_Dead
end;

end.
