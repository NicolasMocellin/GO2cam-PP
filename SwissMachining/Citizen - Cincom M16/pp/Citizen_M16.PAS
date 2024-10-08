{****************************************************************************
Customer .......... : 
CNC ............... : 
MachineTool ....... : 
Standard PP ....... : S69_CITIZEN.SPS
Comment ........... : 
Date .............. : 
Ppman ............. : 
-----------------------------------------------------------------------------
Modified .......... : 
****************************************************************************}


FUNCTION GetGaugeMTE_SPE(VAR real_GaugeX, real_GaugeY, real_GaugeZ : REAL) : BOOLEAN; FORWARD;

{----------------------------------------------------------------------------}
PROCEDURE InitPPVariables;
{----------------------------------------------------------------------------}
VAR
	str_Null : TC255;
	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'InitPPVariables -> Citizen_M16.PAS');
	DebugBegin(str_ProcName,CONST_NO);
	str_Null[0] := chr(0);


	{CONTROLLER PAGE}
	INTWR(STD_LIST_PERCENT_OUTPUT,1); {output percent at start and end of program, 0 : no, 1 : yes}
	INTWR(STD_LIST_PROG_NUMBER_FORMAT,0);{character for program number, 0 : 'O', 1 : ':'}
	INTWR(STD_LIST_PARTNAME_COMMENT,1); {Add the partname as comment, 0 : no, 1 : yes}

	INTWR(STD_LIST_SPINDLE_LIMITATION,1); {code to limit spindle 0 : G92, 1 : G50}
	INTWR(STD_LIST_FEED_CODE,0); {code for feed choice 0 : G98/G99, 1 : G94/G95}

	INTWR(STD_LIST_PARAM_5101,1); {0 : don't use, 1 : G83 is chipbreaking, 2 : G83 is deburring}
	INTWR(STD_LIST_THREADING_CYCLE,0); {code for threading cycle 0 : use multithreading, 1 : G92, 2 : G78, 3 : G21. If 0 Multi thread is used}
	INTWR(STD_LIST_MULTI_THREADING_CYCLE,0); {type of threading cycle 0 : G76 on 2 blocks, 1 : G76 on 1 block, 2 : G78 on 1 block}
	INTWR(STD_LIST_DECOMPOSED_THREADING_CYCLE,0); {code to choose code for decomposed threading cycle 0 : G33, 1 : G32}


	{TURNING PAGE}
	INTWR(LIB_LIST_OUTPUT_STOCK,0);                                         {output the stock for cnc simulation 0 : no, 1 : yes}
	INTWR(LIB_LIST_OUTPUT_TOOL_PLANE_EACH_OP,0);    {output tool and plane for each operation, 0 : no, 1 : yes}
	INTWR(LIB_LIST_FEED_PARAMETER,0); {0 don't use parameters for feed, 1 : use parameters for feed}
	INTWR(LIB_LIST_CCS_POSITION,0); {position of CSS output 0 : the CSS is output at the start of cycle, 1 : the css is output at start of machining with a spindle on in tr/min at start of operation}


	INTWR(LIB_LIST_TOOL_LIST,0);                                            {output tool list, 0 : no, 1 : yes}

	INTWR(LIB_LIST_ORIGIN_LIST,0);                                  {output origin list, 0 : no, 1 : yes}

	INTWR(LIB_LIST_COOLANT_POSITION,0);                             {position to output coolant, 0 : with spindle, 1 : with plane move, 2 with plunge move}

	{CODE MANAGEMENT PAGE}

	STRINGWR(LIB_STR_ENABLE_C_AXIS_MS,'M18');
	STRINGWR(LIB_STR_ENABLE_C_AXIS_RS,'M48');
	STRINGWR(LIB_STR_DISABLE_C_AXIS_MS,'M20');
	STRINGWR(LIB_STR_DISABLE_C_AXIS_RS,'M20');

	INTWR(LIB_INT_USE_AXIAL_INTERPO_MODE,1); {use interpo code for frontal cycle. 0 : no, 1 : yes}
	STRINGWR(LIB_STR_ENABLE_AXIAL_INTERPO_MS,str_Null);
	STRINGWR(LIB_STR_ENABLE_AXIAL_INTERPO_RS,str_Null);
	STRINGWR(LIB_STR_DISABLE_AXIAL_INTERPO_MS,str_Null);
	STRINGWR(LIB_STR_DISABLE_AXIAL_INTERPO_RS,str_Null);

	STRINGWR(LIB_STR_CLAMP_MS,str_Null);
	STRINGWR(LIB_STR_CLAMP_RS,str_Null);
	STRINGWR(LIB_STR_UNCLAMP_MS,str_Null);
	STRINGWR(LIB_STR_UNCLAMP_RS,str_Null);

	INTWR(LIB_INT_USE_RADIAL_INTERPO_MODE,1); {use interpo code for radial cycle . 0 : no, 1 : yes}
	STRINGWR(LIB_STR_ENABLE_RADIAL_INTERPO_MS,str_Null);
	STRINGWR(LIB_STR_ENABLE_RADIAL_INTERPO_RS,str_Null);
	STRINGWR(LIB_STR_DISABLE_RADIAL_INTERPO_MS,str_Null);
	STRINGWR(LIB_STR_DISABLE_RADIAL_INTERPO_RS,str_Null);

	INTWR(LIB_LIST_C_AXIS_MANAGEMENT,2); {management of C axis, 0 : Modulo mode, 1 : Continuous mode, 2 : Incremental mode}


	{FILE MANAGEMENT PAGE}

	INTWR(LIB_INT_FILE_PER_CHANNEL,0);      {Create one file per channel, 0 : No, 1 : Yes}
	INTWR(LIB_INT_EMPTY_CHANNEL,1);         {create the channel is it is empty, 0 : No, 1 : Yes}

	INTWR(LIB_INT_LISTING_FILE,1); {output the listing file, 1 to do, 0 don't}
	INTWR(LIB_INT_LISTING_MIN,0); {minimum value for synchro number}
	INTWR(LIB_INT_LISTING_MAX,0); {maximum value for synchro number}

	{WARNING AND DEBUG MANAGEMENT}
	INTWR(TOOL_LIST_WARNING_MANAGEMENT,1); {Kind of display for warning pp. 0 : inactive, 1 : debug, 2 : message box, 3 : message box + exit}
	INTWR(TOOL_LIST_DEBUG_MANAGEMENT,1); {kind of debug procedure display. 0 : normal, 1 : Advanced, 2 : Filter PP67_TOOLS}

	DebugEnd;
END;{@}

{----------------------------------------------------------------------------}
PROCEDURE OutputStartProgramNumber;
{----------------------------------------------------------------------------}
{
Output the start number for the main programm
}
VAR
	str_PartName : TC255;
	int_ProgNb :INTEGER;
	str_ProcName : TC255;
	int_Channel	:INTEGER;
BEGIN
	strcpy(str_ProcName,'OutputStartProgramNumber -> Citizen_M16.PAS');
	DebugBegin(str_ProcName,CONST_NO);
	{read values & infos}

	PCALL(READ_PART_channel_no, int_Channel);
	
	IF 1=int_Channel THEN
	BEGIN
		PCALL(READ_PART_part_name,str_PartName);

		InitProgNumber(int_ProgNB);
		WriteProgramNumber(int_ProgNb);

		IF ((INTRD(STD_LIST_PARTNAME_COMMENT) = CONST_YES) AND (strlen(str_PartName) > 0)) THEN
		BEGIN
			PCALL(OUTPUT_NC_tab_str,'CO',str_PartName,CONST_YES);
		END;
		Punchb(2);
	END;

	DebugEnd;
END;{@}

{----------------------------------------------------------------------------}
PROCEDURE StartProgram;
{----------------------------------------------------------------------------}
{
Output at the start of program
}
VAR
	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'StartProgram -> Citizen_M16.PAS');
	DebugBegin(str_ProcName,CONST_NO);
	
	PCALL(WRITE_NC_init_g,700);
	
	OutputStartProgramNumber;
	OutputStartComment;
	

	OutputStartChannel;
	OutputListTool;
	OutputListOrigin;

	OutputStock;
	OutputStartFixedBlock;

	DebugEnd;
END;{@}

{----------------------------------------------------------------------------}
PROCEDURE CheckOpSetting;
{----------------------------------------------------------------------------}
VAR
	int_No_Y : INTEGER;
	str_Message : TC255;
	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'CheckOpSetting -> Citizen_M16.PAS');
	DebugBegin(str_ProcName,CONST_NO);
	
	If IsMillingOperation and IsReworkSpindle THEN
	BEGIN
		PCALL(READ_PART_boolean_tec,BOOLEAN_CYC_POLAR_CYCLE,int_No_Y);
		IF int_No_Y = CONSt_NO THEN
		BEGIN
			strcpy(str_Message, 'You can not program Y axis for axial milling on Sub Spindle');
			MessageWarning(0,str_Message);
		END;
	END;
	
	DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE StartOperation;
{----------------------------------------------------------------------------}
{
For each start operation we outupt the following functions
}
VAR
	int_OutputCoolantPosition :INTEGER;
	int_MainPattern, int_BActive, int_GroupNo, int_ToolNumber : INTEGER;
	str_ProcName : TC255;
	int_Turret, int_Channel:INTEGER;
	Bcompo, Bclamp, Bmove	:INTEGER;
	tr3_Pos				:TR3;
	real_X,real_Y,real_Z : REAL;
	str_Debug:TC255;
	real_Partlength, real_FaceAllowance, real_PartingWidth, real_StockDiameter	:REAL;
	int_CycleNo	:INTEGER;
BEGIN
	strcpy(str_ProcName,'StartOperation -> Citizen_M16.PAS');
	DebugBegin(str_ProcName,CONST_NO);

	CheckOpSetting;

{2024-06-05 XP If the tool index change and not the tool number we add a Z-10 befaor begin the operation}
	IF (ICALL(TEST_change_tool_pocket_turret) = CONST_YES) AND not IsOutputToolChange THEN
	BEGIN
		{ PCALL(OUTPUT_NC_tab_str,'SP_START','Z-10',CONST_YES); }
		PCALL(OUTPUT_NC_paxis1,10,CONST_YES);
		OutputNCRadiusOffsetNumber(0);
		writeb;
	END;


	PCALL(WRITE_DPP_integer,GPP_INTEGER_CW_LIVE_TOOL,80);
	PCALL(WRITE_DPP_integer,GPP_INTEGER_STOP_LIVE_TOOL,82);

	If GetCurrentGroupNo = 6 THEN
	BEGIN
		PCALL(WRITE_DPP_integer,GPP_INTEGER_CW_LIVE_TOOL,72);
		PCALL(WRITE_DPP_integer,GPP_INTEGER_STOP_LIVE_TOOL,73);
		
	END;

	IF IsOutputPlane OR IsOutputToolChange THEN
	BEGIN
		int_MainPattern := 700;
		PCALL(READ_NC_g,int_MainPattern,int_BActive);
		int_GroupNo := GetCurrentGroupNo;
		OutputPattern(int_MainPattern,int_GroupNo);
	END;

	int_OutputCoolantPosition := 0;
	OutputSynchroToolpath(2);
	OutputOperationComment;
	
	PCALL(READ_PART_synchro_axes, Bcompo, Bclamp, Bmove, tr3_Pos);
	strcpy(str_Debug, '(Bcompo ');
	CASE BCompo OF
		CONST_NO:		strcat(str_Debug, 'none)');
		CONST_SPINDLE:	strcat(str_Debug, 'spindle)');
		CONST_TURRET:	strcat(str_Debug, 'turret)');
	END;
	PCALL(OUTPUT_NC_punch_str, str_Debug);

	strcpy(str_Debug, '(Bclamp ');
	ConcatVal(str_Debug, Bclamp, 0);
	strcat(str_Debug, ')');
	PCALL(OUTPUT_NC_punch_str, str_Debug);
	strcpy(str_Debug, '(Bmove ');
	CASE Bmove OF
		CONST_NO:				strcat(str_Debug, 'none)');
		CONST_COORDINATES:		strcat(str_Debug, 'move coords)');
		CONST_MOVE_COMPONENT:	strcat(str_Debug, 'move comp)');
	END;
	PCALL(OUTPUT_NC_punch_str, str_Debug);
	
	IF Bmove = CONST_COORDINATES THEN
	BEGIN
		strcpy(str_Debug, '(pos X');
		ConcatVal(str_Debug, tr3_Pos[0], 3);
		strcat(str_Debug, ' Y');
		ConcatVal(str_Debug, tr3_Pos[1], 3);
		strcat(str_Debug, ' Z');
		ConcatVal(str_Debug, tr3_Pos[2], 3);
		strcat(str_Debug, ')');
		PCALL(OUTPUT_NC_punch_str, str_Debug);
		
		PCALL(WRITE_NC_init_plane, 11);
		
		PCALL(OUTPUT_NC_g, 0, CONST_YES);
		PCALL(OUTPUT_NC_paxis1, tr3_Pos[2], CONST_YES);
		writeb;
	END;
	
	{ IF (Bcompo<>CONST_NO) AND (Bmove<>CONST_NO) THEN }
	{ BEGIN }
		{ PCALL(OUTPUT_NC_punch_validate, CONST_NO); }
	{ END; }
	
	OutputToolComment;
	OutputFeedParam;
	OutputToolChange;
	
	PCALL(READ_PART_tool_no,int_ToolNumber);
	{2024-05-06 for tool 44 we always put on high pressure coolant}
	IF (int_ToolNumber = 44) and IsOutputToolChange THEN
	BEGIN
		PCALL(Output_NC_m,214,CONST_YES);
		writeb;
	END;
	
	{ IF IsOutputToolChange THEN }
	{ BEGIN }
		{ IF GetCurrentGroupNo = 4 THEN }
		{ BEGIN }
			{ PCALL(OUTPUT_NC_g,50,CONSt_YES); }
			{ PCALL(OUTPUT_NC_tab_str,'SP','Z#101',CONST_YES); }
			{ writeb; }
		{ END; }
	{ END; }
	
	IF IsCycle(CONST_CYCLE_BROACHING) THEN
	BEGIN
		IF GetGaugeMTE_SPE(real_X,real_Y,real_Z) THEN
		BEGIN
			{ writeln('           gauges ',real_X, real_Y,real_Z); }
			{ PCALL(WRITE_NC_coord_translate,-real_X,0,0); }
			PCALL(OUTPUT_NC_g,50,CONST_YES);
			PCALL(OUTPUT_NC_tab,'U',-(2 * real_X),CONST_YES);
			writeb;
		END;
	END;
	
	
	OutputSynchroToolpath(1);
	
	IF IsMillingOperation THEN
	BEGIN
		PCALL(READ_PART_turret_no, int_Turret);
		CASE int_Turret OF
			1: PCALL(WRITE_DPP_key_str, 'S', 'S3=');
			2: PCALL(WRITE_DPP_key_str, 'S', 'S4=');
		END;
	END
	ELSE
	IF IsReworkSpindle THEN
		PCALL(WRITE_DPP_key_str, 'S', 'S2=')
	ELSE
		PCALL(WRITE_DPP_key_str, 'S', 'S1=');
	
	
	OutputCoolant(int_OutputCoolantPosition);
	
	{V6.09}
	IF (INTRD(LIB_LIST_CCS_POSITION) = 0) OR IsMillingOperation THEN
	BEGIN
		OutputSpindleOn;
	END
	ELSE
	BEGIN
		OutputSpindleRPM;
	END;
	OutputSpindleLivetoolOn;
	{V6.09}
	OutputPlaneChange;


	PCALL(READ_PART_cycle_no, int_CycleNo);
	{ writeln('cycle ', int_CycleNo); }
	IF int_CycleNo=CONST_PARTING THEN
	BEGIN
		PCALL(READ_PART_part_length, real_Partlength);
		PCALL(READ_PART_real_tec, REAL_TURN_Z_ALLOWANCE, real_FaceAllowance);
		PCALL(READ_PART_real_tec, REAL_TOOL_WIDTH, real_PartingWidth);
		PCALL(READ_PART_stock_dia, real_StockDiameter);

		strcpy(str_Debug, 'Teilelaenge ........ ');
		ConcatVal(str_Debug, real_Partlength, 3);
		{ writeln(str_Debug); }
		
		strcpy(str_Debug, 'Planaufmass ........ ');
		ConcatVal(str_Debug, real_FaceAllowance, 3);
		{ writeln(str_Debug); }

		strcpy(str_Debug, 'Abstecher Breite  .. ');
		ConcatVal(str_Debug, real_PartingWidth, 3);
		{ writeln(str_Debug); }
		
		strcpy(str_Debug, '$REAL_PARTING_Z');
		DatSetValueFormat(str_Debug, (real_Partlength+real_FaceAllowance+real_PartingWidth), SPI_FORMAT_REAL_DISTANCE);

		strcpy(str_Debug, '$REAL_PARTING_X_AT_START');
		DatSetValueFormat(str_Debug, (real_StockDiameter+1.0), SPI_FORMAT_REAL_DISTANCE);

	END;

	DebugEnd;
END;{@}


{----------------------------------------------------------------------------}
PROCEDURE OutputSpindleOn;
{----------------------------------------------------------------------------}
{
Output the spindle on
}
VAR
	int_IsPlaneChange,int_BRotDir,int_BUnit,int_Range,int_CurBUnit,int_CurRange     :INTEGER;
	real_Speed,real_CurSpeed, real_Feed :REAL;
	int_BUnitFeed,int_CurRotation : INTEGER;
	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'OutputSpindleOn -> Citizen_M16.PAS');
	DebugBegin(str_ProcName,CONST_NO);

	PCALL(READ_PART_rotation,int_BRotDir);
	PCALL(READ_PART_spindle,real_Speed,int_BUnit,int_Range);
	PCALL(READ_PATH_feed,real_Feed,int_BUnitFeed);


	PCALL(READ_NC_spindle,real_CurSpeed,int_CurBUnit,int_CurRange);
	PCALL(READ_NC_rotation, int_CurRotation);

	IF (int_CurRotation <> int_BRotDir) AND (int_CurRotation <> CONST_BREAK) THEN
	BEGIN
		OutputNCRotation(CONST_BREAK);
		writeb;
		PCALL(WRITE_NC_init_spindle);
		PCALL(READ_NC_spindle,real_CurSpeed,int_CurBUnit,int_CurRange);
	END;
	
	IF (ICALL(TEST_change_tool_pocket_turret) = CONST_YES) THEN
	BEGIN
		PCALL(WRITE_NC_init_spindle);
		PCALL(WRITE_NC_m_force,3);
		PCALL(READ_NC_spindle,real_CurSpeed,int_CurBUnit,int_CurRange);
	END;

	IF int_BUnit = CONST_SMM THEN
	BEGIN
		OutputLimitSpindle;
	END;
	IF (IsOutputToolChange) OR (int_BUnit <> int_CurBUnit) OR (real_CurSpeed <> real_Speed) THEN
	BEGIN
		IF IsOutputToolChange THEN
		BEGIN
			PCALL(WRITE_NC_m_force,3);
			PCALL(WRITE_NC_init_spindle);
		END;
		IF (GetCurrentGroupNo <> 6) or Not IsMillingOperation THEN
			OutputNCSpindle(real_Speed,int_BUnit,int_Range);
		{ PCALL(OUTPUT_NC_spindle,real_Speed,int_BUnit,int_Range); }
		OutputNCRotation(int_BRotDir);
		{ PCALL(OUTPUT_NC_rotation,int_BRotDir); }
		IF int_BUnitFeed = CONST_MMPR THEN
		BEGIN
			PCALL(OUTPUT_NC_g,99,CONST_NO);
		END
		ELSE
		BEGIN
			PCALL(OUTPUT_NC_g,98,CONST_NO);
		END;
		PCALL(WRITE_NC_feed,0,int_BUnitFeed);
		writeb;
	END;


	DebugEnd;
END;{@}

{----------------------------------------------------------------------------}
PROCEDURE InitPlaneKey;
{----------------------------------------------------------------------------}
{
Initialize the key of plane in function of spindle and tool selected
Must be called after activeplane
}
VAR
	int_ChannelNo : INTEGER;
	str_ProcName : TC255;
	int_Turret	:INTEGER;
BEGIN
	strcpy(str_ProcName,'InitPlaneKey -> Citizen_M16.PAS');
	DebugBegin(str_ProcName,CONST_NO);


	{ default init for keys used by dpp planes }
	PCALL(WRITE_DPP_KEY_UNIT,'C',1.0);
	PCALL(WRITE_DPP_KEY_UNIT,'C_CART',1.0);
	PCALL(WRITE_DPP_KEY_UNIT,'R',1.0);
	PCALL(WRITE_DPP_KEY_UNIT,'X',2.0); {X is in diameter by default in turning}
	PCALL(WRITE_DPP_KEY_UNIT,'Y',2.0); {Y is in diameter by default in turning}
	PCALL(WRITE_DPP_KEY_UNIT,'Z',1.0);
	PCALL(WRITE_DPP_KEY_UNIT,'I',1.0); 
	PCALL(WRITE_DPP_KEY_UNIT,'J',1.0);
	PCALL(WRITE_DPP_KEY_UNIT,'K',1.0);
	
	
	PCALL(WRITE_DPP_integer,GPP_INTEGER_CW_LIVE_TOOL,80);
	PCALL(WRITE_DPP_integer,GPP_INTEGER_STOP_LIVE_TOOL,82);

	PCALL(READ_PART_channel_no,int_ChannelNo);
	CASE int_ChannelNo OF
		1 : BEGIN
			PCALL(WRITE_DPP_KEY_UNIT,'Z',-1.0);
		END;
		2,3 : BEGIN
			PCALL(WRITE_DPP_KEY_UNIT,'Z',-1.0);
		END;
	END;
	
	IF IsMillingOperation THEN
	BEGIN
		CASE GetCurrentGroupNo OF
			2 : BEGIN
				PCALL(WRITE_DPP_key_str,'S','S3=');
				PCALL(WRITE_DPP_key_str,'SMM','S3=');
			END;
			3 : BEGIN
				PCALL(WRITE_DPP_key_str,'S','S4=');
				PCALL(WRITE_DPP_key_str,'SMM','S4=');
			END;

		END;
		If IsAxialInterpoPlane THEN
		BEGIN
			PCALL(WRITE_DPP_KEY_UNIT,'X',1.0);
		END;
	
	END
	ELSE
	BEGIN
		IF IsReworkSpindle THEN
		BEGIN
			PCALL(WRITE_DPP_key_str,'S','S2=');
			PCALL(WRITE_DPP_key_str,'SMM','S2=');
			PCALL(WRITE_DPP_boolean,GPP_BOOLEAN_PLANE_OFFSET_DIRECTION,CONST_DIRECT);
			
		END
		ELSE
		BEGIN
			PCALL(WRITE_DPP_key_str,'S','S1=');
			PCALL(WRITE_DPP_key_str,'SMM','S1=');
			PCALL(WRITE_DPP_boolean,GPP_BOOLEAN_PLANE_OFFSET_DIRECTION,CONST_INVERTED);
		END;
	END;
	
	
	DebugEnd;
END;{@}

{----------------------------------------------------------------------------}
PROCEDURE EndOperation;
{----------------------------------------------------------------------------}
{
For each end of operation we output the following functions
}
VAR
	int_ToolNumber : INTEGER;
	real_X,real_Y,real_Z : REAL;
	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'EndOperation -> Citizen_M16.PAS');
	DebugBegin(str_ProcName,CONST_NO);

	If GetCurrentGroupNo = 6 THEN
	BEGIN
		PCALL(WRITE_DPP_integer,GPP_INTEGER_CW_LIVE_TOOL,72);
		PCALL(WRITE_DPP_integer,GPP_INTEGER_STOP_LIVE_TOOL,73);
	END;

	OutputPlaneCancel;
	PCALL(READ_PART_tool_no,int_ToolNumber);
	{2024-05-06 for tool 44 we always put off high pressure coolant}
	IF (int_ToolNumber = 44) and IsOutputToolChange THEN
	BEGIN
		PCALL(Output_NC_m,215,CONST_YES);
		writeb;
	END;
	OutputStopCoolant;
	{V6.09}
	OutputSpindleLivetoolOff;
	{V6.09}
	
	
	IF IsOutputToolChange THEN
	BEGIN
		OutputNCRapid;
		CASE GetCurrentGroupNo OF
			1,2 : BEGIN
				PCALL(OUTPUT_NC_tab,'X',35,CONST_YES)
			END;
			3,4 : BEGIN
				PCALL(OUTPUT_NC_tab,'X',80,CONST_YES)
			END;
			6 : BEGIN
				PCALL(OUTPUT_NC_tab,'Z',10,CONST_YES);
			END;
			OTHERWISE
			BEGIN

			END;
		END;
	END;
	
	
	OutputCancelToolOffset;
	
	
	
	IF IsCycle(CONST_CYCLE_BROACHING) THEN
	BEGIN
		IF GetGaugeMTE_SPE(real_X,real_Y,real_Z) THEN
		BEGIN
			{ writeln('           gauges ',real_X, real_Y,real_Z); }
			{ PCALL(WRITE_NC_coord_translate,-real_X,0,0); }
			PCALL(OUTPUT_NC_g,50,CONST_YES);
			PCALL(OUTPUT_NC_tab,'U',(2 * real_X),CONST_YES);
			writeb;
		END;
	END;
	
	{ IF IsOutputToolChange THEN }
	{ BEGIN }
		{ If GetCurrentGroupNo= 4 THEN }
		{ BEGIN }
			{ PCALL(OUTPUT_NC_g,50,CONST_YEs); }
			{ PCALL(OUTPUT_NC_tab_str,'SP','Z0',CONST_YES); }
			{ writeb; }
		{ END; }
	{ END; }
	
	If IsChangeKindCycle OR (ICALL(TEST_latest_cycle,CONST_YES,CONST_YES,CONST_NO,CONSt_NO) = CONST_YES) THEN
	BEGIN
		If IsMillingOperation THEN
		BEGIN
			PCALL(OUTPUT_NC_g,18,CONST_NO);
			writeb;
		END;
		OutputNCRotation(CONST_BREAK);
		writeb;
	END;
	
	
	PCALL(OUTPUT_NC_punch_validate, CONST_YES);

	DebugEnd;
END;{@}

{----------------------------------------------------------------------------}
PROCEDURE TTPattern{(int_IdSync : INTEGER)};
{----------------------------------------------------------------------------}
VAR
	int_ChannelNo, int_Out, int_ChangePattern : INTEGER;
	str_Label, str_Main, str_Sub, str_Axis : TC255;
	str_ProcName :	TC255;
	str_Debug:		TC255;
	int_i, int_len	:INTEGER;
BEGIN
	strcpy(str_ProcName,'TTPattern -> Citizen_M16.PAS');
	DebugBegin(str_ProcName,CONST_NO);

	int_Out := CONST_NO;
	int_ChangePattern := CONST_NO;

	{If int_IdSync is different of 0 there is a pattern changement with synchro}
	IF int_IdSync <> 0 THEN
	BEGIN
		PCALL(READ_PART_synchro_pattern,int_IdSync,str_Label, str_Main, str_Sub);

		PCALL(READ_PART_channel_no,int_ChannelNo);
		PCALL(READ_PART_synchro_pattern_channel,int_IdSync,int_ChannelNo,int_Out,str_Axis);
		
		IF (ICALL(TEST_new_main_pattern,int_IdSync) = CONST_YES) THEN
		BEGIN
			{ writeln('new pattern ', str_Main, '/', str_Sub, ', channel ', int_ChannelNo, ', axis ', str_Axis); }

			PCALL(OUTPUT_NC_tab_str, 'MainPatt', str_Main, CONST_NO);

			{ Add retract moves }
			IF strcmp(str_Main, 'G710')=0 THEN
			BEGIN
				CASE int_ChannelNo OF
					{ 1:	PCALL(OUTPUT_NC_tab_str, 'SP', 'U1', CONST_YES); }
					2:	PCALL(OUTPUT_NC_tab_str, 'SP', 'U1 V1', CONST_YES);
					3:	PCALL(OUTPUT_NC_tab_str, 'SP', 'U1 W1', CONST_YES);
				END;
			END
			ELSE IF strcmp(str_Main, 'G720')=0 THEN
			BEGIN
				CASE int_ChannelNo OF
					{ 1:	PCALL(OUTPUT_NC_tab_str, 'SP', 'U1', CONST_YES); }
					2:	PCALL(OUTPUT_NC_tab_str, 'SP', 'U1 W1', CONST_YES);
					3:	PCALL(OUTPUT_NC_tab_str, 'SP', 'U1 W1', CONST_YES);
				END;
			END
			ELSE IF strcmp(str_Main, 'G730')=0 THEN
			BEGIN
				CASE int_ChannelNo OF
					{ 1:	PCALL(OUTPUT_NC_tab_str, 'SP', 'U1', CONST_YES); }
					2:	PCALL(OUTPUT_NC_tab_str, 'SP', 'U1 W1', CONST_YES);
					3:	PCALL(OUTPUT_NC_tab_str, 'SP', 'U1 W1', CONST_YES);
				END;
			END;
			writeb;
		END;
	END;
	
	{if int_IdSync is 0 then the pattern is changing without synchronization}
	IF int_IdSync = 0 THEN
		PCALL(READ_PART_new_pattern,int_ChangePattern,str_Label,str_Sub,str_Axis);
	
	{if int_Out is YES or int_ChangePattern is YES}
	{we have to output sub pattern}
	If (int_Out = CONST_YES) OR (int_ChangePattern = CONST_YES) THEN
	BEGIN
		PCALL(OUTPUT_NC_tab_str, 'SubPatt', str_Sub,CONST_NO);
		IF strcmp(str_Sub,'G732') = 0 THEN
		BEGIN
			CASE int_ChannelNo OF
				{ 1:	PCALL(OUTPUT_NC_tab_str, 'SP', 'U1', CONST_YES); }
				2:	BEGIN
					PCALL(OUTPUT_NC_tab_str, 'SP', 'U1 W1', CONST_YES);
					writeb;
					PCALL(OUTPUT_NC_g,50,CONSt_YES);
					PCALL(OUTPUT_NC_tab_str,'SP','Z#101',CONST_YES);
				END;
				3:	PCALL(OUTPUT_NC_tab_str, 'SP', 'U1 W1 I30.0', CONST_YES);
			END;
		END;
		IF strcmp(str_Sub,'G733') = 0 THEN
		BEGIN
			CASE int_ChannelNo OF
				{ 1:	PCALL(OUTPUT_NC_tab_str, 'SP', 'U1', CONST_YES); }
				2:	PCALL(OUTPUT_NC_tab_str, 'SP', 'U1 W1', CONST_YES);
				3:	PCALL(OUTPUT_NC_tab_str, 'SP', 'U1 W1', CONST_YES);
			END;
		END;
		
		
		writeb;
	END;
	
	{	Replace axis comment like (X3,Z3,C2,BACK 3 SPINDLE POST (3)) with (X3,Z3,C2,BACK 3 SPINDLE POST .3.)
		because ((3)) can cause errors }
	IF NOT IsNullString(str_Axis) THEN
	BEGIN
		int_len := strlen(str_Axis);
		str_Debug[0] := chr(0);
		FOR int_i := 0 TO (int_Len-1) DO
		BEGIN
			CASE str_Axis[int_i] OF
				'(':	strcat(str_Debug, '.');
				')':	strcat(str_Debug, '.');
			OTHERWISE	strcat(str_Debug, (str_Axis[int_i]));
			END;
		END;
		PCALL(OUTPUT_NC_tab_str, 'CO', str_Debug,CONST_YES);
		writeb;
	END;

	DebugEnd;
END;{@}


{----------------------------------------------------------------------------}
PROCEDURE OutputReworkPartXXX;
{----------------------------------------------------------------------------}
VAR
	str_Debug	:TC255;
	str_ProcName : TC255;
	str_Var			:TC255;
	real_Speed		:REAL;
	int_BUnit, int_lgamme	:INTEGER;
	tr3_Gauge	:TR3;
	real_RzmorsMain, real_RzminMain, real_RzmaxMain, real_RzoriMain	:REAL;
	real_RzmorsSub, real_RzminSub, real_RzmaxSub, real_RzoriSub	:REAL;
	real_PartLength		:REAL;
	debug:BOOLEAN;
BEGIN
	strcpy(str_ProcName,'OutputReworkPart');
	DebugBegin(str_ProcName,CONST_NO);
	
	debug := false;

	PCALL(READ_PART_chuck_part_position, 1, real_RzmorsMain, real_RzminMain, real_RzmaxMain, real_RzoriMain);
	PCALL(READ_PART_chuck_part_position, 2, real_RzmorsSub, real_RzminSub, real_RzmaxSub, real_RzoriSub);
	PCALL(READ_PART_part_length, real_PartLength);

	IF debug THEN
	BEGIN
		strcpy(str_Debug, 'real_PartLength ... '); ConcatVal(str_Debug, real_PartLength, 3);
		writeln(str_Debug);

		strcpy(str_Debug, 'real_RzmorsMain ... '); ConcatVal(str_Debug, real_RzmorsMain, 3);
		writeln(str_Debug);
		strcpy(str_Debug, 'real_RzminMain .... '); ConcatVal(str_Debug, real_RzminMain, 3);
		writeln(str_Debug);
		strcpy(str_Debug, 'real_RzmaxMain .... '); ConcatVal(str_Debug, real_RzmaxMain, 3);
		writeln(str_Debug);
		strcpy(str_Debug, 'real_RzoriMain .... '); ConcatVal(str_Debug, real_RzoriMain, 3);
		writeln(str_Debug);

		strcpy(str_Debug, 'real_RzmorsSub .... '); ConcatVal(str_Debug, real_RzmorsSub, 3);
		writeln(str_Debug);
		strcpy(str_Debug, 'real_RzminSub ..... '); ConcatVal(str_Debug, real_RzminSub, 3);
		writeln(str_Debug);
		strcpy(str_Debug, 'real_RzmaxSub ..... '); ConcatVal(str_Debug, real_RzmaxSub, 3);
		writeln(str_Debug);
		strcpy(str_Debug, 'real_RzoriSub ..... '); ConcatVal(str_Debug, real_RzoriSub, 3);
		writeln(str_Debug);
	END;

	{ PCALL(READ_PART_tool_offset_vector, tr3_Gauge); }
	
	{ strcpy(str_Debug, 'Tool gauge '); }
	{ ConcatVal(str_Debug, tr3_Gauge[0], 3); }
	{ strcat(str_Debug, ' '); }
	{ ConcatVal(str_Debug, tr3_Gauge[1], 3); }
	{ strcat(str_Debug, ' '); }
	{ ConcatVal(str_Debug, tr3_Gauge[2], 3); }
	{ writeln(str_Debug); }

	PCALL(READ_NC_spindle, real_Speed, int_BUnit, int_lgamme);
	
	strcpy(str_Var, '$REAL_PARTING_D');
	DatSetValueFormat(str_Var, 22, SPI_FORMAT_REAL_DISTANCE);

	strcpy(str_Var, '$REAL_PARTING_Z');
	DatSetValueFormat(str_Var, real_PartLength, SPI_FORMAT_REAL_DISTANCE);

	strcpy(str_Var, '$REAL_PARTING_GRIP_Z');
	DatSetValueFormat(str_Var, (-real_RzminSub), SPI_FORMAT_REAL_DISTANCE);

	strcpy(str_Var, '$PARTING_S');
	DatSetValue(str_Var, real_Speed);

	strcpy(str_Var, '$PARTING_G');
	IF int_BUnit=CONST_RPM THEN
		DatSetValue(str_Var, 97)
	ELSE
		DatSetValue(str_Var, 96);

	DebugEnd;
END;{@}

{----------------------------------------------------------------------------}
PROCEDURE ToolChange{(int_ToolNb,int_ToolLengthOffset,int_IsFirstTool : INTEGER)};
{----------------------------------------------------------------------------}
{
Write in the NC File the tool change
   int_ToolNb : tool number
   int_IsFirstTool : CONST_YES if the tool is the first of the programm
}
VAR
	int_ToolChangeMode, int_NumActiveTool, int_BType :INTEGER;
	real_ToolSelected :REAL;
	str_ProcName : TC255;
	int_ToolGroup	:INTEGER;
BEGIN
	strcpy(str_ProcName,'ToolChange -> Citizen_M16.PAS');
	DebugBegin(str_ProcName,CONST_NO);

	PCALL(READ_NC_key,'T',real_ToolSelected,int_BType);
	{ int_ToolChangeMode := INTRD(LIB_LIST_TOOLCHANGE_MODE); }

	IF INTRD(STD_LIST_BLOCK_NUMBERS) = 2 THEN PCALL(WRITE_NC_block_format,0);

	int_ToolGroup := GetCurrentGroupNo;

	PCALL(WRITE_NC_init_key,'T');
	{2024-06-04 If the tool number is 44 we have to call it with T43}
	IF (int_ToolNb = 44) THEN int_ToolNb := 43;
	PCALL(OUTPUT_NC_tab,'T',(100*int_ToolNb),CONST_NO);

	IF IsOutputToolChange THEN
	BEGIN
		{ IF int_ToolGroup = 1 THEN }
			{ PCALL(OUTPUT_NC_tab_str, 'SP', 'Q3', CONST_YES); }
	END;

	writeb;

	IF INTRD(STD_LIST_BLOCK_NUMBERS) = 2 THEN PCALL(WRITE_NC_block_format,2);

	DebugEnd;
END;{@}

{----------------------------------------------------------------------------}
PROCEDURE MTESimuToolApproach;
{----------------------------------------------------------------------------}
VAR
	str_ProcName : TC255;
	tr3_Pt			:TR3;
	int_CycleNo		:INTEGER;
	str_Debug		:TC255;
BEGIN
	strcpy(str_ProcName,'MTESimuToolApproach -> Citizen_M16.PAS');
	DebugBegin(str_ProcName,CONST_NO);

	PCALL(READ_PART_cycle_no, int_CycleNo);
	
	IF int_CycleNo = CONST_PARTING THEN
	BEGIN
		PCALL(PPMTE_set_reference, 1, CONST_YES, CONST_YES, CONST_NO);
		PCALL(PPMTE_get_next_point, tr3_Pt);
		strcpy(str_Debug, 'Next pos: X');
		ConcatVal(str_Debug, tr3_Pt[0], 3);
		strcat(str_Debug, ' Y');
		ConcatVal(str_Debug, tr3_Pt[1], 3);
		strcat(str_Debug, ' Z');
		ConcatVal(str_Debug, tr3_Pt[2], 3);
		{ PCALL(prgEXE_Display, CONST_YES, str_Debug); }
		
		PCALL(PPMTE_set_posax, 1, tr3_Pt[0]);
		PCALL(PPMTE_set_posax, 2, tr3_Pt[1]);
		PCALL(PPMTE_set_posax, 3, tr3_Pt[2]);
		PCALL(PPMTE_exe_event, MTE_GOTO);
	END;

	DebugEnd;
END;{@}

{----------------------------------------------------------------------------}
PROCEDURE DatVarManage{(VAR str_Input: TC255)};
{ we treat all with '$'... }
{ '$[' start a formula, ended by ']'  }
{ '$[$var1*10+$var2]' }
{----------------------------------------------------------------------------}
{UNIT TEST CREATED}
VAR
   int_Pos,int_Pos2,int_Var,int_Val,int_Err,int_Convert : INTEGER;
	real_Val : REAL;
   str_Var,str_Val,str_Message : TC255;
   str_Base,str_1,str_2,str_3,str_Compute, str_Test : TC255;
	str_c1, str_c2, str_c3, str_c0 : TC255;
	str_ProcName : TC255;
	real_Tmp	:REAL;
BEGIN
	strcpy(str_ProcName,'DatVarManage -> Citizen_M16.PAS');
	DebugBegin(str_ProcName,CONST_NO);
	{ writeln('                               ligne ', str_Input); }
	{ gestion variables }
	strcpy(str_c0,'0');
	strcpy(str_c1,'1');
	strcpy(str_c2,'2');
	strcpy(str_c3,'3');
	
	strcpy(str_Base,str_Input);
	str_Input[0] := chr(0);
	int_Pos := str_pos('$',str_Base,0);
	WHILE (int_Pos >= 0) DO 
	BEGIN
		{ 2022-10-31 XP IF the line begin by $ char we don't have to init str_1 with str_range }
		InitNullString(str_1);
		IF int_Pos > 0 THEN
			str_range(str_1,str_Base,0,int_Pos-1);
		str_range(str_2,str_Base,int_Pos,strlen(str_Base)-1);
		strcpy(str_Base,str_2);
		
		
		DatGetVarName(str_Base, str_Var);
		DatGetStrValue(str_Var,str_Val);
		{ writeln('                get var : ', str_Var, '   ', str_Val); }
		
		IF str_Val[0] = chr(0) THEN
		BEGIN
			strcpy(str_Test,'$TOOL_LIST');
			IF IsSameStr(str_Var,str_Test) THEN
			BEGIN
				ListTool;
				strcpy(str_Val,' ');
			END;
		END;
		
		
		{ gestion directe clefs GO2cam (V607) }
		IF (str_Val[0] = chr(0)) THEN
		BEGIN
			IF (str_pos('$',str_Base,0) = 0) THEN
			BEGIN
				{ writeln('handle dat var ', str_Base); }
				int_Pos2 := 1;
				WHILE (IsCharVarDat(str_Base,int_Pos2)=1) DO int_Pos2 := int_Pos2 + 1;
				{ DatGetVarName(str_Base,str_Var); }
				IF (int_Pos2 > 1) THEN
					str_range(str_Var,str_Base,1,int_Pos2-1);
				{ IF strlen(str_Var) > 1 THEN }
					{ str_range(str_Var,str_Base,1,(strlen(str_Var)-1)); }
				IF (str_Var[0] = 'E') OR (str_Var[0] = 'I') THEN
				BEGIN
					PCALL(SPI_GEN_get_integer_information,(GO2CAMID(str_Var)),int_Val);
					real_Val := int_Val;
					PCALL(UTIL_KEY_VALUE,'DATVAL_I',real_Val,str_Val);
				END
				ELSE IF (str_Var[0] = 'R') THEN
				BEGIN
					PCALL(SPI_GEN_get_real_information,(GO2CAMID(str_Var)),real_Val);
					PCALL(UTIL_tec_conversion,str_Var,int_Convert);
					
					ConcatValFormat(str_Val,real_Val,int_Convert);
					PCALL(UTIL_KEY_VALUE,'DATVAL_R',real_Val,str_Val);
				END
				ELSE IF (str_Var[0] = 'S') THEN
				BEGIN
					PCALL(SPI_GEN_get_information,(GO2CAMID(str_Var)),str_Val);
				END;
				IF (str_Val[0] <> chr(0)) THEN
					str_range(str_Var,str_Base,0,int_Pos2-1)
				ELSE
				BEGIN
					
					strcpy(str_Message,'Variable dat file not initialized $');
					if not IsSameStr(str_Var,str_c0) and not IsSameStr(str_Var,str_c1)
						and not IsSameStr(str_Var,str_c2) and not IsSameStr(str_Var,str_c3) THEN
							MessagePPWarning(-1,str_Message,str_var);
					{ writeln('Variable dat file not initialized $', str_var); }
					str_Var[0] := chr(0);
				END;
			END;
		END;

		IF (str_Var[0] <> chr(0)) AND (str_Val[0] <> chr(0)) THEN
		BEGIN
			strcat(str_1,str_Val);
			str_range(str_2,str_Base,strlen(str_Var),strlen(str_Base)-1);
		END
		ELSE
		BEGIN
			strcat(str_1,'$'); {on laisse $ si pas de var correspondante}
			str_range(str_2,str_Base,1,strlen(str_Base)-1);
			
		END;
		strcat(str_Input,str_1);
		strcpy(str_Base,str_2);
		int_Pos := str_pos('$',str_Base,0);
	END;
	strcat(str_Input,str_Base);

	{ gestion calculs }
	strcpy(str_Base,str_Input);
	str_Input[0] := chr(0);
	int_Pos := str_pos('$[',str_Base,0);
	{2021-01-18 XP Modification to start for looking ']'}
	{we should start from int_Pos instead of 0 because in Fanuc CNC [] are used too for calculation}
	int_Pos2 := str_pos(']',str_Base,(int_Pos+1));
	WHILE ((int_Pos >= 0) AND (int_Pos2 >= int_Pos+3)) DO 
	BEGIN
		str_range(str_1,str_Base,0,int_Pos-1); { debut }
		str_range(str_2,str_Base,int_Pos,int_Pos2); { '$[...]') }
		str_range(str_Compute,str_Base,int_Pos+2,int_Pos2-1); { '...' }
		str_range(str_3,str_Base,int_Pos2+1,strlen(str_Base)-1); { fin }
		{2020-11-13 add a treatment on the string sended to SPI_GEN_calculate_numerical_value}
		IF IsStringOkToCompute(str_Compute) THEN FormatStringToCompute(str_Compute);
		PCALL(SPI_GEN_calculate_numerical_value,str_Compute,real_Val,int_Err);
		IF (int_Err = 0) THEN 
		BEGIN
			PCALL(UTIL_KEY_VALUE,'DATVAL',real_Val,str_Val);
			IF (str_Val[0] <> chr(0)) THEN
				strcat(str_1,str_Val)
			ELSE
				strcat(str_1,str_2);
			strcat(str_Input,str_1);
			strcpy(str_Base,str_3);
			int_Pos := str_pos('$[',str_Base,0);
			int_Pos2 := str_pos(']',str_Base,(int_Pos+1));
			
		END
		ELSE
		BEGIN
			writeln('Error of computing in dat file ', str_Compute);
			{ int_Pos := -1; }
			{2021-03-25 XP in case of not computed value, we continue with the next if exists}
			{instead of not continue to treat}
			int_Pos := str_pos('$[',str_Base,(int_Pos+1));
			int_Pos2 := str_pos(']',str_Base,(int_Pos+1));
		END;
		{ END; }
	END;
	strcat(str_Input,str_Base);
	DebugEnd;
END;{@}


{----------------------------------------------------------------------------}
FUNCTION IsLineStartProg{(str_Line : TC255):BOOLEAN};
{----------------------------------------------------------------------------}
VAR
        str_Key : TC255;
        int_Ret : INTEGER;
        real_Val : REAL;
        str_ProcName : TC255;
BEGIN
        strcpy(str_ProcName,'IsLineStartProg -> Citizen_M16.PAS');
        DebugBegin(str_ProcName,CONST_NO);
        int_Ret := CONST_NO;
        strcpy(str_Key,'$');
        IF (ReadValKey(str_Line,str_Key,0,real_Val) = 0) THEN strcpy(str_Key,':');  
        IF (ReadValKey(str_Line,str_Key,0,real_Val) = 1) THEN int_Ret := CONST_YES;

        IsLineStartProg := int_Ret = CONST_YES;

        DebugEnd;
END;{@}


{----------------------------------------------------------------------------}
PROCEDURE EndFile;
{----------------------------------------------------------------------------}
{
Output the end of file
}
VAR
	str_Dat : TC255;
	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'EndFile -> Citizen_M16.PASS');
	DebugBegin(str_ProcName,CONST_NO);

{change format of dat key to ouput end parameters for citizen machine}
	IF ICALL(TEST_select_string_tec,TEC_PPCLEF,GPP_STRING_KEY,'DATVAL') = CONST_YES THEN
	BEGIN
		{datval is used to compute output valurs computed by PP}
		{no need to use factor 1000, the value has been converted before}
		PCALL(WRITE_DPP_integer,GPP_INTEGER_KEY_NBINT_MINI,10);
		PCALL(WRITE_DPP_integer,GPP_INTEGER_KEY_NBDEC_MAXI,0);
		{ PCALL(WRITE_DPP_real,GPP_REAL_KEY_FACTOR,1000); }
		PCALL(WRITE_DPP_boolean,GPP_BOOLEAN_KEY_DECIMAL,CONST_NO);
	END;	
	IF ICALL(TEST_select_string_tec,TEC_PPCLEF,GPP_STRING_KEY,'REAL_NO') = CONST_YES THEN
	BEGIN

		PCALL(WRITE_DPP_integer,GPP_INTEGER_KEY_NBINT_MINI,10);
		PCALL(WRITE_DPP_integer,GPP_INTEGER_KEY_NBDEC_MAXI,0);
		PCALL(WRITE_DPP_real,GPP_REAL_KEY_FACTOR,1000);
		PCALL(WRITE_DPP_boolean,GPP_BOOLEAN_KEY_DECIMAL,CONST_NO);
	END;
	IF ICALL(TEST_select_string_tec,TEC_PPCLEF,GPP_STRING_KEY,'REAL_LG') = CONST_YES THEN
	BEGIN

		PCALL(WRITE_DPP_integer,GPP_INTEGER_KEY_NBINT_MINI,10);
		PCALL(WRITE_DPP_integer,GPP_INTEGER_KEY_NBDEC_MAXI,0);
		PCALL(WRITE_DPP_real,GPP_REAL_KEY_FACTOR,1000);
		PCALL(WRITE_DPP_boolean,GPP_BOOLEAN_KEY_DECIMAL,CONST_NO);
	END;
	
	
	IF ICALL(TEST_select_string_tec,TEC_PPCLEF,GPP_STRING_KEY,'DATVAL_I') = CONST_YES THEN
	BEGIN
		PCALL(WRITE_DPP_integer,GPP_INTEGER_KEY_NBINT_MINI,10);
		PCALL(WRITE_DPP_integer,GPP_INTEGER_KEY_NBDEC_MAXI,0);
		PCALL(WRITE_DPP_real,GPP_REAL_KEY_FACTOR,1000);
	END;
	IF ICALL(TEST_select_string_tec,TEC_PPCLEF,GPP_STRING_KEY,'DATVAL_R') = CONST_YES THEN
	BEGIN
		PCALL(WRITE_DPP_integer,GPP_INTEGER_KEY_NBINT_MINI,10);
		PCALL(WRITE_DPP_integer,GPP_INTEGER_KEY_NBDEC_MAXI,0);
		PCALL(WRITE_DPP_real,GPP_REAL_KEY_FACTOR,1000);
		PCALL(WRITE_DPP_boolean,GPP_BOOLEAN_KEY_DECIMAL,CONST_NO);
	END;

	strcpy(str_Dat,'PARAM');
	OutputDatSection(str_Dat);
	
	OutputEndFile;
	DebugEnd;
END;{@}


{----------------------------------------------------------------------------}
PROCEDURE InitDatVariables;
{----------------------------------------------------------------------------}
{
Initialize the variables use in the DAT file
}
VAR
	str_Var : TC255;
	real_Val, real_ZJaws, real_ZMin, real_ZMax,real_ZOri : REAL;
	real_XMin, real_XMax,real_Speed : REAL;
	i, int_NbCycle, int_TypeCycle,int_BUnit,int_Range : INTEGER;
	int_NumProg : INTEGER;
	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'InitDatVariables -> Citizen_M16.PAS');
	DebugBegin(str_ProcName,CONST_NO);

	DatInitArrayInfo(50);
	
	strcpy(str_Var,'$PART_LG');
	PCALL(READ_PART_part_length,real_Val);
	DatSetValueFormat(str_Var,real_Val,SPI_FORMAT_REAL_DISTANCE);
	
	PCALL(READ_PART_STOCK_BOX,real_ZMin,real_XMin,real_ZMax,real_XMax);
	
	strcpy(str_Var,'$STOCK_LG');
	real_Val := real_ZMax - real_ZMin;
	DatSetValueFormat(str_Var,real_Val,SPI_FORMAT_REAL_DISTANCE);
	
	strcpy(str_Var,'$STOCK_ZMAX');
	DatSetValueFormat(str_Var,real_ZMax,SPI_FORMAT_REAL_DISTANCE);
	
	strcpy(str_Var,'$STOCK_DIAM');
	real_Val := 2 * real_XMax;
	DatSetValueFormat(str_Var,real_Val,SPI_FORMAT_REAL_DISTANCE);
	
	
	{ strcpy(str_Var,'$PARTING_LEFT_POS'); }
	{ real_Val := ReadPartingToolLeftPos; }
	{ DatSetValueFormat(str_Var, real_Val,SPI_FORMAT_REAL_DISTANCE); }
	
	PCALL(READ_PART_chuck_part_position,1,real_ZJaws, real_ZMin, real_ZMax,real_ZOri);
	strcpy(str_Var,'$Z_ALLOWANCE');
	real_Val := real_ZMax - real_ZOri;
	DatSetValueFormat(str_Var,real_Val,SPI_FORMAT_REAL_DISTANCE);
	
	
	real_ZMin := 0;
	real_ZMax := 0;
	IF ICALL(TEST_exist_rework_spindle) = CONST_YES THEN
	BEGIN
		PCALL(READ_PART_chuck_part_position,2,real_ZJaws, real_ZMin, real_ZMax,real_ZOri);
	END;
		
	strcpy(str_Var,'$REWORK_IN');
	real_Val := abs(real_ZMin);
	DatSetValueFormat(str_Var,real_Val,SPI_FORMAT_REAL_DISTANCE);
	
	strcpy(str_Var,'$REWORK_OUT');
	real_Val := real_ZMax;
	DatSetValueFormat(str_Var,real_Val,SPI_FORMAT_REAL_DISTANCE);
	
	strcpy(str_Var,'$CUT_PART_LG');
	real_Val := real_Zmax + abs(real_ZMin);
	DatSetValueFormat(str_Var,real_Val,SPI_FORMAT_REAL_DISTANCE);


	PCALL(READ_PART_cycle_nb,int_NbCycle);
	FOR i:=1 TO int_NbCycle DO
	BEGIN
		PCALL(UTIL_cycle_load,i);
		PCALL(READ_PART_cycle_no,int_TypeCycle);
		{loop on the parting cycle to store some values for Dat file}
		IF int_TypeCycle = CONST_PARTING THEN
		BEGIN
			PCALL(READ_PART_real_tec,REAL_TURN_Z_ALLOWANCE,real_Val);
			{ writeln('                     parting ', real_Val); }
			strcpy(str_Var,'$CUT_Z_ALLOWANCE');
			DatSetValueFormat(str_Var,real_Val, SPI_FORMAT_REAL_DISTANCE);
			PCALL(READ_PART_spindle,real_Speed,int_BUnit,int_Range);
			real_Val := 97;
			IF int_BUnit = CONST_SMM THEN real_Val := 96;
			strcpy(str_Var,'$CUT_UNIT');
			DatSetValue(str_Var,real_Val);
			
			real_Val := 0;
			IF int_Bunit = CONST_SMM THEN real_Val := real_Speed;
			strcpy(str_Var,'$CUT_CCS');
			DatSetValueFormat(str_Var, real_Val, SPI_FORMAT_REAL_CUTTING_SPEED);
			
			real_Val := 0;
			IF int_BUnit = CONST_RPM THEN real_Val := real_Speed;
			strcpy(str_Var,'$CUT_RPM');
			DatSetValueFormat(str_Var, real_Val, SPI_FORMAT_REAL_ROTATION_SPEED);
			
		END;
	END;

	InitProgNumber(int_NumProg);
	strcpy(str_Var,'$NUM_PROG');
	real_Val := int_NumProg;
	DatSetValue(str_Var,real_Val);

	DebugEnd;
END;{@}


{----------------------------------------------------------------------------}
PROCEDURE CycleDrillingCommonBegin;
{----------------------------------------------------------------------------}
VAR
	int_BReturnType, int_GCode,int_Bunit, int_CycleType, int_FirstPt :INTEGER;
	int_DepthSign, int_CycleDirection : INTEGER;
	real_Depth, real_Depth1,real_FinalDepth, real_Feed,real_SafetyDistance :REAL;
	real_RValue, real_DwellTime, real_RapidPlane, real_Return, real_InitLevel :REAL;
	tr3_Pt, tr3_PtApp, tr3_PtSafety, tr3_PtEnd, tr3_PtRet : TR3;
	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'CycleDrillingCommonBegin -> Citizen_M16.PAS');
	DebugBegin(str_ProcName,CONST_NO);

	PCALL(READ_PART_boolean_tec,BOOLEAN_MILL_RETRACT_MANAGE,int_BReturnType);
	PCALL(READ_PATH_point,tr3_Pt);
	PCALL(READ_PART_drill_depth,real_Depth,real_Depth1,real_FinalDepth);
	PCALL(READ_PATH_feed,real_Feed,int_BUnit);
	PCALL(READ_PATH_safety_distance,real_SafetyDistance);
	PCALL(READ_PATH_hole_points,tr3_PtApp,tr3_PtSafety,tr3_PtEnd,tr3_PtRet);
	PCALL(READ_PART_real_tec,REAL_MILL_END_DWELL,real_DwellTime);
	PCALL(READ_PART_pp_cycle_no,int_CycleType);
	PCALL(READ_PART_real_tec,REAL_MILL_RAPID_PLANE,real_RapidPlane);
	PCALL(READ_PART_boolean_tec,BOOLEAN_TURN_MACHINING_DIRECTION,int_CycleDirection);

	int_FirstPt := ICALL(TEST_FIRST_HOLE);

	int_DepthSign :=1;
	IF InvertSignCycle(CONST_NO) THEN int_DepthSign := -1; 

	{Test if we are already on the point to start}
	IF int_FirstPt = CONST_YES THEN
	BEGIN
		MovePlan;
		PCALL(OUTPUT_NC_paxis3,tr3_PtApp[2],CONST_NO);
		IF TESTMOVE THEN writeb;
	END;
	real_InitLevel := GetLastDrillingInitLevel;
	IF IsGCodeActivated(80) THEN
	BEGIN
		PCALL(READ_NC_pax3,real_InitLevel);
		SetLastDrillingInitLevel(real_InitLevel);
	END;

	{IF G98/G99 is used for the feed parameter, don't use for the return plane}
	IF INTRD(STD_LIST_FEED_CODE) = 1 THEN
	BEGIN
		IF (int_BReturnType = CONST_SAFETY_PLANE) THEN int_GCode := 98
			ELSE int_GCode := 99;

		PCALL(OUTPUT_NC_G,int_GCode,CONST_NO);
	END;

	real_RValue := (tr3_Pt[2] + real_SafetyDistance - real_InitLevel) * int_DepthSign;
	{ IF NOT IsNull(real_RValue) THEN }
	{ BEGIN }
	IF (int_CycleType <> CONST_TAPPING) THEN PCALL(OUTPUT_NC_tab,'R_DRILL',(real_RValue),CONST_NO);
	{ END; }

	IF NOT IsNull(real_Depth1) THEN
	BEGIN
		PCALL(OUTPUT_NC_tab,'Q_DRILL',real_Depth1,CONST_YES);
	END;

	IF NOT IsNull(real_DwellTime) THEN
	BEGIN
		PCALL(OUTPUT_NC_tab,'P_DRILL',real_DwellTime,CONST_NO);
	END;

	{ PCALL(OUTPUT_NC_paxis3,((-real_SafetyDistance-real_Depth) * int_DepthSign),CONST_NO); }
	PCALL(OUTPUT_NC_paxis3,(tr3_PtEnd[2]),CONST_NO);
	{ PCALL(OUTPUT_NC_pplane_db,CONST_NO); }
	OutputNCpplane;
	IF (int_CycleType <> CONST_TAPPING) THEN PCALL(OUTPUT_NC_feed,real_Feed,int_BUnit);

	real_Return := tr3_Pt[2] + real_SafetyDistance;
	IF int_BReturnType = CONST_SAFETY_PLANE THEN real_Return := real_RapidPlane;

	SetLastDrillingDep(tr3_Pt[2]);
	SetLastDrillingEnd((tr3_Pt[2] - real_Depth));
	SetLastDrillingRet(real_Return);

	DebugEnd;
END;{@}


{----------------------------------------------------------------------------}
PROCEDURE OutputCycleDrillingTappingAxial;
{----------------------------------------------------------------------------}
VAR
	int_Dir, int_Unit,int_Range : INTEGER;
	real_Pitch, real_Speed : REAL;
	real_Depth,real_Depth1,real_FinalDepth,real_SafetyDistance : REAL;
	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'OutputCycleDrillingTappingAxial -> Citizen_M16.PAS');
	DebugBegin(str_ProcName,CONST_NO);

	PCALL(READ_PART_real_tool,REAL_TOOL_PITCH,real_Pitch);
	PCALL(READ_PART_rotation,int_Dir);
	PCALL(READ_PART_spindle,real_Speed,int_Unit,int_Range);
	PCALL(READ_PART_drill_depth,real_Depth,real_Depth1,real_FinalDepth);
	PCALL(READ_PATH_safety_distance,real_SafetyDistance);

	IF IsReworkSpindle THEN
	BEGIN
		PCALL(WRITE_DPP_KEY_STR,'Z','W');
		OutputNCRotation(CONST_BREAK);
		writeb;
		OutputDwell(0.1);
		writeb;
		{to cancel the output of CycleDrillingCommonBegin but keep the initialization}
		PCALL(OUTPUT_NC_punch_validate,CONST_NO);
	END;

	CycleDrillingCommonBegin;
	
	IF IsReworkSpindle THEN
	BEGIN
		writeb;
		PCALL(OUTPUT_NC_punch_validate,CONST_YES);
		
		PCALL(OUTPUT_NC_g,984,CONST_YES);
		PCALL(OUTPUT_NC_paxis3,(-real_SafetyDistance-real_Depth),CONST_YES);
		PCALL(OUTPUT_NC_TAB,'FR',real_Pitch,CONST_NO);
		OutputNCRotation(int_Dir);
		PCALL(WRITE_NC_force_spindle,CONST_YES,CONST_NO,CONST_NO);
		OutputNCSpindle(real_Speed,int_Unit,int_Range);
		writeb;
		PCALL(WRITE_DPP_KEY_STR,'Z','Z');
	END
	ELSE
	BEGIN
		PCALL(OUTPUT_NC_G,84,CONST_NO);
		PCALL(OUTPUT_NC_G,95,CONST_NO);
		PCALL(OUTPUT_NC_tab,'S_DRILL',real_Speed,CONST_NO);
		CASE GetCurrentGroupNo OF
			3 : BEGIN
				PCALL(OUTPUT_NC_tab,'D_DRILL',4,CONST_NO);
			END;
		END;
		PCALL(OUTPUT_NC_TAB,'FR',real_Pitch,CONST_NO);
		PCALL(OUTPUT_NC_tab,'R1_DRILL',1,CONST_NO);
		writeb;
	END;
	
	DebugEnd;
END;{@}


{----------------------------------------------------------------------------}
PROCEDURE OutputCycleDrillingTappingRadial;
{----------------------------------------------------------------------------}
VAR
	real_Speed : REAL;
	int_Unit,int_Range : INTEGER;
        real_Pitch : REAL;
        str_ProcName : TC255;
BEGIN
        strcpy(str_ProcName,'OutputCycleDrillingTappingRadial -> Citizen_M16.PAS');
        DebugBegin(str_ProcName,CONST_NO);      
        PCALL(READ_PART_real_tool,REAL_TOOL_PITCH,real_Pitch);
	PCALL(READ_PART_spindle,real_Speed,int_Unit,int_Range);
        
        CycleDrillingCommonBegin;
		  PCALL(OUTPUT_NC_tab,'S_DRILL',real_Speed,CONST_NO);
		CASE GetCurrentGroupNo OF
			3 : BEGIN
				PCALL(OUTPUT_NC_tab,'D_DRILL',4,CONST_NO);
			END;
			2 : BEGIN
				PCALL(OUTPUT_NC_tab,'D_DRILL',3,CONST_NO);
			END;
		END;
		  
        PCALL(OUTPUT_NC_G,88,CONST_NO);
        PCALL(OUTPUT_NC_G,95,CONST_NO);
        PCALL(OUTPUT_NC_TAB,'FR',real_Pitch,CONST_NO);
		  PCALL(OUTPUT_NC_tab,'R1_DRILL',1,CONST_NO);
        writeb;

        DebugEnd;
END;{@}


{----------------------------------------------------------------------------}
PROCEDURE OutputDrillingCancelTurn;
{----------------------------------------------------------------------------}
VAR
	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'OutputDrillingCancelTurn -> Citizen_M16.PAS');
	DebugBegin(str_ProcName,CONST_NO);
	
	PCALL(OUTPUT_NC_g,80,CONST_YES);
	writeb;
		PCALL(WRITE_NC_g,1);
	DebugEnd;
END;{@}

{----------------------------------------------------------------------------}
PROCEDURE OutputCycleDrillingChipbreakingTurn;
{----------------------------------------------------------------------------}
VAR
        int_Bunit, int_ZSign, int_CycleType :INTEGER;
        real_Depth, real_Depth1,real_FinalDepth, real_Feed,real_Dwell :REAL;
        tr3_Pt : TR3;
        str_ProcName : TC255;
BEGIN
        strcpy(str_ProcName,'OutputCycleDrillingChipbreakingTurn -> Citizen_M16.PAS');
        DebugBegin(str_ProcName,CONST_NO);

        PCALL(READ_PATH_point,tr3_Pt);
        PCALL(READ_PART_drill_depth,real_Depth,real_Depth1,real_FinalDepth);
        PCALL(READ_PATH_feed,real_Feed,int_BUnit);
        PCALL(READ_PART_boolean_tec,BOOLEAN_TURN_MACHINING_DIRECTION,int_CycleType);
		PCALL(READ_PART_real_tec,REAL_TURN_DWELL_END, real_Dwell);
        OutputApproachDrillingTurn;
        int_ZSign := 1;
        IF InvertSignCycle(CONST_NO) THEN int_ZSign := -1;

        PCALL(OUTPUT_NC_G,83,CONST_YES);
        PCALL(OUTPUT_NC_pplane,(tr3_Pt[0]-( real_Depth * int_ZSign)),tr3_Pt[1],CONST_YES);
        PCALL(OUTPUT_NC_tab,'Q_DRILL',real_Depth1,CONST_NO);
		  PCALL(OUTPUT_NC_tab,'P_DRILL', real_Dwell,CONST_NO);
        PCALL(OUTPUT_NC_feed,real_Feed,int_BUnit);
        writeb;

	OutputDrillingCancel;

        DebugEnd;
END;{@}


{----------------------------------------------------------------------------}
PROCEDURE OutputDepPlan;
{----------------------------------------------------------------------------}
{
Output a movement in the plan X and Y only
}
VAR
	int_PlaneType,int_ToolNb,int_ToolLengthOffset,int_ToolDiaOffset :INTEGER;
	bool_TestMove :BOOLEAN;
	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'OutputDepPlan -> Citizen_M16.PAS');
	DebugBegin(str_ProcName,CONST_NO);

	PCALL(READ_PART_cycle_plane_type,int_PlaneType);
			 PCALL(READ_PART_tool,int_ToolNb,int_ToolLengthOffset,int_ToolDiaOffset);

	PCALL(OUTPUT_NC_RAPID);
	PCALL(OUTPUT_NC_G,90,CONST_NO);
	IF (int_PlaneType = CONST_PLANE_DEV_Z) THEN PCALL(OUTPUT_NC_tab,'Y',0.0,0);

	bool_TestMove := IsMovePrimaryAxis2;

	{unlock C axis}
	IF bool_TestMove THEN OutputUnclampCAxis;

	OutputNCRadiusOffsetNumber(int_ToolLengthOffset);
	{2024-05-06 XP If we change tool index only and not tool, we decompose appraoch in X then Z instead of XZ}
	IF not IsMillingOperation AND (ICALL(TEST_change_tool_pocket)=CONST_YES) and not IsOutputToolChange THEN
	BEGIN
		PCALL(OUTPUT_NC_paxis2_db,1);
		writeb;
		PCALL(OUTPUT_NC_paxis1_db,1);
		writeb;
	END
	ELSE
	BEGIN
		MovePlan;
	END;
	{ PCALL(OUTPUT_NC_tab,'T',int_ToolNb,CONST_YES); }
	{lock the C axis if it has been unlock except for axial interpolation plane}
	IF bool_TestMove and IsOKOutputLockCAxis THEN OutputClampCAxis;


	DebugEnd;
END;{@}

{----------------------------------------------------------------------------}
PROCEDURE InitOperation;
{----------------------------------------------------------------------------}
VAR
	int_CycleNo,int_Value int_DrillType,int_ChangeCycle, int_Decompose :INTEGER;
	int_Channel, int_GroupNo, int_MainPattern, int_BActive : INTEGER;
	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'InitOperation -> Citizen_M16.PAS');
	DebugBegin(str_ProcName,CONST_NO);

	int_ChangeCycle := ICALL(TEST_CHANGE_CYCLE);
	PCALL(READ_PART_channel_no, int_Channel);

	IF (int_ChangeCycle = CONST_YES) AND IsOutputToolChange THEN
	BEGIN
		PCALL(WRITE_NC_G_force,0);
		PCALL(WRITE_NC_G_force,90);
		PCALL(WRITE_NC_init_feed);
		PCALL(WRITE_NC_G_force,98);
		IF INTRD(STD_LIST_FEED_CODE) = 1 THEN
		BEGIN
			PCALL(WRITE_NC_g_force,94);
		END;
	END;
	
	PCALL(WRITE_NC_BLOCK_OPTIONAL,CONST_NO);
	IF (IsReworkSpindle) AND (int_Channel = 2) THEN
	BEGIN
		{ PCALL(WRITE_NC_BLOCK_OPTIONAL,CONST_YES); }
	END;

	{For FANUC Mill Turn CNC the parameter 5101 bit 2 define if}
	{the G83 and G87 canned cycle are deburring or chipbreak}
	{We decompose the other drilling method}
	{STD_LIST_PARAM_5101}
	{0 : don't use, 1 : G83 is chipbreaking, 2 : G83 is deburring}
	PCALL(READ_PART_pp_cycle_no, int_CycleNo);
	int_Value := INTRD(STD_LIST_PARAM_5101);

	CASE int_CycleNo OF
		CONST_DRILLING_DEBURRING : BEGIN
			{If the value of Param 5101 is 1 we must decompose the deburring cycle}
			IF (int_Value = 1) or (int_Value = 0) THEN
			BEGIN
				PCALL(WRITE_DPP_cycle_exec,CONST_DECOMPOSED);
			END;
		END;
		CONST_DRILL_CHIP_BREAK : BEGIN
			{If the value of Param 5101 is 2 we must decompose the chipbreak cycle}
			IF (int_Value = 2) or (int_Value = 0) THEN
			BEGIN
				PCALL(WRITE_DPP_cycle_exec,CONST_DECOMPOSED);
			END;
		END;
	END;

	IF IsOutputPlane THEN
	BEGIN
		PCALL(WRITE_NC_force_primary);
		PCALL(WRITE_NC_force_secondary);
	END;
	
	
	{2021-01-11 XP Add decompose cycle if invert spindle in drilling cycle}
	int_Decompose := CONST_NO;
	IF IsDrillingWithInvert THEN int_Decompose := CONST_YES;
	
	IF int_Decompose = CONST_YES THEN PCALL(WRITE_DPP_cycle_exec,CONST_DECOMPOSED);

	DebugEnd;
END;{@}


{----------------------------------------------------------------------------}
PROCEDURE StartFile;
{----------------------------------------------------------------------------}
{
Output for the start of file
}
VAR
	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'StartFile -> Citizen_M16.PAS');
	DebugBegin(str_ProcName,CONST_NO);
	{ OutputStartFile; }
	DebugEnd;
END;{@}


{----------------------------------------------------------------------------}
PROCEDURE EnableCAxis;
{----------------------------------------------------------------------------}
{
Enable the C axis
The modality is manage with the group M_5 under M50 and M51 
}
VAR
	str_CAxisCode, str_Key : TC255;
	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'EnableCAxis -> Citizen_M16.PAS');
	DebugBegin(str_ProcName,CONST_NO);

	str_CAxisCode[0] := chr(0);
	
	strcpy(str_Key,'M_5');

	IF not IsMCodeActivated(51) or not IsModalKeyInteger(str_Key) THEN
	BEGIN
		EnableCAxisCode(str_CAxisCode);
		IF str_CAxisCode[0] <> chr(0) THEN
		BEGIN
			PCALL(OUTPUT_NC_tab_str,'SP_START',str_CAxisCode,CONST_YES);
			PCALL(OUTPUT_NC_tab,'C',0,CONST_YES);
			{ PCALL(OUTPUT_NC_M,51,CONST_NO); }
			writeb;
		END;
		{ PCALL(OUTPUT_NC_G,90,CONST_YES); }
		{ PCALL(OUTPUT_NC_G,28,CONST_YES); }
		{ writeb; }

		PCALL(WRITE_NC_M,51);
		PCALL(WRITE_NC_primary,0);
	END;
	DebugEnd;
END;{@}


{----------------------------------------------------------------------------}
PROCEDURE Plane;
{----------------------------------------------------------------------------}
{
Output the block to active the plane
}
VAR
	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'Plane -> Citizen_M16.PAS');
	DebugBegin(str_ProcName,CONST_NO);

	IF IsAxialPlane OR IsBPlane THEN
	BEGIN {Axial Milling}
		PCALL(OUTPUT_NC_G,17,CONST_NO);
		writeb;
	END;

	IF IsRadialPlane THEN
	BEGIN {Radial milling}
		PCALL(OUTPUT_NC_G,19,CONST_NO);
		writeb;
	END;
			 
	IF IsTurnPlane THEN
	BEGIN {Turn}
		{ PCALL(OUTPUT_NC_G,18,CONST_NO); }
		{ writeb; }
	END;

	IF IsBPlane THEN
	BEGIN
		OutputCancelTiltedWorkPlane;
		OutputTiltedWorkPlane;
		writeb;
	END;

	IF NOT IsTurnPlane THEN
	BEGIN
		EnableCAxis;
		{ writeb; }
	END;

	DebugEnd;
END;{@}


{----------------------------------------------------------------------------}
PROCEDURE OutputNCPrimary{(real_Angle : REAL)};
{----------------------------------------------------------------------------}
VAR
	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'OutputNCPrimary -> Citizen_M16.PAS');
	DebugBegin(str_ProcName,CONST_NO);

	If IsReworkSpindle THEN
	BEGIN
	
	END
	ELSE
	BEGIN
		real_Angle := -real_Angle;
	END;


	{ writeln('                              : ', INTRD(LIB_LIST_C_AXIS_MANAGEMENT)); }
	CASE INTRD(LIB_LIST_C_AXIS_MANAGEMENT) OF
		0 : BEGIN
			OutputNCPrimaryModulo(real_Angle);
		END;
		1 : BEGIN
			OutputNCPrimaryContinuous(real_Angle);
		END;
		2 : BEGIN
			OutputNCPrimaryIncremental(real_Angle);
		END;
	END;

	{ IF HavePrimaryAxis THEN PCALL(OUTPUT_NC_primary,real_Angle,CONST_NO); }

	DebugEnd;
END;{@}

{----------------------------------------------------------------------------}
PROCEDURE ApproachPlaneLiveToolBegin;
{----------------------------------------------------------------------------}
VAR

        tr3_Pt : TR3;
        real_Angle1,real_Angle2,real_Angle3 :REAL;
        str_InterpoOn : TC255;
        str_ProcName : TC255;
BEGIN
        strcpy(str_ProcName,'ApproachPlaneLiveToolBegin -> Citizen_M16.PAS');
        DebugBegin(str_ProcName,CONST_NO);

        IF IsAxialInterpoPlane THEN
        BEGIN
                {We must active the plane here because we can't have rapid move}
                {in G112 on Fanuc CNC}
                {we read the last position of C axis to be able to offset the plane}
                {we must do it because the G112 active the current C as C0}
                PCALL(READ_NC_paxis2,real_Angle1);
                ActivePlane;
                
                {we offset the plane to have correct coordinates}
                { PCALL(WRITE_NC_plane_rotation,-real_Angle1); }
                
                { strcpy(str_InterpoOn,'G12.1'); }
                { EnableAxialInterpoCode(str_InterpoOn); }
                { PCALL(OUTPUT_NC_punch_str,str_InterpoOn); }
                { PCALL(WRITE_NC_G,112); }
                
                OutputAxialInterpoOn;
                
                {Write the point in the cn memory to don't have axis tool movement in the next move}
                PCALL(READ_PATH_point,tr3_Pt);
                PCALL(WRITE_NC_paxis3,tr3_Pt[2]);
                writeb;
					 PCALL(WRITE_NC_g_force,1);
					 PCALL(WRITE_NC_force_feed,CONST_YES,CONSt_NO);
        END;

        If IsDevZPlane THEN
        BEGIN
                OutputRadialInterpoOn;
        END;


        DebugEnd;
END;{@}


{----------------------------------------------------------------------------}
PROCEDURE EndSpecific;
{----------------------------------------------------------------------------}
VAR
	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'EndSpecific -> Citizen_M16.PAS');
	DebugBegin(str_ProcName,CONST_NO);
	
	IF (ICALL(TEST_latest_cycle,CONST_YES,CONST_YES,CONST_NO,CONSt_NO) = CONST_NO) THEN
		OutputSynchroToolpath(-2);

	DebugEnd;
END;{@}



{----------------------------------------------------------------------------}
FUNCTION GetGaugeMTE_SPE{(VAR real_GaugeX, real_GaugeY, real_GaugeZ : REAL) : BOOLEAN};
{----------------------------------------------------------------------------}
VAR
	int_ToolNo, int_TurretNo, int_NbTools,i, int_TurretNoMTE, int_ToolNoMTE : INTEGER;
	int_Ret : INTEGER;
	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'GetGaugeMTE');
	DebugBegin(str_ProcName,CONST_NO);
	
	PCALL(READ_PART_tool_no,int_ToolNo);
	PCALL(READ_PART_turret_no, int_TurretNo);
	int_Ret := CONST_NO;
	
	PCALL(SPI_ASM_load_assembly);
	
	int_NbTools := ICALL(SPI_ASM_init_toollist);
	
	FOR i := 0 TO (int_NbTools - 1) DO
	BEGIN
		IF (ICALL(SPI_ASM_select_tool,i) = CONST_YES) THEN
		BEGIN
			PCALL(SPI_ASM_get_tool_position,i, int_TurretNoMTE,int_ToolNoMTE);
			{ writeln('                      tool nose number ', int_ToolNo, int_ToolNoseNumber); }
			IF (int_TurretNo = int_TurretNoMTE) AND (int_ToolNo = int_ToolNoMTE) THEN
			BEGIN
				PCALL(SPI_ASM_read_real_tool,MT_JAUGE_X,real_GaugeX);
				PCALL(SPI_ASM_read_real_tool,MT_JAUGE_Y,real_GaugeY);
				PCALL(SPI_ASM_read_real_tool,MT_JAUGE_Z,real_GaugeZ);
				int_Ret := CONST_YES;
			END;
			
		END;
	END;
	
	
	PCALL(SPI_ASM_free_toollist);
	
	GetGaugeMTE_SPE := int_Ret = CONST_YES;
	
	DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE OutputToolChange;
{----------------------------------------------------------------------------}
{
Write a toolchange in the programm if needed
}
VAR
	int_ToolNb,int_IsFirstTool :INTEGER;
	int_ToolLengthOffset, int_ToolDiaOffset :INTEGER;
	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'OutputToolChange -> S69_CITIZEN.LIB');
	DebugBegin(str_ProcName,CONST_NO);

	int_IsFirstTool := ICALL(TEST_FIRST_TOOL_MILLING);
	PCALL(READ_PART_tool,int_ToolNb,int_ToolLengthOffset,int_ToolDiaOffset);

	IF IsOutputToolChange or (ICALL(TEST_change_tool_pocket_turret) = CONST_YES) THEN
	BEGIN
		OutputToolFixedBlock;
		ToolChange(int_ToolNb,int_ToolLengthOffset,int_IsFirstTool);
	END;

	DebugEnd;
END;{@}


{----------------------------------------------------------------------------}
PROCEDURE Change_Plane;
{----------------------------------------------------------------------------}
VAR
	real_PrimaryAngle,real_SecondaryAngle,real_Angle3 : REAL ;
	real_X,real_Y,real_Z : REAL;
	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'Change_Plane -> Citizen_M16.PAS');
	DebugBegin(str_ProcName,CONST_YES);

	{ writeln('                       Change Plane'); }
	PCALL(READ_PART_rot_angles,real_PrimaryAngle,real_SecondaryAngle,real_Angle3);
	{ DOUBLEWR(LIB_ANGLE_ROT1,a1); }
	{ DOUBLEWR(LIB_ANGLE_ROT2,a2); }
	PCALL(WRITE_NC_g_force,0);

	{ Rotation_axeB(0,a2); }
	{ certainement dangereux, il vaut mieux casser le cycle en saisie dans ce cas }


	{ PCALL(bcnPRIMAIRE,a1,1); }
	OutputNCPrimary(real_PrimaryAngle);
	OutputNCSecondary(real_SecondaryAngle);
	IF TESTMOVE THEN
	BEGIN
		OutputNCRapid;
		{ PCALL(bcnRAPID); }
		writeb;
	END;
	
	DebugEnd;
END;{@}



{----------------------------------------------------------------------------}
PROCEDURE MTE_ASM_offset_number(VAR int_LComp : INTEGER; VAR int_LComp2 : INTEGER; var int_DComp : INTEGER; VAR str_SpecificID : TC80);
{----------------------------------------------------------------------------}  
VAR
	int_TurretNo, int_ToolNo, int_PocketNo, int_IndexNo, int_FirstMutliSuppNo, int_ToolLastSuppNo : INTEGER;
	int_LCompIncr, int_LCompIncr2, int_DCompIncr : INTEGER;
	str_AutoID : TC80;
BEGIN
	PCALL(READ_PART_integer_tec,INTEGER_MAC_LENGTH_OFFSET_INCR,int_LCompIncr);
	PCALL(READ_PART_integer_tec,INTEGER_MAC_LENGTH_OFFSET_INCR_2,int_LCompIncr2);
	PCALL(READ_PART_integer_tec,INTEGER_MAC_DIAMETER_OFFSET_INCR,int_DCompIncr);

	PCALL(UTILMTE_ASM_tool_mounted,int_TurretNo,int_ToolNo,int_PocketNo,int_IndexNo);
	PCALL(UTILMTE_ASM_tool_mounted_trihedral,str_AutoID, int_FirstMutliSuppNo, int_ToolLastSuppNo);

	{ writeln('------'); }
	{ writeln('incr',int_LCompIncr,int_LCompIncr2,int_DCompIncr); }
	{ writeln('tool',int_TurretNo,int_ToolNo,int_PocketNo,int_IndexNo); }
	{ writeln('triedre',str_AutoID,int_FirstMutliSuppNo,int_ToolLastSuppNo); }
	{ writeln('-------'); }
	
	{ traitement std selon MCT ... idem si procedure absente }
	int_LComp := int_ToolNo + int_LCompIncr;
	int_LComp2 := int_ToolNo + int_LCompIncr2;
	int_DComp := int_ToolNo + int_DCompIncr;
	
	{2024-06-04 for tool T44 we force the tool offset to T40}
	IF (int_ToolNo = 44) THEN
	BEGIN
		int_LComp := 40;
		int_LComp2 :=40;
		int_DComp := 40;
	END;
	
END;{@}




