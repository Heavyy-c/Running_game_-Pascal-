{ Written by Heavyy-c }
{ GNU GPLv3.0 }

unit CrtKeyboardModule;

interface
uses crt;

procedure GetKey(var key: integer);

const
	Key_LeftArrow = -75;
	Key_RightArrow = -77;
	Key_UpArrow = -72;
	Key_DownArrow = -80;
	Key_Enter = 13;
	Key_Escape = 27;
	Key_Space = 32;
	Key_Slash = 47;
	Key_BackSlash = 92;
	Key_Tab = 9;
	Key_Home = -71;
	Key_VerticalLine = 124;
	Key_0_Number = 48;
	Key_1_Number = 49;
	Key_2_Number = 50;
	Key_3_Number = 51;
	Key_4_Number = 52;
	Key_5_Number = 53;
	Key_6_Number = 54;	
	Key_7_Number = 55;	
	Key_8_Number = 56;
	Key_9_Number = 57;
	Key_W_LowerCase = 119;
	Key_W_UpperCase = 87;
	Key_A_LowerCase = 97;
	Key_A_UpperCase = 65;
	Key_D_LowerCase = 100;
	Key_D_UpperCase = 68;
	Key_S_LowerCase = 115;
	Key_S_UpperCase = 83;	
implementation

procedure GetKey(var key: integer);
begin
	key := ord(ReadKey);
	if key = 0 then
		key := -ord(ReadKey)
end;

end.
