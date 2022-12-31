{ Written by Heavyy-c }
{ GNU GPLv3.0 }

unit FilePlayerController;

interface
uses GamePlayerController, TimeConsts;

type
	AccountType = record
		name: string;
		MaxFramesAlive: longint;
		MaxTimeAlive: real;
		MaxCountOfCollectedStars: longint;
		password: integer;
		filePos: integer;
	end;

procedure GetPlayer(fileName: string; var account: AccountType);
procedure WriteScore(fileName: string; var account: AccountType;
							data: PlayerData);

function GetMaxCountOfCollectedStars(account: AccountType): longint;
function GetMaxTimeAlive(account: AccountType): real;

implementation

const
	NoFileDetectedMsg = 'No file of player accounts detected';
	CreateNewFileOrExitMsg = 'Would uou like to create new file ' +
						'or exit program?';
	CreateNewFileDescription = 'Create new file';
	ExitProgramDescription = 'Exit program';
	TypePasswordMsg = 'Please type your password: ';
	RepeatPasswordMsg = 'Please repeat your password: ';
	TypeNameMsg = 'Please type your name: ';
	CreateNewAccountOrSelectOneMsg = 'Would you like to create new ' +
				'account or select one?';
	CreateNewAccountDescription = 'Create new account';
	SelectAccountDescription = 'Select account';
	TypeYourPasswordMsg = 'Type your password:  ' +
				'(or EXIT to stop program): ';
	ZeroFilePos = 0;

type
	ActionEnum = (ACTION_EXIT_PROGRAM, ACTION_CREATE_NEW_FILE,
			ACTION_CREATE_NEW_ACCOUNT, ACTION_SELECT_ACCOUNT);
	AccountFile = file of AccountType;
	AccountListPtr = ^AccountList;
	AccountList = record
		account: AccountType;
		next: AccountListPtr;
	end;

procedure PrintChoiceItem(point, description: string);
const
	SEPARATOR = ': ';
var
	res: string;
begin
	res := point + SEPARATOR + description;
	writeln(res)
end;

procedure CreateNewFileOrExit(var action: ActionEnum);
const
	CREATE_NEW_FILE_CODE = '0';
	EXIT_PROGRAM_CODE = '1';
var
	a: string;
begin
	repeat
		writeln(CreateNewFileOrExitMsg);
		PrintChoiceItem(CREATE_NEW_FILE_CODE,
				CreateNewFileDescription);
		PrintChoiceItem(EXIT_PROGRAM_CODE,
				ExitProgramDescription);
		readln(a);
	until (a = CREATE_NEW_FILE_CODE) or (a = EXIT_PROGRAM_CODE);
	case a of
	CREATE_NEW_FILE_CODE:
		action := ACTION_CREATE_NEW_FILE;
	EXIT_PROGRAM_CODE:
		action := ACTION_EXIT_PROGRAM
	end
end;

procedure GetName(var name: string);
begin
	write(TypeNameMsg);
	readln(name)
end;

procedure GetPassword(var password: integer);
var
	passwd1, passwd2: integer;
begin
	repeat
		write(TypePasswordMsg);
		readln(passwd1);
		write(RepeatPasswordMsg);
		readln(passwd2);
	until passwd1 = passwd2;
	password := passwd1;
end;

procedure CreateNewAccount(var account: AccountType; filePos: integer);
begin
	GetName(account.name);
	GetPassword(account.password);
	account.MaxFramesAlive := 0;
	account.MaxCountOFCollectedStars := 0;
	account.filePos := filePos;
end;

procedure GetAccounts(var f: AccountFile; var list: AccountListPtr);
var
	tempData: AccountType;
	tempPtr, tempPtrNew: AccountListPtr;
begin
	tempPtr := nil;
	while not eof(f) do
	begin
		read(f, tempData);
		new(tempPtrNew);
		(tempPtrNew^).next := nil;
		(tempPtrNew^).account := tempData;
		if tempPtr <> nil then
			(tempPtr^).next := tempPtrNew;
		tempPtr := tempPtrNew;
		if list = nil then
			list := tempPtr;
	end;
end;

procedure CreateNewAccountOrSelectOne(var action: ActionEnum);
const
	CREATE_NEW_ACCOUNT_CODE = '0';
	SELECT_ACCOUNT_CODE = '1';
var
	a: string;
begin
	repeat
		writeln(CreateNewAccountOrSelectOneMsg);
		PrintChoiceItem(CREATE_NEW_ACCOUNT_CODE,
				CreateNewAccountDescription);
		PrintChoiceItem(SELECT_ACCOUNT_CODE,
				SelectAccountDescription);
		readln(a);
	until (a = CREATE_NEW_ACCOUNT_CODE) or (a = SELECT_ACCOUNT_CODE);
	case a of
	CREATE_NEW_ACCOUNT_CODE:
		action := ACTION_CREATE_NEW_ACCOUNT;
	SELECT_ACCOUNT_CODE:
		action := ACTION_SELECT_ACCOUNT
	end

end;

function ListLength(list: AccountListPtr): integer;
var
	count: integer;
begin
	count := 0;
	while list <> nil do
	begin
		count := count + 1;
		list := (list^).next;
	end;
	ListLength := count
end;

function GetAccountByNumber(list: AccountListPtr; num: integer): AccountType;
begin
	while (list <> nil) and (num <> 1) do
	begin
		list := (list^).next;
		num := num - 1;
	end;
	GetAccountByNumber := (list^).account
end;

procedure SelectAccount(list: AccountListPtr; var account: AccountType);
const
	SEPARATOR_DOT = '. ';
	SEPARATOR_DOUBLEDOT = ': ';
var
	count: integer;
	a: integer;
	listCopy: AccountListPtr;
begin
	count := 1;
	listCopy := list;
	while list <> nil do
	begin
		write(count, SEPARATOR_DOT);
		writeln((list^).account.name);
		count := count + 1;
		list := (list^).next
	end;
	repeat
		write(SelectAccountDescription, SEPARATOR_DOUBLEDOT);
		readln(a);
	until (a < count) and (a > 0);
	account := GetAccountByNumber(listCopy, a);
end;

procedure CheckPassword(account: AccountType; var state: boolean);
const
	EXIT_CHOICE_CODE = 'EXIT';
var
	a, passwordString: string;
begin
	str(account.password, passwordString);
	repeat
		write(TypeYourPasswordMsg);
		readln(a);
	until (a = EXIT_CHOICE_CODE) or (a = passwordString);
	if a = passwordString then
		state := true
	else
		state := false
end;

procedure GetPlayer(fileName: string; var account: AccountType);
var
	list: AccountListPtr = nil;
	f: AccountFile;
	action: ActionEnum;
	state: boolean;
begin
	{$I-}
	assign(f, fileName);
	reset(f);
	if IOResult <> 0 then
	begin
		{close(f);}
		writeln(NoFileDetectedMsg);
		CreateNewFileOrExit(action);
		if action = ACTION_EXIT_PROGRAM then
			halt(0);
		rewrite(f);
		close(f);
		CreateNewAccount(account, ZeroFilePos);
	end
	else
	begin
		GetAccounts(f, list);
		CreateNewAccountOrSelectOne(action);
		if action = ACTION_SELECT_ACCOUNT then
		begin
			SelectAccount(list, account);
			CheckPassword(account, state);
			if state = false then
				halt(0);	
		end
		else
			CreateNewAccount(account, ListLength(list));
		close(f);
	end;
end;

procedure WriteScore(fileName: string; var account: AccountType;
						data: PlayerData);
var
	f: AccountFile;
begin
	if data.countOfCollectedStars > account.MaxCountOfCollectedStars then
		account.MaxCountOfCollectedStars :=
					data.countOfCollectedStars;
	if data.framesAlive > account.MaxFramesAlive then
	begin
		account.MaxFramesAlive := data.framesAlive;
		account.MaxTimeAlive := data.framesAlive /
				(OneSecondInMillis / FrameDelay);
	end;
	assign(f, fileName);
	reset(f);
	seek(f, account.filePos);
	write(f, account);
	close(f);
end;

function GetMaxCountOfCollectedStars(account: AccountType): longint;
begin
	GetMaxCountOfCollectedStars := account.MaxCountOfCollectedStars;
end;

function GetMaxTimeAlive(account: AccountType): real;
begin
	GetMaxTimeAlive := account.MaxTimeAlive;
end;

end.
