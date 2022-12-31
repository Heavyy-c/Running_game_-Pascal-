{ Written by Heavyy-c }
{ GNU GPLv3.0 }

program RunningGameProgram;
uses crt, CrtKeyboardModule, GamePlayerController,
	GameEnemyController, GameStarController,
	FilePlayerController, TimeConsts;

const
	InitPlayerDirection = Direction_Left;
	PlayerSimbolConst = 'U';
	StarSimbolConst = '*';
	MaxEnemyFramesAliveConst = 30;
	MinEnemyFramesAliveConst = 10;
	MaxEnemyFramesBeforeSpawnConst = 30;
	MinEnemyFramesBeforeSpawnConst = 10;
	MaxEnemyCount = 5;
	EnemyFGColorConst = White;
	EnemyBGColorConst = Green;
	EnemySimbolConst = '#';
	CollectedNowMsg = 'You collected now: ';
	TimeAliveNowMsg = 'You was alive in (sec): ';
	MaxTimeAliveMsg = 'Your max time alive (sec): ';
	MaxCollectionMsg = 'Your max collection: ';
	FileSavesName = 'Saves.bin';

type
	EnemyDataArray = array[1..MaxEnemyCount] of EnemyData;

procedure CleanOutKeyBuffer;
begin
	while KeyPressed do
		ReadKey;
end;

function KeyIsAnArrow(key: integer): boolean;
begin
	KeyIsAnArrow := (key = Key_LeftArrow) or (key = Key_RightArrow)
			or (key = Key_UpArrow) or (key = Key_DownArrow);
end;

function ConvertKeyToDirection(key: integer): MoveDirections;
var
	res: MoveDirections;
begin
	case key of
	Key_LeftArrow:
		res := Direction_Left;
	Key_RightArrow:
		res := Direction_Right;
	Key_UpArrow:
		res := Direction_Up;
	Key_DownArrow:
		res := Direction_Down;
	end;
	ConvertKeyToDirection := res
end;

procedure SetRandomEnemyValues(var Enemy: EnemyData);
begin
	Enemy_SetRandomType(Enemy);
	Enemy_SetRandomFramesBeforeSpawn(Enemy, MinEnemyFramesBeforeSpawnConst,
				MaxEnemyFramesBeforeSpawnConst);
	Enemy_SetRandomFramesAlive(Enemy, MinEnemyFramesAliveConst,
						MaxEnemyFramesAliveConst);
	Enemy_SetRandomCoordsLine(Enemy)
end;

procedure UpdateEnemy(var EnemyArray: EnemyDataArray);
var
	i: integer;
begin
	for i := 1 to MaxEnemyCount do
	begin
		if Enemy_IsEnemyBlink(EnemyArray[i]) then
			Enemy_DecrementFramesBeforeSpawn(EnemyArray[i]);
		if Enemy_IsTimeToSpawn(EnemyArray[i]) and 
			Enemy_IsEnemyBlink(EnemyArray[i]) then
				Enemy_Spawn(EnemyArray[i]);
		if Enemy_IsEnemyAlive(EnemyArray[i]) then
			Enemy_DecrementFramesAlive(EnemyArray[i]);
		if Enemy_IsLifeTimeOut(EnemyArray[i]) and
			Enemy_IsEnemyAlive(EnemyArray[i]) then
		begin
			Enemy_Destroy(EnemyArray[i]);
		end;
		if Enemy_IsEnemyDead(EnemyArray[i]) then
		begin
			SetRandomEnemyValues(EnemyArray[i]);
			Enemy_SpawnBlink(EnemyArray[i])
		end
	end
end;

procedure MovePlayer(var Player: PlayerData);
begin
	Player_Hide(Player);
	Player_Move(Player);
	Player_Show(Player);
end;

procedure SpawnNewStar(var Star: StarData);
begin
	Star_SetRandom(Star);
	Star_Show(Star);
end;

var
	Player: PlayerData;
	DirVar: MoveDirections;
	Star: StarData;
	i: integer;
	time: real;
	GameEnd: boolean = false;
	EnemyArray: EnemyDataArray;
	key: integer;
	account: AccountType;
BEGIN
	Randomize;
	for i := 1 to MaxEnemyCount do
	begin
		Enemy_SetFGColor(EnemyArray[i], EnemyFGColorConst);
		Enemy_SetBGColor(EnemyArray[i], EnemyBGColorConst);
		Enemy_SetSimbol(EnemyArray[i], EnemySimbolConst);		
		SetRandomEnemyValues(EnemyArray[i]);
		EnemyArray[i].State := EnemyState_Dead
	end;

	GetPlayer(FileSavesName, account);

	clrscr;
	GotoXY(1, 1);
	Player_SetSimbol(Player, PlayerSimbolConst);
	Player_SetDirection(Player, InitPlayerDirection);
	Player_Show(Player);
	Player_SetCoords(Player, ScreenWidth div 2, ScreenHeight div 2);
	Star_SetSimbol(Star, StarSimbolConst);
	SpawnNewStar(Star);
	while true do
	begin
		if KeyPressed then
		begin
			GetKey(key);
			if KeyIsAnArrow(key) then
			begin
				DirVar := ConvertKeyToDirection(key);
				Player_SetDirection(Player, DirVar)
			end;
			CleanOutKeyBuffer
		end;
		MovePlayer(Player);
		UpdateEnemy(EnemyArray);
		Star_Show(Star);
		for i := 1 to MaxEnemyCount do
		begin
			if Player_IsPlayerDead(Player, EnemyArray[i]) then
			begin
				GameEnd := true;
				break
			end
		end;
		if GameEnd then
			break;
		if Player_IsPlayerCollectedStar(Player, Star) then
		begin
			Player_IncrementCollectedStarsVar(Player);
			Star_Hide(Star);
			SpawnNewStar(Star)
		end;
		delay(FrameDelay);
		Player_IncrementFramesAlive(Player);
	end;
	clrscr;
	time := (Player_GetFramesAlive(Player) / 10);
	WriteScore(FileSavesName, account, Player);
	writeln(CollectedNowMsg, Player_GetCountOfCollectedStars(Player));
	writeln(TimeAliveNowMsg, time:5:5);
	writeln(MaxCollectionMsg, GetMaxCountOfCollectedStars(account));
	writeln(MaxTimeAliveMsg, GetMaxTimeAlive(account):5:5);
END.
