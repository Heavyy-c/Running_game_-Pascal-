{ Written by Heavyy-c }
{ GNU GPLv3.0 }

unit GamePlayerController;

interface
uses crt, GameEnemyController, GameStarController;


type
	GameSettings = record
		PlayerSpeed: integer;
		FrameDelay: integer;
	end;

	MoveDirections = (Direction_Up, Direction_Down,
		Direction_Left, Direction_Right);
	PlayerData = record
		CountOfCollectedStars: longint;
		FramesAlive: longint;
		Simbol: char;
		X, Y: integer;
		MoveDirection: MoveDirections;
	end;

procedure Player_SetSimbol(var Player: PlayerData; Simbol: char);
procedure Player_SetCoords(var Player: PlayerData; X, Y: integer);
procedure Player_SetFramesAlive(var Player: PlayerData; Frames: integer);
procedure Player_SetCollectedStars(var Player: PlayerData; Count: integer);
procedure Player_SetDirection(var Player: PlayerData;
				Direction: MoveDirections);

procedure Player_IncrementCollectedStarsVar(var Player: PlayerData);
procedure Player_IncrementFramesAlive(var Player: PlayerData);
procedure Player_Move(var Player: PlayerData);
procedure Player_Show(var Player: PlayerData);
procedure Player_Hide(var Player: PlayerData);
function Player_IsPlayerCollectedStar(Player: PlayerData; Star: StarData)
								: boolean;
function Player_IsPlayerDead(Player: PlayerData; Enemy: EnemyData): boolean;
function Player_GetFramesAlive(var Player: PlayerData): integer;
function Player_GetCountOfCollectedStars(var Player: PlayerData): integer;

implementation

procedure Player_SetSimbol(var Player: PlayerData; Simbol: char);
begin
	Player.Simbol := Simbol
end;

procedure Player_SetCoords(var Player: PlayerData; X, Y: integer);
begin
	Player.X := X;
	Player.Y := Y
end;

procedure Player_SetFramesAlive(var Player: PlayerData; Frames: integer);
begin
	Player.FramesAlive := Frames
end;

procedure Player_SetCollectedStars(var Player: PlayerData; Count: integer);
begin
	Player.CountOfCollectedStars := Count
end;

procedure Player_SetDirection(var Player: PlayerData;
				Direction: MoveDirections);
begin
	Player.MoveDirection := Direction
end;

procedure Player_IncrementCollectedStarsVar(var Player: PlayerData);
begin
	Inc(Player.CountOfCollectedStars)
end;

procedure Player_IncrementFramesAlive(var Player: PlayerData);
begin
	Inc(Player.FramesAlive)
end;

procedure MovePlayerUp(var Player: PlayerData);
begin
	Dec(Player.Y)
end;

procedure MovePlayerDown(var Player: PlayerData);
begin
	Inc(Player.Y)
end;

procedure MovePlayerLeft(var Player: PlayerData);
begin
	Dec(Player.X)
end;

procedure MovePlayerRight(var Player: PlayerData);
begin
	Inc(Player.X)
end;

procedure MovePlayerByDirection(var Player: PlayerData);
begin
	case Player.MoveDirection of
	Direction_Up:
		begin
			MovePlayerUp(Player);
			if Player.Y < 1 then
				Player.Y := ScreenHeight
		end;
	Direction_Down:
		begin
			MovePlayerDown(Player);
			if Player.Y > ScreenHeight then
				Player.Y := 1
		end;
	Direction_Left:
		begin
			MovePlayerLeft(Player);
			if Player.X < 1 then
				Player.X := ScreenWidth
		end;
	Direction_Right:
		begin
			MovePlayerRight(Player);
			if Player.X > ScreenWidth then
				Player.X := 1
		end
	end
end;

function PlayerAtRightDownAngle(Player: PlayerData): boolean;
begin
	PlayerAtRightDownAngle := (Player.X = ScreenWidth) and
				(Player.Y = ScreenHeight)
end;

function PlayerIsOutOfScreen(Player: PlayerData): boolean;
begin
	PlayerIsOutOfScreen := (Player.X > ScreenWidth) or (Player.X < 1)
			or (Player.Y > ScreenHeight) or (Player.Y < 1)
end;

procedure Player_Move(var Player: PlayerData);
begin
	MovePlayerByDirection(Player);
	if PlayerAtRightDownAngle(Player) or PlayerIsOutOfScreen(Player) then
		MovePlayerByDirection(Player);
end;

procedure Player_Show(var Player: PlayerData);
var
	CursorX, CursorY: integer;
begin
	CursorX := WhereX;
	CursorY := WhereY;
	GotoXY(Player.X, Player.Y);
	write(Player.Simbol);
	GotoXY(CursorX, CursorY);
end;

procedure Player_Hide(var Player: PlayerData);
var
	CursorX, CursorY: integer;
begin
	CursorX := WhereX;
	CursorY := WhereY;
	GotoXY(Player.X, Player.Y);
	write(' ');
	GotoXY(CursorX, CursorY);
end;

function IsPlayerInFrameEnemy(Player: PlayerData): boolean;
begin
	IsPlayerInFrameEnemy := (Player.X = 1) or 
		(Player.X = ScreenWidth) or (Player.Y = 1) or
		(Player.Y = ScreenHeight)
end;

function IsPlayerInRowEnemy(Player: PlayerData; Enemy: EnemyData): boolean;
begin
	IsPlayerInRowEnemy := (Player.Y = Enemy.YCoordLine)
end;

function IsPlayerInColomnEnemy(Player: PlayerData; Enemy: EnemyData): boolean;
begin
	IsPlayerInColomnEnemy := (Player.X = Enemy.XCoordLine)
end;

function Player_IsPlayerCollectedStar(Player: PlayerData; Star: StarData)
								: boolean;
begin
	Player_IsPlayerCollectedStar := (Player.X = Star.X) and
						(Player.Y = Star.Y)
end;

function Player_IsPlayerDead(Player: PlayerData; Enemy: EnemyData): boolean;
begin
	if Enemy.State = EnemyState_Alive then
	begin
		case Enemy.EnemyType of
		EnemyType_Frame:
			Player_IsPlayerDead := IsPlayerInFrameEnemy(Player);
		EnemyType_Row:
			Player_IsPlayerDead :=
					IsPlayerInRowEnemy(Player, Enemy);
		EnemyType_Colomn:
			Player_IsPlayerDead :=
					IsPlayerInColomnEnemy(Player, Enemy)
		end
	end
	else
	begin
		Player_IsPlayerDead := false
	end
end;

function Player_GetFramesAlive(var Player: PlayerData): integer;
begin
	Player_GetFramesAlive := Player.FramesAlive
end;

function Player_GetCountOfCollectedStars(var Player: PlayerData): integer;
begin
	Player_GetCountOfCollectedStars := Player.CountOfCollectedStars
end;

end.
