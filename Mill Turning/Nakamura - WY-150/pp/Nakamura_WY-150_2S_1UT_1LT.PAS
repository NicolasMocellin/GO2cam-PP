{#-----------------------------------------------------------------------------#
#                              www.cam-team.com                                #
#                                	copyright                                 	 #
#------------------------------------------------------------------------------#
#   CAM-Team GmbH              WEB:     www.cam-team.com                       #
#   Boettgerstr. 2/3           Mail:    info@cam-team.com                      #
#   DE-89231 Neu-Ulm       		 Tel DE:  +49 7311 411 43 45     							   #
#   																																					 #
#   CAM-Team GmbH              WEB:     www.cam-team.com                       #
#   Weidmattstrasse 33         Mail:    info@cam-team.com                      #
#   CH-Walterswil SO       		 Tel CH:  +41 62 534 45 52     							     #
#                         ___                                                  #
#                        (O O)                                                 #
#---------------------ooO-(_)-Ooo----------------------------------------------#
#
# GO2cam Version   	  : 6.08.213-2022
# Basis PP   	  	  	: T67_Fanuc.SPT
# Maschine            : Nakamura WY-150
# Steuerung           : Fanuc
# Programmiert fuer   : 2-Kanal Revolver Oben+Unten/ CY-Achsen Uebergabe
# Unterprogramme      : Nein
# MDM-System     			: Nein
# Kunde               : RAU AG
# Code                : 0050569133D8,005056913BB6
# -----------------------------------------------------------------------------#
# Wir haften fuer Schaeden oder Fehlfunktionen, die durch diesen Postprozessor #
# oder durch mit diesem Postprozessor betriebene Software entstehen, grund-    #
# saetzlich nicht. Die Benutzung dieses Postprozessors erfolgt fuer Sie aus-   #
# schliesslich auf Ihre eigene Gefahr.                                         #
# Sind Sie mit den obigen Anmerkungen nicht Einverstanden, ist die Benutzung   #
# des Postprozessors nicht gestattet. Wir behalten uns alle Rechte an diesem   #
# Postprozessor vor. Unerlaubte Vervielfaeltigung ist verboten. Teilen Sie     #
# uns alle Aenderungen unbedingt muendlich oder schriftlich mit.               #
#                                                                              #
# Aenderungen dieser Anmerkungen verstossen gegen das Urheberrecht.            #
#                                                                              #
# ******************************************************************************}

PROCEDURE OutputDatSectionSpe(str_SectionName : TC255);		FORWARD;


{#include "~/Nakamura_WY-150_2S_1UT_1LT.MTE"}

{----------------------------------------------------------------------------}
PROCEDURE PP_CODE(VAR int_BitNumber : INTEGER);
{----------------------------------------------------------------------------}
VAR
	str_MCBNameRead,str_MCBName, str_Message : TC255;
	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'PP_CODE');
	DebugBegin(str_ProcName,CONST_NO);
	
	int_BitNumber := 3200;
	
	PCALL(READ_PART_string_tec,STRING_MAC_MCG_KINE,str_MCBNameRead);
	strcpy(str_MCBName,'Nakamura_WY-150_2S_1UT_1LT.MCB');
	
	IF not IsSameStr(str_MCBName,str_MCBNameRead) THEN
	BEGIN
		strcpy(str_Message,'Kinemac machine not set correctly. Select the machine : ');
		strcat(str_Message, str_MCBName);
		MessageError(0,str_Message);
		PCALL(SPI_GEN_exit_all);
	END;
	
	
	DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE ReadTxtPack(int_Number : INTEGER;VAR str_Text : TC255);
{----------------------------------------------------------------------------}
VAR
	int_Err, int_Lng : INTEGER;
	str_MsgPath, str_MsgName, str_Lng : TC255;
	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'ReadTxtPack');
	DebugBegin(str_ProcName,CONST_NO);
	
	PCALL(SPI_GEN_get_information,STRING_DIRECTORY_PP, str_MsgPath);
	PCALL(SPI_GEN_get_information,STRING_DIRECTORY_LANGUAGE, str_Lng);
	PCALL(SPI_GEN_get_integer_information,	EEN_LANG, int_Lng);
	PCALL(READ_PART_string_tec,STRING_MAC_PP_NAME,str_MsgName);
	strcat(str_MsgName,'.dico');
	
	
	int_Err := ICALL(SPI_GEN_load_user_msgfile,str_MsgPath,str_MsgName);

	PCALL(SPI_GEN_read_user_message,(int_Lng * 10000 + int_Number),str_Text);

	
	DebugEnd;
END;

{----------------------------------------------------------------------------}
PROCEDURE InitPPVariables;
{----------------------------------------------------------------------------}
VAR
	str_Null,str_ProcName, str_Init, str_Message
	: TC255;
	
BEGIN
	strcpy(str_ProcName,'InitPPVariables');
	DebugBegin(str_ProcName,CONST_NO);
	str_Null[0] 						:= chr(0);
	{Haupt-Einstellungen:}
	INTWR(STD_LIST_PERCENT_OUTPUT,1); {output percent at start and end of program, 0 : no, 1 : yes}
	INTWR(STD_LIST_PROG_NUMBER_FORMAT,0);	{character for program number, 0 : 'O', 1 : ':'}
	INTWR(STD_LIST_PARTNAME_COMMENT,1);   {Add the partname as comment, 0 : no, 1 : yes}
	INTWR(STD_LIST_USE_G10_FOR_ORIGIN,1); {Output G10 as begin of program to manage origin 0=No 1=Yes}
	
	INTWR(STD_LIST_SPINDLE_LIMITATION,1); {code to limit spindle 0 : G92, 1 : G50}
	INTWR(STD_LIST_FEED_CODE,0); {code for feed choice 0 : G98/G99, 1 : G94/G95}
	
	INTWR(STD_LIST_PARAM_5101,0); {0 : don't use, 1 : G83 is chipbreaking, 2 : G83 is deburring}
	INTWR(STD_LIST_THREADING_CYCLE,0); {code for threading cycle 0 : use multithreading, 1 : G92, 2 : G78, 3 : G21. If 0 Multi thread is used}
	INTWR(STD_LIST_MULTI_THREADING_CYCLE,0); {type of threading cycle 0 : G76 on 2 blocks, 1 : G76 on 1 block, 2 : G78 on 1 block}
	INTWR(STD_LIST_DECOMPOSED_THREADING_CYCLE,0); {code to choose code for decomposed threading cycle 0 : G33, 1 : G32}

	{Erweitere-Einstellungen:}
	INTWR(LIB_LIST_OUTPUT_STOCK,0); {output the stock for cnc simulation 0 : no, 1 : yes}
	INTWR(LIB_LIST_OUTPUT_TOOL_PLANE_EACH_OP,0); {output tool and plane for each operation, 0 : no, 1 : yes}
	INTWR(LIB_LIST_FEED_PARAMETER,0); {0 don't use parameters for feed, 1 : use parameters for feed}
	INTWR(LIB_LIST_CCS_POSITION,0); {position of CSS output 0 : the CSS is output at the start of cycle, 1 : the css is output at start of machining with a spindle on in tr/min at start of operation}

	INTWR(LIB_LIST_TOOL_LIST,1); {output tool list, 0 : no, 1 : yes}
	
	INTWR(LIB_LIST_ORIGIN_LIST,0); {output origin list, 0 : no, 1 : yes}
	INTWR(LIB_LIST_MULTI_ORIGIN,1); {Kind of management for multi-origin, 0 : origin number only, 1 : origin + offset}
	
	INTWR(LIB_LIST_COOLANT_POSITION,0); {position to output coolant, 0 : with spindle, 1 : with plane move, 2 with plunge move}

	{M-Befehle C-Achsen Aktivieren:}
	strcpy(str_Init,'M98 P9000 (');
	ReadTxtPack(5,str_Message);
	strcat(str_Init,str_Message);
	strcat(str_Init,')');
	STRINGWR(LIB_STR_ENABLE_C_AXIS_MS,str_Init);
	
	
	strcpy(str_Init,'M98 P9001 (');
	ReadTxtPack(5,str_Message);
	strcat(str_Init,str_Message);
	strcat(str_Init,')');
	STRINGWR(LIB_STR_ENABLE_C_AXIS_RS,str_Init);
	
	
	strcpy(str_Init,'M41 (');
	ReadTxtPack(6,str_Message);
	strcat(str_Init,str_Message);
	strcat(str_Init,')');
	STRINGWR(LIB_STR_DISABLE_C_AXIS_MS,str_Init);
	
	
	strcpy(str_Init,'M411 (');
	ReadTxtPack(6,str_Message);
	strcat(str_Init,str_Message);
	strcat(str_Init,')');
	STRINGWR(LIB_STR_DISABLE_C_AXIS_RS,str_Init);


	{G-Befehle C-Achsen Stirnseitig Axial Frasen:}
	STRINGWR(LIB_STR_ENABLE_AXIAL_INTERPO_MS,str_Null);
	STRINGWR(LIB_STR_ENABLE_AXIAL_INTERPO_RS,str_Null);
	STRINGWR(LIB_STR_DISABLE_AXIAL_INTERPO_MS,str_Null);
	STRINGWR(LIB_STR_DISABLE_AXIAL_INTERPO_RS,str_Null);

	{M-Befehle C-Achsen Klemmen und Loesen:}
	strcpy(str_Init,'M86 (');
	ReadTxtPack(18,str_Message);
	strcat(str_Init,str_Message);
	strcat(str_Init,')');
	STRINGWR(LIB_STR_CLAMP_MS,str_Init);
	
	
	strcpy(str_Init,'M32 (');
	ReadTxtPack(18,str_Message);
	strcat(str_Init,str_Message);
	strcat(str_Init,')');
	STRINGWR(LIB_STR_CLAMP_RS,str_Init);
	
	
	strcpy(str_Init,'M87 (');
	ReadTxtPack(9,str_Message);
	strcat(str_Init,str_Message);
	strcat(str_Init,')');
	STRINGWR(LIB_STR_UNCLAMP_MS,str_Init);
	
	strcpy(str_Init,'M33 (');
	ReadTxtPack(9,str_Message);
	strcat(str_Init,str_Message);
	strcat(str_Init,')');
	STRINGWR(LIB_STR_UNCLAMP_RS,str_Init);

	{G-Befehle C-Achsen Aussen Radial Frasen:}
	STRINGWR(LIB_STR_ENABLE_RADIAL_INTERPO_MS,str_Null);
	STRINGWR(LIB_STR_ENABLE_RADIAL_INTERPO_RS,str_Null);
	STRINGWR(LIB_STR_DISABLE_RADIAL_INTERPO_MS,str_Null);
	STRINGWR(LIB_STR_DISABLE_RADIAL_INTERPO_RS,str_Null);

	{Datei Ausgabe:}
	INTWR(LIB_INT_FILE_PER_CHANNEL,1);    {Eine NC-Programm pro Kanal, 0=Nein, 1=Ja}
	INTWR(LIB_INT_EMPTY_CHANNEL,1);       {Kanal erstellen auch falls nicht benutzt, 0=Nein, 1=Ja}
	
	{COMMENTED because we display the page to be able to modify those values
	INTWR(LIB_INT_LISTING_FILE,1); 				{Synchron Liste nach PP Ausgeben, 1=Ja, 0=Nein}
	INTWR(LIB_INT_LISTING_MIN,100); 			{Start Synchron Nummer}
	INTWR(LIB_INT_LISTING_MAX,199); 			{End Synchron Nummer}
	}
	
	{WARNING AND DEBUG MANAGEMENT}
	INTWR(TOOL_LIST_WARNING_MANAGEMENT,2); {Kind of display for warning pp. 0 : inactive, 1 : debug, 2 : message box, 3 : message box + exit}
	INTWR(TOOL_LIST_DEBUG_MANAGEMENT,1); {kind of debug procedure display. 0 : normal, 1 : Advanced}


	STRINGWR(LIB_STR_TOOL1,'G0 G28 U0. V0.');
	STRINGWR(LIB_STR_TOOL2,'G28 W0.');
	{ STRINGWR(LIB_STR_TOOL1,str_Null); }
	{ STRINGWR(LIB_STR_TOOL2,str_Null); }
	
	DebugEnd;
END;


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
	int_NumProg, int_NbParting, int_PartingType : INTEGER;
	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'InitDatVariables');
	DebugBegin(str_ProcName,CONST_NO);

	DatInitArrayInfo(50);
	
	
	strcpy(str_Var,'$REWORK_PART_CATCHER');
	DatSetValue(str_Var,-120);
	
	strcpy(str_Var,'$PART_LG');
	PCALL(READ_PART_part_length,real_Val);
	DatSetValue(str_Var,real_Val);
	
	PCALL(READ_PART_STOCK_BOX,real_ZMin,real_XMin,real_ZMax,real_XMax);
	
	strcpy(str_Var,'$STOCK_LG');
	real_Val := real_ZMax - real_ZMin;
	DatSetValue(str_Var,real_Val);
	
	strcpy(str_Var,'$STOCK_ZMAX');
	DatSetValue(str_Var,real_ZMax);
	
	strcpy(str_Var,'$STOCK_DIAM');
	real_Val := 2 * real_XMax;
	DatSetValue(str_Var,real_Val);
	
	strcpy(str_Var,'$STOCK_DIAM_IN');
	real_Val := 2 * real_XMin;
	DatSetValue(str_Var,real_Val);
	
	
	{ strcpy(str_Var,'$PARTING_LEFT_POS'); }
	{ real_Val := ReadPartingToolLeftPos; }
	{ DatSetValue(str_Var, real_Val); }
	
	PCALL(READ_PART_chuck_part_position,1,real_ZJaws, real_ZMin, real_ZMax,real_ZOri);
	strcpy(str_Var,'$Z_ALLOWANCE');
	real_Val := real_ZMax - real_ZOri;
	DatSetValue(str_Var,real_Val);
	
	strcpy(str_Var,'$MAIN_OUT');
	DatSetValue(str_Var,real_Zmax);
	
	PCALL(READ_PART_chuck_part_position,2,real_ZJaws, real_ZMin, real_ZMax,real_ZOri);
	strcpy(str_Var,'$REWORK_IN');
	real_Val := abs(real_ZMin);
	DatSetValue(str_Var,real_Val);
	
	strcpy(str_Var,'$REWORK_OUT');
	real_Val := real_ZMax;
	DatSetValue(str_Var,real_Val);
	
	strcpy(str_Var,'$CUT_PART_LG');
	real_Val := real_Zmax + abs(real_ZMin);
	DatSetValue(str_Var,real_Val);
	
	INTWR(SPE_INT_NB_PARTING_CYCLE,0);
	INTWR(SPE_INT_NB_PARTING_DONE,0);
	int_NbParting := 0;

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
			DatSetValue(str_Var,real_Val);
			PCALL(READ_PART_spindle,real_Speed,int_BUnit,int_Range);
			real_Val := 97;
			IF int_BUnit = CONST_SMM THEN real_Val := 96;
			strcpy(str_Var,'$CUT_UNIT');
			DatSetValue(str_Var,real_Val);
			
			real_Val := 0;
			IF int_Bunit = CONST_SMM THEN real_Val := real_Speed;
			strcpy(str_Var,'$CUT_CCS');
			DatSetValue(str_Var, real_Val);
			
			real_Val := 0;
			IF int_BUnit = CONST_RPM THEN real_Val := real_Speed;
			strcpy(str_Var,'$CUT_RPM');
			DatSetValue(str_Var, real_Val);
			
			PCALL(READ_PART_boolean_tec,BOOLEAN_TURN_PARTING_TYPE,int_PartingType);
			CASE int_PartingType OF
				CONST_TYPE_CYCLE_DRILLING_SIMPLE : BEGIN
					real_Val := 0;
				END;
				CONST_TYPE_CYCLE_DRILLING_DEBURRING : BEGIN
					real_Val := 1;
				END;
				CONST_TYPE_CYCLE_DRILLING_CHIP_BREAKING : BEGIN
					real_Val := 2;
				END;
				CONST_TYPE_CYCLE_DRILLING_DEBURRING_CHIP_BREAKING : BEGIN
					real_Val := 3;
				END;
			END;
			strcpy(str_Var,'$CUT_TYPE');
			DatSetValue(str_Var, real_Val);
			
			PCALL(READ_PART_real_tec,REAL_TURN_DEBURRING_DEPTH,real_Val);
			strcpy(str_Var,'$CUT_DEBURRING_DEPTH');
			DatSetValue(str_Var,real_Val);
			
			
			PCALL(READ_PART_real_tec,REAL_TURN_CHIP_BREAK_DEPTH,real_Val);
			strcpy(str_Var,'$CUT_CHIP_BREAK_DEPTH');
			DatSetValue(str_Var,real_Val);
			
			
			PCALL(READ_PART_real_tec,REAL_TURN_RETREAT_DISTANCE,real_Val);
			strcpy(str_Var,'$CUT_CHIP_BREAK_RETRACT');
			DatSetValue(str_Var,real_Val);
			
			
			int_NbParting := int_NbParting + 1;
		END;
	END;
	INTWR(SPE_INT_NB_PARTING_CYCLE,int_NbParting);

	InitProgNumber(int_NumProg);
	strcpy(str_Var,'$NUM_PROG');
	real_Val := int_NumProg;
	DatSetValue(str_Var,real_Val);

	DebugEnd;
END;{@}

{----------------------------------------------------------------------------}
PROCEDURE CreateNCFile{(int_Channel : INTEGER)};
{----------------------------------------------------------------------------}
VAR
	i,int_StrLen,int_PosUnder,int_ProgNb, int_Err
	: INTEGER;

	str_CreateName,str_Adr,str_FileName,str_Ext,str_BaseName,str_Channel,str_ProcName,str_Prognb
	: TC255;
BEGIN
	strcpy(str_ProcName,'CreateNCFile');
	DebugBegin(str_ProcName,CONST_NO);

	PCALL(READ_PART_isofile,str_Adr,str_FileName,str_Ext);
	STRINGRD(LIB_STR_NOM_FIC_ISO,str_FileName);
	int_Err := ICALL(SPI_FIL_remove_extension,str_Filename,str_Filename);
	{ int_ProgNb := INTRD(STD_INT_PROG_NUMBER);	 }
		
	{ str_itoa(str_Prognb,int_ProgNb);	 }
	{ strcpy(str_Filename,'T'); }
	{ IF (int_ProgNb < 10) THEN strcat(str_Filename,'000') }
	{ ELSE IF (int_ProgNb < 100) THEN strcat(str_Filename,'00') }
	{ ELSE IF (int_ProgNb < 1000) THEN strcat(str_Filename,'0'); }
	
	{ strcat(str_Filename,str_Prognb); }
	
	IF (int_Channel = 1) THEN Strcpy(str_Channel,' C1');
	IF (int_Channel = 2) THEN Strcpy(str_Channel,' C2');
	
	strcpy(str_CreateName,str_Adr);
	strcat(str_CreateName,str_Filename);
	strcat(str_Createname,str_Channel);
	strcat(str_CreateName,str_Ext);
	PCALL(OUTPUT_NC_cut_file_name,str_CreateName);
	


	DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE InitProgNumber{(VAR int_ProgNb:INTEGER)};
{----------------------------------------------------------------------------}
{
Initialisation of program number with function of channel
}
VAR
	int_ChannelNb :INTEGER;
	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'InitProgNumber');
	DebugBegin(str_ProcName,CONST_NO);

	PCALL(READ_PART_channel_no,int_ChannelNb);

	int_ProgNb := INTRD(STD_INT_PROG_NUMBER);
	IF int_ProgNb = 0 THEN int_ProgNb := 1;
	{We keep the same program number on the both channel}
	{ int_ProgNB := int_ProgNB - 1 + int_ChannelNb; }

	DebugEnd;
END;{@}

{XP}
{We use the InitProgNumber instead of modify OutputStartProgramNumber}
{----------------------------------------------------------------------------}
PROCEDURE OutputStartProgramNumber_CAMTeam;
{----------------------------------------------------------------------------}
VAR
	int_ProgNb,int_Channel
	:INTEGER;
	
	str_ProcName,str_PartName,str_PRG_NUMMER,str_1
	: TC255;
	
BEGIN
	strcpy(str_ProcName,'OutputStartProgramNumber');
	DebugBegin(str_ProcName,CONST_NO);

	PCALL(READ_PART_part_name,str_PartName);
	PCALL(READ_PART_channel_no,int_Channel);

	InitProgNumber(int_ProgNB);
		
	strcpy(str_1,'O');
	IF (int_ProgNb < 10) THEN strcat(str_1,'000')
	ELSE IF (int_ProgNb < 100) THEN strcat(str_1,'00')
	ELSE IF (int_ProgNb < 1000) THEN strcat(str_1,'0');
		
	IF int_Channel = 1 THEN
		BEGIN
		str_itoa(str_PRG_NUMMER,int_ProgNB); 
		END
	ELSE IF int_Channel = 2 THEN
		BEGIN
		str_itoa(str_PRG_NUMMER,(int_ProgNB-1)); 
		END;

	strcat(str_1,str_PRG_NUMMER);
	PCALL(OUTPUT_NC_tab_str,'SP',str_1,1);

	IF ((INTRD(STD_LIST_PARTNAME_COMMENT) = CONST_YES) AND (strlen(str_PartName) > 0)) THEN
		BEGIN
		PCALL(OUTPUT_NC_tab_str,'CO',str_PartName,CONST_YES); Punchb(2);
		END;

	DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE ParameterCustomerInit;
{----------------------------------------------------------------------------}
VAR
	str_Null,str_ProcName
	: TC255;
	
BEGIN
	strcpy(str_ProcName,'ParameterCustomerInit');
	DebugBegin(str_ProcName,CONST_NO);

	str_Null[0] := chr(0);

	INTWR(SPE_LIZENZ_VERSION_PRUEFEN,0);
	INTWR(SPE_GEWINDE_M329,0);		{Fuer Gewinde + G07.1 Flag}
	INTWR(SPE_REV1_STUFENBOHRER_1,0);
	INTWR(SPE_REV1_STUFENBOHRER_2,0);
	INTWR(SPE_REV2_STUFENBOHRER_1,0);
	INTWR(SPE_REV2_STUFENBOHRER_2,0);
	INTWR(SPE_REV1_MESSTASTER,0);
	INTWR(SPE_REV2_MESSTASTER,0);
	INTWR(SPE_OLD_WZ_LAENGE_OFFSET,0);
	INTWR(SPE_G8P1,0);  						{G8 P1 lesen}
	INTWR(SPE_M471,0);
	INTWR(SPE_C_KLEMMEN,0);
	INTWR(SPE_ABWICKLUNG_AKTIV,0);
	INTWR(SPE_WZ_WECHSEL_ERZWINGEN,0);{WZ-Wechsel erzwingen}
	INTWR(SPE_AKTUELLES_WERKZEUG,0);
	INTWR(SPE_FESTANSCHLAG,0);
	INTWR(SPE_INT_WZ_WECHSEL_TECHNO,0);
	INTWR(SPE_SPANNDRUCK,0);
	INTWR(SPE_INT_KANAL_WECHSEL,0);
	INTWR(SPE_AKTUELL_WZ_LAENGE_OFFSET,0);
	INTWR(SPE_INT_EBENEN_NR,0);

	DOUBLEWR(SPE_M471_WERT,0.0); 
	DOUBLEWR(SPE_SICHERHEITS_W_POS,0.0);
	DOUBLEWR(SPE_B_UEBERGABE_KORR,0.0);
	DOUBLEWR(SPE_REAL_ABSTECHBREITE,0.0);
	DOUBLEWR(SPE_REAL_WZ_WECHSEL_TECHNO,0.0);
	DOUBLEWR(SPE_REAL_RUECKZUG_Z,0.0);
	DOUBLEWR(SPE_REAL_REV1_Z_FREIFAHREN,0.0);
	DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE ParameterPPStore;
{----------------------------------------------------------------------------}
VAR
	str_ProcName 
	: TC255;
BEGIN
	strcpy(str_ProcName,'ParameterPPStore');
	DebugBegin(str_ProcName,CONST_NO);

	StoreGlobalString(LIB_STR_NOM_FIC_ISO);
	StoreGlobalString(SPE_PROGRAMM_ERSTELLER);
	StoreGlobalString(SPE_PROGRAMM_VERSION);
	
	StoreGlobalInteger(STD_INT_PROG_NUMBER);
	StoreGlobalInteger(SPE_FESTANSCHLAG);
	StoreGlobalInteger(SPE_REV1_MESSTASTER);
	StoreGlobalInteger(SPE_REV2_MESSTASTER);
	StoreGlobalInteger(SPE_INT_WZ_WECHSEL_TECHNO);
	StoreGlobalInteger(SPE_SPANNDRUCK);
	StoreGlobalInteger(SPE_INT_KANAL_WECHSEL);
	StoreGlobalInteger(SPE_AKTUELL_WZ_LAENGE_OFFSET);
	StoreGlobalInteger(SPE_AKTUELLES_WERKZEUG);
	StoreGlobalInteger(SPE_REV1_STUFENBOHRER_1);
	StoreGlobalInteger(SPE_REV1_STUFENBOHRER_2);
	StoreGlobalInteger(SPE_REV2_STUFENBOHRER_1);
	StoreGlobalInteger(SPE_REV2_STUFENBOHRER_2);
	StoreGlobalInteger(SPE_INT_EBENEN_NR);
	
	StoreGlobalList(LIB_LIST_COMMENTS);
	StoreGlobalList(STD_LIST_BLOCK_NUMBERS);
	StoreGlobalList(STD_LIST_CODE_END);
	
	StoreGlobalReal(SPE_ANSCHLAG_END_Z);		{Anschlag End Z-Wert}
	StoreGlobalReal(SPE_SICHERHEITS_W_POS);
	StoreGlobalReal(SPE_B_UEBERGABE_KORR);
	StoreGlobalReal(SPE_REAL_ABSTECHBREITE);
	StoreGlobalReal(SPE_M471_WERT);
	StoreGlobalReal(SPE_REAL_WZ_WECHSEL_TECHNO);
	StoreGlobalReal(SPE_REAL_RUECKZUG_Z);
	StoreGlobalReal(SPE_REAL_REV1_Z_FREIFAHREN);

	StoreGlobalList(SPE_LIST_DAT);

	DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE ParameterPP_{(int_Line,int_Column:INTEGER)};
{----------------------------------------------------------------------------}
VAR
	int_Line,int_Column:INTEGER;
	str_Message,str_FileName,str_ProcName,str_Leer
	:TC255;

BEGIN
	strcpy(str_ProcName,'ParameterPP');
	DebugBegin(str_ProcName,CONST_NO);

	Str_Message[0] := chr(0);
	strcpy(Str_Message,'Spezifische Parameter von der Firma RAU AG');
	{ ReadTxtPack(1,str_Message); }
	ParameterCreatePage(0,Str_Message);

	int_Column := int_Column - 0;
	
	ParameterCreateFrame(0,int_Line,1,18,52,str_Message);
	ParametercreateBitmapGO;  

	strcpy(str_Message,'Programmnummer');
	{ ReadTxtPack(2,str_Message); }
	ParameterCreateInteger(STD_INT_PROG_NUMBER,0,0,int_Line,20,str_Message);

	strcpy(str_Message,'Programm Ersteller');
	{ ReadTxtPack(3,str_Message); }
	ParameterCreateString(SPE_PROGRAMM_ERSTELLER,0,str_Leer,int_Line,20,int_Column,str_Message);

	strcpy(str_Message,'Programm Version');
	{ ReadTxtPack(4,str_Message); }
	ParameterCreateString(SPE_PROGRAMM_VERSION,0,str_Leer,int_Line,20,int_Column,str_Message);

	int_Line := int_Line + 1;
	int_Column := int_Column - 5;
	
	{ strcpy(str_Message,'REV-1 Messtaster T-Nr.='); }
	{ ParameterCreateInteger(SPE_REV1_MESSTASTER,-810,0303,int_Line,int_Column,str_Message); }
	
	{ strcpy(str_Message,'REV-2 Messtaster T-Nr.='); }
	{ ParameterCreateInteger(SPE_REV2_MESSTASTER,-810,0454,int_Line,int_Column,str_Message); }
	
	{ int_Line := int_Line + 1; }
	
	{ strcpy(str_Message,'REV-1 Stufenbohrer #1 T-Nr.='); }
	{ ParameterCreateInteger(SPE_REV1_STUFENBOHRER_1,-810,0151,int_Line,int_Column,str_Message); }
	
	{ int_Line := int_Line - 1; }
	int_Column := int_Column + 15;
	
	{ strcpy(str_Message,'#2 T-Nr.='); }
	{ ParameterCreateInteger(SPE_REV1_STUFENBOHRER_2,-810,1161,int_Line,int_Column,str_Message); }
	
	int_Column := int_Column - 15;
	
	{ strcpy(str_Message,'REV-2 Stufenbohrer #1 T-Nr.='); }
	{ ParameterCreateInteger(SPE_REV2_STUFENBOHRER_1,-810,0505,int_Line,int_Column,str_Message); }
	
	{ int_Line := int_Line - 1; }
	int_Column := int_Column + 15;
	
	{ strcpy(str_Message,'#2 T-Nr.='); }
	{ ParameterCreateInteger(SPE_REV2_STUFENBOHRER_2,-810,0707,int_Line,int_Column,str_Message); }
	
	{ int_Line := int_Line + 1; }
	{ int_Column := int_Column - 10; }

	{ strcpy(str_Message,'B-Achsen G0 Sicherheitsposition'); }
	{ ParameterCreateReal(SPE_SICHERHEITS_W_POS,-810,100,int_Line,int_Column,str_Message); }
	
	{ strcpy(str_Message,'B-Achsen G1 Uebergabe Korrektur'); }
	{ ParameterCreateReal(SPE_B_UEBERGABE_KORR,-810,100,int_Line,int_Column,str_Message); }

	{ int_Line := int_Line + 1; }

	{ strcpy(str_Message,'Festanschlag-Nein-Ja'); }
	{ ParameterCreateList(SPE_FESTANSCHLAG,0,0,int_Line,int_Column,str_Message); }

	{ strcpy(str_Message,'Spanndruck Festanschlag'); }
	{ ParameterCreateInteger(SPE_SPANNDRUCK,-810,30,int_Line,int_Column,str_Message); }

	int_Column := int_Column - 200;

	{strcpy(str_Message,'Comment Output-No-Yes');}
	ParameterCreateList(LIB_LIST_COMMENTS,1122,1,int_Line,int_Column,str_Message);

	{strcpy(str_Message,'Block Numbers-With-Without-Tool Change Only');}
	ParameterCreateList(STD_LIST_BLOCK_NUMBERS,1123,1,int_Line,int_Column,str_Message);

	{PCALL(READ_PART_file_name,str_FileName);}
	{strcpy(str_Message,'File Name');}
	ParameterCreateStringIgnore(LIB_STR_NOM_FIC_ISO,780,str_FileName,int_Line,-100,int_Column,str_Message);

	{strcpy(str_Message,'Code for program end-M30-M02-M99');}
	ParameterCreateList(STD_LIST_CODE_END,1124,0,int_Line,int_Column,str_Message);

	DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE TechnoFunctionTurn;
{----------------------------------------------------------------------------}
VAR
	int_Type,int_RotDir,int_Unit,int_Range,int_Zyklus_Nr,Int_Spindel_Pruefen
	: INTEGER ;
	
	real_Value,real_Speed,real_Bohren_Verweilzeit_Ende,real_Z_SicherheitsAbstand
	: REAL ;
	
	str_ProcName,str_Comment,str_Message,str_Rev_Z_Achse,str_Rev_X_Achse,str_1
	str_Z_SicherheitsAbstand,str_Bohren_Verweilzeit_Ende,str_Kommentar, str_Var
	: TC255;
	
	tr3_Pt
	: TR3;
	
BEGIN
	strcpy(str_ProcName,'TechnoFunctionTurn');
	DebugBegin(str_ProcName,CONST_NO);;


	PCALL(READ_PART_real_tec,REAL_TURN_DWELL_END,real_Bohren_Verweilzeit_Ende);
	{PCALL(lit_RTEC,RTT_DISTANCE_SECURITE_Z,real_Z_SicherheitsAbstand);}
	PCALL(READ_PART_SPINDLE_TYPE,Int_Spindel_Pruefen);		{HS oder GS Spindel}
	PCALL(READ_PATH_comment,str_Kommentar);
	PCALL(READ_PART_customer_type,int_Type);
	PCALL(READ_PART_customer_value,1,real_Value);
	PCALL(READ_PART_cycle_no,int_Zyklus_Nr);												{Zyklus Nummer}

	real_Z_SicherheitsAbstand := DOUBLERD(SPE_REAL_RUECKZUG_Z);			{Beim Bohren}

{
	writeln('----------int_Zyklus_Nr',int_Zyklus_Nr);
	writeln('----------real_Value',real_Value);
}
		
	IF (INTRD(LIB_LIST_COMMENTS) = CONST_YES) THEN
		BEGIN
		IF ((int_Type <> CONST_FCT_PPWORD) AND (int_Type <> CONST_FCT_OPION_ON)) THEN PCALL(OUTPUT_NC_write_com,0,str_Comment,CONST_YES);
		END;

	CASE int_Type OF
		CONST_FCT_STOP : BEGIN
			IF (TRUNC(real_Value) = 0) THEN PCALL(OUTPUT_NC_M,00,CONST_YES)
			ELSE IF (TRUNC(real_Value) = 1) THEN PCALL(OUTPUT_NC_M,01,CONST_YES);
			writeb;
		END;

		CONST_FCT_FEEDER : {Stangenlader aktivieren}
			BEGIN

			END;

		CONST_FCT_COLLECTOR : {Abstechen mit Fangschale und Vorschub reduktion Ein}
			BEGIN
			PCALL(bcnTAB_STR,'SP','M68 (TEILEFAENGER EIN)',1); Punchb(2);

			END;
			
		CONST_FCT_DWELL_REVOLUTION : {Abstechen mit Fangschale und Vorschub reduktion Aus}
			BEGIN
			PCALL(bcnTAB_STR,'SP','M69 (TEILEFAENGER AUS)',1); Punchb(2);
			END;

		CONST_FCT_TAILSTOCK_APP : {Reitstock Anfahren}
			BEGIN
			PCALL(bcnTAB_STR,'SP',' ',1); Punchb(2);
			PCALL(bcnTAB_STR,'SP','N200 (REITSTOCK ANSTELLEN)',1); Punchb(2);
			END;
			
		CONST_FCT_TAILSTOCK_RET : {Reitstock Zurueckfahren}
			BEGIN
			PCALL(bcnTAB_STR,'SP',' ',1); Punchb(2);
			PCALL(bcnTAB_STR,'SP','N300 (REITSTOCK ZURUECK)',1); Punchb(2);
			END;

		CONST_FCT_DWELL : 
			BEGIN	
			{ IF (int_Zyklus_Nr = 11) AND (real_Value < 0.5) THEN					{Wert kleiner als 0.5 dann F + G1 Z} }
				{ BEGIN }
				{ IF Int_Spindel_Pruefen = CONST_MAIN_SPINDLE THEN 					{HS Bearbeitungen} }
					{ BEGIN }
					{ strcat(str_1,'G1 Z'); }
					{ ConcatStrVal(str_Z_SicherheitsAbstand,str_Z_SicherheitsAbstand,real_Z_SicherheitsAbstand,3); }
					{ strcat(str_1,str_Z_SicherheitsAbstand); }
					{ END }
				{ ELSE IF Int_Spindel_Pruefen = CONST_REWORK_SPINDLE THEN 	{GS Bearbeitungen} }
					{ BEGIN }
					{ strcat(str_1,'G1 Z'); }
					{ ConcatStrVal(str_Z_SicherheitsAbstand,str_Z_SicherheitsAbstand,-real_Z_SicherheitsAbstand,3); }
					{ strcat(str_1,str_Z_SicherheitsAbstand); }
					{ END; }
				
				{ strcat(str_1,' F'); }
				{ ConcatStrVal(str_Bohren_Verweilzeit_Ende,str_Bohren_Verweilzeit_Ende,real_Bohren_Verweilzeit_Ende,3); }
				{ strcat(str_1,str_Bohren_Verweilzeit_Ende); }
				{ PCALL(OUTPUT_NC_tab_str,'SP',str_1,1); Punchb(2); }
				{ END }
			{ ELSE  }
			OutputDwell(real_Value);				{Sonst Verweilzeit schreiben}
				
			END;

		CONST_FCT_ROTATION_INVERT : BEGIN
			writeb;
			PCALL(READ_NC_rotation,int_RotDir);
			PCALL(READ_NC_spindle,real_Speed,int_Unit,int_Range);
			IF (int_RotDir = CONST_CW) THEN int_RotDir := CONST_CCW
				ELSE int_RotDir := CONST_CW;
			OutputNCRotation(CONST_BREAK);
			writeb;

			PCALL(WRITE_NC_init_spindle);
			OutputNCSpindle(real_Speed,int_Unit,int_Range);
			OutputNCRotation(int_RotDir);
			writeb;
		END;

		CONST_FCT_SPEED : BEGIN
			PCALL(READ_PART_spindle,real_Speed,int_Unit,int_Range);
			OutputNCSpindle(real_Value,int_Unit,int_Range);
			writeb;
		END;

		CONST_FCT_COOLANT : BEGIN
			PCALL(OUTPUT_NC_coolant, ROUND(real_Value));
			writeb;
		END;

		DPP_INDEX_TURRET : BEGIN						{WZ-Wechsel ueber TechnoFunktionen}
			DOUBLEWR(SPE_REAL_WZ_WECHSEL_TECHNO,real_Value);
		END;

		DPP_CP_AMENEE : BEGIN
			{ WriteBlock(LIB_AVCE_FOUR1); }
			{ WriteBlock(LIB_AVCE_FOUR2); }
		END;

		DPP_CP_RETRAIT : BEGIN
			{ WriteBlock(LIB_RETR_FOUR1); }
			{ WriteBlock(LIB_RETR_FOUR2); }
		END;

		CONST_FCT_REST_OFF : BEGIN
			{ WriteBlock(LIB_OUV_LUNET1); }
			{ WriteBlock(LIB_OUV_LUNET2); }
		END;

		CONST_FCT_REST_ON : BEGIN
			{ WriteBlock(LIB_FERM_LUNET1); }
			{ WriteBlock(LIB_FERM_LUNET2); }
		END;

		CONST_FCT_FEEDER : BEGIN
			strcpy(str_Message,'Feeder not treated');
			MessageWarning(216,str_Message);
		END;
		CONST_FCT_OPION_ON : PCALL(WRITE_NC_block_optional,CONST_YES);

		CONST_FCT_OPTION_OFF : PCALL(WRITE_NC_block_optional,CONST_NO);

		CONST_FCT_PPWORD : BEGIN
		
		IF (str_pos('WZ Wechsel erzwingen',str_Kommentar,0) > -1) THEN
			BEGIN	 	     		 	     	
			INTWR(SPE_WZ_WECHSEL_ERZWINGEN,1);  		{WZ-Wechsel erzwingen}   
			END;
		
		IF (str_pos('M471',str_Kommentar,0) > -1) THEN
			BEGIN	 	     		 	     	
			INTWR(SPE_M471,1);
			DOUBLEWR(SPE_M471_WERT,real_Value);       
			END;	
			
		IF (str_pos('REV1_Z-Freifahren',str_Kommentar,0) > -1) THEN
			BEGIN	 	     		 	     	
			DOUBLEWR(SPE_REAL_REV1_Z_FREIFAHREN,real_Value);       
			END;	
			
			
		IF (str_pos('G8 P1',str_Kommentar,0) > -1) THEN
			BEGIN	 	     		 	     	
			INTWR(SPE_G8P1,1);      
			END;	
			
		IF (str_pos('C_KLEMMEN',str_Kommentar,0) > -1) THEN
			BEGIN	 	     		 	     	
			INTWR(SPE_C_KLEMMEN,1);      
			END;

		END;
		
		CONST_PARKING : BEGIN
			{ MTETreatment(5,CONST_NO); }

		END;
		CONST_CHUCK_PART_OFF : BEGIN
			strcpy(str_Var,'$REWORK_PART_CATCHER');
			DatSetValue(str_Var,real_Value);
		END;
	END;

	DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE InitPlaneKey;
{----------------------------------------------------------------------------}
VAR
	int_ChannelNo,int_TurnCycle,Int_Spindel_Pruefen,int_EBENEN_NR
	: INTEGER;
	
	str_ProcName 
	: TC255;
	
BEGIN
	strcpy(str_ProcName,'InitPlaneKey');
	DebugBegin(str_ProcName,CONST_NO);

	PCALL(READ_PART_channel_no,int_ChannelNo);
	PCALL(READ_PART_SPINDLE_TYPE,Int_Spindel_Pruefen);		{HS oder GS Spindel}

	int_EBENEN_NR 	:= INTRD(SPE_INT_EBENEN_NR);	
	
	PCALL(WRITE_DPP_boolean,GPP_BOOLEAN_PLANE_OFFSET_DIRECTION,CONST_DIRECT);
	CASE int_ChannelNo OF											{Kanal 1 Revolver Oben}
		1 : BEGIN
				IF Int_Spindel_Pruefen = CONST_MAIN_SPINDLE THEN 		{Hauptspindel}
				BEGIN
					PCALL(WRITE_DPP_KEY_UNIT,'C',1.0);
					PCALL(WRITE_DPP_KEY_UNIT,'C_CART',1.0);
					PCALL(WRITE_DPP_KEY_UNIT,'R',1.0);
					PCALL(WRITE_DPP_KEY_UNIT,'X',1.0);
					PCALL(WRITE_DPP_KEY_UNIT,'Y',1.0); {Y is in diameter by default in turning}
					PCALL(WRITE_DPP_KEY_UNIT,'Z',1.0);
					PCALL(WRITE_DPP_KEY_UNIT,'I',1.0); 
					PCALL(WRITE_DPP_KEY_UNIT,'J',1.0);
					PCALL(WRITE_DPP_KEY_UNIT,'K',1.0);
					PCALL(WRITE_DPP_KEY_UNIT,'X_LATHE',2.0);
					PCALL(WRITE_DPP_boolean,GPP_BOOLEAN_PLANE_ARC_DIRECTION,CONST_DIRECT);
				END
				ELSE IF Int_Spindel_Pruefen = CONST_REWORK_SPINDLE THEN {Gegenspindel}
				BEGIN
					PCALL(WRITE_DPP_KEY_UNIT,'C',-1.0);
					PCALL(WRITE_DPP_KEY_UNIT,'C_CART',-1.0);
					PCALL(WRITE_DPP_KEY_UNIT,'R',1.0);
					PCALL(WRITE_DPP_KEY_UNIT,'X',1.0);
					PCALL(WRITE_DPP_KEY_UNIT,'Y',-1.0); {Y is in diameter by default in turning}
					PCALL(WRITE_DPP_KEY_UNIT,'Z',-1.0);
					PCALL(WRITE_DPP_KEY_UNIT,'I',1.0); 
					PCALL(WRITE_DPP_KEY_UNIT,'J',1.0);
					PCALL(WRITE_DPP_KEY_UNIT,'K',1.0);
					PCALL(WRITE_DPP_KEY_UNIT,'X_LATHE',2.0);
					PCALL(WRITE_DPP_boolean,GPP_BOOLEAN_PLANE_ARC_DIRECTION,CONST_DIRECT);
					IF IsAxialPlane THEN
					BEGIN
						
						PCALL(WRITE_DPP_boolean,GPP_BOOLEAN_PLANE_ARC_DIRECTION,CONST_INVERTED);
						PCALL(WRITE_DPP_boolean,GPP_BOOLEAN_PLANE_OFFSET_DIRECTION,CONST_INVERTED);
					END;
				END;
			END;
				
		2 : BEGIN																	{Kanal 2 Revolver Unten}
				IF Int_Spindel_Pruefen = CONST_MAIN_SPINDLE THEN 			{Hauptspindel}
				BEGIN
					PCALL(WRITE_DPP_KEY_UNIT,'C',1.0);
					PCALL(WRITE_DPP_KEY_UNIT,'C_CART',1.0);
					PCALL(WRITE_DPP_KEY_UNIT,'R',1.0);
					PCALL(WRITE_DPP_KEY_UNIT,'X',1.0);
					PCALL(WRITE_DPP_KEY_UNIT,'Y',1.0); {Y is in diameter by default in turning}
					PCALL(WRITE_DPP_KEY_UNIT,'Z',1.0);
					PCALL(WRITE_DPP_KEY_UNIT,'I',1.0); 
					PCALL(WRITE_DPP_KEY_UNIT,'J',1.0);
					PCALL(WRITE_DPP_KEY_UNIT,'K',1.0);
					PCALL(WRITE_DPP_KEY_UNIT,'X_LATHE',2.0);
					PCALL(WRITE_DPP_boolean,GPP_BOOLEAN_PLANE_ARC_DIRECTION,CONST_DIRECT);
				END
				ELSE IF Int_Spindel_Pruefen = CONST_REWORK_SPINDLE THEN {Gegenspindel}
				BEGIN
					PCALL(WRITE_DPP_KEY_UNIT,'C',-1.0);
					PCALL(WRITE_DPP_KEY_UNIT,'C_CART',-1.0);
					PCALL(WRITE_DPP_KEY_UNIT,'R',1.0);
					PCALL(WRITE_DPP_KEY_UNIT,'X',1.0);
					PCALL(WRITE_DPP_KEY_UNIT,'Y',-1.0); {Y is in diameter by default in turning}
					PCALL(WRITE_DPP_KEY_UNIT,'Z',-1.0);
					PCALL(WRITE_DPP_KEY_UNIT,'I',1.0); 
					PCALL(WRITE_DPP_KEY_UNIT,'J',1.0);
					PCALL(WRITE_DPP_KEY_UNIT,'K',1.0);
					PCALL(WRITE_DPP_KEY_UNIT,'X_LATHE',2.0);
					PCALL(WRITE_DPP_boolean,GPP_BOOLEAN_PLANE_ARC_DIRECTION,CONST_DIRECT);
					
					IF IsAxialPlane THEN
					BEGIN
						
						PCALL(WRITE_DPP_boolean,GPP_BOOLEAN_PLANE_ARC_DIRECTION,CONST_INVERTED);
						PCALL(WRITE_DPP_boolean,GPP_BOOLEAN_PLANE_OFFSET_DIRECTION,CONST_INVERTED);
					END;
					
				END;
				{2023-02-16 XP}
				{invert X and C coordinates for axial interpo plane for rework spindle and channel 2}
				{ IF IsAxialInterpoPlane AND (int_Spindel_pruefen = CONST_REWORK_SPINDLE) and IsChannel(2) THEN }
				{ BEGIN }
					{ PCALL(WRITE_DPP_boolean,GPP_BOOLEAN_PLANE_AXIS_1_DIRECTION,CONST_INVERTED); }
					{ PCALL(WRITE_DPP_boolean,GPP_BOOLEAN_PLANE_AXIS_2_DIRECTION,CONST_INVERTED); }
				{ END; }
				
				{
				IF int_TurnCycle = 1 THEN PCALL(WRITE_DPP_boolean,GPP_BOOLEAN_PLANE_ARC_DIRECTION,CONST_INVERTED)	{G2/G3 beim Drehen getauscht}
				 ELSE PCALL(WRITE_DPP_boolean,GPP_BOOLEAN_PLANE_ARC_DIRECTION,CONST_DIRECT);
				 }
				END;
	END;
	
	{
	writeln('-------------int_EBENEN_NR',int_EBENEN_NR);
	}
	
	DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE InitMillingPlane{(VAR int_NumPlane:INTEGER)};
{----------------------------------------------------------------------------}
VAR
	int_ToolType, int_IsHoleCycle, int_No_Y,int_SpindleType,int_NumPlaneLu
	: INTEGER;
	
	real_Angle1, real_Angle2, real_Angle3 
	: REAL;

	str_ProcName 
	: TC255;
	
BEGIN
	strcpy(str_ProcName,'InitMillingPlane');
	DebugBegin(str_ProcName,CONST_NO);

	PCALL(READ_PART_tool_position,int_ToolType);

	PCALL(READ_PART_boolean_tec,BOOLEAN_CYC_POLAR_CYCLE,int_No_Y);
	PCALL(READ_PART_spindle_type, int_SpindleType);

	CASE int_ToolType OF
		CONST_Z_PLUS, CONST_Z_MINUS_LT : BEGIN {Axial plane}
			PCALL(READ_PART_secondary,real_Angle2);
			int_IsHoleCycle := ICALL(TEST_HOLE_CYCLE);

			IF int_IsHoleCycle = CONST_YES THEN
				BEGIN
				IF (int_No_Y = CONST_NO) THEN int_NumPlane := 121 {Axial Cartesian}
					ELSE int_NumPlane := 120;{Axial polar}
				END
			ELSE
				BEGIN
				IF (int_No_Y = CONST_NO) THEN int_NumPlane := 121 {Axial Cartesian}
					ELSE int_NumPlane := 122;{Axial interpolation}
				END;
				
			IF NOT IsNull(real_Angle2) THEN
				BEGIN
				int_NumPlane :=126;
				END;
		END;

		CONST_X_PLUS_LT : BEGIN {Radial plane}
			PCALL(READ_PART_secondary,real_Angle2);
			PCALL(READ_PART_boolean_tec,BOOLEAN_MAC_Y_AXIS,int_No_Y);
			int_NumPlane := 123;												{HS Radial Fraesen = 123}
																									{GS Radial Fraesen = 143}
			IF (int_No_Y = CONST_NO) THEN
				BEGIN
				int_NumPlane := 124;
				PCALL(WRITE_NC_cancel_paxis2,CONST_YES);
				END;
				
			IF not IsNull(real_Angle2) THEN int_NumPlane := 126; 
			INTWR(LIB_INT_MULTAX,0);
		END;

		CONST_B_INCLINED : BEGIN {Positionned plane}
			PCALL(READ_PART_secondary,real_Angle2);
			int_NumPlane := 126;
			IF IsNull(real_Angle2) THEN {inclined tool}
				BEGIN
				int_NumPlane := 125;											{HS Radial Bohren = 125}
				END;																			{GS Radial Bohren = 145}
			END;
		END;

	IF (int_SpindleType = CONST_REWORK_SPINDLE) THEN
		BEGIN
		int_NumPlane := int_NumPlane + 20;
		END;

	INTWR(SPE_INT_EBENEN_NR,int_NumPlane); 

{
	writeln('-------------int_EBENEN_NR',int_EBENEN_NR);
}

	DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE Stangenanfang_Abstechen_Kanal_2;
{----------------------------------------------------------------------------}
VAR
	Int_WZ_Abstech_NR,int_TypeCycle,int_NbCycle,i,int_Range,int_BUnit_G96_G97
	: INTEGER;
	
	real_Speed,Real_G96_G97,real_Max_Drehzahl,real_Teilelaenge,Real_Rohteil_D
	Real_Abstecher_Durchstechen,real_Abstech_laenge,real_GS_Planaufmass
	real_WZ_Abstech_Breite,real_Abstecher_Vorschub
	:REAL;
	
	str_ProcName,str_1,str_WZ_Abstech_NR,str_VC_G96_Abstecher,str_Drehzahl,str_Max_Drehzahl
	str_Rohteil,str_Abstecher_Durchstechen,str_Abstecher_Vorschub, str_Out
	: TC255;

BEGIN
  strcpy(str_ProcName,'Kopf_Beschreibung');
  DebugBegin(str_ProcName,CONST_NO);
		
	PCALL(READ_PART_cycle_nb,int_NbCycle);																	{Zyklus Nummer}
	PCALL(READ_DPP_integer,INTEGER_PARTING_TOOL_NUMBER,Int_WZ_Abstech_NR);	{Abstecher T Nummer}
	PCALL(litLG_PIECE,real_Teilelaenge); 																		{Teilenlaenge}
	PCALL(litDIA_BRUT,Real_Rohteil_D);   																		{Rohteil Durchmesser}
	PCALL(READ_DPP_real,REAL_PARTING_X_AT_END,Real_Abstecher_Durchstechen);	{Abstecher Ueberlappung}
	
	PCALL(bcnTAB_STR,'SP','(STANGENANFANG ABSTECHEN)',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G28 U0. W0.',1); Punchb(2);
	{ PCALL(bcnTAB_STR,'SP','M87',1); Punchb(2); }
	STRINGRD(LIB_STR_UNCLAMP_MS,str_Out);
	PCALL(bcnTAB_STR,'SP',str_Out,1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M41',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M370',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G0 G18 G40 G80 G99 G113',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M8',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M471',1); Punchb(2);
		
	FOR i:=1 TO int_NbCycle DO
		BEGIN
		PCALL(UTIL_cycle_load,i);
		PCALL(READ_PART_cycle_no,int_TypeCycle);

		IF int_TypeCycle = CONST_PARTING THEN
			BEGIN
			
			IF Int_WZ_Abstech_NR < 10 THEN strcat(str_1,'G54 T0')
				ELSE strcat(str_1,'G54 T');
			str_itoa(str_WZ_Abstech_NR,(100 * Int_WZ_Abstech_NR + Int_WZ_Abstech_NR)); 
			strcat(str_1,str_WZ_Abstech_NR);															{ABSTECHER STATION}
			strcat(str_1,' (ABSTECHSTAHL)');
			PCALL(OUTPUT_NC_tab_str,'SP',str_1,1); Punchb(2);
			str_1[0] := chr(0);
			
			PCALL(READ_PART_smax,real_Max_Drehzahl);
			PCALL(READ_PART_spindle,real_Speed,int_BUnit_G96_G97,int_Range);
			IF int_BUnit_G96_G97 = CONST_SMM THEN Real_G96_G97 := 96
				ELSE Real_G96_G97 := 97;
			
			IF Real_G96_G97 = 96 THEN
				BEGIN
				strcat(str_1,'G50 S');
				str_ftoa(str_Max_Drehzahl,real_Max_Drehzahl,1,0); 				{DREHZAHLBEGRENZUNG=G50}
				strcat(str_1,str_Max_Drehzahl);
				PCALL(OUTPUT_NC_tab_str,'SP',str_1,1); Punchb(2);
				str_1[0] := chr(0);
				END;
			
			strcat(str_1,'G');
			str_ftoa(str_VC_G96_Abstecher,Real_G96_G97,1,0); 							{G96 oder G97}
			strcat(str_1,str_VC_G96_Abstecher);
			strcat(str_1,' S');
			str_ftoa(str_Drehzahl,real_Speed,1,0); 												{Abstech Drehzahl}
			strcat(str_1,str_Drehzahl);
			strcat(str_1,' M3');
			
			PCALL(OUTPUT_NC_tab_str,'SP',str_1,1); Punchb(2);
			str_1[0] := chr(0);
			
			PCALL(lit_RTEC,RTT_SUREPAISSEUR_Z,real_GS_Planaufmass);			  {Abstech Aufmass}		
			PCALL(lit_RTEC,RO_LARGEUR,real_WZ_Abstech_Breite);						{Abstecher Breite}
			
			DOUBLEWR(SPE_REAL_ABSTECHBREITE,real_WZ_Abstech_Breite); 			{Wert speichern fuer Anschlag}
			
			real_Abstech_laenge 				:= (real_Teilelaenge + real_WZ_Abstech_Breite);
			
			PCALL(bcnG,0,1);
			PCALL(OUTPUT_NC_tab,'Z',real_Abstech_laenge,1);
			PCALL(bcnTAB_STR,'SP','(ABSTECH+TEILELAENGE)',1); Punchb(2);
			
			strcat(str_1,'G0 Y0 X');
			ConcatStrVal(str_Rohteil,str_Rohteil,Real_Rohteil_D+1,3);				{Durchmesser Rohteil}
			strcat(str_1,str_Rohteil);
			strcat(str_1,' (STANGENDURCHMESSER + 1MM)');
			PCALL(OUTPUT_NC_tab_str,'SP',str_1,1); Punchb(2);
			str_1[0] := chr(0);
			
			PCALL(lit_RTEC,RTT_AVANCE_X,real_Abstecher_Vorschub);					{Erster X Vorschub}
			
			strcat(str_1,'G1 G99 X-1 F');
			ConcatStrVal(str_Abstecher_Vorschub,str_Abstecher_Vorschub,real_Abstecher_Vorschub,3);
			strcat(str_1,str_Abstecher_Vorschub); 												{VORSCHUB=F}
			PCALL(OUTPUT_NC_tab_str,'SP',str_1,1); Punchb(2);
			str_1[0] := chr(0);
		END;
	END;

	PCALL(bcnTAB_STR,'SP','G0 W0.5 M9',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G28 U0. W0. V0.',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M470',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M1',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP',' ',1); Punchb(2);
	
	DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE Programmkopf_Kanal_1;
{----------------------------------------------------------------------------}
VAR	
	Int_Stufenbohrer_1,Int_Stufenbohrer_2,Int_Spanndruck,Int_Messtaster
	: INTEGER;

	str_ProcName,str_1,str_Stufenbohrer_1,str_Stufenbohrer_2,str_Messtaster
	str_Message, str_Init: TC255;

BEGIN
	strcpy(str_ProcName,'Programmkopf_Kanal_1');
	DebugBegin(str_ProcName,CONST_NO);

	Int_Stufenbohrer_1	:= INTRD(SPE_REV1_STUFENBOHRER_1);
	Int_Stufenbohrer_2	:= INTRD(SPE_REV1_STUFENBOHRER_2);
	Int_Messtaster			:= INTRD(SPE_REV1_MESSTASTER);

	ReadTxtPack(7,str_Message);
	PCALL(bcnTAB_STR,'CO',str_Message,1); Punchb(2);

	PCALL(bcnTAB_STR,'SP',' ',1); Punchb(2);
	STRINGRD(LIB_STR_DISABLE_C_AXIS_MS,str_Init);
	PCALL(bcnTAB_STR,'SP',str_Init,1); Punchb(2);
	
	strcpy(str_Init,'M87');
	ReadTxtPack(9,str_Message);
	PCALL(bcnTAB_STR,'SP',str_Init,1);
	PCALL(OUTPUT_NC_tab_str,'CO',str_Message,CONST_YES);
	Punchb(2);
	PCALL(bcnTAB_STR,'SP','G28 U0. V0.',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G28 W0.',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G333',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M1',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP',' ',1); Punchb(2);

	
  DebugEnd;
END;




{----------------------------------------------------------------------------}
PROCEDURE Programmkopf_Kanal_2;
{----------------------------------------------------------------------------}
VAR	
	Int_Stufenbohrer_1,Int_Stufenbohrer_2,Int_Spanndruck,Int_Messtaster
	: INTEGER;

	str_ProcName,str_1,str_Stufenbohrer_1,str_Stufenbohrer_2,str_Messtaster
	str_Init, str_Message: TC255;

BEGIN
	strcpy(str_ProcName,'Programmkopf_Kanal_2');
	DebugBegin(str_ProcName,CONST_NO);

	Int_Stufenbohrer_1	:= INTRD(SPE_REV2_STUFENBOHRER_1);
	Int_Stufenbohrer_2	:= INTRD(SPE_REV2_STUFENBOHRER_2);
	Int_Messtaster			:= INTRD(SPE_REV2_MESSTASTER);


	ReadTxtPack(8,str_Message);
	PCALL(bcnTAB_STR,'CO',str_Message,1); Punchb(2);
	PCALL(bcnTAB_STR,'SP',' ',1); Punchb(2);
	STRINGRD(LIB_STR_DISABLE_C_AXIS_MS,str_Init);
	PCALL(bcnTAB_STR,'SP',str_Init,1); Punchb(2);
	
	ReadTxtPack(9,str_Message);
	PCALL(bcnTAB_STR,'SP','M87',1);
	PCALL(OUTPUT_NC_tab_str,'CO',str_Message,CONST_YES); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G28 U0. V0. W0. B0.',1); Punchb(2);
	
	strcpy(str_Init,'M370');
	ReadTxtPack(10,str_Message);
	PCALL(bcnTAB_STR,'SP',str_Init,1);
	PCALL(OUTPUT_NC_tab_str,'CO',str_Message,CONST_YES); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G333',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M1',1); Punchb(2);
	

  DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE Werkzeugnummer_Offset_Berechnung;
{----------------------------------------------------------------------------}
VAR
	int_ToolNb,int_ToolLengthOffset,int_ToolDiaOffset,int_Post,int_Index,int_Spindel_pruefen
	: INTEGER;
	int_Turret, int_Dec, int_DecToolNo, int_MultiSupport : INTEGER;
	str_ProcName , str_Name
	: TC255;
	
BEGIN
	strcpy(str_ProcName,'Werkzeugnummer_Offset_Berechnung');
	DebugBegin(str_ProcName,CONST_NO);
	
	PCALL(READ_PART_tool,int_ToolNb,int_ToolLengthOffset,int_ToolDiaOffset);
	PCALL(READ_PART_tool_post_index,int_Post,int_Index);
	{2022-07-18 we use READ_PART_MTE_tool_trihedral to be sure to have the number of last triedrial support}
	PCALL(READ_PART_MTE_tool_trihedral,str_Name,int_MultiSupport,int_Index);
	{ writeln('              index : ', int_Index); }
	PCALL(READ_PART_SPINDLE_TYPE,int_Spindel_pruefen);

{CAM team initial treatment}
	IF (int_Spindel_pruefen = CONST_MAIN_SPINDLE)	THEN			{Hauptspindel}
		BEGIN
		IF int_ToolNb = int_ToolLengthOffset THEN							{nur bei WZ = Korrektur berechnen}
			BEGIN
			CASE int_ToolNb OF																	{Korrektur berechnen}
				1 : BEGIN
						IF int_Index = 2 THEN int_ToolLengthOffset := int_ToolLengthOffset + 12;
						IF int_Index = 22 THEN int_ToolLengthOffset := 22;	{Beim Anschlag Korrektur = 22}				
						END;
			
				2 : BEGIN
						IF int_Index = 2 THEN int_ToolLengthOffset := int_ToolLengthOffset + 12; 
						IF int_Index = 22 THEN int_ToolLengthOffset := 22; 
						END;
						
				3 : BEGIN
						IF int_Index = 2 THEN int_ToolLengthOffset := int_ToolLengthOffset + 12;
						IF int_Index = 22 THEN int_ToolLengthOffset := 22; 
						END;
						
				4 : BEGIN
						IF int_Index = 2 THEN int_ToolLengthOffset := int_ToolLengthOffset + 12; 
						IF int_Index = 22 THEN int_ToolLengthOffset := 22; 
						END;
						
				5 : BEGIN
						IF int_Index = 2 THEN int_ToolLengthOffset := int_ToolLengthOffset + 12; 
						IF int_Index = 22 THEN int_ToolLengthOffset := 22; 
						END;
						
				6 : BEGIN
						IF int_Index = 2 THEN int_ToolLengthOffset := int_ToolLengthOffset + 12; 
						IF int_Index = 22 THEN int_ToolLengthOffset := 22; 
						END;
			
				7 : BEGIN
						IF int_Index = 2 THEN int_ToolLengthOffset := int_ToolLengthOffset + 12; 
						IF int_Index = 22 THEN int_ToolLengthOffset := 22; 
						END;
			
				8 : BEGIN
						IF int_Index = 2 THEN int_ToolLengthOffset := int_ToolLengthOffset + 12; 
						IF int_Index = 22 THEN int_ToolLengthOffset := 22; 
						END;
						
				9 : BEGIN
						IF int_Index = 2 THEN int_ToolLengthOffset := int_ToolLengthOffset + 12; 
						IF int_Index = 22 THEN int_ToolLengthOffset := 22; 
						END;
						
			 10 : BEGIN
						IF int_Index = 2 THEN int_ToolLengthOffset := int_ToolLengthOffset + 12; 
						IF int_Index = 22 THEN int_ToolLengthOffset := 22; 
						END;
						
			 11 : BEGIN
						IF int_Index = 2 THEN int_ToolLengthOffset := int_ToolLengthOffset + 12; 
						IF int_Index = 22 THEN int_ToolLengthOffset := 22; 
						END;
						
			 12 : BEGIN
						IF int_Index = 2 THEN int_ToolLengthOffset := int_ToolLengthOffset + 12; 
						IF int_Index = 22 THEN int_ToolLengthOffset := 22; 
						END;
				END;
			END;
	
			CASE int_ToolNb OF																	{WZ-Nummer berechnen}
				1 : BEGIN
						IF int_Index = 2 THEN int_ToolNb := int_ToolNb + 12; 
						END;
						
				2 : BEGIN
						IF int_Index = 2 THEN int_ToolNb := int_ToolNb + 12; 
						END;
						
				3 : BEGIN
						IF int_Index = 2 THEN int_ToolNb := int_ToolNb + 12; 
						END;
						
				4 : BEGIN
						IF int_Index = 2 THEN int_ToolNb := int_ToolNb + 12; 
						END;
						
				5 : BEGIN
						IF int_Index = 2 THEN int_ToolNb := int_ToolNb + 12; 
						END;
						
				6 : BEGIN
						IF int_Index = 2 THEN int_ToolNb := int_ToolNb + 12; 
						END;
						
				7 : BEGIN
						IF int_Index = 2 THEN int_ToolNb := int_ToolNb + 12; 
						END;
						
				8 : BEGIN
						IF int_Index = 2 THEN int_ToolNb := int_ToolNb + 12; 
						END;
						
				9 : BEGIN
						IF int_Index = 2 THEN int_ToolNb := int_ToolNb + 12; 
						END;
						
			 10 : BEGIN
						IF int_Index = 2 THEN int_ToolNb := int_ToolNb + 12; 
						END;
						
			 11 : BEGIN
						IF int_Index = 2 THEN int_ToolNb := int_ToolNb + 12; 
						END;
						
			 12 : BEGIN
						IF int_Index = 2 THEN int_ToolNb := int_ToolNb + 12; 
						END;
				END;
		END
	ELSE IF (int_Spindel_pruefen = CONST_REWORK_SPINDLE) THEN	{Gegenspindel}
		BEGIN
			CASE int_ToolNb OF																	{Korrektur berechnen}
				1 : BEGIN
						IF int_Index <> 4 THEN int_ToolLengthOffset := int_ToolLengthOffset + 50; 
						IF int_Index = 4 THEN int_ToolLengthOffset := int_ToolLengthOffset + 62; 
						END;
			
				2 : BEGIN
						IF int_Index <> 4 THEN int_ToolLengthOffset := int_ToolLengthOffset + 50; 
						IF int_Index = 4 THEN int_ToolLengthOffset := int_ToolLengthOffset + 62; 
						END;
						
				3 : BEGIN
						IF int_Index <> 4 THEN int_ToolLengthOffset := int_ToolLengthOffset + 50;
						IF int_Index = 4 THEN int_ToolLengthOffset := int_ToolLengthOffset + 62; 
						END;
						
				4 : BEGIN
						IF int_Index <> 4 THEN int_ToolLengthOffset := int_ToolLengthOffset + 50;
						IF int_Index = 4 THEN int_ToolLengthOffset := int_ToolLengthOffset + 62; 
						END;
						
				5 : BEGIN
						IF int_Index <> 4 THEN int_ToolLengthOffset := int_ToolLengthOffset + 50;
						IF int_Index = 4 THEN int_ToolLengthOffset := int_ToolLengthOffset + 62; 
						END;
						
				6 : BEGIN
						IF int_Index <> 4 THEN int_ToolLengthOffset := int_ToolLengthOffset + 50;
						IF int_Index = 4 THEN int_ToolLengthOffset := int_ToolLengthOffset + 62; 
						END;
			
				7 : BEGIN
						IF int_Index <> 4 THEN int_ToolLengthOffset := int_ToolLengthOffset + 50;
						IF int_Index = 4 THEN int_ToolLengthOffset := int_ToolLengthOffset + 62; 
						END;
			
				8 : BEGIN
						IF int_Index <> 4 THEN int_ToolLengthOffset := int_ToolLengthOffset + 50;
						IF int_Index = 4 THEN int_ToolLengthOffset := int_ToolLengthOffset + 62; 
						END;
						
				9 : BEGIN
						IF int_Index <> 4 THEN int_ToolLengthOffset := int_ToolLengthOffset + 50;
						IF int_Index = 4 THEN int_ToolLengthOffset := int_ToolLengthOffset + 62; 
						END;
						
			 10 : BEGIN
						IF int_Index <> 4 THEN int_ToolLengthOffset := int_ToolLengthOffset + 50;
						IF int_Index = 4 THEN int_ToolLengthOffset := int_ToolLengthOffset + 62; 
						END;
						
			 11 : BEGIN
						IF int_Index <> 4 THEN int_ToolLengthOffset := int_ToolLengthOffset + 50;
						IF int_Index = 4 THEN int_ToolLengthOffset := int_ToolLengthOffset + 62; 
						END;
						
			 12 : BEGIN
						IF int_Index <> 4 THEN int_ToolLengthOffset := int_ToolLengthOffset + 50;
						IF int_Index = 4 THEN int_ToolLengthOffset := int_ToolLengthOffset + 62; 
						END;
				END;

	
			CASE int_ToolNb OF																	{WZ-Nummer berechnen}
				1 : BEGIN
						IF int_Index = 4 THEN int_ToolNb := int_ToolNb + 12; 
						END;
						
				2 : BEGIN
						IF int_Index = 4 THEN int_ToolNb := int_ToolNb + 12; 
						END;
						
				3 : BEGIN
						IF int_Index = 4 THEN int_ToolNb := int_ToolNb + 12; 
						END;
						
				4 : BEGIN
						IF int_Index = 4 THEN int_ToolNb := int_ToolNb + 12; 
						END;
						
				5 : BEGIN
						IF int_Index = 4 THEN int_ToolNb := int_ToolNb + 12; 
						END;
						
				6 : BEGIN
						IF int_Index = 4 THEN int_ToolNb := int_ToolNb + 12; 
						END;
						
				7 : BEGIN
						IF int_Index = 4 THEN int_ToolNb := int_ToolNb + 12; 
						END;
						
				8 : BEGIN
						IF int_Index = 4 THEN int_ToolNb := int_ToolNb + 12; 
						END;
						
				9 : BEGIN
						IF int_Index = 4 THEN int_ToolNb := int_ToolNb + 12; 
						END;
						
			 10 : BEGIN
						IF int_Index = 4 THEN int_ToolNb := int_ToolNb + 12; 
						END;
						
			 11 : BEGIN
						IF int_Index = 4 THEN int_ToolNb := int_ToolNb + 12; 
						END;
						
			 12 : BEGIN
						IF int_Index = 4 THEN int_ToolNb := int_ToolNb + 12; 
						END;
				END;
		END;
{End CAM Team initial treatment}


{Package treatment}
	PCALL(READ_PART_tool,int_ToolNb,int_ToolLengthOffset,int_ToolDiaOffset);
	PCALL(READ_PART_osetno,int_ToolLengthOffset);
	IF int_Index = 0 THEN int_Index := 1;
	PCALL(READ_PART_turret_no,int_Turret);
	IF (int_Turret = 1) THEN {UPPER TURRET}
	BEGIN
		int_Dec :=INTRD(SPE_INT_PACK_OFFSET_UPPER_TURRET_1 + int_Index - 1);
		int_DecToolNo := SPE_INT_PACK_OFFSET_UPPER_TOOL_1 + int_Index - 1;
	END
	ELSE IF int_Turret = 2 THEN {LOWER TURRET}
	BEGIN
		int_Dec := INTRD(SPE_INT_PACK_OFFSET_LOWER_TURRET_1 + int_Index - 1);
		int_DecToolNo := SPE_INT_PACK_OFFSET_LOWER_TOOL_1 + int_Index -1;
	END;
	
	{ writeln('                        dec : ', int_dec); }
	int_ToolLengthOffset := int_ToolLengthOffset + int_Dec;

	IF INTRD(int_DecToolNo) = CONST_YES THEN int_ToolNb := int_ToolNb + 12;

	INTWR(SPE_AKTUELL_WZ_LAENGE_OFFSET,int_ToolLengthOffset); 
	INTWR(SPE_AKTUELLES_WERKZEUG,int_ToolNb); 

{
	writeln('--------------INTWR(SPE_AKTUELL_WZ_LAENGE_OFFSET',INTRD(SPE_AKTUELL_WZ_LAENGE_OFFSET));
	writeln('--------------INTWR(SPE_AKTUELLES_WERKZEUG',INTRD(SPE_AKTUELLES_WERKZEUG));
}

	DebugEnd;
END;

{----------------------------------------------------------------------------}
PROCEDURE OutputNCChangeOffsetNumber;
{----------------------------------------------------------------------------}
VAR
	int_ToolNo, int_ToolLengthOffset : INTEGER;
	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'OutputNCChangeOffsetNumber');
	DebugBegin(str_ProcName,CONST_NO);
	

	Werkzeugnummer_Offset_Berechnung;
	int_ToolNo := INTRD(SPE_AKTUELLES_WERKZEUG);
	int_ToolLengthOffset := INTRD(SPE_AKTUELL_WZ_LAENGE_OFFSET);
	
	
	PCALL(OUTPUT_NC_tab,'T',(int_ToolNo * 100 + int_ToolLengthOffset), CONST_NO);
	
	
	DebugEnd;
END;{@}


{----------------------------------------------------------------------------}
PROCEDURE Werkzeugliste;
{----------------------------------------------------------------------------}
VAR
	Int_Zaehler,Int_Endung_Enfernen,int_ToolLengthOffset,int_ToolDiaOffset
	int_Channel,int_NbTool,int_TypeMac,int_ToolNb
	: INTEGER;

	str_ToolName_TEMP_1,str_ToolName,str_WZ_Final
	: TC255;

BEGIN
	PCALL(READ_PART_channel_no,int_Channel);
	PCALL(READ_PART_channel_tool_number,int_Channel,int_NbTool);
	PCALL(READ_DPP_integer,BPP_TYPE_MAC,int_TypeMac);
	
	PCALL(bcnTAB_STR,'SP','(*********************************)',1); Punchb(2);
	IF int_TypeMac = 9002 THEN PCALL(READ_PART_tool_number,int_NbTool);
	
	FOR Int_Zaehler := 1 to int_NbTool DO
	BEGIN
		PCALL(UTIL_load_tool_channel,int_Channel,Int_Zaehler);
		IF int_TypeMac = 9002 THEN PCALL(UTIL_tool_load,Int_Zaehler);
	
		PCALL(READ_PART_tool_name,str_ToolName_TEMP_1);
		Int_Endung_Enfernen := ICALL(SPI_FIL_remove_extension,str_ToolName_TEMP_1,str_ToolName);

		PCALL(READ_PART_tool,int_ToolNb,int_ToolLengthOffset,int_ToolDiaOffset);
		
		Werkzeugnummer_Offset_Berechnung;
		int_ToolNb 						:= INTRD(SPE_AKTUELLES_WERKZEUG); 
		int_ToolLengthOffset 	:= INTRD(SPE_AKTUELL_WZ_LAENGE_OFFSET); 

		PCALL(OUTPUT_NC_tab,'T_WZ_LISTE',(100 * int_ToolNb + int_ToolLengthOffset),CONST_NO);
    strcpy(str_WZ_Final,'= ');
	  strcat(str_WZ_Final,str_ToolName);
	  strcat(str_WZ_Final,')');
    PCALL(bcnTAB_STR,'SP',str_WZ_Final,1); Punchb(2);
	END;
	
	PCALL(bcnTAB_STR,'SP','(*********************************)',1); Punchb(2);
	DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE Freifahren_Start;	{WZ-Wechsel Start}
{----------------------------------------------------------------------------}
VAR
	int_ToolNb,int_ToolLengthOffset,int_ToolDiaOffset,int_CycleType,int_IsChangeCycle
	int_Channel,int_Spindel_pruefen
	:INTEGER;

	str_ProcName,str_1,str_Rev_X_Achse,str_2,str_Rev_Z_Achse,str_3,str_4
	: TC255;
	
	Rev_X_Achse,Rev_Z_Achse
	: REAL;
	
BEGIN
	strcpy(str_ProcName,'Freifahren_Start');
	DebugBegin(str_ProcName,CONST_NO);
	
	PCALL(lit_RTEC,RM_Z_EVOL,Rev_Z_Achse);
	PCALL(lit_RTEC,RM_X_EVOL,Rev_X_Achse);
	PCALL(READ_PART_tool,int_ToolNb,int_ToolLengthOffset,int_ToolDiaOffset);
	PCALL(litNUM_CANAL,int_Channel);
	PCALL(READ_PART_SPINDLE_TYPE,int_Spindel_pruefen);
	
	int_ToolNb 						:= INTRD(SPE_AKTUELLES_WERKZEUG); 
	int_ToolLengthOffset 	:= INTRD(SPE_AKTUELL_WZ_LAENGE_OFFSET); 
	int_IsChangeCycle 		:= ICALL(TEST_CHANGE_CYCLE);


	IF (INTRD(LIB_LIST_COMMENTS) = CONST_YES) AND not IsOutputToolChange THEN
		BEGIN
		IF (INTRD(SPE_OLD_WZ_LAENGE_OFFSET) <> int_ToolLengthOffset) AND (int_IsChangeCycle = 1) THEN
			BEGIN																											{Bei Korrektur Enderung schreiben}
			IF NOT IsRadialPlane OR NOT IsDevZPlane THEN
				BEGIN
				IF INTRD(SPE_G8P1) = 1 THEN
					BEGIN
					PCALL(bcnTAB_STR,'SP','G8 P0',1); Punchb(2);
					INTWR(SPE_G8P1,0);
					END;
		
				IF IsMillingOperation THEN 														{Fraes Operation}
					BEGIN
					IF (int_CycleType = CONST_TAPPING) THEN 
						BEGIN
						OutputSpindleOn;
						END;
						
					IF Int_Spindel_Pruefen = CONST_MAIN_SPINDLE THEN 
						BEGIN
						{PCALL(bcnTAB_STR,'SP','G0 Y0.',1); Punchb(2);}
						PCALL(bcnTAB_STR,'SP','G28 U0. V0.',1); Punchb(2);
						END
					ELSE IF Int_Spindel_Pruefen = CONST_REWORK_SPINDLE THEN 
						BEGIN
						{PCALL(bcnTAB_STR,'SP','G0 Y0.',1); Punchb(2);}
						PCALL(bcnTAB_STR,'SP','G28 U0.',1); Punchb(2);
						PCALL(bcnTAB_STR,'SP','G28 V0.',1); Punchb(2);
						END;
					END
				ELSE 																									{Dreh Operation}
					BEGIN
					
					IF Int_Spindel_Pruefen = CONST_MAIN_SPINDLE THEN 
						BEGIN
						PCALL(bcnTAB_STR,'SP','G28 U0. V0. M702',1); Punchb(2);
						END
					ELSE IF Int_Spindel_Pruefen = CONST_REWORK_SPINDLE THEN 
						BEGIN
						PCALL(bcnTAB_STR,'SP','G28 U0.',1); Punchb(2);
						PCALL(bcnTAB_STR,'SP','G28 V0. M702',1); Punchb(2);
						END;
					END;
					
				IF (int_Channel = 1) THEN															{Kanal 1 beim Fraesen}
				BEGIN
					IF IsMillingOperation THEN PCALL(bcnTAB_STR,'SP','M90',1); Punchb(2);
				END
				ELSE IF (int_Channel = 2) THEN												{Kanal 2 beim Fraesen}
				BEGIN
					IF IsMillingOperation THEN
					BEGIN
						PCALL(bcnTAB_STR,'SP','M490',1); Punchb(2);
					END;
				END;

				PCALL(bcnTAB_STR,'SP','M9',1); Punchb(2);
				PCALL(bcnTAB_STR,'SP','M1',1); Punchb(2);
				INTWR(SPE_ABWICKLUNG_AKTIV,0);
				END;
			END;
		END;
	DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE Freifahren_Ende;	{WZ-Wechsel Ende}
{----------------------------------------------------------------------------}
VAR
	int_ToolNb,int_ToolLengthOffset,int_ToolDiaOffset,num_cycle,int_IsToolChange
	int_CycleType,int_IsChangeCycle,int_Channel,int_Spindel_pruefen,int_Kanal_Aktiv, int_NumberCycle
	,int_NbPartingDone, int_NbParting :INTEGER;

	str_ProcName,str_1,str_Rev_X_Achse,str_2,str_Rev_Z_Achse,str_3,str_4
	: TC255;
	
	Rev_X_Achse,Rev_Z_Achse
	: REAL;
	
BEGIN
	strcpy(str_ProcName,'Freifahren_Ende');
	DebugBegin(str_ProcName,CONST_YES);

	PCALL(lit_RTEC,RM_Z_EVOL,Rev_Z_Achse);
	PCALL(lit_RTEC,RM_X_EVOL,Rev_X_Achse);
	PCALL(litNUM_CYCLE,num_cycle);
	PCALL(READ_PART_pp_cycle_no,int_CycleType);
	PCALL(READ_PART_tool,int_ToolNb,int_ToolLengthOffset,int_ToolDiaOffset);
	PCALL(litNUM_CANAL,int_Channel);
	PCALL(READ_PART_SPINDLE_TYPE,int_Spindel_pruefen);

	int_Kanal_Aktiv 			:= INTRD(SPE_INT_KANAL_WECHSEL);
	{ int_IsToolChange 			:= ICALL(TEST_CHANGE_TOOL); }
	int_IsToolChange 			:= ICALL(TEST_change_tool_pocket);
	int_IsChangeCycle 		:= ICALL(TEST_CHANGE_CYCLE);
	int_ToolNb 						:= INTRD(SPE_AKTUELLES_WERKZEUG); 
	int_ToolLengthOffset 	:= INTRD(SPE_AKTUELL_WZ_LAENGE_OFFSET); 
	
	INTWR(SPE_OLD_WZ_LAENGE_OFFSET,int_ToolLengthOffset); 
	
	IF IsDevZPlane THEN INTWR(SPE_ABWICKLUNG_AKTIV,1);

	IF (INTRD(LIB_LIST_COMMENTS) = CONST_YES) THEN
		BEGIN
		IF (int_IsToolChange = CONST_YES) OR (INTRD(SPE_INT_FORCE_TOOL_CHANGE)=1) OR (INTRD(SPE_WZ_WECHSEL_ERZWINGEN) = 1) THEN
			BEGIN
			IF NOT IsRadialPlane OR NOT IsDevZPlane THEN
				BEGIN

				IF INTRD(SPE_G8P1) = 1 THEN
					BEGIN
					PCALL(bcnTAB_STR,'SP','G8 P0',1); Punchb(2);
					INTWR(SPE_G8P1,0);
					END;
	
				IF IsMillingOperation THEN 												{Fraes Operation}
					BEGIN
					IF (int_CycleType = CONST_TAPPING) THEN 
						BEGIN
						OutputSpindleOn;
						END;

					{ IF Int_Spindel_Pruefen = CONST_MAIN_SPINDLE THEN  }
						{ BEGIN }
						{PCALL(bcnTAB_STR,'SP','G0 Y0.',1); Punchb(2);}
						PCALL(bcnTAB_STR,'SP','G28 U0. V0. M702',1); Punchb(2);
						PCALL(bcnTAB_STR,'SP','G28 W0.',1); Punchb(2);
					{ END }
					{ ELSE IF Int_Spindel_Pruefen = CONST_REWORK_SPINDLE THEN  }
						{ BEGIN }
						{ PCALL(bcnTAB_STR,'SP','G0 Y0.',1); Punchb(2); }
						{ PCALL(bcnTAB_STR,'SP','G28 U0.',1); Punchb(2); }
						{ PCALL(bcnTAB_STR,'SP','G28 V0. W0.',1); Punchb(2); }
					{ END; }
				END
				ELSE 																							{Dreh Operation}
				BEGIN
					
					{ IF Int_Spindel_Pruefen = CONST_MAIN_SPINDLE THEN  }
						{ BEGIN }
						PCALL(bcnTAB_STR,'SP','G28 U0. V0. M702',1); Punchb(2);
						PCALL(bcnTAB_STR,'SP','G28 W0.',1); Punchb(2);
						{ END }
					{ ELSE IF Int_Spindel_Pruefen = CONST_REWORK_SPINDLE THEN  }
						{ BEGIN }
						{ PCALL(bcnTAB_STR,'SP','G28 U0.',1); Punchb(2); }
						{ PCALL(bcnTAB_STR,'SP','G28 V0. W0. M702',1); Punchb(2); }
						{ END; }
					END;

					IF (int_Channel = 1) THEN
					BEGIN
						IF IsMillingOperation THEN PCALL(bcnTAB_STR,'SP','M90',1); Punchb(2);
					END
					ELSE IF (int_Channel = 2) THEN
					BEGIN
						IF IsMillingOperation THEN
						BEGIN
							{2023-03-15 XP Add M472 before M490}
							PCALL(bcnTAB_STR,'SP','M472',1); Punchb(2);
							PCALL(bcnTAB_STR,'SP','M490',1); Punchb(2);
						END;
					END;
						
				OutputStopCoolant;					{Kuehlung}
					
					
				
	{output the end of spindle}
	{for rework spindle we test it is the last cycle}
	IF (ICALL(TEST_latest_cycle,CONST_NO,CONST_NO,CONST_YES,CONST_NO) = CONST_YES) AND IsReworkSpindle THEN
	BEGIN
		PCALL(OUTPUT_NC_m,799,CONST_YES);
		writeb;
	END;
	
	{for main spindle we test if the next cycle is parting}
	PCALL(READ_PART_next_cycle_typno,CONST_NO,CONST_NO,int_NumberCycle);
	int_NbPartingDone := INTRD(SPE_INT_NB_PARTING_DONE);
	int_NbParting := INTRD(SPE_INT_NB_PARTING_CYCLE);
	
	IF not IsReworkSpindle AND (int_NumberCycle = CONST_PARTING) THEN
	BEGIN
		{we output the M797 only for the last parting operation}
		IF int_NbPartingDone = (int_NbParting - 1) THEN
		BEGIN
			PCALL(OUTPUT_NC_m,797,CONST_YES);
			writeb;
		END;
	END;
	
			PCALL(bcnTAB_STR,'SP','M1',1); Punchb(2);
			INTWR(SPE_ABWICKLUNG_AKTIV,0);
		
			IF (INTRD(SPE_WZ_WECHSEL_ERZWINGEN) = 1) THEN 
				BEGIN
				PCALL(bcnTAB_STR,'SP',' ',1); Punchb(2);
				PCALL(bcnTAB_STR,'SP','(WZ-WECHSEL ERZWINGEN AKTIV)',1); ecritb;
				END;
			END;
		END;
	END;
	DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE ZYKLUS_DEAKTIVIEREN;		{Zyklus deaktivieren}
{----------------------------------------------------------------------------}
BEGIN
	PCALL(bcnVALIDE_PUNCH,0);
	INTWR(SPE_PUNCH_ACTIF,0);
END;


{----------------------------------------------------------------------------}
PROCEDURE ACTIVE_PUNCH;	 					{Zyklus aktivieren}
{----------------------------------------------------------------------------}
BEGIN
	IF INTRD(SPE_LIZENZ_VERSION_PRUEFEN) = 0 THEN
		BEGIN
		PCALL(bcnVALIDE_PUNCH,1);
		INTWR(SPE_PUNCH_ACTIF,1);
		END;
END;


{----------------------------------------------------------------------------}
PROCEDURE Anschlag_Start_Kanal_2;	{Stangenlader Ein}
{----------------------------------------------------------------------------}
VAR
	str_ProcName, str_Out
	: TC255;
	
BEGIN
	PCALL(bcnTAB_STR,'SP','N1234',1); Punchb(2);	
	PCALL(bcnTAB_STR,'SP','G0 G80 G98 G13.1',1); Punchb(2);	
	PCALL(bcnTAB_STR,'SP','M199 (SYNC HARTKODIERT)',1); Punchb(2);	
	{ PCALL(bcnTAB_STR,'SP','M87',1); Punchb(2);	 }
	STRINGRD(LIB_STR_UNCLAMP_MS,str_Out);
	PCALL(bcnTAB_STR,'SP','M87',1); Punchb(2);	
	PCALL(bcnTAB_STR,'SP','M41',1); Punchb(2);	
END;


{----------------------------------------------------------------------------}
PROCEDURE Anschlag_Ende_Kanal_2;	{Stangenlader Ein}
{----------------------------------------------------------------------------}
VAR
	Real_Teilelaenge,Real_F_Vorziehen,real_ZMin,real_RayInt,real_ZMax,real_RayExt
	real_WZ_Abstech_Breite
	: REAL;

	str_ProcName,str_Anschlag_End_Z,str_1,str_HS_Planaufmass,str_F_Vorziehen
	: TC255;

BEGIN
	PCALL(litLG_PIECE,Real_Teilelaenge);   
	PCALL(lit_RTEC,RTT_AVANCE_Z,Real_F_Vorziehen);
	PCALL(READ_PART_stock_box,real_ZMin,real_RayInt,real_ZMax,real_RayExt); {HS GS Aufmass}
	
	real_WZ_Abstech_Breite		:= DOUBLERD(SPE_REAL_ABSTECHBREITE);
	
	PCALL(bcnTAB_STR,'SP','Z2.',1); Punchb(2);	
	OutputSynchroToolpath(0);
	PCALL(bcnTAB_STR,'SP','G4 U0.2',1); Punchb(2);	
	PCALL(bcnTAB_STR,'SP','G379 Z2. Y6. E60.',1); Punchb(2);	
	
	PCALL(bcnG,1,1);
	PCALL(bcnG,98,1);
	PCALL(bcnTAB,'Z',-(Real_Teilelaenge+real_WZ_Abstech_Breite-5.5),1);
	PCALL(bcnTAB,'F',Real_F_Vorziehen,1);
	
	PCALL(bcnTAB_STR,'SP','(ABSTECH+TEILELAENGE-5.5)',1); Punchb(2);
	
	PCALL(bcnTAB_STR,'SP','M11  (HS FUTTER AUF)',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G4 U1.',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M61',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G4 U0.8',1); Punchb(2);

	strcat(str_1,'G1 G98 Z');
	str_ftoa(str_HS_Planaufmass,real_ZMax,1,1);
	strcat(str_1,str_HS_Planaufmass);
	strcat(str_1,' F');
	str_ftoa(str_F_Vorziehen,Real_F_Vorziehen-1000,1,0);
	strcat(str_1,str_F_Vorziehen);
	PCALL(OUTPUT_NC_tab_str,'SP',str_1,1); Punchb(2);

	PCALL(bcnTAB_STR,'SP','G4 U0.8',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M10  (HS FUTTER ZU)',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G4 U1.',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G0 W2.',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M705 (STANGE VORGEZOGEN?)',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G28 U0. V0.',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G0 Z50.',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M370',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M1',1); Punchb(2);
	
	PCALL(bcnTAB_STR,'SP',' ',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G471 R3228.4 Q1 I1235',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','#3000=1 (KUEHLWASSER NICHT AUTO)',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','N1235',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M1',1); Punchb(2);

	ZYKLUS_DEAKTIVIEREN;		{Zyklus deaktivieren}
END;


{----------------------------------------------------------------------------}
FUNCTION DistanceBetweenSpindles(real_PartLength, real_ZmorsMS, real_ZminMS,real_ZMorsRS, real_ZminRS : REAL):REAL;
{----------------------------------------------------------------------------}
VAR
	real_Ret : REAL;
	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'DistanceBetweenSpindles');
	DebugBegin(str_ProcName,CONST_NO);


	real_Ret := real_ZmorsMS + real_ZmorsRS + real_PartLength + real_ZminMS + real_ZminRS;
	
	
	DistanceBetweenSpindles := real_Ret;

	DebugEnd;
END;

{----------------------------------------------------------------------------}
PROCEDURE Uebergabe_Abstechen_Kanal_2_Start;
{----------------------------------------------------------------------------}
VAR
	Int_Spanndruck
	: INTEGER;

	real_PosZ,Real_B_Uebergabe,Real_Spanntiefe_Teil_laenge,Real_Teil_Laenge,Real_Sicherheits_W_Pos
	Real_HS_Futter_Laenge,Real_HS_Spanntiefe,Real_HS_Rohteil_Laenge,Real_HS_Rohteil_NP_Laenge
	Real_GS_Futter_Laenge,Real_GS_Spanntiefe,Real_GS_Rohteil_Laenge,Real_GS_Rohteil_NP_Laenge
	Real_B_Uebergabe_korr,Real_HS_Winkel,Real_GS_Winkel,Real_Spindel_Abstand,Real_HS_Nullpunkt
	Real_GS_Nullpunkt
	: REAL;
	real_ZmorsMS, real_ZminMS, real_ZmaxMS, real_ZOriMS,real_ZmorsRS, real_ZminRS, real_ZmaxRS, real_ZOriRS, real_PartLength, real_DistSpindle : REAL;
	str_1,str_B_Uebergabe_Sicher,str_B_Uebergabe,str_Spanndruck
	: TC255;

	tr3_Pt
	:TR3;

BEGIN
	PCALL(READ_PATH_point,tr3_Pt);
	PCALL(lit_RTEC,RM_ANGLE_MORS,Real_HS_Winkel);
	PCALL(lit_RTEC,RM_ANGLE_MORS_REP,Real_GS_Winkel);
	PCALL(lit_RTEC,RM_BROCHE_DECAL,Real_Spindel_Abstand); 
	PCALL(litLG_PIECE,Real_Teil_Laenge); 				  						{Teile Laenge}
	PCALL(READ_PART_CHUCK_PART_POSITION,1,Real_HS_Futter_Laenge,Real_HS_Spanntiefe,Real_HS_Rohteil_Laenge,Real_HS_Rohteil_NP_Laenge); 
	PCALL(READ_PART_CHUCK_PART_POSITION,2,Real_GS_Futter_Laenge,Real_GS_Spanntiefe,Real_GS_Rohteil_Laenge,Real_GS_Rohteil_NP_Laenge);

	real_PosZ := tr3_Pt[0];
	{ writeln('                      spindel abstand : ',Real_Spindel_Abstand); }
	{ writeln('                   Real_HS_Spanntiefe ', Real_HS_Spanntiefe); }
	Real_Spanntiefe_Teil_laenge := (Real_HS_Spanntiefe + Real_Teil_laenge);		{HS= Spanntiefe Z-Min + Teile Laenge}
	{ writeln('             part langue cam team : ', Real_Spanntiefe_Teil_laenge); }
	Real_B_Uebergabe	:= (0) + (Real_HS_Futter_Laenge + Real_GS_Futter_Laenge) + (Real_Spanntiefe_Teil_laenge + Real_GS_Spanntiefe) - Real_Spindel_Abstand; 

	Real_HS_Nullpunkt	:= (Real_HS_Futter_Laenge) + (Real_HS_Rohteil_NP_Laenge) - (0); {HS Spindelnase Nullpunkt - Futter}
	Real_GS_Nullpunkt	:= (0) - (Real_GS_Futter_Laenge + Real_GS_Rohteil_NP_Laenge); 	{GS Spindelnase Nullpunkt - Futter}

	Real_Sicherheits_W_Pos	:= DOUBLERD(SPE_SICHERHEITS_W_POS);
	Real_B_Uebergabe_korr		:= DOUBLERD(SPE_B_UEBERGABE_KORR);
	Int_Spanndruck					:= INTRD(SPE_SPANNDRUCK);

	{PCALL(bcnTAB_STR,'SP','M180 (FEIGABE TEIL MIT ROEBI ENTLADEN)',1); Punchb(2);}
	PCALL(bcnTAB_STR,'SP','M264 (SCHIEBER AUF)',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M751 (FREIGABE ENTLADEN)',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M265 (SCHIEBER ZU)',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G28 U0. V0.',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M1',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP',' ',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','N1313 (*********************************)',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M182 (GS START WASCHEN - DORN WASCHEN)',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','(TEIL UNTEN ENTLADEN)',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G28 W0. V0.',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','N63 (A-DREHEN)',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M427',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M420 (LUFT AN)',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G55',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G18 G40',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M441',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G0 T1363',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G97 S600 M54',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M8',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M742',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','Z-2.',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G0 X60. Z20.',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','Z56.',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G4 U1.',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G97 S300',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','X160.',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','U0.5',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G0 Z-10.',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','X160.',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G28 V0.',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M9',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M55',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M51',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M421 (LUFT AUS)',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M1',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP',' ',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M199 (SYNC HARTKODIERT)',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP',' ',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','N1111 (UEBERGABE MIT ABSTECHEN)',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G54',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G28 U0. W0. V0.',1); Punchb(2);

	OutputToolChange;						{Abstech Station}

	PCALL(OUTPUT_NC_g,0,1);
	PCALL(OUTPUT_NC_tab,'Z',real_PosZ,1);
	PCALL(bcnTAB_STR,'SP','(ABSTECH+TEILELAENGE+ZUGABE)',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M470',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M41',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M5',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M1',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP',' ',1); Punchb(2);
	
	PCALL(bcnTAB_STR,'SP','M198',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M98 P9000 (HS C-ACHSE EIN)',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G0 C0.',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M51',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G4 U0.1',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G28 U0.',1); Punchb(2);



	PCALL(READ_PART_chuck_part_position,1,real_ZmorsMS, real_ZminMS, real_ZmaxMS, real_ZOriMS);
	PCALL(READ_PART_chuck_part_position,2,real_ZmorsRS, real_ZminRS, real_ZmaxRS, real_ZOriRS);
	real_PartLength := real_ZmaxMS - real_ZminMS;
	real_DistSpindle := DistanceBetweenSpindles(real_PartLength,real_ZmorsMS,real_ZminMS, real_ZmorsRS, real_ZminRS);


	{ writeln('             dist between spindle : ', real_DistSpindle-Real_Spindel_Abstand); }

	strcat(str_1,'G0 B');											{B-ACHSEPOSITION 50MM VOR STUECK}
	{ ConcatStrVal(str_B_Uebergabe_Sicher,str_B_Uebergabe_Sicher,(Real_B_Uebergabe+Real_Sicherheits_W_Pos),3); }
	{ writeln('                       ubergabe : ',Real_B_Uebergabe); }
	{ writeln('                      sicherheits : ',Real_Sicherheits_W_Pos); }
	ConcatStrVal(str_B_Uebergabe_Sicher,str_B_Uebergabe_Sicher,(Real_B_Uebergabe+Real_Sicherheits_W_Pos),3);
	strcat(str_1,str_B_Uebergabe_Sicher);
	strcat(str_1,' (B-ACHSEPOSITION VOR STUECK)');
	PCALL(OUTPUT_NC_tab_str,'SP',str_1,CONST_YES); ecritb;
	str_1[0] := chr(0);
	
	PCALL(bcnTAB_STR,'SP','M743',1); Punchb(2);
	
	IF INTRD(SPE_FESTANSCHLAG) = 1 THEN
		BEGIN
		IF Real_B_Uebergabe_korr = 0 THEN										{Uebergabe rechnen oder manuell Eingabe}
			BEGIN
			strcat(str_1,'G1 G98 B');													{Abgreifwert B-Achse GS}
			ConcatStrVal(str_B_Uebergabe,str_B_Uebergabe,Real_B_Uebergabe,3);
			strcat(str_1,str_B_Uebergabe);	
			strcat(str_1,' F2000 (B-ACHSEN ENDPOSITION)');
			PCALL(OUTPUT_NC_tab_str,'SP',str_1,CONST_YES); Punchb(2);
			END
		ELSE
			BEGIN
			strcat(str_1,'G1 G98 B');													{Abgreifwert B-Achse GS}
			ConcatStrVal(str_B_Uebergabe,str_B_Uebergabe,Real_B_Uebergabe_korr,3);
			strcat(str_1,str_B_Uebergabe);	
			strcat(str_1,' F2000 (B-ACHSEN ENDPOSITION)');
			PCALL(OUTPUT_NC_tab_str,'SP',str_1,CONST_YES); Punchb(2);
			END;
		END
	ELSE IF INTRD(SPE_FESTANSCHLAG) = 2 THEN
		BEGIN
		IF Real_B_Uebergabe_korr = 0 THEN										{Uebergabe rechnen oder manuell Eingabe}
			BEGIN
			strcat(str_1,'G1 G98 B');													{Abgreifwert B-Achse GS}
			ConcatStrVal(str_B_Uebergabe,str_B_Uebergabe,Real_B_Uebergabe,3);
			strcat(str_1,str_B_Uebergabe);	
			strcat(str_1,' F2000 (G1 B-ACHSEN VORPOSITION)');
			PCALL(OUTPUT_NC_tab_str,'SP',str_1,CONST_YES); Punchb(2);
			str_1[0] := chr(0);
			str_B_Uebergabe[0] := chr(0);
			
			strcat(str_1,'G131 B');													{Abgreifwert B-Achse GS}
			ConcatStrVal(str_B_Uebergabe,str_B_Uebergabe,(Real_B_Uebergabe-16),3);
			strcat(str_1,str_B_Uebergabe);	
			strcat(str_1,' A');
			str_itoa(str_Spanndruck,Int_Spanndruck);
			strcat(str_1,str_Spanndruck);
			strcat(str_1,' F200 (AUF FESTANSCHLAG FAHREN)');
			PCALL(OUTPUT_NC_tab_str,'SP',str_1,CONST_YES); Punchb(2);
			str_1[0] := chr(0);
			END
		ELSE
			BEGIN
			strcat(str_1,'G1 G98 B');													{Abgreifwert B-Achse GS}
			ConcatStrVal(str_B_Uebergabe,str_B_Uebergabe,(Real_B_Uebergabe_korr),3);
			strcat(str_1,str_B_Uebergabe);	
			strcat(str_1,' F2000 (G1 B-ACHSEN VORPOSITION)');
			PCALL(OUTPUT_NC_tab_str,'SP',str_1,CONST_YES); Punchb(2);
			str_1[0] := chr(0);
			str_B_Uebergabe[0] := chr(0);
			
			strcat(str_1,'G131 B');													{Abgreifwert B-Achse GS}
			ConcatStrVal(str_B_Uebergabe,str_B_Uebergabe,(Real_B_Uebergabe_korr-16),3);
			strcat(str_1,str_B_Uebergabe);	
			strcat(str_1,' A');
			str_itoa(str_Spanndruck,Int_Spanndruck);
			strcat(str_1,str_Spanndruck);
			strcat(str_1,' F200 (AUF FESTANSCHLAG FAHREN)');
			PCALL(OUTPUT_NC_tab_str,'SP',str_1,CONST_YES); Punchb(2);
			str_1[0] := chr(0);
			END;
		END;

	PCALL(bcnTAB_STR,'SP','M50',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G4 U1.',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M197',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M41',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G4 U0.5',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M196',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M96 (DREHZAHL SYNCHRO)',1); Punchb(2);
END;


{----------------------------------------------------------------------------}
PROCEDURE Uebergabe_Abstechen_Kanal_2_Ende;
{----------------------------------------------------------------------------}
VAR

BEGIN
	PCALL(bcnTAB_STR,'SP','M195',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M470',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M71',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G98',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','(G300B-502F200. ELEKTRO ABST. KONTROLLE)',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G28 B0. M9',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M97',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M421',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M194',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G28 W0.',1); Punchb(2);
END;


{----------------------------------------------------------------------------}
PROCEDURE Uebergabe_Abstechen_Kanal_1;
{----------------------------------------------------------------------------}
VAR
	real_WZ_Station,real_Z_Freifahren
	: REAL;
	
	str_1,str_WZ_Station,str_Z_Freifahren
	:TC255;

BEGIN
	real_WZ_Station 	:= DOUBLERD(SPE_REAL_WZ_WECHSEL_TECHNO);
	real_Z_Freifahren := DOUBLERD(SPE_REAL_REV1_Z_FREIFAHREN);

	PCALL(bcnTAB_STR,'SP',' ',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','N56 (*********************************)',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','(TEIL UNTEN ENTLADEN)',1); Punchb(2);
	{PCALL(bcnTAB_STR,'SP','M180 (FEIGABE TEIL MIT ROEBI ENTLADEN)',1); Punchb(2);}
	PCALL(bcnTAB_STR,'SP','M182 (HS START WASCHEN)',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','N4444(STUECK WASCHEN)',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M428',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G54',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G28 W0.',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G50 S3000',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G17 G40 M470',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M41',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G0 G99 T0404 (BOHRER D25.7)',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G97 S1500 M3',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M8',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M471',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','Z10.',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G0 X0. Y0.',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G1 Z-70 F2.',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','W0.5',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','S800',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','Z15 F20. S50',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G0 X30.',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G4 U1.',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G0 X0. S950',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G1 Z-70. F8',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','W0.5',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','Z15 F8',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G0 X30. S50',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G4 U0.5',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M9',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G0 X125.',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G28 U0. V0. M702',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M5',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M1',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP',' ',1); Punchb(2);
	
	PCALL(bcnTAB_STR,'SP','M199 (SYNC HARTKODIERT)',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP',' ',1); Punchb(2);
	
	PCALL(bcnTAB_STR,'SP','N1111 (*********************************)',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','(UEBERGABE MIT ABSTECHEN)',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G18',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M470',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G28 W0.',1); Punchb(2);
	
	IF real_WZ_Station > 0 THEN
		BEGIN
		IF real_WZ_Station > 9 THEN strcat(str_1,'T')
		 ELSE strcat(str_1,'T0');
		ConcatStrVal(str_WZ_Station,str_WZ_Station,100 * real_WZ_Station + real_WZ_Station,3);
		strcat(str_1,str_WZ_Station);
		strcat(str_1,' (WKZ ZUM FREIFAHREN)');
		PCALL(bcnTAB_STR,'SP',str_1,1); Punchb(2);
		str_1[0] := chr(0);
		DOUBLEWR(SPE_REAL_WZ_WECHSEL_TECHNO,0.0); 
		END
	ELSE
		BEGIN
		PCALL(bcnTAB_STR,'SP','T0101 (WKZ ZUM FREIFAHREN)',1); Punchb(2);
		END;
	
	PCALL(bcnTAB_STR,'SP','G28 U0.',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G54',1); Punchb(2);
	
	IF real_Z_Freifahren <> 0 THEN
		BEGIN
		strcat(str_1,'G0 Z');
		ConcatStrVal(str_Z_Freifahren,str_Z_Freifahren,real_Z_Freifahren,3);
		strcat(str_1,str_Z_Freifahren);
		strcat(str_1,' (FREIFAHREN Z-ACHSE)');
		PCALL(bcnTAB_STR,'SP',str_1,1); Punchb(2);
		str_1[0] := chr(0);
		END
	ELSE
		BEGIN
		PCALL(bcnTAB_STR,'SP','G0 Z0. (FREIFAHREN Z-ACHSE)',1); Punchb(2);
		END;
	
	PCALL(bcnTAB_STR,'SP','#531=#2601 (AKTIVE NPV VON R)',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M97',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M87',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M55',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M1',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP',' ',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M198',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M442',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M98 P9001 (GS C-ACHSE EIN) ',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G0 C0.',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M197',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M441',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G4 U0.2',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M196',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M195',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G28 V0. M9',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M470',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M71',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M5',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','M194',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','G28 W0.',1); Punchb(2);
	PCALL(bcnTAB_STR,'SP','N1112',1); Punchb(2);
END;


{----------------------------------------------------------------------------}
PROCEDURE Befehl_P8_P1;
{----------------------------------------------------------------------------}
VAR
	str_Zyklus_Kommentar_Zeile_1,str_Zyklus_Kommentar_Zeile_2,str_Zyklus_Kommentar
	: TC255;

BEGIN
	PCALL(READ_PART_cycle_comment,str_Zyklus_Kommentar);
	
	strcpy(str_Zyklus_Kommentar_Zeile_1,'P8 P1 Ein');
	strcpy(str_Zyklus_Kommentar_Zeile_2,'P8 P1 Aus');

	IF str_Zyklus_Kommentar = str_Zyklus_Kommentar_Zeile_1 THEN 
		BEGIN
		PCALL(bcnTAB_STR,'SP','G8 P1',1); Punchb(2);
		INTWR(SPE_G8P1,1);	{P8 P1 Ein}
		END
	ELSE IF str_Zyklus_Kommentar = str_Zyklus_Kommentar_Zeile_2 THEN 
		BEGIN
		PCALL(bcnTAB_STR,'SP','G8 P0',1); Punchb(2);
		INTWR(SPE_G8P1,2);	{P8 P0 Aus}
		END;
END;


{----------------------------------------------------------------------------}
PROCEDURE Befehl_M471;
{----------------------------------------------------------------------------}
VAR
	real_Y_Wert
	: REAL;

	str_Zyklus_Kommentar_Zeile_1,str_Zyklus_Kommentar_Zeile_2,str_Zyklus_Kommentar
	str_Zyklus_Wert
	: TC255;

BEGIN
	PCALL(lit_STEC,ST_MOYEN_CONTROLE,str_Zyklus_Wert);
	PCALL(READ_PART_cycle_comment,str_Zyklus_Kommentar);
	
	strcpy(str_Zyklus_Kommentar_Zeile_1,'M471 Ein');
	strcpy(str_Zyklus_Kommentar_Zeile_2,'M470 Aus');

	IF str_Zyklus_Kommentar = str_Zyklus_Kommentar_Zeile_1 THEN 
		BEGIN
		INTWR(SPE_M471,1);
		str_atof(str_Zyklus_Wert,real_Y_Wert);
		DOUBLEWR(SPE_M471_WERT,real_Y_Wert);
		END
	ELSE IF str_Zyklus_Kommentar = str_Zyklus_Kommentar_Zeile_2 THEN 
		BEGIN
		INTWR(SPE_M471,2);
		DOUBLEWR(SPE_M471_WERT,0.0);
		END;
END;


{----------------------------------------------------------------------------}
PROCEDURE ApproachPlaneBegin;
{----------------------------------------------------------------------------}
VAR
	str_ProcName 
	: TC255;
	
	tr3_Pt
	: TR3;
	
BEGIN
	strcpy(str_ProcName,'ApproachPlaneBegin');
	DebugBegin(str_ProcName,CONST_NO);

	PCALL(READ_PATH_point,tr3_Pt);
	DOUBLEWR(SPE_REAL_RUECKZUG_Z,tr3_Pt[0]);		{Wert Speichern fuer Bohren Rueckzug}

	DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE Z_Achse_Anfahren;
{----------------------------------------------------------------------------}
VAR
	int_CycleNo
	:INTEGER;

	real_PrimaryAngle,real_SecondaryAngle,real_PosZ,real_PosZ_Axial,real_PosZ_Radial
	real_Y_Achse
	: REAL;

	tr3_Pt
	: TR3;

BEGIN
	PCALL(READ_PATH_point,tr3_Pt);
	PCALL(READ_PATH_point_5axis,tr3_Pt,real_PrimaryAngle,real_SecondaryAngle);
	PCALL(READ_PART_cycle_no,int_CycleNo);
	
	real_PosZ 				:= tr3_Pt[0];
	real_PosZ_Axial 	:= tr3_Pt[2];
	real_PosZ_Radial  := tr3_Pt[0];
	real_Y_Achse 			:= DOUBLERD(SPE_M471_WERT);
			
	IF IsAxialPlane OR IsBPlane OR IsBPlaneToolInclined THEN
	BEGIN
		PCALL(WRITE_NC_g_force,0);
		OutputNCRapid;
		PCALL(OUTPUT_NC_paxis3,real_PosZ_Axial,CONST_YES);
		{ PCALL(OUTPUT_NC_g,0,1); }
		{ PCALL(OUTPUT_NC_tab,'Z',real_PosZ_Axial,1); }
		{ OutputNCPrimary(real_PrimaryAngle); }
		OutputNCSecondary(real_SecondaryAngle);
		IF TESTMOVE THEN writeb;
		{ IF ICALL(TEST_HOLE_CYCLE) = CONST_NO THEN }
		{ BEGIN }
			{ PCALL(OUTPUT_NC_tab_str,'SP','G05.1 Q1',CONST_YES); }
			{ writeb; }
		{ END; }
	END;
		
	IF IsRadialPlane THEN
	BEGIN
		PCALL(OUTPUT_NC_g,0,1);
		PCALL(OUTPUT_NC_tab,'Z',real_PosZ_Radial,1);
		OutputNCPrimary(real_PrimaryAngle);
		OutputNCSecondary(real_SecondaryAngle);
	END;
		
	IF IsTurnPlane THEN 
	BEGIN
		IF int_CycleNo = CONST_PARTING THEN PCALL(bcnTAB_STR,'SP','M70',1); Punchb(2);
		
		PCALL(OUTPUT_NC_g,0,1);
		PCALL(OUTPUT_NC_tab,'Z',real_PosZ,1); 
		
		IF INTRD(SPE_M471) = 1 THEN
		BEGIN
			PCALL(OUTPUT_NC_tab,'Y',real_Y_Achse,1); 

			INTWR(SPE_M471,0);
			DOUBLEWR(SPE_M471_WERT,0.0); 
		END;

		writeb;
	END;
END;

{----------------------------------------------------------------------------}
PROCEDURE ApproachReworkSpindle;
{----------------------------------------------------------------------------}
VAR
	str_Read : TC255;
	real_Angle,real_ZmorsMS, real_ZminMS, real_ZmaxMS, real_ZOriMS,real_ZmorsRS, real_ZminRS, real_ZmaxRS, real_ZOriRS : REAL;
	real_PartLength,real_DistSpindle,real_DistBetweenSpindles : REAL;
	
	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'ApproachReworkSpindle');
	DebugBegin(str_ProcName,CONST_NO);
	
	
	PCALL(lit_RTEC,RM_BROCHE_DECAL,real_DistBetweenSpindles); 
	
	If IsChannel(1) THEN
	BEGIN
	PCALL(OUTPUT_NC_tab_str,'SP','M182',CONST_YES);
		writeb;
		
		PCALL(bcnTAB_STR,'SP','G28 U0. V0.',1); Punchb(2);
		PCALL(bcnTAB_STR,'SP','G28 W0.',1); Punchb(2);
		
		PCALL(bcnTAB_STR,'SP','M198',1); Punchb(2);
		PCALL(bcnTAB_STR,'SP','M442',1); Punchb(2);
		STRINGRD(LIB_STR_ENABLE_C_AXIS_RS,str_Read);
		PCALL(bcnTAB_STR,'SP',str_Read,1); Punchb(2);
		PCALL(READ_PART_chuck_part_angle,2,real_Angle);
		{ PCALL(bcnTAB_STR,'SP','G0 C0.',1);  }
		PCALL(OUTPUT_NC_G,0,CONST_YES);
		PCALL(OUTPUT_NC_primary,real_Angle,CONST_YES);
		Punchb(2);
		PCALL(bcnTAB_STR,'SP','M197',1); Punchb(2);
		
		PCALL(bcnTAB_STR,'SP','M199',1); Punchb(2);
		
	END;
	
	IF IsChannel(2) THEN
	BEGIN
		PCALL(OUTPUT_NC_tab_str,'SP','M182',CONST_YES);
		writeb;
		
		PCALL(OUTPUT_NC_tab_str,'SP','G28 U0. V0.',CONST_YES);
		writeb;
		PCALL(OUTPUT_NC_tab_str,'SP','G28 W0.',CONST_YES);
		writeb;
		
		{select rework spindle}
		PCALL(OUTPUT_NC_tab_str,'SP','M427',CONST_YES);
		writeb;
		{blow thru rework spindle}
		PCALL(OUTPUT_NC_tab_str,'SP','M420',CONST_YES);
		writeb;
		
		{select rework spindle}
		PCALL(OUTPUT_NC_tab_str,'SP','M441',CONST_YES); 
		writeb;
		{stop rework spindle rotation}
		PCALL(OUTPUT_NC_tab_str,'SP','M55',CONST_YES);
		writeb;
		{Open rework spindle}
		PCALL(OUTPUT_NC_tab_str,'SP','M51',CONST_YES);
		writeb;
		{stop blow thru rework spindle}
		PCALL(OUTPUT_NC_tab_str,'SP','M421',CONST_YES);
		writeb;
		
		{select main spindle}
		PCALL(OUTPUT_NC_tab_str,'SP','M41',CONST_YES);
		writeb;
		{stop main spindle}
		PCALL(OUTPUT_NC_tab_str,'SP','M5',CONST_YES);
		writeb;
		
		PCALL(bcnTAB_STR,'SP','M198',1); Punchb(2);
		STRINGRD(LIB_STR_ENABLE_C_AXIS_MS,str_Read);
		PCALL(bcnTAB_STR,'SP',str_Read,1); Punchb(2);
		PCALL(bcnTAB_STR,'SP','G0 C0.',1); Punchb(2);
		
		PCALL(bcnTAB_STR,'SP','M197',1); Punchb(2);
		{open rework spindle}
		PCALL(bcnTAB_STR,'SP','M51',1); Punchb(2);
		
		PCALL(READ_PART_chuck_part_position,1,real_ZmorsMS, real_ZminMS, real_ZmaxMS, real_ZOriMS);
		PCALL(READ_PART_chuck_part_position,2,real_ZmorsRS, real_ZminRS, real_ZmaxRS, real_ZOriRS);
		real_PartLength := real_ZmaxMS - real_ZminMS;
		real_DistSpindle := DistanceBetweenSpindles(real_PartLength,real_ZmorsMS,real_ZminMS, real_ZmorsRS, real_ZminRS);

		
		{B approach}
		PCALL(WRITE_NC_init_g,0);
		OutputNCRapid;
		PCALL(OUTPUT_NC_tab,'B', (real_DistSpindle - real_DistBetweenSpindles - real_ZminRS + 5), CONST_YES);
		writeb;
		
		{B G1}
		OutputNCG1;
		PCALL(OUTPUT_NC_tab,'B',(real_DistSpindle-real_DistBetweenSpindles),CONST_YES);
		PCALL(OUTPUT_NC_tab,'F', 1000, CONST_YES);
		writeb;
		
		
		{close rework spindle}
		PCALL(OUTPUT_NC_tab_str,'SP', 'M50',CONST_YES);
		writeb;
		OutputDwell(1);
		writeb;
		
		
		
	END;
	
	
	DebugEnd;
END;

{----------------------------------------------------------------------------}
PROCEDURE ReturnReworkSpindle;
{----------------------------------------------------------------------------}
VAR
	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'ReturnReworkSpindle');
	DebugBegin(str_ProcName,CONST_NO);
	
	IF IsChannel(2) THEN
	BEGIN
		
		{open main spindle}
		PCALL(OUTPUT_NC_tab_str,'SP','M10',CONST_YES);
		writeb;
		OutputDwell(1);
		writeb;
		
		{back rework spindle}
		
		PCALL(bcnTAB_STR,'SP','G28 B0. M9',1); Punchb(2);

		PCALL(bcnTAB_STR,'SP','M199',1); Punchb(2);
		
	END;
	
	DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE StartSpecific;
{----------------------------------------------------------------------------}
VAR
	int_Channel,int_CycleNo,int_IsLastOperationTurret
	: INTEGER;
	
	str_ProcName 
	: TC255;
BEGIN
	strcpy(str_ProcName,'StartSpecific');
	DebugBegin(str_ProcName,CONST_NO);

	PCALL(litNUM_CANAL,int_Channel);
	PCALL(READ_PART_cycle_no,int_CycleNo);
	
	int_IsLastOperationTurret := ICALL(TEST_last_cycle,CONST_YES);

	IF IsOutputToolChange AND (int_IsLastOperationTurret = 1) AND (int_Channel = 1) THEN 
	BEGIN
		{ Uebergabe_Abstechen_Kanal_1; }
	END;

	IF IsPartingReworkOperation AND (INTRD(SPE_LIST_USE_DAT_FILE) = 0) THEN
	BEGIN
		OutputSynchroToolpath(2);
		OutputOperationComment;
		ApproachReworkSpindle;
		IF IsChannel(2) THEN
		BEGIN
			PCALL(OUTPUT_NC_tab_str,'SP','M199',CONST_YES);
			writeb;
			PCALL(OUTPUT_NC_tab_str,'SP','M197',CONST_YES);
			writeb;
		END;
		IF IsChannel(1) THEN
		BEGIN
			PCALL(OUTPUT_NC_tab_str,'SP','M197',CONST_YES);
			writeb;
			PCALL(OUTPUT_NC_tab_str,'SP','M199',CONST_YES);
			writeb;
		END;
	END;

	DebugEnd;
END;

{----------------------------------------------------------------------------}
PROCEDURE EndSpecific;
{----------------------------------------------------------------------------}
VAR
	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'EndSpecific');
	DebugBegin(str_ProcName,CONST_NO);

	OutputSynchroToolpath(-2);

	IF IsPartingReworkOperation AND (INTRD(SPE_LIST_USE_DAT_FILE) = 0) THEN
	BEGIN
		ReturnReworkSpindle;
	END;
	
	ACTIVE_PUNCH;
	
	DebugEnd;
END;{@}

{----------------------------------------------------------------------------}
PROCEDURE OutputReworkPart;
{----------------------------------------------------------------------------}
VAR
	str_Read : TC255;
	real_Angle,real_ZmorsMS, real_ZminMS, real_ZmaxMS, real_ZOriMS,real_ZmorsRS, real_ZminRS, real_ZmaxRS, real_ZOriRS : REAL;
	real_PartLength,real_DistSpindle,real_DistBetweenSpindles : REAL;
	str_ProcName : TC255;
	
BEGIN
	strcpy(str_ProcName,'OutputReworkPart');
	DebugBegin(str_ProcName,CONST_NO);


	PCALL(lit_RTEC,RM_BROCHE_DECAL,real_DistBetweenSpindles); 

		ApproachReworkSpindle;
	IF IsChannel(1) THEN
	BEGIN

		
	END;
	
	IF IsChannel(2) THEN
	BEGIN
		
		ReturnReworkSpindle;
		
	END;


	DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE CoolantOn;
{----------------------------------------------------------------------------}
VAR
	int_PartCoolant,int_ToolNb,int_ToolLengthOffset,int_ToolDiaOffset, int_CurCool
	:INTEGER;
	
	str_ProcName 
	: TC255;

BEGIN
	strcpy(str_ProcName,'CoolantOn');
	DebugBegin(str_ProcName,CONST_NO);

	PCALL(READ_PART_tool,int_ToolNb,int_ToolLengthOffset,int_ToolDiaOffset);
	PCALL(READ_PART_coolant,int_PartCoolant);
	
	int_ToolNb 								:= INTRD(SPE_AKTUELLES_WERKZEUG); 
	int_ToolLengthOffset 			:= INTRD(SPE_AKTUELL_WZ_LAENGE_OFFSET); 
	
	Werkzeugnummer_Offset_Berechnung;
	
	IF IsOutputToolChange OR (int_ToolLengthOffset <> INTRD(SPE_OLD_WZ_LAENGE_OFFSET)) OR
	(INTRD(SPE_WZ_WECHSEL_ERZWINGEN) = 1) THEN
		BEGIN
			OutputNCCoolant(int_PartCoolant);
			{ PCALL(WRITE_NC_coolant,int_PartCoolant); }
			writeb;
			PCALL(READ_NC_coolant,int_CurCool);

			BEGIN
			{ IF int_PartCoolant = 1 THEN PCALL(bcnTAB_STR,'SP','M8',1); Punchb(2); }
			
			{ IF int_PartCoolant = 2 THEN  }
				{ BEGIN }
				{ PCALL(bcnTAB_STR,'SP','M742',1); Punchb(2); }
				{ PCALL(bcnTAB_STR,'SP','M8',1); Punchb(2); }
				{ END; }
			{
			IF int_PartCoolant = 3 THEN PCALL(bcnTAB_STR,'SP','(AUSSEN LUFTKUEHLUNG EIN)',1); Punchb(2);
			IF int_PartCoolant = 4 THEN PCALL(bcnTAB_STR,'SP','(INNEN LUFTKUEHLUNG EIN)',1); Punchb(2);
			IF int_PartCoolant = 5 THEN PCALL(bcnTAB_STR,'SP','(INNENKUEHLUNG STUFE 2 EIN)',1); Punchb(2);
			IF int_PartCoolant = 6 THEN PCALL(bcnTAB_STR,'SP','(INNENKUEHLUNG STUFE 3 EIN)',1); Punchb(2);
			IF int_PartCoolant = 7 THEN PCALL(bcnTAB_STR,'SP','(INNENKUEHLUNG STUFE 4 EIN)',1); Punchb(2);
			IF int_PartCoolant = 8 THEN PCALL(bcnTAB_STR,'SP','(INNENKUEHLUNG STUFE 5 EIN)',1); Punchb(2);
			IF int_PartCoolant = 9 THEN PCALL(bcnTAB_STR,'SP','(INNENKUEHLUNG STUFE 6 EIN)',1); Punchb(2);
			IF int_PartCoolant = 10 THEN PCALL(bcnTAB_STR,'SP','(INNENKUEHLUNG STUFE 7 EIN)',1); Punchb(2);
			}
			END;
		END;
		
	DebugEnd;
END;



{----------------------------------------------------------------------------}
PROCEDURE OutputStopCoolant;
{----------------------------------------------------------------------------}
VAR
	int_IsToolChange,int_IsPlaneChange,int_PartCoolant, int_CurCool,int_IsToolChangePocket
	:INTEGER;
	int_CurTurret,int_Tool,int_Post, int_Index : INTEGER;
	int_NextTool,int_NextPost, int_NextIndex : INTEGER;
	str_ProcName, str_Tool 
	: TC255;
	
BEGIN
	strcpy(str_ProcName,'OutputStopCoolant');
	DebugBegin(str_ProcName,CONST_NO);
	
	PCALL(READ_PART_coolant,int_PartCoolant);
	PCALL(READ_PART_turret_no,int_CurTurret);
	
	int_IsToolChange := ICALL(TEST_CHANGE_TOOL);
	int_IsPlaneChange := ICALL(TEST_CHANGE_PLANE);
	
	int_IsToolChangePocket := ICALL(TEST_change_tool_pocket_turret);

	PCALL(READ_PART_next_tool_turret_INFOS,int_CurTurret,int_NextTool,int_NextPost, int_NextIndex, str_Tool);
	PCALL(READ_PART_tool_no, int_Tool);
	PCALL(READ_PART_tool_post_index,int_Post,int_Index);

	{ IF IsOutputToolChange THEN }
	{we change the test because TEST_change_tool_pocket_turret doesn't work properly in IsOutputToolChange }
	IF (int_Tool <> int_NextTool) OR (int_Post <> int_NextPost) OR (int_Index <> int_NextIndex) THEN
		BEGIN
		PCALL(READ_NC_coolant,int_CurCool);
		OutputNCCoolant(0);
		writeb;
		{ IF int_PartCoolant = 1 THEN PCALL(bcnTAB_STR,'SP','M9',1); Punchb(2); }
		
		{ IF int_PartCoolant = 2 THEN  }
			{ BEGIN }
			{ PCALL(bcnTAB_STR,'SP','M9',1); Punchb(2); }
			{ PCALL(bcnTAB_STR,'SP','M743',1); Punchb(2); }
			{ END; }
		
		{
		IF int_PartCoolant = 3 THEN PCALL(bcnTAB_STR,'SP','M9',1); Punchb(2);
		IF int_PartCoolant = 4 THEN PCALL(bcnTAB_STR,'SP','M9',1); Punchb(2);
		IF int_PartCoolant = 5 THEN PCALL(bcnTAB_STR,'SP','M9',1); Punchb(2);
		IF int_PartCoolant = 6 THEN PCALL(bcnTAB_STR,'SP','M9',1); Punchb(2);
		IF int_PartCoolant = 7 THEN PCALL(bcnTAB_STR,'SP','M9',1); Punchb(2);
		IF int_PartCoolant = 8 THEN PCALL(bcnTAB_STR,'SP','M9',1); Punchb(2);
		IF int_PartCoolant = 9 THEN PCALL(bcnTAB_STR,'SP','M9',1); Punchb(2);
		IF int_PartCoolant = 10 THEN PCALL(bcnTAB_STR,'SP','M9',1); Punchb(2);
		}

		END;
		
	DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE StartProgram;	{Programm Start}
{----------------------------------------------------------------------------}
VAR
	int_Type,int_Channel
	: INTEGER;
	str_DatSection : TC255;
	str_ProcName
	: TC255;
	
BEGIN
	strcpy(str_ProcName,'StartProgram');
	DebugBegin(str_ProcName,CONST_NO);

	INTWR(SPE_PUNCH_ACTIF,1);
	PCALL(READ_PART_customer_type,int_Type);
	PCALL(litNUM_CANAL,int_Channel);
	
	PCALL(WRITE_NC_block_no,10);

	OutputStartProgramNumber;
	OutputHeader;
	
	Werkzeugnummer_Offset_Berechnung;
	{ Werkzeugliste; }
	OutputListTool;
	PCALL(WRITE_NC_init_key,'Origin');
	strcpy(str_DatSection,'START_CHANNEL');
	ConcatVal(str_DatSection,int_Channel,0);
	{standard output}
	IF INTRD(SPE_LIST_USE_DAT_FILE) = 0 THEN
	BEGIN
		IF int_Channel = 1 THEN 
		BEGIN
			Programmkopf_Kanal_1;
		END
		ELSE IF int_Channel = 2 THEN 
		BEGIN
			Programmkopf_Kanal_2;
		END;
	END
	ELSE
	BEGIN
		{output from dat file}
		OutputDatSectionSpe(str_DatSection);
	END;
	
	
	OutputStartComment;
	OutputListOrigin;
	OutputG10ForOrigin;
	OutputStock;
	OutputStartFixedBlock;
	
	INTWR(SPE_G8P1,0);
	INTWR(SPE_M471,0);
	INTWR(SPE_C_KLEMMEN,0);
	INTWR(SPE_INT_NB_PARTING_DONE,0);
	
	DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE EndProgram;
{----------------------------------------------------------------------------}
VAR
	int_Channel : INTEGER;
	str_DatSection : TC255;
	str_ProcName 
	: TC255;
	
BEGIN
	strcpy(str_ProcName,'EndProgram');
	DebugBegin(str_ProcName,CONST_NO);
	
	PCALL(READ_PART_channel_no,int_Channel);
	
	IF INTRD(SPE_LIST_USE_DAT_FILE) = 0 THEN
	BEGIN
		PCALL(OUTPUT_NC_tab_str,'SP','G28 U0. V0.',CONST_YES);
		writeb;
		
		OutputEndProgram;
	END
	ELSE
	BEGIN
		strcpy(str_DatSection,'END_CHANNEL');
		ConcatVal(str_DatSection,int_Channel,0);
		OutputDatSectionSpe(str_DatSection);
	END;
	
	
	DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE StartOperation;
{----------------------------------------------------------------------------}
VAR
	int_OutputCoolantPosition,num_cycle,int_CycleType,int_ToolNb,int_ToolLengthOffset,int_ToolDiaOffset
	int_Type,int_IsChangeCycle,int_Erste_Dreh_OP,int_Channel,int_Spindel_pruefen,int_Kanal_Aktiv,int_CycleNo
	int_IsLastOperationTurret, int_BlockNo, int_Incr, int_NumPlane, int_NbParting
	:INTEGER;

	SicherheitsEbene_Z,real_PosZ,real_PosZ_Axial,real_PosZ_Radial,real_RayExt
	:REAL;

	str_ProcName
	: TC255;
	
	tr3_Pt
	:TR3;
	
BEGIN
	strcpy(str_ProcName,'StartOperation');
	DebugBegin(str_ProcName,CONST_NO);
		
	IF IsMillingOperation AND IsOutputToolChange THEN
	BEGIN
		PCALL(WRITE_NC_force_primary);
	END;
		
		InitPlane(int_NumPlane);
		{ writeln('                 num plane : ', int_NumPlane); }
		
	PCALL(litNUM_CYCLE,num_cycle);
	PCALL(READ_PART_pp_cycle_no,int_CycleType);	
	PCALL(lit_RTEC,RTF_VALEUR_GARDE,SicherheitsEbene_Z);
	PCALL(READ_PART_SPINDLE_TYPE,int_Spindel_pruefen);
	PCALL(READ_PART_cycle_no,int_CycleNo);

	PCALL(READ_PART_tool,int_ToolNb,int_ToolLengthOffset,int_ToolDiaOffset);
	PCALL(litNUM_CANAL,int_Channel);

	{We increment the number of parting done to detest the last parting cycle to output correctly the M797}
	IF int_CycleNo = CONST_PARTING THEN 
	BEGIN
		int_NbParting := INTRD(SPE_INT_NB_PARTING_DONE);
		INTWR(SPE_INT_NB_PARTING_DONE,(int_NbParting+1));
		
	END;

	Werkzeugnummer_Offset_Berechnung;

	int_IsChangeCycle 				:= ICALL(TEST_CHANGE_CYCLE);
	int_Erste_Dreh_OP 				:= ICALL(TEST_first_tool_turning);
	int_IsLastOperationTurret := ICALL(TEST_last_cycle,CONST_YES);
	{ int_OutputCoolantPosition := -1; }
	int_ToolNb 								:= INTRD(SPE_AKTUELLES_WERKZEUG); 
	int_ToolLengthOffset 			:= INTRD(SPE_AKTUELL_WZ_LAENGE_OFFSET); 
	
	InitPlaneKey;
	
	IF (INTRD(SPE_WZ_WECHSEL_ERZWINGEN) = 1) THEN Freifahren_Ende;
	
	IF (INTRD(LIB_LIST_COMMENTS) = CONST_YES) THEN
	BEGIN
		Freifahren_Start;
	END;
	
	{ IF INTRD(SPE_LIST_USE_G411) = 1 THEN PCALL(WRITE_NC_block_format,0); }
	OutputOperationComment;
	{ IF INTRD(SPE_LIST_USE_G411) = 1 THEN PCALL(WRITE_NC_block_format,2); }
	
	
	OutputSynchroToolpath(2);
	
	IF IsOutputToolChange OR (int_ToolLengthOffset <> INTRD(SPE_OLD_WZ_LAENGE_OFFSET)) OR (INTRD(SPE_WZ_WECHSEL_ERZWINGEN) = 1) THEN
	BEGIN
		
		IF INTRD(SPE_LIST_USE_G411) = 1 THEN
		BEGIN
			PCALL(OUTPUT_NC_g,411,CONST_YES);
			If IsReworkSpindle THEN PCALL(OUTPUT_NC_tab, 'G411_R' ,1,CONST_YES)
				ELSE PCALL(OUTPUT_NC_tab, 'G411_L',1,CONST_YES);
			PCALL(READ_NC_block_no,int_BlockNo);
			{ IF ICALL(TEST_last_cycle,CONST_YES) = CONST_YES THEN int_BlockNo := 5000; }
			PCALL(READ_PART_integer_tec,GPP_INTEGER_SYNCHRO_INCREMENT, int_Incr);

			PCALL(OUTPUT_NC_tab, 'G411_I',int_BlockNo,CONST_YES);
			INTWR(SPE_INT_BLOCK_NO_G411,int_BlockNo);
			writeb;
		END;
		IF int_IsLastOperationTurret = 1 THEN						{Letzte Revolver OP - Uebergabe mit Abstechen}
		BEGIN
		{ IF (int_Channel = 2) AND (int_CycleNo = CONST_PARTING) THEN  }
			{ BEGIN }
				{ Uebergabe_Abstechen_Kanal_2_Start; }
				{ ApproachReworkSpindle; }
			{ END; }
		END;
		IF IsPartingReworkOperation THEN
		BEGIN
			
			ApproachReworkSpindle;
			PCALL(OUTPUT_NC_tab_str,'SP', 'M96',CONST_YES);
			writeb;
			
		END;
		

		Befehl_P8_P1;
		
		IF (num_cycle = DPP_SET_BUTEE_TOUR) THEN 				{Mit Anschlag}
		BEGIN
			{ Anschlag_Start_Kanal_2; }
		END;
		
		IF IsMillingOperation THEN 											{Fraes-Operationen}
		BEGIN
			IF (int_Spindel_pruefen = CONST_MAIN_SPINDLE)	THEN
				BEGIN
				PCALL(bcnM,5,1); writeb;	{Nach Fraesen Spindel Stop}
				END
			ELSE IF (int_Spindel_pruefen = CONST_REWORK_SPINDLE)THEN
				BEGIN
				PCALL(bcnM,55,1); writeb;	{Nach Fraesen Spindel Stop}
				END;
			{PCALL(bcnTAB_STR,'SP','  (DREHSPINDEL STOP)',1); writeb;}
		END
		ELSE																						{Dreh-Operationen}					
		BEGIN
			IF (int_Spindel_pruefen = CONST_MAIN_SPINDLE)	THEN
				BEGIN
				PCALL(bcnTAB_STR,'SP','M428',1); writeb;
				END
			ELSE IF (int_Spindel_pruefen = CONST_REWORK_SPINDLE)THEN
				BEGIN
				PCALL(bcnTAB_STR,'SP','M427',1); writeb; 
				END;
		END;
	END
	ELSE IF (INTRD(LIB_LIST_COMMENTS) = CONST_YES) THEN
	BEGIN 
		PCALL(bcnTAB_STR,'SP',' ',CONST_YES); Punchb(2);
		{ PCALL(OUTPUT_NC_comment_cycle);  }
	END;

	OutputPlaneChange;			{Nullpunkt + Ebene}

{for radial plane we offset toolpath to have correct X value}
	IF (int_NumPlane = 131) or (int_NumPlane = 151) THEN
	BEGIN
		PCALL(READ_PART_plane_radius,real_RayExt);

		PCALL(WRITE_NC_coord_translate,0,0,real_RayExt);
	END;

	IF int_IsChangeCycle = 1 THEN
	BEGIN
		OutputFeedParam;
		OutputToolChange;
		OutputSynchroToolpath(1);
		
		IF IsOutputToolChange OR (int_ToolLengthOffset <> INTRD(SPE_OLD_WZ_LAENGE_OFFSET)) OR 
			(INTRD(SPE_WZ_WECHSEL_ERZWINGEN) = 1) THEN
		BEGIN
			IF not IsMillingOperation THEN
			BEGIN
				IF (int_Spindel_pruefen = CONST_MAIN_SPINDLE) THEN 				{HS Bearbeitungen}
				BEGIN
					PCALL(bcnTAB_STR,'SP','M41',1); Punchb(2);
				END
				ELSE IF Int_Spindel_Pruefen = CONST_REWORK_SPINDLE THEN 	{GS Bearbeitungen}
				BEGIN
					PCALL(bcnTAB_STR,'SP','M441',1); Punchb(2);
				END;
			END;
		END;
		IF not IsMillingOperation AND IsOutputToolChange THEN
		BEGIN
			PCALL(OUTPUT_NC_m,371,CONST_YES);
			writeb;
		END;
		
		
		CoolantOn;
	
		IF (num_cycle <> DPP_SET_BUTEE_TOUR) THEN OutputSpindleOn;

		IF not IsMillingOperation AND IsOutputToolChange THEN
		BEGIN
			PCALL(WRITE_NC_g_force,0);
			OutputNCRapid;
			PCALL(OUTPUT_NC_paxis3,0,CONST_YES);
			writeb;
		END;
		
		{for dev plane we force Y0}
		IF (int_NumPlane = 131) or (int_NumPlane = 151) THEN
		BEGIN
			PCALL(WRITE_NC_g_force,0);
			OutputNCRapid;
			PCALL(OUTPUT_NC_tab,'Y',0, CONST_YES);
			writeb;
		END;
		
		IF IsOutputToolChange OR (int_ToolLengthOffset <> INTRD(SPE_OLD_WZ_LAENGE_OFFSET)) OR 
			(INTRD(SPE_WZ_WECHSEL_ERZWINGEN) = 1) THEN
		BEGIN
			IF (num_cycle = DPP_SET_BUTEE_TOUR) THEN 				{Nur bei Anschlag schreiben}
			BEGIN
				
			END
			ELSE																						{Alle anderen Operationen}
			BEGIN
				{for axial polar plane we force Y0}
				IF (int_NumPlane = 120) OR (int_NumPlane = 140) THEN
				BEGIN
					{ PCALL(WRITE_NC_g_force,0); }
					OutputNCRapid;
					PCALL(OUTPUT_NC_tab,'Y',0, CONST_YES);
					{ writeb; }
				END;
				Z_Achse_Anfahren;															{Z-Achse als erstes schreiben}
			END;
		END;
		
		IF IsDevZPlane THEN PCALL(bcnTAB_STR,'SP','G19 H0. W0.',1); Punchb(2);	{Bei Abwicklung G07.1 schreiben}

		OutputZApproach;
	END;
		
	INTWR(SPE_WZ_WECHSEL_ERZWINGEN,0);
	INTWR(SPE_INT_FORCE_TOOL_CHANGE,0);
	DebugEnd;
END;

{----------------------------------------------------------------------------}
PROCEDURE StartMillOperation;
{----------------------------------------------------------------------------}
VAR
	tr3_Pt :TR3;
	int_OutputCoolantPosition :INTEGER;
	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'StartMillOperation');
	DebugBegin(str_ProcName,CONST_NO);
	int_OutputCoolantPosition:=1;
	StartOperation;

	OutputCoolant(int_OutputCoolantPosition);
	{2023-04-21 XP only output G05.1 Q1 if we change tool}
	IF (ICALL(TEST_HOLE_CYCLE) = CONST_NO) AND IsOutputToolChange THEN
	BEGIN
		PCALL(OUTPUT_NC_tab_str,'SP','G05.1 Q1',CONST_YES);
		writeb;
	END;
	OutputDepPlan;
	IF IsAxialPlane AND not IsAxialInterpoPlane AND not IsPAPCycle THEN OutputClampCAxis;
	OutputCoolant(int_OutputCoolantPosition);
	OutputDepPlunge;
	{ IF IsAxialPlane AND not IsAxialInterpoPlane AND IsPAPCycle THEN OutputClampCAxis; }


	DebugEnd;
END;{@}

{----------------------------------------------------------------------------}
PROCEDURE EndOperation;
{----------------------------------------------------------------------------}
VAR
	Ilastoperation,int_ToolNb,int_ToolLengthOffset,int_ToolDiaOffset,num_cycle
	int_IsLastOperationTurret,int_Channel,int_CycleNo,int_BlockNo, int_NextCycle, int_FindBeforeEnd
	: INTEGER;
	
	Anschlag_End_Z
	: REAL;
	
	str_ProcName,str_Read,str_Ret,str_Anschlag_End_Z,str_1, str_Operation 
	: TC255;
	
BEGIN
	strcpy(str_ProcName,'EndOperation');
	DebugBegin(str_ProcName,CONST_NO);
	
	int_IsLastOperationTurret := ICALL(TEST_last_cycle,CONST_YES);
	Ilastoperation 						:= ICALL(isDERNIER_OPERATION,CONST_NO);
	Anschlag_End_Z						:= DOUBLERD(SPE_ANSCHLAG_END_Z);

	If IsChangeCycle THEN
	BEGIN
		{ PCALL(READ_PART_next_cycle,0,CONST_YES,CONST_YES,int_NextCycle,int_FindBeforeEnd); }
		PCALL(READ_PART_next_customer_type,int_NextCycle);
		{ PCALL(READ_PART_cycle_name, str_Operation); }
		{ writeln('                op name : ', str_Operation); }
		{ writeln('            next parking ', int_NextCycle); }
		IF int_NextCycle = CONST_PARKING THEN
		BEGIN
			INTWR(SPE_INT_FORCE_TOOL_CHANGE,1);
		END;
	END;

	PCALL(READ_PART_tool,int_ToolNb,int_ToolLengthOffset,int_ToolDiaOffset);
	PCALL(litNUM_CYCLE,num_cycle);
	PCALL(litNUM_CANAL,int_Channel);
	PCALL(READ_PART_cycle_no,int_CycleNo);

	int_ToolNb 								:= INTRD(SPE_AKTUELLES_WERKZEUG); 
	int_ToolLengthOffset 			:= INTRD(SPE_AKTUELL_WZ_LAENGE_OFFSET); 

	OutputPlaneCancel;
	
	
	OutputStopCoolant;
	
	
	IF (INTRD(SPE_WZ_WECHSEL_ERZWINGEN) <> 1) OR IsOutputToolChange THEN 
		BEGIN
		Freifahren_Ende;	{Freifahren + Kuehlung}
		END;

	IF IsRadialPlane THEN
		BEGIN

		END
	ELSE
		BEGIN
		INTWR(SPE_GEWINDE_M329,0);	{Fuer Gewinde + G07.1 Flag}
	END;
	
	IF Ilastoperation = 1 THEN
		BEGIN
		IF IsRadialPlane THEN
			BEGIN
			INTWR(SPE_GEWINDE_M329,0);	{Fuer Gewinde + G07.1 Flag}
			END;
		END;
		
	INTWR(SPE_WZ_WECHSEL_ERZWINGEN,0); 

	
	IF IsOutputToolChange THEN 
	BEGIN
		
		IF int_IsLastOperationTurret = 1 THEN						{Letzte Revolver OP - Uebergabe mit Abstechen}
			BEGIN
			IF (int_Channel = 2) AND (int_CycleNo = CONST_PARTING) THEN 
				BEGIN
				{ Uebergabe_Abstechen_Kanal_2_Ende; }
				ReturnReworkSpindle;
				END;
			END;
		
		INTWR(SPE_C_KLEMMEN,0);
		
		PCALL(OUTPUT_NC_line_feed,CONST_YES);
		IF INTRD(SPE_LIST_USE_G411) = CONST_YES THEN
		BEGIN
			PCALL(WRITE_NC_block_format,0);
			int_BlockNo := INTRD(SPE_INT_BLOCK_NO_G411);
			PCALL(WRITE_NC_block_no,int_BlockNo);
			PCALL(OUTPUT_NC_tab_str,'SP',' ',CONST_YES);
			writeb;
			PCALL(WRITE_NC_block_format,2);
		END;
		
	END;
	IF IsPartingReworkOperation THEN
	BEGIN
		
		PCALL(OUTPUT_NC_tab_str,'SP', 'M197',CONST_YES);
		writeb;
		PCALL(OUTPUT_NC_tab_str,'SP', 'M199',CONST_YES);
		writeb;
	END;
		
	ACTIVE_PUNCH;			{Zyklus aktivieren}
	IF IsPartingReworkOperation THEN
	BEGIN
		ZYKLUS_DEAKTIVIEREN;
	END;
	

	
	PCALL(OUTPUT_NC_punch_validate,CONST_YES);
	
	DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE OutputG10ForOrigin;
{----------------------------------------------------------------------------}
VAR
	int_OffsetNb,i,int_StrLen 
	:INTEGER;
	
	real_OriNum, real_LValue, real_PValue 
	:REAL;
	
	str_ProcName,str_OriName,str_OriNum,str_Temp, str_Output,str_Search,str_Null 
	: TC255;
	
BEGIN
	strcpy(str_ProcName,'OutputG10ForOrigin');
	DebugBegin(str_ProcName,CONST_NO);
	str_OriName[0] 	:= chr(0);
	str_Null[0] 		:= chr(0);
	
	IF INTRD(STD_LIST_USE_G10_FOR_ORIGIN) = 1 THEN
		BEGIN
		i:=1;
		REPEAT
			GetOriInOriginArray(i,str_OriName);
			IF str_OriName[0] <> chr(0) THEN
				BEGIN
				str_range(str_Temp,str_OriName,1,strlen(str_OriName));
				str_atof(str_Temp,real_OriNum);
				
				IF (real_OriNum < 55) AND (real_OriNum > 54) THEN
					BEGIN
					real_LValue := 20;
					strcpy(str_Search,'54.');
					StringReplace(str_Temp,str_Search,str_Null);
					str_atof(str_Temp,real_PValue);
					END
				ELSE
					BEGIN
					real_LValue := 2;
					real_PValue := real_OriNum-53;
					END;
				END;

			i := i + 1;
		UNTIL str_OriName[0] = chr(0);
	END;

	DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE Origin;
{----------------------------------------------------------------------------}
VAR
	real_Val, real_LastOri,real_DecX,real_DecY,real_DecZ 
	: REAL;
	
	i,int_BActive,int_NumPlane,int_Err,int_LenDec,int_Coeff,int_Spindel_pruefen,int_Channel
	: INTEGER;
	
	str_ProcName,str_OriName,str_Letter,str_Temp,str_Search,str_Null 
	: TC255;
	
BEGIN
	strcpy(str_ProcName,'Origin');
	DebugBegin(str_ProcName,CONST_NO);

	PCALL(READ_NC_key,'Origin',real_LastOri, int_BActive);
	PCALL(litNUM_CANAL,int_Channel);
	PCALL(READ_PART_SPINDLE_TYPE,int_Spindel_pruefen);
	
	GetOriginNameFromCycle(str_OriName);

	str_range(str_Temp,str_OriName,1,strlen(str_OriName));
	str_atof(str_Temp,real_Val);
	
	IF (real_Val > 54) AND (real_Val < 55) THEN
		BEGIN
		strcpy(str_Search,'54.');
		str_Null[0] := chr(0);
		StringReplace(str_Temp,str_Search,str_Null);
		int_LenDec := strlen(str_Temp);
		int_Coeff := 1;
		FOR i := 1 to int_LenDec DO
			BEGIN
			int_Coeff := int_Coeff * 10;
			END;
			
		real_Val := real_Val * int_Coeff;
		END;
	{to force the output}
	real_LastOri := -1;
	IF IsNotEqual(real_LastOri,real_Val) OR IsOutputPlane THEN
		BEGIN

		IF (real_Val > 540) THEN
			BEGIN
			int_Err := ICALL(TEST_select_string_tec, TEC_PPCLEF, GPP_STRING_KEY, 'Origin');
			IF int_Err = CONST_YES THEN PCALL(WRITE_DPP_integer,GPP_INTEGER_KEY_NBDEC_MINI,int_LenDec);

			PCALL(OUTPUT_NC_tab,'Origin',(real_Val / int_Coeff),CONST_NO); writeb;
			PCALL(WRITE_NC_key, 'Origin', real_Val);

			int_Err := ICALL(TEST_select_string_tec, TEC_PPCLEF, GPP_STRING_KEY, 'Origin');
			IF int_Err = CONST_YES THEN PCALL(WRITE_DPP_integer,GPP_INTEGER_KEY_NBDEC_MINI,0);
			END
		ELSE
			BEGIN
				{ writeln('                    ori val : ', real_Val); }
				PCALL(OUTPUT_NC_tab,'Origin',real_Val,CONST_YES);
				PCALL(OUTPUT_NC_g,40,CONST_YES);
				writeb;
				{CAM TEAM original treatment}
			{ IF (int_Spindel_pruefen = CONST_MAIN_SPINDLE)	THEN  }
				{ BEGIN						 }
				{ IF (int_Channel = 1) OR (int_Channel = 2) THEN }
					{ BEGIN }
					{ PCALL(bcnTAB_STR,'SP','G54 G40',1); Punchb(2); }
					{ END; }
				{ END }
			{ ELSE																			 }
				{ BEGIN }
				{ IF (int_Channel = 1) OR (int_Channel = 2) THEN }
					{ BEGIN }
					{ PCALL(bcnTAB_STR,'SP','G55 G40',1); Punchb(2); }
					{ END; }
				{ END; }
				{END CAM TEAM original treatment}
		END;
	END;
	
	DebugEnd;
END;

{----------------------------------------------------------------------------}
PROCEDURE GetOriginNameFromCycle{(VAR str_OriName : TC255)};
{----------------------------------------------------------------------------}
VAR
	int_NumPlane : INTEGER;
	real_Val : REAL;
	str_Letter : TC255;
	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'GetOriginNameFromCycle');
	DebugBegin(str_ProcName,CONST_NO);

	PCALL(READ_PART_origin_no,int_NumPlane);
	{We try to decode the origin name in the name of origin}
	{The origin is code between the two characters $ and _}
	{For example for G54 for Fanuc $G54_}
	{For example for 1 for parameter Q339 for heidenhain $1_}
	DecodeOriginName(str_OriName);

	{If the origin code is not find we take the default origin of the machine}
	IF (str_OriName[0] = chr(0)) THEN
	BEGIN
		real_Val := INTRD(SPE_INT_PACK_MAIN_SPINDLE_ORIGIN);
		{in rework spindle we have G55 as default origin}
		IF IsReworkSpindle THEN real_Val := INTRD(SPE_INT_PACK_REWORK_SPINDLE_ORIGIN);
		IF INTRD(LIB_LIST_MULTI_ORIGIN) = 0 THEN
			real_Val := real_Val + int_NumPlane;
		strcpy(str_Letter,'G');
		ConcatStrVal(str_OriName,str_Letter,real_Val,0);
	END;


	DebugEnd;
END;{@}

{----------------------------------------------------------------------------}
PROCEDURE OutputOperationComment_CAMTeam;
{----------------------------------------------------------------------------}
VAR
	int_IsChangeCycle,T_Nummer,numcorlg,numcordia,I_Endung_Enfernen,int_ToolNb,int_ToolLengthOffset
	int_ToolDiaOffset,num_cycle             
	:INTEGER;
	
	str_ProcName,str_Operation_Name,str_1,str_Operation_Name_ohne_Endung
	: TC255;
	
BEGIN
	strcpy(str_ProcName,'OutputOperationComment');
	DebugBegin(str_ProcName,CONST_NO);
	int_IsChangeCycle := ICALL(TEST_CHANGE_CYCLE);
	
	PCALL(litNUM_CYCLE,num_cycle);
	PCALL(READ_PART_tool,int_ToolNb,int_ToolLengthOffset,int_ToolDiaOffset);
	PCALL(litNOM_CYCLE,str_Operation_Name);
	
	Werkzeugnummer_Offset_Berechnung;
	int_ToolNb 						:= INTRD(SPE_AKTUELLES_WERKZEUG); 
	int_ToolLengthOffset 	:= INTRD(SPE_AKTUELL_WZ_LAENGE_OFFSET); 
	I_Endung_Enfernen 		:= ICALL(SPI_FIL_remove_extension,str_Operation_Name,str_Operation_Name_ohne_Endung);

	IF (INTRD(LIB_LIST_COMMENTS) = CONST_YES) THEN
		BEGIN

		IF int_IsChangeCycle = CONST_YES THEN 
			BEGIN
			IF num_cycle <> 255 THEN PCALL(bcnTAB_STR,'SP',' ',CONST_YES); {Punchb(2);}	{Manuelle Eingaben nicht schreiben}
			
			IF (IsOutputToolChange AND (num_cycle <> 255)) OR ((INTRD(SPE_OLD_WZ_LAENGE_OFFSET) <> int_ToolLengthOffset) OR
			 (INTRD(SPE_WZ_WECHSEL_ERZWINGEN) = 1)) THEN
				BEGIN
				{PCALL(OUTPUT_NC_tab,'N',int_ToolLengthOffset,CONST_YES);}	{Satznummer = Korrektur Nr}
				
				strcpy(str_1,'(');
				strcat(str_1,str_Operation_Name_ohne_Endung);								{OP Kommentar}
				strcat(str_1,')');
				IF num_cycle <> 255 THEN PCALL(bcnTAB_STR,'SP',str_1,1); {Punchb(2);}	{OP Kommentar}
				END;
				writeb;
			END;
		END;
	DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE OutputToolComment;
{----------------------------------------------------------------------------}
VAR
	int_ToolNb,int_ToolLengthOffset,int_ToolDiaOffset
	:INTEGER;

	str_ProcName,str_1,str_Rev_X_Achse,str_2,str_Rev_Z_Achse,str_3,str_4
	: TC255;
	
	Rev_X_Achse,Rev_Z_Achse
	: REAL;
	
BEGIN
	strcpy(str_ProcName,'OutputToolComment');
	DebugBegin(str_ProcName,CONST_NO);

	DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE OutputNCRadiusOffsetNumber{(int_OffsetNo : INTEGER)};
{----------------------------------------------------------------------------}
VAR
	str_ProcName 
	: TC255;
	
BEGIN
	strcpy(str_ProcName,'OutputNCRadiusOffsetNumber');
	DebugBegin(str_ProcName,CONST_NO);
	
	DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE ToolChange{(int_ToolNb,int_ToolLengthOffset,int_IsFirstTool : INTEGER)};
{----------------------------------------------------------------------------}
VAR
	int_ToolChangeMode, int_NumActiveTool, int_BType :INTEGER;
	real_ToolSelected :REAL;
	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'ToolChange');
	DebugBegin(str_ProcName,CONST_NO);

	PCALL(READ_NC_key,'T',real_ToolSelected,int_BType); 

	PCALL(WRITE_NC_init_key,'T');
	PCALL(OUTPUT_NC_tab,'T',(100* int_ToolNb + int_ToolLengthOffset),CONST_NO);
	PCALL(OUTPUT_NC_comment_tool); Punchb(2);													{WZ-Kommentar}
	
	DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE OutputToolChange;
{----------------------------------------------------------------------------}
VAR
	int_ToolNb,int_IsFirstTool,int_ToolLengthOffset,int_ToolDiaOffset,I_WZ_Erzwingen_Korrektur
	int_CycleType,int_Channel
	:INTEGER;

	real_PrimaryAngle,real_SecondaryAngle
	:REAL;
	
  str_ProcName,WZ_Erzwingen_Korrektur 
	: TC255;
	
BEGIN

	strcpy(str_ProcName,'OutputToolChange');
	DebugBegin(str_ProcName,CONST_NO);
	
	PCALL(READ_PART_tool,int_ToolNb,int_ToolLengthOffset,int_ToolDiaOffset);
	PCALL(READ_PART_pp_cycle_no,int_CycleType);
	PCALL(litNUM_CANAL,int_Channel);

	int_ToolNb 						:= INTRD(SPE_AKTUELLES_WERKZEUG); 
	int_ToolLengthOffset 	:= INTRD(SPE_AKTUELL_WZ_LAENGE_OFFSET); 
	int_IsFirstTool 			:= ICALL(TEST_FIRST_TOOL_MILLING);

	IF IsOutputToolChange OR (int_ToolLengthOffset <> INTRD(SPE_OLD_WZ_LAENGE_OFFSET)) OR
	(INTRD(SPE_WZ_WECHSEL_ERZWINGEN) = 1) THEN
		BEGIN
		OutputToolFixedBlock;
		
		IF IsMillingOperation AND (int_CycleType <> CONST_TAPPING) OR (int_CycleType = DPP_SET_BUTEE_TOUR) THEN 
			BEGIN
			PCALL(OUTPUT_NC_RAPID);
			PCALL(bcnG,98,1)
			END
		ELSE 
			BEGIN
			PCALL(OUTPUT_NC_RAPID);
			PCALL(bcnG,99,1);
			END;
		
		ToolChange(int_ToolNb,int_ToolLengthOffset,int_IsFirstTool);	{WZ-Ausgabe + WZ-Kommentar}
		END;
	DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE OutputPlaneChange;
{----------------------------------------------------------------------------}
VAR
	int_IsChangeCycle,int_ToolNb,int_ToolLengthOffset,int_ToolDiaOffset,Int_num_cycle
	: INTEGER;

	str_ProcName
	: TC255;
	
BEGIN
	strcpy(str_ProcName,'OutputPlaneChange');
	DebugBegin(str_ProcName,CONST_NO);
	
	PCALL(litNUM_CYCLE,Int_num_cycle);
	PCALL(READ_PART_tool,int_ToolNb,int_ToolLengthOffset,int_ToolDiaOffset);
	
	int_IsChangeCycle 				:= ICALL(TEST_CHANGE_CYCLE);
	int_ToolNb 								:= INTRD(SPE_AKTUELLES_WERKZEUG); 
	int_ToolLengthOffset 			:= INTRD(SPE_AKTUELL_WZ_LAENGE_OFFSET); 
	
	IF IsOutputToolChange OR (int_ToolLengthOffset <> INTRD(SPE_OLD_WZ_LAENGE_OFFSET)) OR
		(INTRD(SPE_WZ_WECHSEL_ERZWINGEN) = 1) THEN
		BEGIN
		Origin;
		Plane;
		
		IF NOT IsTurnPlane THEN
			BEGIN
			EnableCAxis;					{C-Achse aktivieren}
			END
		ELSE IF (Int_num_cycle <> DPP_SET_BUTEE_TOUR) THEN
			BEGIN
			DisableCAxis;					{C-Achse deaktivieren}
			END
		ELSE IF (Int_num_cycle = DPP_SET_BUTEE_TOUR) THEN
			BEGIN
			PCALL(bcnTAB_STR,'SP','M471',1); writeb;
			PCALL(bcnTAB_STR,'SP','M5',1); writeb;
			END
		END;
		
	IF NOT (IsAxialInterpoPlane OR IsBPlane) THEN
		BEGIN
		ActivePlane;
		END; 
	
	DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE Plane;
{----------------------------------------------------------------------------}
VAR
	int_CycleType,int_Zyklus_Nr
	: INTEGER;
	
	str_ProcName 
	: TC255;
	
	real_SafetyDistance,SicherheitsEbene_Z 
	: REAL;
	
BEGIN
	strcpy(str_ProcName,'Plane');
	DebugBegin(str_ProcName,CONST_NO);

	PCALL(READ_PART_cycle_no,int_Zyklus_Nr);																	{Zyklus Nummer}

	IF IsAxialPlane OR IsBPlane OR (int_Zyklus_Nr = 11) THEN									{Zyklus 11 = Dreh-Bohren}
		BEGIN {Axial Milling}
		PCALL(OUTPUT_NC_G,17,CONST_YES);
		PCALL(READ_PATH_safety_distance,real_SafetyDistance);
		PCALL(READ_PART_pp_cycle_no,int_CycleType);		
		PCALL(lit_RTEC,RTF_VALEUR_GARDE,SicherheitsEbene_Z);
		END
	ELSE IF IsTurnPlane THEN
		BEGIN {Turn}
		PCALL(OUTPUT_NC_G,18,CONST_YES);
		END
	ELSE IF IsRadialPlane THEN
		BEGIN {Radial milling}
		PCALL(OUTPUT_NC_G,19,CONST_YES);
		END
	ELSE IF IsBPlane THEN
		BEGIN
		PCALL(OUTPUT_NC_G,17,CONST_YES);
		OutputCancelTiltedWorkPlane;
		OutputTiltedWorkPlane;
		END
	ELSE
		BEGIN
		PCALL(OUTPUT_NC_G,17,CONST_YES);
		END;
		
	DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE MovePlan;
{----------------------------------------------------------------------------}
VAR
	int_IsChangeCycle,Int_num_cycle , int_PlaneType
	: INTEGER;
	
	real_Angle,real_PrimaryAngle,real_SecondaryAngle , real_Pax2, real_C
	: REAL;
	
	tr3_Pt 
	: TR3;

	str_ProcName
	: TC255;
	
	bool_TestMove , bool_IsMovePax2
	:BOOLEAN;
	
BEGIN
	strcpy(str_ProcName,'MovePlan');
	DebugBegin(str_ProcName,CONST_NO);

	int_IsChangeCycle := ICALL(TEST_CHANGE_CYCLE);
	PCALL(litNUM_CYCLE,Int_num_cycle);
	PCALL(READ_PATH_point,tr3_Pt);
	PCALL(READ_PATH_point_5axis,tr3_Pt,real_PrimaryAngle,real_SecondaryAngle);
	
	{ IF IsAxialPlane THEN }
	{ BEGIN }
		{ real_PrimaryAngle := tr3_Pt[1]; }
		{ IF IsChannel(2) THEN real_PrimaryAngle := real_PrimaryAngle + 180; }
	{ END; }
	
	IF IsRadialPlane OR IsAxialPlane OR IsBPlane OR IsBPlaneToolInclined THEN
		BEGIN
		bool_TestMove := IsMovePrimaryAxis2;
		IF IsAxialInterpoPlane THEN OutputUnclampCAxis;
		
		IF (INTRD(SPE_C_KLEMMEN) = 1) THEN
			BEGIN
			IF bool_TestMove AND (Int_num_cycle = 113) THEN OutputUnclampCAxis		{C-Achse Loesen}
				ELSE IF (Int_num_cycle <> 113) THEN OutputUnclampCAxis;
			END;

		If not IsAxialPlane THEN
			OutputNCPrimary(real_PrimaryAngle);
		
		InitPlane(int_PlaneType);
		If (int_PlaneType = 121) OR (int_PlaneType = 141) THEN
			OutputNCPrimary(real_PrimaryAngle);
			
		OutputNCSecondary(real_SecondaryAngle);
		
		IF (INTRD(SPE_C_KLEMMEN) = 1) THEN
			BEGIN
			IF bool_TestMove AND (Int_num_cycle = 113) AND IsOKOutputLockCAxis THEN OutputClampCAxis			{C-Achse Klemmen}
				ELSE IF (Int_num_cycle <> 113) THEN OutputClampCAxis;
			END;
		
		IF TESTMOVE THEN writeb;
		{ IF NOT IsAxialInterpoPlane AND IsAxialPlane AND (Int_num_cycle <> 113) THEN PCALL(OUTPUT_NC_tab,'C',0.0,1); }
		{2022-03-10 XP add a control to not output Y0 when we will have a movement on Y axis}
		PCALL(READ_NC_paxis2,real_Pax2);
		bool_IsMovePax2 := not IsEqual(real_Pax2,tr3_Pt[1]);
		IF IsMovePrimaryAxis2 AND (int_IsChangeCycle = 1) and (not bool_IsMovePax2) THEN PCALL(OUTPUT_NC_tab,'Y',0.0,1)		{Nicht bei Y-Achse schreiben}
		ELSE IF IsAxialInterpoPlane THEN PCALL(OUTPUT_NC_tab,'Y',0.0,1);												{Nur bei C-Achsen schreiben}
		
		
	END;

	IF IsOutputToolChange AND IsRadialPlane THEN 
		BEGIN
		PCALL(OUTPUT_NC_tab,'X',(tr3_Pt[2])*2,1);
		END;
{ writeln('                     poc C from pt : ', tr3_Pt[1]); }

	IF (IsAxialPlanePolar OR IsAxialInterpoPlane) AND Not IsGCodeActivated(112) THEN
	BEGIN
		{ writeln('              test'); }
		real_C := tr3_Pt[1];
		IF IsChannel(2) THEN
		BEGIN
			IF IsSup(real_C,180) OR IsEqual(real_C,180) THEN
			BEGIN
				real_C := real_C - 180;
			END
			ELSE
			BEGIN
				real_C := real_C + 180;
			END;
		END;
		PCALL(OUTPUT_NC_pplane,tr3_Pt[0],real_C,0);
	END
	ELSE
	BEGIN
		PCALL(OUTPUT_NC_pplane,tr3_Pt[0],tr3_Pt[1],0);
	END;
	
	IF IsOutputToolChange AND (Int_num_cycle = DPP_SET_BUTEE_TOUR) THEN 
		BEGIN
		PCALL(OUTPUT_NC_tab,'Y',0.0,1); writeb;
		Anschlag_Ende_Kanal_2;
		END;
		
	IF TESTMOVE THEN writeb;

	DebugEnd;
END;

{----------------------------------------------------------------------------}
PROCEDURE MoveAll{(int_IsPPlan,int_IsPax3:INTEGER)};
{----------------------------------------------------------------------------}
VAR
	real_Angle,real_PrimaryAngle,real_SecondaryAngle, real_C : REAL;
	tr3_Pt : TR3;

	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'MoveAll');
	DebugBegin(str_ProcName,CONST_NO);

	PCALL(READ_PATH_point,tr3_Pt);

	{2021-12-01 XP If we are in AxialPolar plane, we don't output primary or secondary axis}
	{the priamry axis will be output by paxis2}
	IF (IsContinuousWork OR IsRadialPlane OR (IsAxialPlane AND NOT IsAxialInterpoPlane AND NOT IsAxialPlanePolar)) THEN
	BEGIN
		PCALL(READ_PATH_point_5axis,tr3_Pt,real_PrimaryAngle,real_SecondaryAngle);
		OutputNCPrimary(real_PrimaryAngle);
		OutputNCSecondary(real_SecondaryAngle);
	END;


	IF (IsAxialPlanePolar OR IsAxialInterpoPlane) AND Not IsGCodeActivated(112) THEN
	BEGIN
		real_C := tr3_Pt[1];
		IF IsChannel(2) THEN
		BEGIN
			IF IsSup(real_C,180) OR IsEqual(real_C,180) THEN
			BEGIN
				real_C := real_C - 180;
			END
			ELSE
			BEGIN
				real_C := real_C + 180;
			END;

		END;
		PCALL(OUTPUT_NC_pplane,tr3_Pt[0],real_C,int_IsPPlan);
	END
	ELSE
	BEGIN
		PCALL(OUTPUT_NC_pplane,tr3_Pt[0],tr3_Pt[1],int_IsPPlan);
	END;

	{ PCALL(OUTPUT_NC_pplane,tr3_Pt[0],tr3_Pt[1],int_IsPPlan); }
	PCALL(OUTPUT_NC_paxis3,tr3_Pt[2],int_IsPax3);

	DebugEnd;
END;{@}


{----------------------------------------------------------------------------}
PROCEDURE OutputSpindleOn;
{----------------------------------------------------------------------------}
VAR
	int_IsPlaneChange,int_BRotDir,int_BUnit,int_Range,int_CurBUnit,int_CurRange    
	int_ToolNb,int_ToolLengthOffset,int_ToolDiaOffset,int_CycleType,int_Channel, int_Active
	:INTEGER;
	
	real_Speed,real_CurSpeed, real_SpeedOutput, real_Factor        
	:REAL;
	
	str_ProcName, str_Message
	: TC255;
	
BEGIN
	strcpy(str_ProcName,'OutputSpindleOn');
	DebugBegin(str_ProcName,CONST_NO);
	
	PCALL(READ_PART_rotation,int_BRotDir);
	PCALL(READ_PART_spindle,real_Speed,int_BUnit,int_Range);
	{ writeln('                    speed ouput spindle  : ', real_Speed); }
	PCALL(READ_PART_pp_cycle_no,int_CycleType);
	PCALL(READ_NC_spindle,real_CurSpeed,int_CurBUnit,int_CurRange);
	PCALL(litNUM_CANAL,int_Channel);
	PCALL(READ_PART_tool,int_ToolNb,int_ToolLengthOffset,int_ToolDiaOffset);	{WZ-Offset}

	int_ToolNb 								:= INTRD(SPE_AKTUELLES_WERKZEUG); 
	int_ToolLengthOffset 			:= INTRD(SPE_AKTUELL_WZ_LAENGE_OFFSET); 
	
	IF IsRadialPlane AND (int_BRotDir = 7) THEN 
	BEGIN
		int_BRotDir := 7;														{Drehrichtung CW = M88}
	END
	ELSE IF IsRadialPlane AND (int_BRotDir = 8) THEN 
	BEGIN
		int_BRotDir := 8;														{Drehrichtung CCW = M89}
	END;
		
	IF (int_BUnit = CONST_SMM) OR (int_ToolLengthOffset <> INTRD(SPE_OLD_WZ_LAENGE_OFFSET)) THEN
	BEGIN
		IF int_BUnit = 64 THEN OutputLimitSpindle;   {63=G97 / 64=G96}
	END;
		
	IF (int_Channel = 1) OR (int_Channel = 2) THEN
		BEGIN
		IF (int_CycleType = CONST_TAPPING) THEN 
		BEGIN
			PCALL(WRITE_NC_m_force,3);
			PCALL(WRITE_NC_init_spindle);
			{2023-03-15 XP Remove S output for tapping}
			{ OutputNCSpindle(real_Speed,int_BUnit,int_Range); }
			OutputNCRotation(int_BRotDir); writeb;
		END
		ELSE IF (IsOutputToolChange) OR (int_BUnit <> int_CurBUnit) OR (int_ToolLengthOffset <> INTRD(SPE_OLD_WZ_LAENGE_OFFSET)) OR
		(INTRD(SPE_WZ_WECHSEL_ERZWINGEN) = 1) THEN
		BEGIN
			PCALL(WRITE_NC_m_force,3);
			PCALL(WRITE_NC_init_spindle);
			OutputNCSpindle(real_Speed,int_BUnit,int_Range);
			OutputNCRotation(int_BRotDir); writeb;
		END;
	END
	ELSE IF (int_Channel = 3) THEN
	BEGIN
		IF (int_CycleType = CONST_TAPPING) THEN 
		BEGIN
			PCALL(WRITE_NC_m_force,3);
			PCALL(WRITE_NC_init_spindle);
			OutputNCSpindle(real_Speed,int_BUnit,int_Range);

			IF IsMillingOperation THEN
			BEGIN
				IF int_BRotDir = 7 THEN {Drehrichtung CW = M488}
				BEGIN
					PCALL(bcnM,488,1);  
				END
				ELSE IF int_BRotDir = 8 THEN {Drehrichtung CCW = M489}
				BEGIN
					PCALL(bcnM,489,1);  
				END;
			END
			ELSE
			BEGIN
				OutputNCRotation(int_BRotDir);
			END;
			writeb;
		END
		ELSE IF (IsOutputToolChange) OR (int_BUnit <> int_CurBUnit) OR (int_ToolLengthOffset <> INTRD(SPE_OLD_WZ_LAENGE_OFFSET)) OR
		(INTRD(SPE_WZ_WECHSEL_ERZWINGEN) = 1) THEN
			BEGIN
			PCALL(WRITE_NC_m_force,3);
			PCALL(WRITE_NC_init_spindle);
			OutputNCSpindle(real_Speed,int_BUnit,int_Range);

			IF IsMillingOperation THEN
			BEGIN
				IF int_BRotDir = 7 THEN {Drehrichtung CW = M488}
				BEGIN
					PCALL(bcnM,488,1);  
				END
				ELSE IF int_BRotDir = 8 THEN {Drehrichtung CCW = M489}
				BEGIN
					PCALL(bcnM,489,1);  
				END;
			END
			ELSE
			BEGIN
				OutputNCRotation(int_BRotDir);
			END;
			writeb;
		END;
	END;
		
	PCALL(READ_NC_key,'S',real_SpeedOutput,int_Active);
	{ writeln('           speed ouput : ', real_SpeedOutput); }
	IF not IsEqual(real_Speed,real_SpeedOutput) and Not IsNull(real_SpeedOutput) THEN 
	BEGIN
		real_Factor := real_Speed / real_SpeedOutput;
		strcpy(str_Message,'WARNING SPEED FACTOR x');
		ReadTxtPack(20,str_Message);
		ConcatVal(str_Message, real_Factor,2);
		PCALL(OUTPUT_NC_tab_str,'CO',str_Message, CONST_YES);
		writeb;
	END;
		
	DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE OutputLimitSpindle;
{----------------------------------------------------------------------------}
VAR
	real_SMax,real_Val 
	: REAL;
	
	int_TurnCycle,int_SpindleType,int_Active,int_LimitCode,int_ToolNb,int_ToolLengthOffset
	int_ToolDiaOffset
	: INTEGER;
	
	str_Key, str_ProcName 
	: TC255;
	
BEGIN
	strcpy(str_ProcName,'OutputLimitSpindle');
	DebugBegin(str_ProcName,CONST_NO);
	
	PCALL(READ_PART_smax,real_SMax);
	PCALL(READ_PART_spindle_type, int_SpindleType);
	PCALL(READ_PART_tool,int_ToolNb,int_ToolLengthOffset,int_ToolDiaOffset);	{WZ-Offset}
	
	int_TurnCycle 						:= ICALL(TEST_TURNING_CYCLE);
	int_ToolNb 								:= INTRD(SPE_AKTUELLES_WERKZEUG); 
	int_ToolLengthOffset 			:= INTRD(SPE_AKTUELL_WZ_LAENGE_OFFSET); 
	
	IF (int_TurnCycle = CONST_TURNING) THEN
		BEGIN
			IF int_SpindleType = CONST_MAIN_SPINDLE THEN
				BEGIN
				strcpy(str_Key,'SMAX_MS');
				END
			ELSE
				BEGIN
				strcpy(str_Key,'SMAX_RS');
				END;
			
			PCALL(READ_NC_key,str_Key,real_Val,int_Active);
			
			CASE INTRD(STD_LIST_SPINDLE_LIMITATION) OF
				0 : 
					BEGIN
					int_LimitCode := 92;
					END;
					
				1 : 
					BEGIN
					int_LimitCode := 50;
					END;
			END;
			
			IF (IsOutputToolChange) OR (IsNotEqual(real_Val,real_SMax)) OR (int_ToolLengthOffset <> INTRD(SPE_OLD_WZ_LAENGE_OFFSET)) OR
			(INTRD(SPE_WZ_WECHSEL_ERZWINGEN) = 1) THEN
				BEGIN
				PCALL(OUTPUT_NC_G,int_LimitCode,CONST_YES);
				PCALL(OUTPUT_NC_tab,str_Key,real_SMax,CONST_YES);
				END;
		END;
		writeb;
	
	DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE OutputDepPlan;
{----------------------------------------------------------------------------}
VAR
	int_PlaneType :INTEGER;

	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'OutputDepPlan');
	DebugBegin(str_ProcName,CONST_NO);

	PCALL(READ_PART_cycle_plane_type,int_PlaneType);
	PCALL(OUTPUT_NC_RAPID);
	MovePlan;

	DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE EnableCAxis;
{----------------------------------------------------------------------------}
VAR
	int_Spindel_pruefen,int_Channel
	: INTEGER;

	str_CAxisCode, str_Key,str_ProcName, str_Out 
	: TC255;

BEGIN
	strcpy(str_ProcName,'EnableCAxis');
	DebugBegin(str_ProcName,CONST_NO);
	
	PCALL(READ_PART_SPINDLE_TYPE,int_Spindel_pruefen);
	PCALL(litNUM_CANAL,int_Channel);
	
	str_CAxisCode[0] := chr(0);
	strcpy(str_Key,'M_5');
	EnableCAxisCode(str_CAxisCode);
	PCALL(bcnTAB_STR,'SP','M471',1); writeb;
	
	OutputUnclampCAxis; Punchb(2);
	
	IF (int_Spindel_pruefen = CONST_MAIN_SPINDLE)	THEN 
	BEGIN								{Hauptspindel}
		{ PCALL(bcnTAB_STR,'SP','M87',1); Punchb(2); }
		{ STRINGRD(LIB_STR_UNCLAMP_MS,str_Out); }
		{ PCALL(bcnTAB_STR,'SP',str_Out,1); Punchb(2); }
		{ PCALL(bcnTAB_STR,'SP','M98 P9000',1); Punchb(2); }
		PCALL(bcnTAB_STR,'SP',str_CAxisCode,1); Punchb(2);
	END
	ELSE IF (Int_Spindel_Pruefen = CONST_REWORK_SPINDLE) THEN							
	BEGIN								{Gegenspindel}
		{ PCALL(bcnTAB_STR,'SP','M33',1); Punchb(2);}
		{ STRINGRD(LIB_STR_UNCLAMP_RS,str_Out); }
		{ PCALL(bcnTAB_STR,'SP',str_Out,1); Punchb(2); }
		{ PCALL(bcnTAB_STR,'SP','M98 P9001',1); Punchb(2); }
		PCALL(bcnTAB_STR,'SP',str_CAxisCode,1); Punchb(2);
	END;
{
	IF not IsMCodeActivated(51) or not IsModalKeyInteger(str_Key) THEN
		BEGIN
		EnableCAxisCode(str_CAxisCode);
		IF str_CAxisCode[0] <> chr(0) THEN
			BEGIN
			IF (int_Spindel_pruefen = CONST_MAIN_SPINDLE)	THEN 
				BEGIN						{Hauptspindel}
				IF (int_Channel = 1) THEN
					BEGIN
					PCALL(bcnTAB_STR,'SP','M98 P9000',1); Punchb(2);
					END
				ELSE IF (int_Channel = 2) THEN
					BEGIN
					PCALL(bcnTAB_STR,'SP','M98 P9000',1); Punchb(2);
					END;
				END
			ELSE IF (Int_Spindel_Pruefen = CONST_REWORK_SPINDLE) THEN													
				BEGIN						{Gegenspindel}
				IF (int_Channel = 1) THEN
					BEGIN
					PCALL(bcnTAB_STR,'SP','M98 P9001',1); Punchb(2);
					END
				ELSE IF (int_Channel = 2) THEN
					BEGIN
					PCALL(bcnTAB_STR,'SP','M98 P9001',1); Punchb(2);
					END;
				END;
			END;                
		PCALL(WRITE_NC_M,51);
		PCALL(WRITE_NC_primary,0);
		IF IsChannel(2) THEN PCALL(WRITE_NC_primary,180);
		END
	ELSE
		BEGIN

		END;
}
	
		DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE DisableCAxis;
{----------------------------------------------------------------------------}
VAR
	int_Spindel_pruefen
	: INTEGER;

	str_CAxisCode,str_Key,str_ProcName 
	:TC255;

BEGIN
	strcpy(str_ProcName,'DisableCAxis');
	DebugBegin(str_ProcName,CONST_NO);
	
	PCALL(READ_PART_SPINDLE_TYPE,int_Spindel_pruefen);
	
	Befehl_M471;																							{M471 lesen}
	
	IF INTRD(SPE_M471) = 1 THEN																{M471 schreiben}
		BEGIN
		PCALL(bcnTAB_STR,'SP','M471',1); Punchb(2);
		END
	ELSE
		BEGIN
		PCALL(bcnTAB_STR,'SP','M470',1); Punchb(2);
		END;
	
{	
	strcpy(str_Key,'M_5');
	IF not IsMCodeActivated(50) or not IsModalKeyInteger(str_Key) THEN
		BEGIN
		DisableCAxisCode(str_CAxisCode);
		IF str_CAxisCode[0] <> chr(0) THEN
			BEGIN

			END;
		PCALL(WRITE_NC_M,50);
		END;
}

	DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE OutputClampCAxis;
{----------------------------------------------------------------------------}
VAR
	str_Clamp,str_Key,str_ProcName 
	: TC255;
	
BEGIN
	strcpy(str_ProcName,'OutputClampCAxis');
	DebugBegin(str_ProcName,CONST_NO);
	
	strcpy(str_Key,'M_6');
	IF not IsMCodeActivated(10) or not IsModalKeyInteger(str_Key) THEN
		BEGIN
		{ writeb; }
		{ strcpy(str_Clamp,'M86   (C-ACHSE KLEMMEN)'); }
		ClampCAxisCode(str_Clamp);
		IF str_Clamp[0] <> chr(0) THEN
			BEGIN
			PCALL(OUTPUT_NC_punch_str,str_Clamp);
			writeb;
			END;
		PCALL(WRITE_NC_M,10);
		END;

	DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE OutputUnclampCAxis;
{----------------------------------------------------------------------------}
VAR
	str_Unclamp, str_Key,str_ProcName 
	: TC255;
	
BEGIN
	strcpy(str_ProcName,'OutputUnclampCAxis');
	DebugBegin(str_ProcName,CONST_NO);
	
	strcpy(str_Key,'M_6');
	IF not IsMCodeActivated(11) or not IsModalKeyInteger(str_Key) THEN
		BEGIN
		writeb;
		{ strcpy(str_Unclamp,'M87   (C-ACHSE LOESEN)');	 }
		UnclampCAxisCode(str_Unclamp);
		IF str_Unclamp[0] <> chr(0) THEN
			BEGIN
			PCALL(OUTPUT_NC_punch_str,str_Unclamp);
			writeb;
			END;
		PCALL(WRITE_NC_M,11);
		END;
	
	DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE OutputPlaneCancel;
{----------------------------------------------------------------------------}
VAR
	str_ProcName 
	: TC255;
	
BEGIN
	strcpy(str_ProcName,'OutputPlaneCancel');
	DebugBegin(str_ProcName,CONST_NO);
	
	{2023-04-21 XP only cancel G05.1 Q1 if we change tool}
	IF IsMillingOperation AND IsOutputToolChange THEN
	BEGIN
		IF ICALL(TEST_HOLE_CYCLE) = CONST_NO THEN
		{ If IsAxialInterpoPlane THEN }
		BEGIN
			{2023-06-07 XP JINFO asking to unclamp C axis for last repetition }
			OutputUnclampCAxis;
			writeb;
			PCALL(OUTPUT_NC_tab_str, 'SP','G05.1 Q0',CONST_YES);
			writeb;
		END;
	END;
	
	IF IsOutputPlane THEN
	BEGIN
		OutputCancelTiltedWorkPlane;
	END;
	
	DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE OutputRadialInterpoOn;
{----------------------------------------------------------------------------}
VAR
	int_IsChangeCycle
	:INTEGER;
	
	real_RayExt 
	: REAL;
	
	str_ProcName, str_InterpoCode 
	: TC255;
				
BEGIN
	strcpy(str_ProcName,'OutputRadialInterpoOn');
	DebugBegin(str_ProcName,CONST_NO);
	
	PCALL(READ_PART_plane_radius,real_RayExt);
	strcpy(str_InterpoCode,'G07.1 ');
	EnableRadialInterpoCode(str_InterpoCode);
	strcat(str_InterpoCode,'C');
	ConcatStrVal(str_InterpoCode,str_InterpoCode,real_RayExt,3);
	PCALL(OUTPUT_NC_punch_str,str_InterpoCode);
	
	DebugEnd;
END;

{----------------------------------------------------------------------------}
PROCEDURE OutputRadialInterpoOff;
{----------------------------------------------------------------------------}
VAR
	str_InterpoCode,str_ProcName
	: TC255;
	
	real_RayExt 
	: REAL;

BEGIN
	strcpy(str_ProcName,'OutputRadialInterpoOff');
	DebugBegin(str_ProcName,CONST_NO);
	
	IF IsDevZPlane THEN
		BEGIN
		strcpy(str_InterpoCode,'G07.1 ');
		DisableRadialInterpoCode(str_InterpoCode);
		strcat(str_InterpoCode,'C');
		ConcatStrVal(str_InterpoCode,str_InterpoCode,0.0,3);
		PCALL(OUTPUT_NC_punch_str,str_InterpoCode);	
		END;
		
	DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE CycleDrillingCommonBegin;
{----------------------------------------------------------------------------}
VAR
	int_BUnit,int_BReturnType,int_Spindel_HS_GS,Int_Rueckzugshoehe,int_IsLast
	int_IsFirstHole,int_GCode,int_BActive, int_CycleType 
	: INTEGER;
	
	real_SafetyDist,real_RapidAlt,real_Feed,real_Depth,real_Depth1,real_Depth2
	real_InitLevel,real_RapidPlane,real_DwellTime
	:REAL;
	
	tr3_Pt,Tr3_X_Oberseite_SA,Tr3_X_Oberseite_SE,ptfond,ptret 
	: TR3;
	
	str_ProcName 
	: TC255;
	
BEGIN
	strcpy(str_ProcName,'CycleDrillingCommonBegin');
	DebugBegin(str_ProcName,CONST_NO);

	PCALL(READ_PATH_safety_distance,real_SafetyDist);
	PCALL(READ_PATH_point,tr3_Pt);
	PCALL(READ_PART_boolean_tec,BOOLEAN_MILL_RETRACT_MANAGE,int_BReturnType);
	PCALL(READ_PART_drill_depth,real_Depth,real_Depth1,real_Depth2);
	PCALL(READ_PATH_feed,real_Feed,int_BUnit);
	PCALL(READ_PART_pp_cycle_no,int_CycleType);
	PCALL(READ_PART_real_tec,REAL_MILL_END_DWELL,real_DwellTime);
  PCALL(ltraPOINTS_TROU,Tr3_X_Oberseite_SA,Tr3_X_Oberseite_SE,ptfond,ptret);
	PCALL(READ_PART_real_tec,REAL_MILL_RAPID_PLANE,real_RapidPlane);
	PCALL(READ_PART_SPINDLE_TYPE,int_Spindel_HS_GS); 							{HS oder GS Spindel}
	PCALL(lit_BTEC,BTF_TYPE_GESTION_REMONTEES,Int_Rueckzugshoehe);
	
	int_IsLast  		:= ICALL(TEST_LAST_RAPG80);
	int_IsFirstHole := ICALL(TEST_FIRST_HOLE);
	real_RapidAlt 	:= GetLastDrillingRet;
	real_InitLevel 	:= GetLastDrillingInitLevel;

	IF (int_BReturnType = CONST_SAFETY_PLANE) THEN int_GCode := 98
	 ELSE int_GCode := 99;


	PCALL(READ_NC_G,int_GCode,int_BActive);
	
	IF ((int_GCode = 98) AND (int_BActive = CONST_YES)) THEN
		BEGIN
		PCALL(READ_NC_pax3,real_RapidAlt);
		END
	ELSE IF (int_GCode = 99) THEN
		BEGIN
		real_RapidAlt := tr3_Pt[2] + real_SafetyDist;
		END;

	MovePlan;

	IF (TESTMOVE AND (int_IsFirstHole = CONST_YES)) THEN writeb;

	IF (int_Spindel_HS_GS = CONST_MAIN_SPINDLE) THEN							{HS Bearbeitung}
		BEGIN
		PCALL(OUTPUT_NC_paxis3,(tr3_Pt[2] - real_Depth),0);
		END
	ELSE																						{GS Bearbeitung}
		BEGIN
		PCALL(OUTPUT_NC_paxis3,(tr3_Pt[2] - real_Depth),0);
		END;
	
	IF IsAxialPlane THEN						{Axial Bohren R = Sicherheitsabstand}
		BEGIN
		IF (int_Spindel_HS_GS = CONST_MAIN_SPINDLE) THEN							{HS Bearbeitung}
			BEGIN
			IF Int_Rueckzugshoehe = 46 THEN PCALL(OUTPUT_NC_tab,'R_DRILL',-(-Tr3_X_Oberseite_SE[2]+Tr3_X_Oberseite_SA[2]),CONST_NO)
				ELSE IF (int_IsFirstHole = 1) THEN PCALL(OUTPUT_NC_tab,'R_DRILL',-(-Tr3_X_Oberseite_SE[2]+Tr3_X_Oberseite_SA[2]),CONST_NO)
			END
		ELSE																													{GS Bearbeitung}
			BEGIN
			IF Int_Rueckzugshoehe = 46 THEN PCALL(OUTPUT_NC_tab,'R_DRILL',(-Tr3_X_Oberseite_SE[2]+Tr3_X_Oberseite_SA[2]),CONST_NO)
				ELSE IF (int_IsFirstHole = 1) THEN PCALL(OUTPUT_NC_tab,'R_DRILL',(-Tr3_X_Oberseite_SE[2]+Tr3_X_Oberseite_SA[2]),CONST_NO)
			END;
		END
	ELSE IF IsRadialPlane THEN		{Radial Bohren R = Sicherheitsabstand}
		BEGIN
		IF (int_IsFirstHole = 1) THEN PCALL(OUTPUT_NC_tab,'R_DRILL',(Tr3_X_Oberseite_SE[2]-Tr3_X_Oberseite_SA[2]),CONST_NO)
			ELSE IF NOT IsNull(Tr3_X_Oberseite_SE[2]-Tr3_X_Oberseite_SA[2]) THEN PCALL(OUTPUT_NC_tab,'R_DRILL',(Tr3_X_Oberseite_SE[2]-Tr3_X_Oberseite_SA[2]),CONST_NO);
		END;

	IF NOT IsNull(real_Depth1) THEN
		BEGIN
		IF (int_IsFirstHole = 1) THEN PCALL(OUTPUT_NC_tab,'Q_DRILL',real_Depth1,1)
			ELSE IF NOT IsNull(real_Depth1) THEN PCALL(OUTPUT_NC_tab,'Q_DRILL',real_Depth1,0);
		END;

	IF NOT IsNull(real_DwellTime) THEN
	BEGIN
		PCALL(OUTPUT_NC_tab,'P_DRILL',real_DwellTime,CONST_NO);
	END;

	IF (int_CycleType <> CONST_TAPPING) THEN OutputNCFeed(real_Feed,int_BUnit);

	SetLastDrillingDep(tr3_Pt[2]);
	SetLastDrillingEnd((tr3_Pt[2]-real_Depth));
	SetLastDrillingRet(real_RapidAlt);

	DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE OutputDrillingCancel;
{----------------------------------------------------------------------------}
VAR
	int_IsLast,int_BType : INTEGER;
	tr3_Pt12,tr3_Pt3 : TR3;

	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'OutputDrillingCancel');
	DebugBegin(str_ProcName,CONST_NO);

	int_IsLast  := ICALL(TEST_LAST_RAPG80);
	PCALL(READ_PART_boolean_tec,BOOLEAN_MILL_RETRACT_MANAGE,int_BType);
	PCALL(READ_PATH_point,tr3_Pt12);

	tr3_Pt3[2] := GetLastDrillingRet;

	IF ((tr3_Pt3[2] + TOLERPP < tr3_Pt12[2]) OR (int_IsLast = CONST_YES)) THEN
		BEGIN
		OutputNCRapid;
		PCALL(OUTPUT_NC_G,80,CONST_NO);
		PCALL(OUTPUT_NC_paxis3,tr3_Pt12[2],0);
		MovePlan;
		IF TESTMOVE THEN writeb;
		IF IsPAPCycle THEN OutputUnclampCAxis;

		PCALL(WRITE_NC_init_key,'P_DRILL');
		PCALL(WRITE_NC_init_key,'Q_DRILL');
		PCALL(WRITE_NC_init_key,'R_DRILL');
		PCALL(WRITE_NC_init_key,'F');
		PCALL(WRITE_NC_init_key,'FR');
		PCALL(WRITE_NC_key,'G_REAL',80);
		INTWR(SPE_GEWINDE_M329,0);
		END;

	DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE OutputApproachDrillingTurn;		{Drehen: Bohren ausprogrammiert}
{----------------------------------------------------------------------------}
VAR
	int_ZSign,int_CycleType 
	: INTEGER;

	real_SafetyDistance 
	: REAL;

	str_ProcName 
	: TC255;

	tr3_Pt 
	: TR3;

BEGIN
	strcpy(str_ProcName,'OutputApproachDrillingTurn');
	DebugBegin(str_ProcName,CONST_NO);
	
	PCALL(READ_PATH_safety_distance,real_SafetyDistance);
	PCALL(READ_PATH_point,tr3_Pt);
	PCALL(READ_PART_boolean_tec,BOOLEAN_TURN_MACHINING_DIRECTION,int_CycleType);
	
	int_ZSign := 1;
	IF InvertSignCycle(CONST_NO) THEN int_ZSign := -1;
	OutputNCRapid;
	PCALL(OUTPUT_NC_pplane,(tr3_Pt[0] + (real_SafetyDistance * int_ZSign)),tr3_Pt[1],CONST_YES); writeb;
	
	DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE OutputCycleDrillingDeburringTurn;	{Drehen: G83 Bohren Entspaehnen}
{----------------------------------------------------------------------------}
VAR
	int_Bunit, int_ZSign, int_CycleType
	:INTEGER;
	
	real_Depth, real_Depth1,real_FinalDepth, real_Feed 
	:REAL;
	
	str_ProcName 
	: TC255;
	
	tr3_Pt 
	: TR3;

BEGIN
	strcpy(str_ProcName,'OutputCycleDrillingDeburringTurn');
	DebugBegin(str_ProcName,CONST_NO);
	
	PCALL(READ_PATH_point,tr3_Pt);
	PCALL(READ_PART_drill_depth,real_Depth,real_Depth1,real_FinalDepth);
	PCALL(READ_PATH_feed,real_Feed,int_BUnit);
	PCALL(READ_PART_boolean_tec,BOOLEAN_TURN_MACHINING_DIRECTION,int_CycleType);
	
	OutputApproachDrillingTurn;
	int_ZSign := 1;
	{ IF int_CycleType = DPP_ARRIERE THEN int_ZSign := -1; }
	
	{ PCALL(OUTPUT_NC_G,83,CONST_YES); }
	PCALL(OUTPUT_NC_tab, 'G_REAL',83.6,CONST_YES);
	PCALL(OUTPUT_NC_pplane,(tr3_Pt[0]-(real_Depth * int_ZSign)),tr3_Pt[1],CONST_YES);
	{ PCALL(OUTPUT_NC_paxis1,32.4,CONST_YES); }
	{ PCALL(OUTPUT_NC_pplane,32.4,tr3_Pt[1],CONST_YES); }
	PCALL(OUTPUT_NC_tab,'Q_DRILL',real_Depth1,CONST_YES);
	PCALL(OUTPUT_NC_feed,real_Feed,int_BUnit); writeb;
	
	PCALL(WRITE_NC_g,83);
	
	OutputDrillingCancelTurn;
	
	PCALL(WRITE_NC_key,'G_REAL',80);
	
	DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE OutputCycleDrillingChipbreakingTurn;	{Drehen: G74 Bohren Spanbrechen}
{----------------------------------------------------------------------------}
VAR
	int_Bunit, int_ZSign, int_CycleType 
	:INTEGER;
	
	real_Depth, real_Depth1,real_FinalDepth, real_Feed 
	:REAL;
	
	tr3_Pt 
	: TR3;
	
	str_ProcName 
	: TC255;
	
BEGIN
	strcpy(str_ProcName,'OutputCycleDrillingChipbreakingTurn');
	DebugBegin(str_ProcName,CONST_NO);
	
	PCALL(READ_PATH_point,tr3_Pt);
	PCALL(READ_PART_drill_depth,real_Depth,real_Depth1,real_FinalDepth);
	PCALL(READ_PATH_feed,real_Feed,int_BUnit);
	PCALL(READ_PART_boolean_tec,BOOLEAN_TURN_MACHINING_DIRECTION,int_CycleType);
	
	OutputApproachDrillingTurn;
	int_ZSign := 1;
	IF InvertSignCycle(CONST_NO) THEN int_ZSign := -1;
	
	PCALL(OUTPUT_NC_G,74,CONST_YES);
	PCALL(OUTPUT_NC_pplane,(tr3_Pt[0]-( real_Depth * int_ZSign)),tr3_Pt[1],CONST_YES);
	PCALL(OUTPUT_NC_tab,'K_DRILL',real_Depth1,CONST_YES);
	PCALL(OUTPUT_NC_feed,real_Feed,int_BUnit); writeb;
	
	DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE OutputCycleDrillingTappingTurn;		{Drehen: G84 Gewinde}
{----------------------------------------------------------------------------}
VAR
	int_Bunit, int_ZSign, int_CycleType , int_RigidTapping ,int_BUnitSpeed,int_Range
	:INTEGER;
	
	real_Depth, real_Depth1,real_FinalDepth, real_Feed , real_Speed
	:REAL;
	
	tr3_Pt 
	: TR3;
	
	str_ProcName 
	: TC255;
	
BEGIN
	strcpy(str_ProcName,'OutputCycleDrillingTappingTurn');
	DebugBegin(str_ProcName,CONST_NO);
	
	PCALL(READ_PATH_point,tr3_Pt);
	PCALL(READ_PART_drill_depth,real_Depth,real_Depth1,real_FinalDepth);
	PCALL(READ_PATH_feed,real_Feed,int_BUnit);
	PCALL(READ_PART_boolean_tec,BOOLEAN_TURN_MACHINING_DIRECTION,int_CycleType);
	PCALL(READ_PART_boolean_tec, BOOLEAN_TURN_RIGID_TAPPING,int_RigidTapping);
	PCALL(READ_PART_spindle,real_Speed,int_BUnitSpeed,int_Range);
	
	OutputApproachDrillingTurn;
	int_ZSign := 1;
	IF InvertSignCycle(CONST_NO) THEN int_ZSign := -1;
	
	IF int_RigidTapping = CONST_YES THEN
	BEGIN
		PCALL(bcnTAB_STR,'SP','M29',1);
		PCALL(OUTPUT_NC_TAB,'S',real_Speed,1); writeb;	{Drehzahl}
	END;
	
	PCALL(OUTPUT_NC_G,84,CONST_YES);
	PCALL(OUTPUT_NC_pplane,(tr3_Pt[0]-( real_Depth * int_ZSign)),tr3_Pt[1],CONST_YES);
	PCALL(OUTPUT_NC_feed,real_Feed,int_BUnit); writeb;
	
	OutputDrillingCancel;
	PCALL(OUTPUT_NC_g,80,CONST_YES);
	writeb;
	DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE OutputCycleDrillingSimpleAxial;	{G81 Bohren C-Achsen: Stirnseitig (Axial)}
{----------------------------------------------------------------------------}
VAR
	str_ProcName 
	: TC255;

BEGIN
	strcpy(str_ProcName,'OutputCycleDrillingSimpleAxial');
	DebugBegin(str_ProcName,CONST_NO);
	
	CycleDrillingCommonBegin;
	PCALL(OUTPUT_NC_G,83,CONST_NO); 
	OutputClampCAxis;
	{ writeb; }
	
	DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE OutputCycleDrillingDeburringAxial;	{G83 Bohren Spanbrechen C-Achsen: Stirnseitig (Axial)}
{----------------------------------------------------------------------------}
VAR
	str_ProcName 
	: TC255;
	
BEGIN
	strcpy(str_ProcName,'OutputCycleDrillingDeburringAxial');
	DebugBegin(str_ProcName,CONST_NO);
	
	CycleDrillingCommonBegin;
	PCALL(OUTPUT_NC_tab,'G_REAL',83.6,CONST_NO); 
	{ writeb; }
	OutputClampCAxis;
	
	PCALL(WRITE_NC_g,83);
	
	DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE OutputCycleDrillingChipbreakingAxial;	{G83 Bohren Entspaehnen C-Achsen: Stirnseitig (Axial)}
{----------------------------------------------------------------------------}
VAR
	str_ProcName 
	: TC255;
	
BEGIN
	strcpy(str_ProcName,'OutputCycleDrillingChipbreakingAxial');
	DebugBegin(str_ProcName,CONST_NO);
	
	CycleDrillingCommonBegin;
	PCALL(OUTPUT_NC_tab,'G_REAL',83.5,CONST_NO); 
	{ writeb; }
	OutputClampCAxis;
	PCALL(WRITE_NC_g,83);
	
	DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE OutputCycleDrillingTappingAxial;  {G84 Gewinde C-Achse Stirnseitig (Axial)}
{----------------------------------------------------------------------------}
VAR
	int_BUnit,int_Range,int_CycleType, int_Active
	:INTEGER;

	real_Pitch,real_Speed ,real_SpeedOutput 
	: REAL;
				
	str_ProcName 
	: TC255;
	
BEGIN
	strcpy(str_ProcName,'OutputCycleDrillingTappingAxial');
	DebugBegin(str_ProcName,CONST_NO);
	
	PCALL(READ_PART_real_tool,REAL_TOOL_PITCH,real_Pitch);
	PCALL(READ_PART_spindle,real_Speed,int_BUnit,int_Range);
	{ writeln('                      speed tapping : ', real_Speed); }
	PCALL(READ_PART_pp_cycle_no,int_CycleType);

	IF (int_CycleType = CONST_TAPPING) AND (INTRD(SPE_GEWINDE_M329) = 0) THEN 
	BEGIN
		{ PCALL(bcnTAB_STR,'SP','M94',1); Punchb(2); }
		PCALL(bcnTAB_STR,'SP','M29',1);
		PCALL(WRITE_NC_force_spindle,CONST_YES,CONST_NO,CONST_NO);
		PCALL(OUTPUT_NC_spindle,real_Speed,int_BUnit,int_Range);
		{ PCALL(OUTPUT_NC_TAB,'S',real_Speed,1); }
		{Drehzahl}
		writeb;
		INTWR(SPE_GEWINDE_M329,1);
	END;
	{2022-12-14 to be able to correct the feedrate if there is a coeeficient apply on the tool speed}
	PCALL(READ_NC_key,'S',real_SpeedOutput,int_Active);
{ writeln('                     ', real_Speed); }
  CycleDrillingCommonBegin;
  PCALL(OUTPUT_NC_G,84,CONST_NO);
  PCALL(OUTPUT_NC_G,95,CONST_NO);
  PCALL(OUTPUT_NC_TAB,'FR',(real_Pitch * real_Speed / real_SpeedOutput),CONST_NO);		{Vorschub = Steigung}
	OutputClampCAxis;
	{ Punchb(2); }

  DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE OutputCycleDrillingSimpleRadial;	{G87 Bohren Standard C-Achse Querseitig (Radial)}
{----------------------------------------------------------------------------}
VAR
	str_ProcName 
	: TC255;
	
BEGIN
	strcpy(str_ProcName,'OutputCycleDrillingSimpleRadial');
	DebugBegin(str_ProcName,CONST_NO);
	
	CycleDrillingCommonBegin;
	PCALL(OUTPUT_NC_G,87,CONST_NO);
	OutputClampCAxis;
	{ writeb; }
	
	DebugEnd;
END;

{----------------------------------------------------------------------------}
PROCEDURE OutputCycleDrillingDeburringRadial;	{G87 oder G83 Bohren Spanbrechen C-Achse Querseitig (Radial)}
{----------------------------------------------------------------------------}
VAR
	str_ProcName 
	: TC255;
	
BEGIN
	strcpy(str_ProcName,'OutputCycleDrillingDeburringRadial');
	DebugBegin(str_ProcName,CONST_NO);
	
	CycleDrillingCommonBegin;
	PCALL(OUTPUT_NC_tab,'G_REAL',87.6,CONST_NO);
	OutputClampCAxis;
	{ writeb; }
	
	PCALL(WRITE_NC_g,87);
	
	DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE OutputCycleDrillingChipbreakingRadial;	{G87 oder G83 Bohren Entspaehnen C-Achse Querseitig (Radial)}
{----------------------------------------------------------------------------}
VAR
	str_ProcName 
	: TC255;
	
BEGIN
	strcpy(str_ProcName,'OutputCycleDrillingChipbreakingRadial');
	DebugBegin(str_ProcName,CONST_NO);
	
	CycleDrillingCommonBegin;
	PCALL(OUTPUT_NC_tab,'G_REAL',87.5,CONST_NO);
	{ writeb; }
	OutputClampCAxis;
	PCALL(WRITE_NC_g,87);
	
	DebugEnd;
END;

{----------------------------------------------------------------------------}
PROCEDURE OutputCycleDrillingTappingRadial;		{G88 oder G84 Gewinde C-Achse Querseitig (Radial)}
{----------------------------------------------------------------------------}
VAR
	int_CycleType,int_BUnit,int_Range
	: INTEGER;

	real_Pitch,real_Speed
	: REAL;

	str_ProcName 
	: TC255;
	
BEGIN
	strcpy(str_ProcName,'OutputCycleDrillingTappingRadial');
	DebugBegin(str_ProcName,CONST_NO);      
	PCALL(READ_PART_real_tool,REAL_TOOL_PITCH,real_Pitch);
	
	PCALL(READ_PART_spindle,real_Speed,int_BUnit,int_Range);
	PCALL(READ_PART_pp_cycle_no,int_CycleType);

	IF (int_CycleType = CONST_TAPPING) AND (INTRD(SPE_GEWINDE_M329) = 0) THEN 
		BEGIN
		{2023-03-03 XP delete M94}
		{ PCALL(bcnTAB_STR,'SP','M94',1); Punchb(2); }
		PCALL(bcnTAB_STR,'SP','M29',1);
		PCALL(OUTPUT_NC_TAB,'S',real_Speed,1); writeb;	{Drehzahl}
		INTWR(SPE_GEWINDE_M329,1);
		END;
				
	CycleDrillingCommonBegin;
	PCALL(OUTPUT_NC_G,88,CONST_NO);
	PCALL(OUTPUT_NC_G,95,CONST_NO);
	PCALL(OUTPUT_NC_TAB,'FR',real_Pitch,CONST_NO);
	OutputClampCAxis;
	
	DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE OutputCycleDrillingCounterboringRadial;
{----------------------------------------------------------------------------}
VAR
	str_ProcName 
	: TC255;
	
BEGIN
	strcpy(str_ProcName,'OutputCycleDrillingCounterboringRadial');
	DebugBegin(str_ProcName,CONST_NO);
	
	CycleDrillingCommonBegin;
	PCALL(OUTPUT_NC_G,87,CONST_NO); 
	{ writeb; }
	OutputClampCAxis;
	
	DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE OutputCycleMultiThreadingTwoBlocks{(int_GCode : INTEGER)};
{----------------------------------------------------------------------------}
{
Outpout a G76 or G78 threading cycle with 2 lines of parameters
ex :    G76 P010060 Q500 R100
                G76 X35.356 Z-43. P2.322 Q500 R0 F3.5
                First Line :
                        PXX     : Repeating time before the final threading
                        P  XX   : Chamfering at the end part of threading
                        P    XX : Angle of tool
                        Q : minimum cut depth
                        R : Allowence for finishing
                Second line :
                        X : final thread diameter
                        Z : final thread Z
                        P : Height of thread
                        Q : First cut depth 
                        R : delta radius for conic thread
                        F : Cutting feedrate
}
VAR
	int_NbExtraPasses,int_PValue, int_Side 
	: INTEGER;
	
	real_EndChanferDist, real_AngTool, real_Pitch, X_Aufmass real_LastPass
	real_RValue, real_Depth, real_DepthOne real_XEnd,real_SafetyX,real_SafetyZ 
	: REAL;
	
	tr3_Pt, tr3_PtEnd 
	:TR3;
	
	str_ProcName 
	: TC255;
	
BEGIN
	strcpy(str_ProcName,'OutputCycleMultiThreadingTwoBlocks');
	DebugBegin(str_ProcName,CONST_NO);
	
	PCALL(lit_RTEC,RTT_SUREPAISSEUR_X,X_Aufmass);
	
	PCALL(READ_PART_integer_tec,INTEGER_TURN_EMPTY_PASSES_NUMBER,int_NbExtraPasses);
	PCALL(READ_PART_real_tec,REAL_TURN_CONE_LENGTH,real_EndChanferDist);
	PCALL(READ_PART_real_tec,REAL_TOOL_RHOMBIC_ANGLE,real_AngTool);
	PCALL(READ_PART_real_tec,REAL_TURN_PITCH,real_Pitch);
	PCALL(READ_PART_real_tec,REAL_TURN_LAST_PASS_DEPTH,real_LastPass);
	PCALL(READ_PATH_point,tr3_Pt);
	PCALL(READ_PATH_point_end,tr3_PtEnd);
	PCALL(READ_PART_real_tec,REAL_TURN_PASS_DEPTH, real_Depth);
	PCALL(READ_PART_real_tec,REAL_TURN_INCR_DEPTH, real_DepthOne);
	PCALL(READ_PART_boolean_tec,BOOLEAN_TURN_MACHINING_DIRECTION,int_Side);
	PCALL(READ_PART_turn_canned_safety_dist,real_SafetyZ,real_SafetyX,CONST_YES);
	
	int_PValue 	:= (10000 * int_NbExtraPasses) + (100 * TRUNC(real_EndChanferDist / real_Pitch)) + TRUNC(real_AngTool);
	real_RValue := tr3_PtEnd[1] - tr3_Pt[1];
	
	PCALL(OUTPUT_NC_G,int_GCode,CONST_YES);
	PCALL(OUTPUT_NC_tab,'MRA_THREAD',int_PValue,CONST_YES);
	PCALL(OUTPUT_NC_tab,'Q_THREAD',real_LastPass,CONST_YES);
	PCALL(OUTPUT_NC_tab,'R_THREAD',X_Aufmass,const_YES);				{Aufmass in X}
	writeb;
	
	PCALL(OUTPUT_NC_G,int_GCode,CONST_YES);
	
	CASE int_Side OF
		CONST_OUTSIDE : real_XEnd := tr3_PtEnd[1] - real_Depth;
		CONST_INSIDE : real_XEnd := tr3_PtEnd[1] + real_Depth;
	END;
	PCALL(OUTPUT_NC_pplane,tr3_PtEnd[0],real_XEnd ,CONST_YES);
	
	
	IF NOT IsNull(real_RValue) THEN
		PCALL(OUTPUT_NC_tab,'R_THREAD',real_RValue,CONST_YES);
		PCALL(OUTPUT_NC_tab,'P_THREAD',real_Depth,CONST_YES);
		PCALL(OUTPUT_NC_tab,'Q_THREAD',real_DepthOne,CONST_YES);
	
	PCALL(OUTPUT_NC_tab,'FR',real_Pitch,CONST_YES); writeb;
	
	DebugEnd;
END;


{----------------------------------------------------------------------------}
FUNCTION IsRadialPlane{:BOOLEAN};
{----------------------------------------------------------------------------}
VAR
	int_PlaneType :INTEGER;

	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'IsRadialPlane');
	DebugBegin(str_ProcName,CONST_NO);

	InitPlane(int_PlaneType);

	IsRadialPlane := (int_PlaneType = 123) OR (int_PlaneType = 124) OR (int_PlaneType = 143)
		OR (int_PlaneType = 130) OR (int_PlaneType = 150)
		OR (int_PlaneType = 124) OR (int_PlaneType = 144);

	DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE OutputMTEMoveOrigin{(int_TypeMove :INTEGER; tr3_Pt : TR3)};
{----------------------------------------------------------------------------}
VAR
	real_PosX, real_PosY, real_PosZ 
	: REAL;
	
	str_ProcName 
	: TC255;
	
BEGIN
	strcpy(str_ProcName,'OutputMTEMoveOrigin');
	DebugBegin(str_ProcName,CONST_NO);

	real_PosX := tr3_Pt[0];
	real_PosY := tr3_Pt[1];
	real_PosZ := tr3_Pt[2];

	DebugEnd;
END;



{----------------------------------------------------------------------------}
PROCEDURE OutputSynchroToolpath{(int_PosSynchro:INTEGER)};
{----------------------------------------------------------------------------}
{BEGIN_ENGLISH                                                                                                                                                                    }
{                                                                                                                                                                                                         }
{ Treatment of synchronisations :                                                                                            }
{ Call of SYNCRO_PASSE                                         int_PosSynchro = 0     }
{ Call of DEBUT_OPERATION after tool selection (and spindle)   int_PosSynchro = 1     }
{ Call of DEBUT_SPECIAL or DEBUT_OPERATION at beginning        int_PosSynchro = 2     }
{ Call of FIN_OPERATION                                        int_PosSynchro = -1    }
{ Call of FIN_SPECIAL                                          int_PosSynchro = -2    }
{                                                                                                                                                                                                         }
{END_ENGLISH                                                                                                                                                                      }
{                                                                                                                                                                                                         }
{ Traitement des synchronisations :                                                                                       }
{ appel de SYNCRO_PASSE                                   int_PosSynchro = 0          }
{ appel de DEBUT_OPE apres selection outil (et broche)    int_PosSynchro = 1          }
{ appel de DEBUT_SPECIAL ou DEBUT_OPERATION au depart     int_PosSynchro = 2          }
{ appel de FIN_OPE                                        int_PosSynchro = -1         }
{ appel de FIN_SPECIAL                                    int_PosSynchro = -2         }
{----------------------------------------------------------------------------}
VAR
	int_SynchroType,int_IdSync,int_SyncNo,int_TypePos,int_CycleNo,int_TurretNo,int_SpindleType,i
	int_SyncNumFirst ,int_Lenght    
	: INTEGER;
	
	str_P,str_Val,str_Label
	: TC80;
	
	str_ProcName ,str_Message,str_CycleName
	: TC255;
	
BEGIN
	strcpy(str_ProcName,'OutputSynchroToolpath');
	DebugBegin(str_ProcName,CONST_NO);
	
	PCALL(READ_DPP_integer,GPP_INTEGER_SYNCHRO_FIRST_NB,int_SyncNumFirst);        
	
	int_SynchroType := CONST_NO;
	
	
	CASE int_PosSynchro OF
		0 : PCALL(READ_PART_synchro_channel,CONST_SYNC_PATH,int_SynchroType,int_IdSync,int_SyncNo);
		1 : PCALL(READ_PART_synchro_channel,CONST_SYNC_TOOL,int_SynchroType,int_IdSync,int_SyncNo);
		2 : PCALL(READ_PART_synchro_channel,CONST_SYNC_START,int_SynchroType,int_IdSync,int_SyncNo);  { faire appel dans debut_ope }
		-1,-2 : PCALL(READ_PART_synchro_channel,CONST_SYNC_END,int_SynchroType,int_IdSync,int_SyncNo);
	END;
	
	
	IF (int_PosSynchro = 1) AND (int_SynchroType <> CONST_NO) THEN
	BEGIN
		PCALL(READ_PART_cycle_name,str_CycleName);
		ReadTxtPack(19, str_Message);
		MessagePPWarning(0,str_Message,str_CycleName);
	END;
									
	IF ( int_SynchroType <> CONST_NO ) THEN 
		BEGIN      
			PCALL(bcnTAB_STR,'SP','(SYNC)',1);
			PCALL(OUTPUT_NC_m,(int_SyncNumFirst+int_IdSync),CONST_YES);
			strcpy(str_P,'P');
			
			FOR i := 1 TO 5 DO { 5 canaux maxi ici }
				BEGIN
				PCALL(READ_PART_synchro_channel_info,int_IdSync,i,int_SynchroType,int_TypePos,int_CycleNo,int_TurretNo,int_SpindleType);
		
				IF (int_SynchroType <> CONST_NO) THEN
					BEGIN
					str_itoa(str_Val,i);
					strcat(str_P,str_Val);
					END;
				END;
			
			PCALL(READ_PART_synchro_label,int_IdSync,str_Label);  
			int_Lenght := strlen(str_Label);
		IF (int_Lenght > 0) THEN 
			BEGIN
			PCALL(OUTPUT_NC_tab_str,'CO',str_Label,1); 
			END;

			{PCALL(OUTPUT_NC_tab_str,'SP',str_P,1); writeb;}			{Kein P Code ausgeben}
			writeb
	END; 
	DebugEnd;
END;



{----------------------------------------------------------------------------}
PROCEDURE MTEToolChange;
{----------------------------------------------------------------------------}
VAR
	i,int_Turret, int_NbPt, int_Err,int_NumTool,int_ToolOffset,int_ToolLenght : INTEGER;
	int_Poste,int_Index,int_CorL,int_CorD : INTEGER;
	tr3_PtLu : TR3;
	str_LabelPoint, str_Tool : TC255;
	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'MTEToolChange');
	DebugBegin(str_ProcName,CONST_NO);


	If IsTurretTurret or IsTurretSpindle THEN
	BEGIN
		PCALL(PPMTE_get_turret,int_Turret);
		if int_Turret = 0 THEN PCALL(READ_PART_turret_no,int_Turret);
		
		PCALL(READ_PART_MTE_number_turret_pt,int_Turret,CONST_TOOL_CHANGE,int_NbPt);
		PCALL(PPMTE_SET_reference,0,CONST_NO,CONST_NO,CONST_NO);
		FOR i:= int_NbPt DOWNTO 1 DO
		BEGIN
			PCALL(READ_PART_MTE_turret_pt,int_Turret,CONST_TOOL_CHANGE,i,int_Err,str_LabelPoint,tr3_PtLu);
			IF int_Err = CONST_YES THEN
			BEGIN
				PCALL(PPMTE_set_posax,1,tr3_PtLu[0]);
				PCALL(PPMTE_set_posax,2,tr3_PtLu[1]);
				PCALL(PPMTE_set_posax,3,tr3_PtLu[2]);
				PCALL(PPMTE_exe_event,MTE_GOTO);
			END;
		END;

{UNLOAD TOOL}


		{ PCALL(PPMTE_set_tool,-1,0,0); }
		{ PCALL(PPMTE_exe_event,EXE_TURRET); }


	{LOAD TOOL think to declare variables}
	{read the information of next tool because it's called at the end of operation}
		{ PCALL(READ_PART_next_tool_informations,int_Turret,int_NumTool,int_Poste,int_Index,str_Tool); }
		PCALL(READ_PART_tool,int_NumTool,int_CorL,int_CorD);
		PCALL(READ_PART_tool_post_index,int_Poste,int_Index);
		PCALL(PPMTE_set_tool,int_NumTool,int_Poste,int_Index);


		PCALL(PPMTE_exe_event,EXE_TURRET);

		FOR i:= 1 TO int_NbPt DO
		BEGIN
			PCALL(READ_PART_MTE_turret_pt,int_Turret,CONST_TOOL_CHANGE,i,int_Err,str_LabelPoint,tr3_PtLu);
			IF int_Err = CONST_YES THEN
			BEGIN
				PCALL(PPMTE_set_posax,1,tr3_PtLu[0]);
				PCALL(PPMTE_set_posax,2,tr3_PtLu[1]);
				PCALL(PPMTE_set_posax,3,tr3_PtLu[2]);
				PCALL(PPMTE_exe_event,MTE_GOTO);
			END;
		END;
END;

	DebugEnd;
END;



{----------------------------------------------------------------------------}
FUNCTION IsOutputToolChange{:BOOLEAN};
{----------------------------------------------------------------------------}
VAR
	int_ToolPos,int_Poste,int_Index,int_Turret,int_NextToolPos,int_NextPoste,int_NextIndex
	int_CorL,int_CorD,int_Call,int_IsToolChange,int_Ret,int_IsChangeCycle, int_IsToolChangePocket
	int_T
	: INTEGER;
	
	str_Tool,str_ProcName 
	: TC255;
	
BEGIN
	strcpy(str_ProcName,'IsOutputToolChange');
	DebugBegin(str_ProcName,CONST_NO);
	int_Ret := CONST_NO;

	int_IsToolChange := ICALL(TEST_change_tool);
	int_IsToolChange := ICALL(TEST_change_tool_pocket);
	int_IsToolChangePocket := ICALL(TEST_change_tool_pocket_turret);
	int_IsChangeCycle := ICALL(TEST_change_cycle);

	IF ((INTRD(SPE_INT_FORCE_TOOL_CHANGE) = CONST_YES) OR ((int_IsToolChange = CONST_YES) OR (int_IsToolChangePocket = CONST_YES)) OR ((INTRD(LIB_LIST_OUTPUT_TOOL_PLANE_EACH_OP) = CONST_YES) AND (int_IsChangeCycle = CONST_YES))) THEN
		BEGIN
		int_Ret := CONST_YES;
		END;
	
	IsOutputToolChange := (int_Ret = CONST_YES);
	DebugEnd;
END;

{----------------------------------------------------------------------------}
PROCEDURE OutputNCPrimary{(real_Angle : REAL)};
{----------------------------------------------------------------------------}
VAR
	str_ProcName : TC255;
	real_AngleToOutput, real_CurAngle : REAL;
BEGIN
	strcpy(str_ProcName,'OutputNCPrimary');
	DebugBegin(str_ProcName,CONST_NO);

	real_AngleToOutput := real_Angle;
	{2022-03-10 XP Add 180 degrees to the C when we are on rework spindle}
	{ IF IsReworkSpindle THEN real_AngleToOutput := real_Angle + 180; }
	IF IsChannel(2) THEN
	BEGIN
		real_AngleToOutput := real_Angle + 180;
		{To keep angle under 360 after transforming}
		IF real_Angle > 180 THEN real_AngleToOutput := real_Angle -180;
	END;
	
	IF HavePrimaryAxis THEN PCALL(OUTPUT_NC_primary,real_AngleToOutput,CONST_NO);

	

	DebugEnd;
END;{@}

{----------------------------------------------------------------------------}
FUNCTION IsMovePrimaryAxis2{:BOOLEAN};
{----------------------------------------------------------------------------}
VAR
	str_PrimaryKey, str_Ax2Key : TC255;
	real_OldPos,real_PrimaryAngle : REAL;
	tr3_Pt : TR3;
	int_Ret,int_Active : INTEGER;
	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'IsMovePrimaryAxis2');
	DebugBegin(str_ProcName,CONST_NO);

	int_Ret := CONST_NO;

	PCALL(READ_NC_key_primary,str_PrimaryKey);
	PCALL(READ_NC_key_axis2,str_Ax2Key);
	PCALL(READ_PATH_point,tr3_Pt);

	IF (strcmp(str_PrimaryKey,str_Ax2Key) = 0) THEN
	BEGIN
		PCALL(READ_NC_PAXIS2,real_OldPos);
		IF IsNotEqual(real_OldPos,tr3_Pt[1]) THEN
		BEGIN
			int_Ret := CONST_YES;
		END;
	END
	ELSE
	BEGIN
		PCALL(READ_NC_primary,real_OldPos);
		PCALL(READ_PART_primary,real_PrimaryAngle);
		{2022-03-10 XP Add 180 degree when we are on reworkspindle}
		{ IF IsReworkSpindle THEN real_PrimaryAngle := real_PrimaryAngle + 180; }
		IF IsChannel(2) THEN 
		BEGIN
			IF real_PrimaryAngle > 180 THEN 
			BEGIN
				real_PrimaryAngle := real_PrimaryAngle - 180;
			END
			ELSE
			BEGIN
				real_PrimaryAngle := real_PrimaryAngle + 180;
			END;
		END;
		IF IsNotEqual(real_OldPos,real_PrimaryAngle) THEN
		BEGIN
			int_Ret := CONST_YES;
		END;
	END;

	IsMovePrimaryAxis2 := int_Ret = CONST_YES;

	DebugEnd;
END;{@}


{----------------------------------------------------------------------------}
PROCEDURE Operation_End;
{----------------------------------------------------------------------------}
VAR
	int_IsLastCycle, int_ToolChange : INTEGER;
	str_OpName : TC255;
	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'Operation_End');
	DebugBegin(str_ProcName,CONST_YES);
	int_IsLastCycle := ICALL(TEST_last_cycle,CONST_YES);

	PCALL(READ_PART_cycle_name, str_OpName);
	{ writeln('          op name : ', str_OpName); }
	int_ToolChange := ICALL(TEST_change_tool);
	{ writeln('            tool change : ', int_ToolChange); }

	IF int_IsLastCycle = CONST_YES THEN
	BEGIN
		MTETreatment(2,CONST_NO);
	END
	ELSE
	BEGIN
		IF IsOutputToolChange THEN
		BEGIN
			MTETreatment(3,CONST_NO);
		END
		ELSE IF IsOutputPlane THEN
		BEGIN
			MTETreatment(4,CONST_NO);
		END;
	END;
	

	
	IF IsMillingOperation THEN
	BEGIN
		EndMillOperation;
	END
	ELSE
	BEGIN
		IF IsPartingReworkOperation THEN
		BEGIN
			EndPartingReworkOperation;
		END
		ELSE
		BEGIN
			EndTurnOperation;
		END;
	END;

	
	FreeArrayDrillingInfo;

	DebugEnd;
END;{@}

{----------------------------------------------------------------------------}
PROCEDURE ParameterPackage;
{----------------------------------------------------------------------------}
VAR
	int_Line, int_Column,int_WidthFrame, int_StartLine, i : INTEGER;
	str_Message : TC255;
	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'ParameterPackage');
	DebugBegin(str_ProcName,CONST_NO);
	
	int_WidthFrame := 70;
	int_Line := 1;
	int_Column := 15;
	
	ReadTxtPack(1,str_Message);
	ParameterCreatePage(0,str_Message);
	
	ReadTxtPack(2,str_Message);
	ParameterCreateFrame(0,int_Line,1,6,int_WidthFrame,str_Message);
	
	int_StartLine := int_Line;
	strcpy(str_Message,'1');
	ParameterCreateComment(0,int_Line,int_Column+2,10,str_Message);
	
	ReadTxtPack(3,str_Message);
	ParameterCreateInteger(SPE_INT_PACK_OFFSET_UPPER_TURRET_1,0,0,int_Line,int_Column,str_Message);
	PCALL(SPI_WIN_write_format_param,0,(int_Line * 12), ((int_Column-9) * 10),5,5);
	{ strcpy(str_Message,'Test'); }
	ReadTxtPack(13,str_Message);
	PCALL(SPI_WIN_write_comment_param,str_Message);
	
	InitNullString(str_Message);
	ParameterCreateCheck(SPE_INT_PACK_OFFSET_UPPER_TOOL_1,0,0,int_Line, (int_Column + 2),str_Message);
	
	
	ReadTxtPack(4,str_Message);
	ParameterCreateInteger(SPE_INT_PACK_OFFSET_LOWER_TURRET_1,0,0,int_Line,int_Column,str_Message);
	
	PCALL(SPI_WIN_write_format_param,0,(int_Line * 12), ((int_Column-9) * 10),5,5);
	{ strcpy(str_Message,'Test'); }
	ReadTxtPack(13,str_Message);
	PCALL(SPI_WIN_write_comment_param,str_Message);
	
	InitNullString(str_Message);
	ParameterCreateCheck(SPE_INT_PACK_OFFSET_LOWER_TOOL_1,0,0,int_Line, (int_Column + 2),str_Message);
	
	
	FOR i:= 1 TO 7 DO
	BEGIN
		int_Column := int_Column + 6;
		int_Line := int_StartLine;
		str_itoa(str_Message,(i+1));
		ParameterCreateComment(0,int_Line,int_Column+2,10,str_Message);
		
		InitNullString(str_Message);
		ParameterCreateInteger((SPE_INT_PACK_OFFSET_UPPER_TURRET_1+i),0,(i*10),int_Line,int_Column,str_Message);
		
		ParameterCreateCheck((SPE_INT_PACK_OFFSET_UPPER_TOOL_1+i),0,0,int_Line, (int_Column + 2),str_Message);
		
		ParameterCreateInteger((SPE_INT_PACK_OFFSET_LOWER_TURRET_1+i),0,(i*10),int_Line,int_Column,str_Message);
		ParameterCreateCheck((SPE_INT_PACK_OFFSET_LOWER_TOOL_1+i),0,0,int_Line, (int_Column + 2),str_Message);
	END;
	
	int_Line := int_Line + 2;
	ReadTxtPack(11,str_Message);
	
	ParameterCreateFrame(0,int_Line,1,3,int_WidthFrame,str_Message);
	
	int_Column := 15;
	
	ReadTxtPack(12,str_Message);
	ParameterCreateList(SPE_LIST_USE_DAT_FILE,0,0,int_Line, int_Column,str_Message);
	
	ReadTxtPack(17,str_Message);
	ParameterCreateList(SPE_LIST_USE_G411,0,0,int_Line,int_Column,str_Message);
	
	
	int_Line := int_Line + 2;
	ReadTxtPack(14,str_Message);
	ParameterCreateFrame(0,int_Line,1,3,int_WidthFrame,str_Message);
	
	ReadTxtPack(15,str_Message);
	ParameterCreateInteger(SPE_INT_PACK_MAIN_SPINDLE_ORIGIN,0,54,int_Line, (int_Column+10),str_Message);
	
	ReadTxtPack(16,str_Message);
	ParameterCreateInteger(SPE_INT_PACK_REWORK_SPINDLE_ORIGIN,0,55,int_Line, (int_Column+10),str_Message);
	
	
	
	DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE ParameterPackageStore;
{----------------------------------------------------------------------------}
VAR
	i : INTEGER;
	str_ProcName : TC255;
	
BEGIN
	strcpy(str_ProcName,'ParameterPackageStore');
	DebugBegin(str_ProcName,CONST_NO);
	
	FOR i := 0 TO 7 DO
	BEGIN
		StoreGlobalInteger(SPE_INT_PACK_OFFSET_UPPER_TURRET_1+i);
		StoreGlobalInteger(SPE_INT_PACK_OFFSET_LOWER_TURRET_1+i);
		StoreGlobalBoolean(SPE_INT_PACK_OFFSET_LOWER_TOOL_1+i);
		StoreGlobalBoolean(SPE_INT_PACK_OFFSET_UPPER_TOOL_1+i);
	END;
	
	StoreGlobalList(SPE_LIST_USE_DAT_FILE);
	
	StoreGlobalInteger(SPE_INT_PACK_MAIN_SPINDLE_ORIGIN);
	StoreGlobalInteger(SPE_INT_PACK_REWORK_SPINDLE_ORIGIN);
	
	StoreGlobalList(SPE_LIST_USE_G411);
	
	DebugEnd;
END;

{----------------------------------------------------------------------------}
PROCEDURE Parameter_Standard;
{----------------------------------------------------------------------------}
VAR
	int_Line,int_Column,int_BTypePP : INTEGER;
	str_Null,str_GppRef : TC255;
	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'Parameter_Standard');
	DebugBegin(str_ProcName,CONST_YES);

	int_line   := 1;
	int_Column := 42;
	str_Null[0] := chr(0);

	PCALL(READ_PART_string_tec,GPP_STRING_IDENTIFICATON,str_GppRef);

	PCALL(SPI_WIN_write_title_param,str_GppRef);

	PCALL(READ_PART_boolean_tec,BOOLEAN_MAC_PP_TYPE,int_BTypePP);
	IF (int_BTypePP = CONST_STD ) THEN
	BEGIN
		ParameterController(int_line,int_Column);
		ParameterTurning(int_line,int_Column);
		ParameterCodeManagement(int_line,30);
		ParameterWarningDebug(int_Line, int_Column);
	END;
	ParameterFileManagement(int_Line,int_Column);
	
	ParameterPackage;

	DebugEnd;
END;{@}

{----------------------------------------------------------------------------}
PROCEDURE File_Begin;
{----------------------------------------------------------------------------}
VAR
	str_FileName :TC255;
	int_BTypePP : INTEGER;
	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'File_Begin');
	DebugBegin(str_ProcName,CONST_YES);

	InitPPVariables;

	PCALL(READ_PART_boolean_tec,BOOLEAN_MAC_PP_TYPE,int_BTypePP);
	IF (int_BTypePP = CONST_STD ) THEN
	BEGIN

		ParameterCustomerInit;
		ParameterControllerInit;
		ParameterTurningInit;
		ParameterCodeManagementInit;
		ParameterFileManagementInit;
		ParameterWarningDebugInit;

	
		ParameterControllerStore;
		ParameterTurningStore;
		ParameterCodeManagementStore;
		ParameterWarningDebugStore;

	

	END;
	
	ParameterFileManagementStore;
	ParameterPackageStore;
	
	ParameterCustomerStore;
	ParameterPPStore;
	{ ParameterValidate; }
	ParameterPPValidate;

	InitGPPNC;
	InitDatVariables;

	STRINGRD(LIB_STR_NOM_FIC_ISO,str_FileName);

	RenameNCFile(str_FileName);

	DebugEnd;
END;{@}

{----------------------------------------------------------------------------}
PROCEDURE OutputLineListTool{(int_ToolNum: INTEGER;str_ToolName: TC255)};
{----------------------------------------------------------------------------}
{
Output a line of tool list
This procedure is called by the ListTool procedure from PP67_TOOL.LIB
}
VAR
	str_Line, str_ToolNum,str_Search, str_Replace :TC255;
	int_ToolLengthOffset : INTEGER;
	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'OutputLineListTool');
	DebugBegin(str_ProcName,CONST_NO);

	strcpy(str_Line,'T');
	Werkzeugnummer_Offset_Berechnung;
	int_ToolLengthOffset := INTRD(SPE_AKTUELL_WZ_LAENGE_OFFSET); 
	int_ToolNum := INTRD(SPE_AKTUELLES_WERKZEUG);
	int_ToolNum := 100 * int_ToolNum + int_ToolLengthOffset;
	str_itoa(str_ToolNum,int_ToolNum);
	strcat(str_Line,str_ToolNum);
	strcat(str_line,' ');
	strcat(str_Line,str_ToolName);

	PCALL(OUTPUT_NC_tab_str,'CO',str_Line,CONST_YES);
	writeb;
	DebugEnd;
END;{@}


{----------------------------------------------------------------------------}
PROCEDURE StartPartingReworkOperation;
{----------------------------------------------------------------------------}
VAR
	int_OutputCoolantPosition :INTEGER;
	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'StartPartingReworkOperation');
	DebugBegin(str_ProcName,CONST_NO);
	{output start tunr operation by default}

	{ ApproachReworkSpindle; }
	
	IF INTRD(SPE_LIST_USE_DAT_FILE) = 0 THEN
	BEGIN
		StartTurnOperation;
	END
	ELSE
	BEGIN
		PCALL(OUTPUT_NC_punch_validate,CONST_NO);
	END;
	
	
	DebugEnd;
END;{@}


{----------------------------------------------------------------------------}
PROCEDURE EndPartingReworkOperation;
{----------------------------------------------------------------------------}
VAR
	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'EndPartingReworkOperation');
	DebugBegin(str_ProcName,CONST_NO);

	{End turn operation by default}
	EndTurnOperation;

	DebugEnd;
END;{@}

{----------------------------------------------------------------------------}
PROCEDURE Part_Return;
{----------------------------------------------------------------------------}
VAR
	int_TypeReturn : INTEGER;
	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'Part_Return');
	DebugBegin(str_ProcName,CONST_YES);

		{ writeln('                       return'); }
	PCALL(READ_PART_customer_type,int_TypeReturn);
	{ writeln('               type return : ', int_TypeReturn); }
	IF int_TypeReturn = CONST_PART_RETURN THEN
	BEGIN
		ReturnPart;
	END
	ELSE IF int_TypeReturn = CONST_PART_REWORK THEN
	BEGIN
		IF not IsPartingReworkOperation THEN
		BEGIN
			{ MTETreatment(5,CONST_NO); }
			ReworkPart;
		END;
		IF IsPartingReworkOperation THEN
		BEGIN
			
		END;
		
	END
	{2021-03-25 XP add treatment for going back in main spindle}
	ELSE IF int_TypeReturn = CONST_PART_MAIN THEN
	BEGIN
		MTETreatment(5,CONST_NO);
		BackMainPart;
	END;

	DebugEnd;
END;{@}

{----------------------------------------------------------------------------}
PROCEDURE File_Treatment;
{----------------------------------------------------------------------------}
VAR
	int_ListingMin,int_ListingMax : INTEGER;
	str_Adr,str_FileName,str_Ext : TC255;
	str_ProcName : TC255;
	BEGIN
	strcpy(str_ProcName,'File_Treatment');
	DebugBegin(str_ProcName,CONST_YES);

	int_ListingMin := INTRD(LIB_INT_LISTING_MIN);
	int_ListingMax := INTRD(LIB_INT_LISTING_MAX);

	IF (INTRD(LIB_INT_LISTING_FILE) = CONST_YES) THEN 
	BEGIN
		{ writeln('                   listing'); }
		{create listing.txt file separateur col 50 (synchro M950 .M999}
		ListingSynchroManage(0,int_ListingMin,int_ListingMax);
		ListingSynchroCopy;
	END;
	

	DebugEnd;
END;{@}


{----------------------------------------------------------------------------}
PROCEDURE InitGPPNC;
{----------------------------------------------------------------------------}
{
This procedure contains all the treatment that must be done in the GPP
It depends of the CNC
}
VAR
	int_TypeFeedCode : INTEGER;
	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'InitGPPNC');
	DebugBegin(str_ProcName,CONST_NO);

	{modification of feed code G94/G95 or G98/G99}
	int_TypeFeedCode := INTRD(STD_LIST_FEED_CODE);
	IF int_TypeFeedCode = 0 THEN
	BEGIN
		PCALL(WRITE_DPP_integer,GPP_INTEGER_GCODE_MM_MIN,98);
		PCALL(WRITE_DPP_integer,GPP_INTEGER_GCODE_MM_REV,99);
		PCALL(WRITE_DPP_integer,GPP_INTEGER_GCODE_MM_MIN_RT,98);
	END;
	
	{if g411 is used we don't output block numbers}
	IF INTRD(SPE_LIST_USE_G411) = CONST_YES THEN PCALL(WRITE_NC_block_format,2);

	DebugEnd;
END;{@}


{----------------------------------------------------------------------------}
PROCEDURE Cycle_Turn_Roughing;
{----------------------------------------------------------------------------}
VAR
	int_BlockDep, int_BlockEnd, int_MemoBlock, int_BlockIncr, int_Unit : INTEGER;
	int_GCode, int_MachiningDirection, int_MemoBlockFormat : INTEGER;
	real_SDz, real_SDx , real_IncrDepth, real_LastPassDepth, real_XAllow, real_ZAllow, real_Feed: REAL;
	real_PosZ, real_PosX : REAL;
	str_Message, str_DepthKey : TC255;
	tr3_Pt : TR3;
	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'Cycle_Turn_Roughing');
	DebugBegin(str_ProcName,CONST_YES);
	{ strcpy(str_Message,'Specific cycle not treated'); }
	{ MessageWarning(217,str_Message); }
	
	PCALL(READ_PART_turn_canned_safety_dist,real_SDz,real_SDx,CONST_YES);
	PCALL(READ_PART_turn_canned_depth,real_IncrDepth,real_LastPassDepth,CONST_NO);
	PCALL(READ_PART_turn_canned_overlength,real_ZAllow,real_XAllow,CONST_YES);
	PCALL(READ_PATH_feed,real_Feed,int_Unit);
	PCALL(READ_PART_boolean_tec,BOOLEAN_TURN_MACHINING_DIRECTION, int_MachiningDirection);
	PCALL(READ_PART_profile_start_point,tr3_Pt);
	PCALL(READ_NC_format_block,int_MemoBlockFormat);
	
	
	PCALL(READ_NC_block_no,int_MemoBlock);
	PCALL(READ_DPP_integer,GPP_INTEGER_BLOCKS_INCREMENT,int_BlockIncr);
	
	PCALL(WRITE_DPP_integer,GPP_INTEGER_BLOCKS_INCREMENT,1);
	int_BlockIncr := 1;

	{offset the bloc number to keep a bloc number for G71 output}
	{we do only if block number is activated}
	IF int_MemoBlockFormat = 0 THEN
		PCALL(WRITE_NC_block_no,(int_MemoBlock + (2 * int_BlockIncr)));
		
	PCALL(READ_NC_paxis1,real_PosZ);
	PCALL(READ_NC_paxis2,real_PosX);
	{store the profile output in the buffer}
	PCALL(OUTPUT_NC_buffer_on);
	
	PCALL(WRITE_NC_init_g,0);
	OutputNCRapid;
	
	IF (int_MachiningDirection = CONST_OUTSIDE) OR (int_MachiningDirection = CONST_INSIDE) THEN 
	BEGIN
		PCALL(OUTPUT_NC_pplane,real_PosZ, tr3_Pt[1],CONST_NO);
	END
	ELSE
	BEGIN
		PCALL(OUTPUT_NC_pplane,tr3_Pt[0], real_PosX,CONST_NO);
	END;
	{we output the block with forcing the block number}
	PCALL(WRITE_NC_block_format,0);
	writeb;
	{we restore the normal block format}
	PCALL(WRITE_NC_block_format,int_MemoBlockFormat);
	
	OutputNCProfile(int_BlockDep,int_BlockEnd);
	{ writeln('                      ' ,int_BlockDep,int_BlockEnd); }
	PCALL(OUTPUT_NC_buffer_off);
	{switch to the normal output}
	
	{restore the block number}
	PCALL(WRITE_NC_block_no,int_MemoBlock);
	
	{output the canned cycle}
	{init the facing G72 cycle}
	int_GCode := 72;
	strcpy(str_DepthKey,'W_ROUGHT');
	{if we are in outside or inside roughing, we init the values for G71}
	IF (int_MachiningDirection = CONST_OUTSIDE) OR (int_MachiningDirection = CONST_INSIDE) THEN 
	BEGIN
		int_GCode := 71;
		strcpy(str_DepthKey,'U_ROUGHT');
	END;
	
	{first line of G71-G72}
	PCALL(OUTPUT_NC_g,int_GCode,CONST_YES);
	PCALL(OUTPUT_NC_tab,str_DepthKey, real_IncrDepth,CONST_YES);
	PCALL(OUTPUT_NC_tab,'R_ROUGHT', (ABS(real_SDx)),CONST_YES);
	writeb;
	
	{ PCALL(READ_NC_block_no,int_BlockDep); }
	{ int_BlockDep := int_BlockDep - 10 + 1; }
	{the first block number will be offset only if we output block number for the program}
	{ IF int_MemoBlockFormat = 0 THEN }
		{ int_BlockDep := int_BlockDep + int_BlockIncr; }
	{Second line of G71-G72}
	PCALL(OUTPUT_NC_g,int_GCode,CONST_YES);
	PCALL(OUTPUT_NC_tab,'P_ROUGHT',(int_BlockDep - int_BlockIncr),CONST_YES);
	PCALL(OUTPUT_NC_tab,'Q_ROUGHT',(int_BlockEnd - int_BlockIncr),CONST_YES);
	PCALL(OUTPUT_NC_tab,'U_ROUGHT',real_XAllow,CONST_YES);
	PCALL(OUTPUT_NC_tab,'W_ROUGHT', real_ZAllow,CONST_YES);
	OutputNCFeed(real_Feed,int_Unit);
	writeb;
	
	{output the buffer to output the profile}
	PCALL(OUTPUT_NC_buffer_punch);
	PCALL(WRITE_NC_block_no,(int_BlockEnd));

	PCALL(WRITE_DPP_integer,GPP_INTEGER_BLOCKS_INCREMENT,10);

	DebugEnd;
END;{@}

{----------------------------------------------------------------------------}
PROCEDURE OutputNCProfile{(VAR int_NumBlockDep, int_NumBlockEnd : INTEGER)};
{----------------------------------------------------------------------------}
VAR
	tr3_Pt : TR3;
	i, int_NbElt, int_Type, int_MemoBlockFormat : INTEGER;
	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'OutputNCProfile');
	DebugBegin(str_ProcName,CONST_NO);
	
	PCALL(READ_NC_format_block,int_MemoBlockFormat);
	
	PCALL(READ_PART_profile_elt_number,int_NbElt);
	

	PCALL(READ_NC_block_no,int_NumBlockDep);
	
	PCALL(READ_PART_profile_start_point,tr3_Pt);
	PCALL(OUTPUT_NC_pplane,tr3_Pt[0], tr3_Pt[1],CONST_NO);
	{ PCALL(WRITE_NC_block_format,0); }
	IF TESTMOVE THEN
	BEGIN
		OutputNCG1;
		writeb;
		{ PCALL(WRITE_NC_block_format,int_MemoBlockFormat) }
	END;
	FOR i:=1 TO int_NbElt DO
	BEGIN
		PCALL(LOAD_profile_elt, i, int_Type);
		IF i = int_NbElt THEN
		BEGIN
			{ PCALL(READ_NC_block_no,int_NumBlockEnd); }
			PCALL(WRITE_NC_block_format,0);
		END;
		IF int_Type = CONST_TOOLPATH_LINE THEN OutputNCLineProfile;
		IF int_Type = CONST_TOOLPATH_CIRCLE THEN OutputNCCircleProfile;
		IF i = int_NbElt THEN
		BEGIN
			PCALL(READ_NC_block_no,int_NumBlockEnd);
			{ PCALL(WRITE_NC_block_format,0); }
		END;
		PCALL(WRITE_NC_block_format,int_MemoBlockFormat)
	END;
	
	DebugEnd;
END;{@}

{----------------------------------------------------------------------------}
PROCEDURE InitOperation;
{----------------------------------------------------------------------------}
VAR
	int_CycleNo,int_Value, int_Decompose :INTEGER;
	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'InitOperation');
	DebugBegin(str_ProcName,CONST_NO);

	PCALL(WRITE_NC_G_force,0);
	PCALL(WRITE_NC_G_force,90);
	PCALL(WRITE_NC_init_feed);
	PCALL(WRITE_NC_G_force,98);
	PCALL(WRITE_NC_init_g,80);
	IF INTRD(STD_LIST_FEED_CODE) = 1 THEN
	BEGIN
			 PCALL(WRITE_NC_g_force,94);
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
					  { PCALL(WRITE_DPP_cycle_exec,CONST_DECOMPOSED); }
			END;
		END;
		CONST_DRILL_CHIP_BREAK : BEGIN
			{If the value of Param 5101 is 2 we must decompose the chipbreak cycle}
			IF (int_Value = 2) or (int_Value = 0) THEN
			BEGIN
					  { PCALL(WRITE_DPP_cycle_exec,CONST_DECOMPOSED); }
			END;
		END;
	END;

	IF IsOutputPlane THEN
	BEGIN
			 PCALL(WRITE_NC_force_primary);
			 PCALL(WRITE_NC_force_secondary);
	END;
	
	
	{2021-01-08 XP Add decompose cycle if invert spindle in drilling cycle}
	int_Decompose := CONST_NO;
	IF IsDrillingWithInvert THEN int_Decompose := CONST_YES;
	
	IF int_Decompose = CONST_YES THEN PCALL(WRITE_DPP_cycle_exec,CONST_DECOMPOSED);

	DebugEnd;
END;{@}

{----------------------------------------------------------------------------}
PROCEDURE OutputAxialInterpoOff;
{----------------------------------------------------------------------------}
{
Output the axial interpo code
Default value is G13.1 if not set on the code management page
}
VAR
        str_InterpoOff : TC255;
        str_ProcName : TC255;
BEGIN
        strcpy(str_ProcName,'OutputAxialInterpoOff');
        DebugBegin(str_ProcName,CONST_NO);

	IF IsGCodeActivated(112) THEN
	BEGIN
		strcpy(str_InterpoOff,'G13.1');
		DisableAxialInterpoCode(str_InterpoOff);
		PCALL(WRITE_NC_G,113);
		PCALL(OUTPUT_NC_punch_str,str_InterpoOff);
	END;
        DebugEnd;
END;{@}


{----------------------------------------------------------------------------}
PROCEDURE Test_Cycle_Turn_Drilling(VAR int_Cable:INTEGER);
{----------------------------------------------------------------------------}
VAR
	int_TypeCycle  : INTEGER;

	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'Test_Cycle_Turn_Drilling');
	DebugBegin(str_ProcName,CONST_YES);
	int_Cable := CONST_YES;
	{ simple drilling always decomposed }
	PCALL(READ_PART_boolean_tec,BOOLEAN_TURN_DRILLING_TYPE,int_TypeCycle);
	{ IF (int_TypeCycle = CONST_TYPE_CYCLE_DRILLING_SIMPLE) THEN int_Cable := CONST_NO; }

	DebugEnd;
END;{@}


{----------------------------------------------------------------------------}
PROCEDURE OutputCycleDrillingSimpleTurn;
{----------------------------------------------------------------------------}
{
This operation is always decompose.
See the Test_Cycle_Turn_Drilling from PP67_TURN.LIB 
}
VAR
	int_Bunit, int_ZSign, int_CycleType 
	:INTEGER;
	
	real_Depth, real_Depth1,real_FinalDepth, real_Feed 
	:REAL;

	tr3_Pt 
	: TR3;

        str_ProcName : TC255;
BEGIN
        strcpy(str_ProcName,'OutputCycleDrillingSimpleTurn');
        DebugBegin(str_ProcName,CONST_NO);


	PCALL(READ_PATH_point,tr3_Pt);
	PCALL(READ_PART_drill_depth,real_Depth,real_Depth1,real_FinalDepth);
	PCALL(READ_PATH_feed,real_Feed,int_BUnit);
	PCALL(READ_PART_boolean_tec,BOOLEAN_TURN_MACHINING_DIRECTION,int_CycleType);
	
	OutputApproachDrillingTurn;
	int_ZSign := 1;
	IF int_CycleType = DPP_ARRIERE THEN int_ZSign := -1;
	
	PCALL(OUTPUT_NC_G,83,CONST_YES);
	{ PCALL(OUTPUT_NC_tab, 'G_REAL',83.6,CONST_YES); }
	{2023-03-03 XP invert sign to manage rework}
	{ PCALL(OUTPUT_NC_pplane,(tr3_Pt[0]-(real_Depth * int_ZSign)),tr3_Pt[1],CONST_YES); }
	PCALL(OUTPUT_NC_pplane,(tr3_Pt[0]-(real_Depth)),tr3_Pt[1],CONST_YES);
	{ PCALL(OUTPUT_NC_tab,'Q_DRILL',real_Depth1,CONST_YES); }
	PCALL(OUTPUT_NC_feed,real_Feed,int_BUnit); writeb;
	
	{ PCALL(WRITE_NC_g,83); }
	
	OutputDrillingCancelTurn;
	
	PCALL(WRITE_NC_key,'G_REAL',80);


        DebugEnd;
END;{@}

{----------------------------------------------------------------------------}
FUNCTION ListDatFile(VAR str_ListDatFile : TC255):INTEGER;
{----------------------------------------------------------------------------}
VAR
	int_Err,int_Ret : INTEGER;
	str_Dir, str_Pattern, str_FileName, str_MachineName, str_Null : TC255;
	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'ProcName');
	DebugBegin(str_ProcName,CONST_NO);

	PCALL(READ_PART_mac_directory,str_Dir);
	PCALL(READ_PART_machine_name,str_MachineName);
	PCALL(SPI_FIL_remove_extension,str_MachineName,str_MachineName);

	InitNullString(str_ListDatFile);
	InitNullString(str_Null);
	int_Ret := 0;
	
	strcpy(str_Pattern,str_MachineName);
	strcat(str_Pattern,'*.DAT');
	int_Err := ICALL(SPI_FIL_open_filcat,str_Dir,str_Pattern);
	strcpy(str_FileName,'init');
	WHILE ( str_FileName[0] <> chr(0) ) DO
	BEGIN
		int_Err := ICALL (SPI_FIL_get_filcat,str_FileName);
		IF not IsNullString(str_FileName)THEN
		BEGIN
			strcat(str_ListDatFile,'-');
			PCALL(SPI_FIL_remove_extension,str_Filename,str_FileName);
			StringReplace(str_Filename,str_MachineName,str_Null);
			strcat(str_ListDatFile,str_FileName);
			int_Ret := int_Ret + 1;
		END;
	END;
	
	int_Err := ICALL(SPI_FIL_close_filcat);
	
	ListDatFile := int_Ret;
	
	DebugEnd;
END;



{----------------------------------------------------------------------------}
PROCEDURE ParameterPP{(int_Line,int_Column:INTEGER)};
{----------------------------------------------------------------------------}
VAR	
	int_NbDatFile : INTEGER;
	str_Message, str_FileName, str_ListDatFile 	: TC255;
	str_ProcName 					: TC255;
		
BEGIN
	strcpy(str_ProcName,'ParameterPP');
	DebugBegin(str_ProcName,CONST_NO);

	Str_Message[0] := chr(0);
	strcpy(Str_Message,'Standard');
	ParameterCreatePage(857,Str_Message);

	{ str_Message[0] := chr(0); }
	ParameterCreateFrame(857,int_Line,1,7,53,str_Message);

	ParametercreateBitmapGO;  

	PCALL(READ_PART_file_name,str_FileName);
	strcpy(str_Message,'File Name');
	ParameterCreateStringIgnore(LIB_STR_NOM_FIC_ISO,780,str_FileName,int_Line,int_Column,20,str_Message);

	strcpy(str_Message,'Program Number');
	ParameterCreateInteger(STD_INT_PROG_NUMBER,1121,0,int_Line, int_Column,str_Message);


	strcpy(str_Message,'Comment Output-No-Yes');
	ParameterCreateList(LIB_LIST_COMMENTS,1122,1,int_Line,int_Column,str_Message);

	strcpy(str_Message,'Block Numbers-With-Without-Tool Change Only');
	ParameterCreateList(STD_LIST_BLOCK_NUMBERS,1123,0,int_Line,int_Column,str_Message);


	strcpy(str_Message,'Code for program end-M30-M02-M99');
	ParameterCreateList(STD_LIST_CODE_END,1124,0,int_Line,int_Column,str_Message);

	int_NbDatFile := ListDatFile(str_ListDatFile);
	IF (int_NbDatFile > 1) THEN
	BEGIN
		ReadTxtPack(21,str_Message);
		strcat(str_Message,str_ListDatFile);
		ParameterCreateList(SPE_LIST_DAT,0,0,int_Line,int_COlumn,str_Message);
	END;
	{ strcpy(str_Message) }

	DebugEnd;
END;{@}


{----------------------------------------------------------------------------}
PROCEDURE GetDatFileName(VAR str_DatFileName: TC255);
{----------------------------------------------------------------------------}
VAR
	int_NbDatFile, int_NumDatFile,int_Ret, i : INTEGER;
	str_DatList, str_Lad, str_Dat, str_Read, str_Null,str_MachineName : TC255;
	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'GetDatFileName');
	DebugBegin(str_ProcName,CONST_NO);
	
	int_NbDatFile := ListDatFile(str_DatList);
	int_NumDatFile := INTRD(SPE_LIST_DAT);
	PCALL(READ_PART_machine_name,str_MachineName);
	PCALL(SPI_FIL_remove_extension,str_MachineName,str_MachineName);
	strcpy(str_Lad,'-');
	InitNullString(str_Null);
	
	IF int_NbDatFile > 1 THEN
	BEGIN
		IF int_NumDatFile <= int_NbDatFile THEN
		BEGIN
			strcat(str_DatList,str_Lad);
			FOR i := 0 TO int_NumDatFile DO
			BEGIN
				StringBetween(str_Read,str_DatList,str_Lad,str_Lad);
				IF i <> int_NumDatFile THEN
				BEGIN
					strcat(str_Read,str_Lad);
					StringReplace(str_DatList,str_Read,str_Null);
				END;
			END;
			
			strcpy(str_DatFileName,str_MachineName);
			strcat(str_DatFileName,str_Read);
		END;
	END;
	
	DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE OutputDatSectionSpe{(str_SectionName : TC255)};
{----------------------------------------------------------------------------}
VAR
	int_Err : INTEGER;
	str_DirName, str_FileName, str_MemoSoftChar, str_Null : TC255;
	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'OutputDatSectionSpe');
	DebugBegin(str_ProcName,CONST_NO);
	
	InitNullString(str_Filename);
	
	PCALL(READ_PART_mac_directory,str_DirName);
	GetDatFileName(str_Filename);
	
	IF IsNullString(str_FileName) THEN
	BEGIN
		PCALL(READ_PART_machine_name,str_FileName);
		int_Err := ICALL(SPI_FIL_remove_extension, str_FileName,str_FileName);
	END;
	strcat(str_FileName,'.DAT');
	str_Null[0] := chr(0);
	
	PCALL(READ_DPP_string,GPP_STRING_SOFT_CHARACTERS,str_MemoSoftChar);
	PCALL(WRITE_DPP_string,GPP_STRING_SOFT_CHARACTERS,str_Null);
	
	
	PCALL(WRITE_DPP_string,GPP_STRING_SOFT_CHARACTERS,str_MemoSoftChar);
	
	DatFileOutput(str_DirName,str_FileName,str_SectionName);

	PCALL(WRITE_NC_FORCE_SPINDLE,CONST_YES,CONST_YES,CONST_NO);
	PCALL(WRITE_NC_FORCE_FEED,CONST_YES,CONST_YES);

	DebugEnd;
END;


{----------------------------------------------------------------------------}
PROCEDURE ApproachPlaneLiveToolBegin;
{----------------------------------------------------------------------------}
VAR

	tr3_Pt : TR3;
	real_Angle1,real_Angle2,real_Angle3,real_a1,real_a2,real_a3 :REAL;
	str_InterpoOn : TC255;
	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'ApproachPlaneLiveToolBegin');
	DebugBegin(str_ProcName,CONST_NO);

	PCALL(READ_PART_rot_angles,real_a1,real_a2,real_a3);
	IF IsAxialInterpoPlane THEN
	BEGIN
		{We must active the plane here because we can't have rapid move}
		{in G112 on Fanuc CNC}
		{we read the last position of C axis to be able to offset the plane}
		{we must do it because the G112 active the current C as C0}
		PCALL(READ_NC_paxis2,real_Angle1);
		If IsReworkSpindle and IsChannel(2) THEN
		BEGIN
			real_Angle1 := real_Angle1 +180;
		END;
		ActivePlane;

		{we offset the plane to have correct coordinates}
		PCALL(WRITE_NC_plane_rotation,-real_Angle1+real_a1);


		OutputAxialInterpoOn;

		{Write the point in the cn memory to don't have axis tool movement in the next move}
		PCALL(READ_PATH_point,tr3_Pt);
		PCALL(WRITE_NC_paxis3,tr3_Pt[2]);
		writeb;
		
	END;

	If IsDevZPlane THEN
	BEGIN
			 OutputRadialInterpoOn;
	END;


	DebugEnd;
END;{@}



{----------------------------------------------------------------------------}
PROCEDURE ReturnPlaneLiveToolEnd;
{----------------------------------------------------------------------------}
{
Adds some treatment after Return_Plane_Livetool
}
VAR
        int_PlaneNum : INTEGER;
        tr3_Pt :TR3;
        str_InterpoOff : TC255;
        str_ProcName : TC255;
BEGIN
        strcpy(str_ProcName,'ReturnPlaneLiveToolEnd');
        DebugBegin(str_ProcName,CONST_NO);

        IF IsAxialInterpoPlane THEN
        BEGIN
                {We reactiv Milling evolution plane to be able to move in rapid}
                ActiveMillingEvolutionPlane;
                OutputAxialInterpoOff;
                writeb;
                {Write the point in the cn memory to don't have in the next move}
                PCALL(READ_PATH_point,tr3_Pt);
                PCALL(WRITE_NC_pplane,tr3_Pt[0],tr3_Pt[1]);
                PCALL(WRITE_NC_paxis3,tr3_Pt[2]);

        END;
        
        IF IsDevZPlane THEN
        BEGIN
                OutputRadialInterpoOff;
        END;

        DebugEnd;
END;{@}

{----------------------------------------------------------------------------}
PROCEDURE File_End;
{----------------------------------------------------------------------------}
VAR
	int_CutFile : INTEGER;
	str_FileName : TC255;
	str_ProcName : TC255;
BEGIN
	strcpy(str_ProcName,'File_End');
	DebugBegin(str_ProcName,CONST_YES);

	int_CutFile := INTRD(LIB_INT_FILE_PER_CHANNEL);
	IF int_CutFile = CONST_NO THEN
	BEGIN
	   EndFile;
	END;
	
	{2023-04-13 XP Restore the filename of original file without C1 or C2}
	STRINGRD(LIB_STR_NOM_FIC_ISO,str_FileName);
	PCALL(SPECIF_file_name,str_FileName);
	
	
	OutputXMLforPDM;
	
	SelectIsoColorSyntax;
	
	DebugEnd;
END;{@}