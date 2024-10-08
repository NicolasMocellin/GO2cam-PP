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


 {INTEGER} 
	SPE_SPANNDRUCK  						= 0;
	SPE_GEWINDE_M329						= 1;
	SPE_REV1_STUFENBOHRER_1			= 2;
	SPE_REV1_STUFENBOHRER_2			= 3;
	SPE_REV2_STUFENBOHRER_1			= 4;
	SPE_REV2_STUFENBOHRER_2			= 5;
	SPE_OLD_WZ_LAENGE_OFFSET		= 6;
	SPE_REV1_MESSTASTER					= 7;
	SPE_REV2_MESSTASTER					= 8;
	SPE_G8P1										= 9;
	SPE_M471    								= 10;
	SPE_ABWICKLUNG_AKTIV    	 	= 11;
	SPE_WZ_WECHSEL_ERZWINGEN		= 12;
	SPE_AKTUELL_WZ_LAENGE_OFFSET= 13;
	SPE_PUNCH_ACTIF							= 14;
	SPE_LIZENZ_VERSION_PRUEFEN	= 15;
	SPE_C_KLEMMEN								= 16;
	SPE_AKTUELLES_WERKZEUG			= 17;
	SPE_FESTANSCHLAG						= 18;
	SPE_INT_WZ_WECHSEL_TECHNO		= 19;
	SPE_INT_KANAL_WECHSEL				= 20;
	SPE_INT_EBENEN_NR						= 21;
	
	SPE_INT_PACK_OFFSET_UPPER_TURRET_1 = 22;
	SPE_INT_PACK_OFFSET_UPPER_TURRET_2 = 23;
	SPE_INT_PACK_OFFSET_UPPER_TURRET_3 = 24;
	SPE_INT_PACK_OFFSET_UPPER_TURRET_4 = 25;
	SPE_INT_PACK_OFFSET_UPPER_TURRET_5 = 26;
	SPE_INT_PACK_OFFSET_UPPER_TURRET_6 = 27;
	SPE_INT_PACK_OFFSET_UPPER_TURRET_7 = 28;
	SPE_INT_PACK_OFFSET_UPPER_TURRET_8 = 29;
	
	SPE_INT_PACK_OFFSET_LOWER_TURRET_1 = 30;
	SPE_INT_PACK_OFFSET_LOWER_TURRET_2 = 31;
	SPE_INT_PACK_OFFSET_LOWER_TURRET_3 = 32;
	SPE_INT_PACK_OFFSET_LOWER_TURRET_4 = 33;
	SPE_INT_PACK_OFFSET_LOWER_TURRET_5 = 34;
	SPE_INT_PACK_OFFSET_LOWER_TURRET_6 = 35;
	SPE_INT_PACK_OFFSET_LOWER_TURRET_7 = 36;
	SPE_INT_PACK_OFFSET_LOWER_TURRET_8 = 37;
	
	SPE_LIST_USE_DAT_FILE = 38;
	
	{ MTE_INT_ACTIV								= 50; }
	
	SPE_INT_PACK_OFFSET_UPPER_TOOL_1 = 39;
	SPE_INT_PACK_OFFSET_UPPER_TOOL_2 = 40;
	SPE_INT_PACK_OFFSET_UPPER_TOOL_3 = 41;
	SPE_INT_PACK_OFFSET_UPPER_TOOL_4 = 42;
	SPE_INT_PACK_OFFSET_UPPER_TOOL_5 = 43;
	SPE_INT_PACK_OFFSET_UPPER_TOOL_6 = 44;
	SPE_INT_PACK_OFFSET_UPPER_TOOL_7 = 45;
	SPE_INT_PACK_OFFSET_UPPER_TOOL_8 = 46;
	
	SPE_INT_NB_PARTING_CYCLE = 47;
	SPE_INT_NB_PARTING_DONE = 48;
	
	SPE_LIST_DAT = 49;
	
	SPE_INT_PACK_OFFSET_LOWER_TOOL_1 = 71;
	SPE_INT_PACK_OFFSET_LOWER_TOOL_2 = 72;
	SPE_INT_PACK_OFFSET_LOWER_TOOL_3 = 73;
	SPE_INT_PACK_OFFSET_LOWER_TOOL_4 = 74;
	SPE_INT_PACK_OFFSET_LOWER_TOOL_5 = 75;
	SPE_INT_PACK_OFFSET_LOWER_TOOL_6 = 76;
	SPE_INT_PACK_OFFSET_LOWER_TOOL_7 = 77;
	SPE_INT_PACK_OFFSET_LOWER_TOOL_8 = 78;
	
	SPE_INT_PACK_MAIN_SPINDLE_ORIGIN = 79;
	SPE_INT_PACK_REWORK_SPINDLE_ORIGIN = 80;
	
	SPE_LIST_USE_G411=81;
	SPE_INT_BLOCK_NO_G411=82;
	SPE_INT_FORCE_TOOL_CHANGE=83;
	
	AAAAA 											= 201;
	
	{Real}	 	
	SPE_ANSCHLAG_END_Z					= 0;	
	SPE_REAL_RUECKZUG_Z					= 1;
	SPE_ANZAHL_TEILE						= 2;	
	SPE_TEILE_VERSCHIEBUNG			= 3;	
	SPE_NP_VERSCHIEBUNG					= 4;	
	SPE_SICHERHEITS_W_POS				= 5;
	SPE_B_UEBERGABE_KORR				= 6;	
	SPE_REAL_ABSTECHBREITE			= 7;
	SPE_M471_WERT								= 8;
	SPE_REAL_WZ_WECHSEL_TECHNO	= 9;
	SPE_REAL_REV1_Z_FREIFAHREN	= 10;
	
	{CHAINE}
   SPE_PROGRAMM_ERSTELLER 		= 51; 
   SPE_PROGRAMM_VERSION 			= 52; 
	