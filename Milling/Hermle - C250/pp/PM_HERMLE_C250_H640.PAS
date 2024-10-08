{****************************************************************************
Customer .......... : 
CNC ............... : 
MachineTool ....... : 
Standard PP ....... : M60_Heidenhain_500.SPF
Comment ........... : 
Date .............. : 
Ppman ............. : 
-----------------------------------------------------------------------------
Modified .......... : 
****************************************************************************}

{----------------------------------------------------------------------------}
FUNCTION Fnmodulo_angle_spe(A2:REAL):REAL;
{----------------------------------------------------------------------------}
VAR
   R       : REAL;
   
BEGIN
        WHILE (A2 < 0) DO A2 := 360 + A2;
        
        IF (ABS(A2)<360) THEN Fnmodulo_angle_spe:= A2
        ELSE
        BEGIN
                R := A2-(TRUNC(A2/360)*360);
                IF (ABS(R-360) < TOLERPP) THEN R := 0;
                Fnmodulo_angle_spe := R;
        END;
END;                                                                                                        {@}


{----------------------------------------------------------------------------}
PROCEDURE User_Primaire{(primaire:REAL)};
{----------------------------------------------------------------------------}
VAR 
   dang,old,ang : REAL;

BEGIN
   IF ((INTRD(LIB_MULTAX) = DPP_OUI) AND (INTRD(1) = 1)) THEN { lineaire }
   BEGIN
      PCALL(lcnPRIMAIRE,old);
      dang := Fnmodulo_angle_spe(primaire)-Fnmodulo_angle_spe(old);
      IF (dang > 180.0) THEN dang := dang-360.0;
      IF (dang < -180.0) THEN dang := dang+360.0;
      PCALL(bcnPRIMAIRE,(old+dang),DPP_NON);
   END
   ELSE   { modulo }
   BEGIN
    	ang := Fnmodulo_angle_spe(primaire);
    	PCALL(bcnprimaire,ang,DPP_OUI);
  	END;
   INTWR(1,1); { active flag apres premier }
END;                                                                       {@}
{----------------------------------------------------------------------------}
FUNCTION isdigit(car : CHAR): INTEGER;
{----------------------------------------------------------------------------}
VAR
BEGIN
   isdigit := 0;
   if ((car = '0') OR
       (car = '1') OR
       (car = '2') OR
       (car = '3') OR
       (car = '4') OR
       (car = '5') OR
       (car = '6') OR
       (car = '7') OR
       (car = '8') OR
       (car = '9')) THEN isdigit := 1;
END;                                                                       {@}

{----------------------------------------------------------------------------}
FUNCTION isnumber(car : CHAR): INTEGER;
{----------------------------------------------------------------------------}
VAR
BEGIN
   isnumber := 0;
   IF (isdigit(car) = 1) THEN isnumber := 1
   ELSE
   IF ((car = '-') OR
       (car = '+') OR
       (car = '.')) THEN isnumber := 1;
END;                                                                       {@}

{----------------------------------------------------------------------------}
PROCEDURE OUTPUT_DAT(VAR sdir, sname: TC255; section_name : TC80);
{    debut section : #BEGIN section_name                                     }
{    blocs         : avec '/' , 'N*', 'Nxxxx'                                }
{    fin section   : #END                                                    }
{----------------------------------------------------------------------------}
VAR
   idfile,ier,posnum,num,inc,numpre,optpre,decode,typunch : INTEGER;
   str0,str,snum : TC255;
BEGIN
   idfile := ICALL(SPI_FIL_OPEN_ASCII_FILE,sdir,sname,2);
   decode := 0;
 
    writeln(sdir,sname,section_name);
    
   IF (idfile >= 0) THEN
   BEGIN
      WHILE (ICALL(SPI_FIL_READ_ASCII_FILE,str0,idfile) = SPI_YES) DO 
      BEGIN
         str_trim(str0,str0);
       
         IF (decode = 1) THEN { test fin section }
            IF (str_pos('#END',str0,0) = 0) THEN decode := 0;
        
         IF ((decode = 1)) THEN
         BEGIN   
            { numero et optionnel }
            PCALL(lcnNUM_BLOC,numpre);
            PCALL(ldppINCR_BLOC,inc);
            PCALL(lcnBLOC_OPTION,optpre);
            
            { init format et numero et optionnel }    
            strcpy(str,str0);
            posnum := 0;
            PCALL(ecnBLOC_OPTION,DPP_NON);
            IF (str_pos('/',str0,0) = 0) THEN
            BEGIN
               str_range(str,str0,1,strlen(str0)-1);
               PCALL(ecnBLOC_OPTION,DPP_OUI);
               strcpy(str0,str);
            END;
            IF (str_pos('N',str0,0) = 0) THEN
            BEGIN
               typunch := 0;
               str_range(str,str0,1,strlen(str0)-1);
               PCALL(ecnFORMAT_BLOC,0);
               strcpy(str0,str);
               IF (str0[0] = '*') THEN
                  str_range(str,str0,1,strlen(str0)-1)
               ELSE
               BEGIN
                  snum[0]:= chr(0);
                  WHILE (isdigit(str0[posnum])=1) DO posnum := posnum + 1;
                  IF (posnum > 0) THEN
                  BEGIN
                     str_range(str,str0,posnum,strlen(str0)-1);
                     str_range(snum,str0,0,posnum-1);
                     str_atoi(snum,num);
                     PCALL(ecnNUM_BLOC,num);
                  END;
               END;
            END
            ELSE typunch := 2;
            
            { sortie du bloc }
            str_trim(str,str);
            {TRAITE_VARIABLES(str);}
            PCALL(bcnTAB_STR,'SP',str,1);
            Punchb(typunch);
            
            { restore numero et optionnel }
            IF (posnum > 0) THEN
               PCALL(ecnNUM_BLOC,(numpre));
            PCALL(ecnBLOC_OPTION,optpre);
         END;
         
         IF (decode = 0) THEN { test debut section }
         BEGIN
            IF (str_pos('#BEGIN',str0,0) = 0) THEN
            BEGIN
               str_range(str,str0,strlen('#BEGIN'),strlen(str0)-1);
               str_trim(str,str);
               IF (str_pos(section_name,str,0) = 0) THEN decode := 1;
            END;
         END;
        
      END;
      ier := ICALL(SPI_FIL_CLOSE_ASCII_FILE,idfile); 
   END;
END;                                                                       {@}                                               
 
{----------------------------------------------------------------------------}
PROCEDURE OUTPUT_PP_DAT(VAR section_name : TC80);
{----------------------------------------------------------------------------}
VAR
   sdir,sname,msg : TC255;
 
BEGIN
   { on pourrait aussi utiliser SM_NOM_DNC pour même PP avec differentes configs }
   PCALL(SPI_GEN_get_information,SEN_PP_DIRECTORY,sdir);
   strcpy(msg,'PM_HERMLE_C250_H640.DAT');
   OUTPUT_DAT(sdir,msg,section_name);  
END;                                                                       {@}  
  
{----------------------------------------------------------------------------}
PROCEDURE Plan_continus;
{BEGIN_ENGLISH																					  }
{																									  }
{ Positionning of the table                                                  }
{																									  }
{END_ENGLISH																					  }
{																									  }
{ Positionnement de la table                                                 }
{                                                                            }
{----------------------------------------------------------------------------}
VAR
   a1,a2,a3,va 			: REAL ;
   strcom   			: TC80 ;
   pt             : TR3 ;
BEGIN
   IF ( ICALL(isCHGT_OUTIL) = DPP_NON ) THEN PCALL(bcnTAB_STR,'SP','CALL LBL "Annulation_Plane"',1);
   ecritb;
   PCALL(litROT_PLATEAU,a1,a2,a3);
   PCALL(litNOM_PLAN,strcom);
   PCALL(ltraPOINT,pt);
   PCALL(lit_RTEC,RTF_VALEUR_GARDE,va);
   PCALL(bcnTAB,'L',0,1);
   PCALL(bcnPPLAN,Pt[0],Pt[1],0);
   PCALL(bcnTAB,'Z',va,1);
   PCALL(bcnTAB,'FMAX',0,1);
   ecritb;
   PCALL(bcnM,128,1);
   ecritb;
   PCALL(bcnM,25,1);
   ecritb;
  
     
    {User_debloc_Plateau_1;	
   Ecritb;
   User_debloc_Plateau_2;
   ecritb;}
   User_Primaire(a1);
   Ecritb;
   User_Secondaire(a2);
   Ecritb;

   
   IF TESTMOVE THEN Ecritb;
END;                                                                       {@}   

{----------------------------------------------------------------------------}
PROCEDURE Fin_Pp;
{----------------------------------------------------------------------------}
VAR
   numbloc,ival : INTEGER;
   msg          : TC80;
BEGIN
   PCALL(ecnINIT_PLAN,DPP_PLAN_DEPART);

   {FMS_PP_END; }

   Bloc_Cn_Fin_Pp;
  PCALL(bcnM,09,1);
  PCALL(bcnTAB_STR,'SP','; Arret Lub',1);
  ecritb;
  PCALL(bcnM,23,1);
  PCALL(bcnTAB_STR,'SP','; Arret convoyeur',1);
  ecritb;
  PCALL(bcnTAB_STR,'SP','CALL LBL "Annulation_Totale"',1);
  ecritb;
  PCALL(bcnTAB_STR,'SP','* - STOP M30',1);
  ecritb;  
   CASE (INTRD(LIB_FIN_PP)) OF
	   0 : ival:=30 ;
     1 : ival:=02 ;
	   2 : ival:=99 ;	
	 END;	
   PCALL(bcnM,ival,DPP_NON);
   PCALL(bcnTAB,'L',0,0);
   Ecritb;

    PCALL(lcnNUM_BLOC,numbloc);
    INTWR(STD_MEMO_NUMBLOC,numbloc);
   
    strcpy(msg,'FIN_PROGRAMME'); 
    
    OUTPUT_PP_DAT(msg);
    
    PCALL(bcnTAB_STR,'CO','MESURE OUTIL',1);
    PUNCHB(2);
    PCALL(bcnTAB_STR,'SP','LBL "Mesure_Outil"',1);
    PUNCHB(2);
    cn_fin_pap(1);
    PCALL(bcnTAB_STR,'SP','TCH PROBE 584 MES. LONGUEUR,RAYON',1);
    PUNCHB(2);
    cn_fin_pap(3);
    PCALL(bcnTAB_STR,'Q350','3',1);
    PUNCHB(2);
    PCALL(bcnTAB_STR,'Q351','0',1);
    PUNCHB(2);
    PCALL(bcnTAB_STR,'Q352','0',1);
    PUNCHB(2);
    PCALL(bcnTAB_STR,'Q355','-1',1);
    PUNCHB(2);
    PCALL(bcnTAB_STR,'Q361','3',1);
    PUNCHB(2);
    PCALL(bcnTAB_STR,'Q362','0.005',1);
    PUNCHB(2);
    PCALL(bcnTAB_STR,'Q359','0',1);
    PUNCHB(2);
    cn_fin_pap(2); 
    PCALL(bcnTAB_STR,'Q360','0',1);
    PUNCHB(2);   
    cn_fin_pap(0);    
    PCALL(bcnTAB_STR,'SP','FN 9: IF +Q199 EQU +2 GOTO LBL "FIN-ERREUR" ;',1);
    PUNCHB(2);
    PCALL(bcnTAB_STR,'SP','LBL 0',1);
    PUNCHB(2);

    
END;                                                                       {@}
   
      
{----------------------------------------------------------------------------}
 PROCEDURE Debut_Pp;
{----------------------------------------------------------------------------}
VAR
      decal,traj      : INTEGER;
      Itool,Icol,Icod : INTEGER;
      sadr,snom,sext  : TC80;
      Long,Diam,val   : REAL;
      rprog           : REAL;
      nb,I            : INTEGER;
      Str1            : TC80;
BEGIN
   Lib_Test_Butee_Mac;  { }
   INTWR(STD_PLATEAU,0);
   INTWR(STD_ORIDECAL,0);
   {INTWR(STD_MATRICE_ROTATION,1);}
     
   PCALL(ecnESPACE_COM,DPP_NON);

   PCALL(litFIC_RUBAN,Sadr,Snom,Sext);

   rprog:=INTRD(LIB_PROGRAM_NUMBER);
   {IF (rprog > TOLERPP) THEN
   BEGIN
      DOUBLEWR(STD_NUMPRG,rprog);
      PCALL(bcnTAB,'BEGIN',rprog,1);
      PCALL(bcnTAB,'MM',0,1);
      Punchb(0);
   END
   ELSE}
   BEGIN
   	 { IF (strlen(snom)>8) THEN snom[8]:=chr(0); }{ 8 caracteres max }
      STRINGWR(NOMPRG,Snom);
      strcpy(str1,'BEGIN PGM ');
      strcat(str1,Snom);
      strcat(str1,' MM');

      PCALL(bcnTAB_STR,'SP',str1,0);
      Ecritb;
   END;

   IF (INTRD(LIB_COMMENTS) = CONST_YES) THEN PCALL(bcnCOM_DEBUT);
   PCALL(bcnTAB_STR,'SP','*- INIT',1);     
   ecritb;
   Bloc_Cn_Debut_Pp;

   IF (INTRD(STD_GRAPHIQUE)=1) OR (INTRD(STD_GRAPHIQUE)=2) THEN Graphique;

   IF INTRD(STD_POS_TOOLDEF) = 1 THEN
   BEGIN
      PCALL(litNB_OUTIL,nb);
      FOR I:=1 TO nb DO
      BEGIN
        PCALL(utilCHARGE_OUTIL,I);
        PCALL(litNUM_OUTIL,Itool);
        IF ( Itool <> 0 ) THEN Std_tool_def(Itool);
      END;
   END;

   {FMS_PP_START; }

   PCALL(ecnPRIMAIRE,0);
   PCALL(ecnSECONDAIRE,0);
   
   { Mouvement au point de chgt outil }
   IF ( INTRD(LIB_DEGAGE_DEBUT) = 0 ) THEN Degagement; { Degagement en Debut de Ruban }
   
   IF (INTRD(STD_EXPERT) = DPP_OUI) THEN
   BEGIN 
      Valide_Lissage; 
      std_Numero_posage;
   END;    
   IF ((INTRD(STD_M126))= 1 ) THEN PCALL(bcnTAB_STR,'SP','M126',1);
   Punchb(0);           
   PCALL(bcnM,21,1);
   PCALL(bcnTAB_STR,'SP','; CONVOYEUR',1);     
   ecritb;                             
   PCALL(bcnTAB_STR,'SP','CALL LBL "Annulation_Totale"',1);
   ecritb;
   PCALL(bcnSAUT_LIGNE,DPP_OUI);
END;                                                                       {@}

{----------------------------------------------------------------------------}
PROCEDURE Debut_Operation;
{----------------------------------------------------------------------------}
VAR     ispremier,ischout,numsuiv,
        numout,numcorlg,numcordia,
        unite,gamme,sensrot,icool,
        ischplan,typplan_cycle,
        isappelsp,I,decal,traj,ival,
        ind_lst,corlg_lst,cordia_lst,
        ischgt_vitesse                     : INTEGER;
        speed,diam,long,ichgt_out,oldspeed,ier,a1,a2,a3 : REAL;
        strcom,nomout,newfile                             : TC255;
        strplan : TC80;
BEGIN
   INTWR(STD_DIACO_TEC,DPP_IGNORE);

   ispremier := ICALL(isPREMIER_OUTIL_F);  { lecture infos ppg }
   ischplan  := ICALL(isCHGT_PLAN);        { chgt_plan GO2cam o/n }
   ischout   := ICALL(isCHGT_OUTIL);       { chgt_outil bdd   o/n }
   isappelsp := ICALL(isAPPEL_SPG);        { pour appel spg   o/n }
   PCALL(litTYPPLAN_CYCLE,typplan_cycle);
   PCALL(litOUTIL_SUIVANT,numsuiv);        { -premier_outil si dernier }
   PCALL(litSPINDLE,speed,unite,gamme);
   PCALL(litROTATION,sensrot);
   PCALL(litTOOL,numout,numcorlg,numcordia);
   PCALL(lcnSPEED,oldspeed);
   ischgt_vitesse:=DPP_NON;
   PCALL(litNOM_OUTIL,nomout);
   
   
   
   Init_debut_operation;
   Init_plan_operation(typplan_cycle);
   std_init_Plan; 
   PCALL(litNOM_PLAN,strplan);

   
   ier := ICALL(SPI_FIL_new_extension,nomout,'',newfile);
 	 newfile[strlen(newfile)-2] := chr(0);
 	 

 	 
   IF (INTRD(LIB_COMMENTS) = CONST_YES) THEN
   BEGIN
   	PCALL(bcnTAB_STR,'SP','; =========================',1);
   	ecritb;
    IF (ICALL(isCHGT_CYCLE) = DPP_OUI) THEN PCALL(bcnCOM_CYCLE);
    PCALL(bcnTAB_STR,'NPLAN',strplan,1);
   	ecritb;
    PCALL(bcnTAB_STR,'SP','; =========================',1);
   	ecritb; 
   END;

	IF (ischout = DPP_OUI) THEN 
   BEGIN
	   IF (INTRD(STD_M6)=3) OR ((INTRD(STD_M6)=4) AND (ispremier=DPP_NON)) THEN        {M6 TOUS OUTILS AVANT TOOL CALL/SAUF 1er}
	   BEGIN
	      PCALL(bcnTAB,'L',0,0);
	      PCALL(bcnM,6,1);
	      Punchb(0);
	   END;
	END;

   Origine_Depart;

   { Si chgt vitesse oblige de repeter TOOL CALL N°outil + S... }             
   IF ((ABS(oldspeed-speed))>TOLERPP) THEN ischgt_vitesse:=DPP_OUI;
                    
   IF (ischout = DPP_OUI) OR (ischgt_vitesse = DPP_OUI) THEN
   BEGIN
      IF (ischout = DPP_OUI) THEN
      BEGIN
         IF (INTRD(STD_POS_TOOLDEF) = 2)  THEN
         BEGIN
            PCALL(litOUTIL_LISTE,numout,0,ind_lst,corlg_lst,ival,cordia_lst);
            IF (ind_lst>INTRD(STD_MEMO_IND_OUT)) THEN
            BEGIN
               Std_tool_def(numout);
               INTWR(STD_MEMO_IND_OUT,ind_lst); {memorise pour ne declarer 2 fois }
            END;
         END;
      END;
      PCALL(bcnTAB_STR,'T_CHAINE',newfile,DPP_OUI);
      PCALL(bcnSPINDLE,speed,unite,gamme);
      Ecrit_Axe_Broche; 								{ attention fait un ecritb }
      PCALL(bcnTAB_STR,'SP','CALL LBL "Chg_Outil"',1);
      ecritb;      

      { M6 }
      IF (ischout = DPP_OUI) THEN 
      BEGIN
         IF (INTRD(STD_M6) = 1) OR ((INTRD(STD_M6) = 2) AND (ispremier = DPP_NON)) THEN             {M6 TOUS OUTILS}
         BEGIN
            PCALL(bcnTAB,'L',0,0);
            PCALL(bcnM,6,1);
            Punchb(0);
         END;
   
         INTWR(STD_ROT,0);  { pour sortir la rotation broche }
   
         IF (INTRD(LIB_CHGT_OUTIL) = 2) THEN { si on a preselection dans CFG }
         BEGIN
            IF (numsuiv>0) THEN PCALL(bcnTAB,'TD',numsuiv,1);
            Punchb(0);
         END;
      END;
   END;
   IF (INTRD(LIB_COMMENTS) = CONST_YES) THEN
   BEGIN   
   IF (ICALL(isCHGT_OUTIL) = DPP_OUI) THEN PCALL(bcnCOM_OUTIL);
   END;
   

   
   Traite_Plan;
   
   IF (Continuous_Work = DPP_OUI) THEN  
    BEGIN
    	PCALL(ecnINIT_PLAN,200);
    END;	
      
   IF (Continuous_Work = DPP_NON) THEN Plan_plateau
                                  ELSE Plan_continus;
                                  
   PCALL(litROT_PLATEAU,a1,a2,a3);                              
   IF  ((a1=0) AND (a2=0) AND ( ispremier = DPP_OUI ) AND (Continuous_Work = DPP_NON)) THEN PCALL(bcnM,25,1);
   ecritb;
   Position_Plan_Dev(typplan_cycle); 				{ En plan developpe => positionnement en X0 ou Y0 }

   PCALL(ecnINIT_COOLANT);
   PCALL(ecnINIT_ROTATION);
   
   IF (isappelsp = DPP_NON) THEN
   BEGIN
      IF (INTRD(STD_POS_COOLANT) = 0) THEN { M13 avant PT }
      BEGIN
         PCALL(bcnROT_COOL_BDD,1);
         PCALL(bcnTAB,'L',0,0);
         Punchb(0);
      END;

      IF (INTRD(STD_POS_COOLANT) = 1) THEN PCALL(bcnROT_COOL_BDD,1);
      IF (INTRD(STD_POS_COOLANT) = 2) THEN PCALL(bcnROTATION_BDD,1);
      Pp_Pnt_Plan;
      INTWR(STD_DIACO,0); { R0 RR RL force }
      Complete_bloc(1);

      IF (INTRD(STD_POS_COOLANT) = 2) THEN
      BEGIN
         PCALL(ecnINIT_COOLANT);
         PCALL(bcnCOOLANT,icool);
      END;
      INTWR(STD_DIACO,1); 										{ R0 RR RL pas force }
      Pp_Pnt_Z;
      Complete_bloc(1);

      IF (INTRD(STD_POS_COOLANT) = 2) THEN 					{ ARROSAGE SUR DS }
      BEGIN
         PCALL(litCOOLANT,Icool);
         IF (Icool>0) THEN
         BEGIN
            PCALL(ecnINIT_COOLANT);
            PCALL(bcnCOOLANT,icool);
            PCALL(bcnTAB,'L',0,0);
            Punchb(0);
         END;
      END;
   END;

   { Decomposition systematique de chacune des passes, sauf trous }
   IF (INTRD(STD_DECOMP_SP) = 1) THEN
      IF ( ICALL(isCYCLE_TROU) = DPP_NON ) THEN
          PCALL(edppTRAITE_CYCLE,DPP_DECOMPOSE);
END;                                                                       {@}

{----------------------------------------------------------------------------}
PROCEDURE Plan_Plateau;   {appelee par debut operation, utile? }
{----------------------------------------------------------------------------}
VAR     strcom  : TC80;
        a1,a2,a3,old_a1,old_a2 : REAL;
        Pos_ini                :INTEGER;
BEGIN
   PCALL(litNOM_PLAN,strcom);
   PCALL(litROT_PLATEAU,a1,a2,a3);
     
   IF  ((a1=0) AND (a2=0)) THEN Pos_ini :=DPP_OUI ;
   
   Ori_Decal;
   IF (INTRD(STD_PLATEAU) = 1) THEN{ Angles usinages }
   BEGIN
      IF ( INTRD(STD_MATRICE_ROTATION) = 0) THEN
      BEGIN
   	   IF ((Pos_ini) = DPP_NON) THEN 
         BEGIN
            std_Cinematique;     
            Punchb(0);
         END;
      END    
      ELSE
      BEGIN  
    	   IF ((Pos_ini) = DPP_NON) THEN 
    	   BEGIN
    	      std_Cinematique; 
         END;    
      END; 
      INTWR(STD_PLATEAU,0);
   END;

   IF TESTMOVE THEN PCALL(bcnPUNCHB,0);
END;                                                                       {@}

{----------------------------------------------------------------------------}
PROCEDURE std_plan_Spatial;
{----------------------------------------------------------------------------}
VAR
   cinematique : INTEGER ;
   a1,a2,a3    : REAL;
BEGIN                   
   PCALL(lit_BTEC,BM_TYPE_ROT,cinematique);
   PCALL(litROT_PLATEAU,a1,a2,a3);      
     
   PCALL(bcnTAB,'PLAN_SPATIAL',0,1); 

   IF(cinematique= DPP_ROT_CB) THEN 
   BEGIN
      PCALL(bcnTAB,'SPA',0,1);
      PCALL(bcnTAB,'SPB',a2,1);  
      PCALL(bcnTAB,'SPC',a1,1); 
   END 	
   ELSE  IF(cinematique= DPP_ROT_AB) THEN
   BEGIN 
      PCALL(bcnTAB,'SPA',a1,1);
      PCALL(bcnTAB,'SPB',a2,1);  
      PCALL(bcnTAB,'SPC',0,1);
   END                         
   ELSE  IF(cinematique= DPP_ROT_BA) THEN
   BEGIN
      PCALL(bcnTAB,'SPA',a2,1);
      PCALL(bcnTAB,'SPB',a1,1);  
      PCALL(bcnTAB,'SPC',0,1);
   END 
   ELSE  IF(cinematique= DPP_ROT_CA) THEN                                             
   BEGIN
      PCALL(bcnTAB,'SPA',a2,1);
      PCALL(bcnTAB,'SPB',0,1);  
      PCALL(bcnTAB,'SPC',a1,1);
   END 
   ELSE    Punchb(0);                
     
   PCALL(bcnTAB,'TURN',0,1);
   PCALL(bcnTAB,'MB MAX',0,1);
   PCALL(bcnTAB,'FMAXI',0,1);
   PCALL(bcnTAB,'SEQ+-',0,1);
   PCALL(bcnTAB,'TABLE_ROT',0,1);      
   Punchb(0);
   PCALL(bcnM,25,1);
   ecritb;
END;                                 {@}

{----------------------------------------------------------------------------}
PROCEDURE std_Plan_Annule_Move_Rot;   {appelee par debut operation , utile ?}
{----------------------------------------------------------------------------}
BEGIN
   IF ( INTRD(STD_MATRICE_ROTATION) = 0) THEN
   BEGIN
      PCALL(bcnTAB,'CDEF',19.0,1);
      PCALL(bcnTAB,'PLAN USI',0,1);
      Punchb(0);
      PCALL(bcnTAB,'CDEF',19.1,1);
      PCALL(bcnPRIMAIRE,0,1);
      PCALL(bcnSECONDAIRE,0,1);
      Punchb(0);      		  
      PCALL(bcnTAB,'CDEF',19.0,1);  
      PCALL(bcnTAB,'CDEF',19.1,1);
      Punchb(0); 
   END
   ELSE 
   BEGIN
      PCALL(bcnTAB_STR,'SP','CALL LBL "Annulation_Plane"',DPP_OUI);
      ecritb;  
     {PCALL(bcnTAB_STR,'SP','PLANE RESET STAY',DPP_OUI);
      ecritb;}
   END; 
END;                                                                       {@}


{----------------------------------------------------------------------------}
PROCEDURE std_init_Plan;   {appelee par debut operation , utile ?}
{----------------------------------------------------------------------------}
VAR
   a1,a2,a3,a1_old,a2_old : REAL;
   Pos_ini,Ini_ROT,Chgt_plan,ispremier :INTEGER;
BEGIN
   PCALL(litROT_PLATEAU,a1,a2,a3);
   PCALL(lcnPRIMAIRE,a1_old);
   PCALL(lcnSECONDAIRE,a2_old);
   ispremier := ICALL(isPREMIER_OUTIL_F);
   
   IF  ((a1=0) AND (a2=0)) THEN Pos_ini :=DPP_OUI 
                           ELSE Pos_ini :=DPP_NON;
  
   IF ((ABS(a1-a1_old)>TOLERPP) OR (ABS(a2-a2_old)>TOLERPP))  THEN Chgt_plan:=DPP_OUI 
                                                              ELSE Chgt_plan:=DPP_NON;
                                                               
   IF (( ICALL(isCHGT_OUTIL) = DPP_OUI ) AND (Pos_ini= DPP_NON)) THEN Ini_ROT:=DPP_OUI
                                                                 ELSE Ini_ROT:=DPP_NON;
   
   IF ((Chgt_plan= DPP_OUI) OR (Ini_ROT = DPP_OUI )) THEN
   BEGIN
      {std_Plan_Annule_Move_Rot; 
      Annule_Exec_Ori_Decal; } 
      {PCALL(bcnTAB_STR,'SP','CALL LBL "Annulation_Totale"',1);
      ecritb;}
      INTWR(STD_PLATEAU,1); 
   END;
END;                                                                       {@}

{----------------------------------------------------------------------------}
PROCEDURE Exec_Percage_Universel{(cycle:INTEGER)};
{----------------------------------------------------------------------------}
VAR     feed,tempofin,tempopass,pene1,pene2,ds,prof,altret,raison,pas,
        Diam_nominal,retrait_inc,distance_retrait,angle_indexage,ri,rj,
        epaisseur,cote_ex,hauteur,Avance_retrait,nbr_brise_copeau,
        avance_pre_pos,diam_outil,Diam_pre_perc,r204                  : REAL;
        typtrou,premier,unite,numarro,numcyc,inbre,Decalage,a,ilen,ref    : INTEGER;
        comment,strtmp,str,str_ep,str_cote,str_hauteur                : TC80; 
        pt                                                            : TR3;
BEGIN
   PCALL(ltraFEED,feed,unite);              { lecture infos ppg }
   PCALL(litCOOLANT,numarro);
   PCALL(ltraPOINT,pt);
   PCALL(litTEMPO,tempopass,tempofin);
   PCALL(litPROF_PER,prof,pene1,pene2);
   PCALL(ltraDS,ds);
   PCALL(ltraALTRET,altret);
   PCALL(lit_RTEC,RTF_RETRAIT_INCR,retrait_inc); 
   PCALL(lit_RTEC,RTF_DISTANCE_RETRAIT,distance_retrait); 
   PCALL(lit_RTEC,RTF_ANGLE_INDEXAGE,angle_indexage);
   PCALL(lit_STEC,ST_COMMENTAIRE,comment);
   PCALL(lit_RTEC,RO_DIAMETRE,diam_outil);
   PCALL(lit_RTEC,RTF_AVANCE_PAR_DENT,pas);
   PCALL(lit_BTEC,BTF_PROFONDEUR_DIAMETRE,ref);
   
   IF Pene1 < TOLERPP THEN Pene1:=Prof;
   ilen:=strlen(comment);
   
   { Calcul du retrait en alesage param Q214 (sens degagement) }
   {cycle 202 et 204}
   IF (angle_indexage<TOLERPP) THEN Decalage:=4 ELSE {Y+}
   IF (ABS(angle_indexage-90)<TOLERPP) THEN Decalage:=3 ELSE {X+}
   IF (ABS(angle_indexage-180)<TOLERPP) THEN Decalage:=2 ELSE {Y-}
   IF (ABS(angle_indexage-270)<TOLERPP) THEN Decalage:=1; {X-}
   
   IF (altret-Pt[2] > ds) THEN r204 := altret-Pt[2]
                          ELSE r204 := ds; 
   PCALL(ecnPAX3_CYCLE,(pt[2]+r204));     
   
   IF ( change_condition(prof,pene1) = DPP_OUI ) THEN
   BEGIN
      Goto_trou(Pt);

      CASE cycle OF
      200 : BEGIN         
         Cn_Fin_Pap(1);
         PCALL(bcnTAB,'CDEF_INT',200,1);
         PCALL(bcnTAB,'PERC_UNI',0,1);
         Punchb(0);

         Calc_Prof_Pap(prof,pene1,pene2,raison,inbre);
         Cn_Fin_Pap(3);

         PCALL(bcnTAB,'Q200',ds,1);
         Punchb(2);
         PCALL(bcnTAB,'Q201',-prof,1);
         Punchb(2);
         PCALL(bcnTAB,'Q206',feed,1);
         Punchb(2);
         PCALL(bcnTAB,'Q202',pene1,1);
         Punchb(2);
         PCALL(bcnTAB,'Q210',tempopass,1);
         Punchb(2);
         PCALL(bcnTAB,'Q203',Pt[2],1);
         Punchb(2);
         PCALL(bcnTAB,'Q204',r204,1);         
         Punchb(2);
         cn_fin_pap(2);
         PCALL(bcnTAB,'Q211',tempofin,1);
         Punchb(2);
         IF (ref = DPP_POINTE_PER) THEN PCALL(bcnTAB,'Q395',0,1)
                                   ELSE PCALL(bcnTAB,'Q395',1,1); 
         Punchb(2);
        
         Cn_Fin_Pap(0);

         PCALL(bcnTAB,'CYCL',0,1);
         Punchb(0);
      END;
      201 : BEGIN
         Avance_retrait:=500;
         { Decodage commentaire pour cycle 201, on extrait format comment : Q208=...; }
         IF (ilen>0) THEN Decode_Comment(cycle,comment,Avance_retrait,cote_ex,hauteur,avance_pre_pos);
         
         cn_fin_pap(1);         
         PCALL(bcnTAB,'CDEF_INT',201,1);
         PCALL(bcnTAB,'ALES_UNI',0,1);
         Punchb(0);

         cn_fin_pap(3);
         PCALL(bcnTAB,'Q200',ds,1);
         Punchb(2);
         PCALL(bcnTAB,'Q201',-prof,1);
         Punchb(2);
         PCALL(bcnTAB,'Q206',feed,1);
         Punchb(2);
         PCALL(bcnTAB,'Q211',tempofin,1);
         Punchb(2);
         PCALL(bcnTAB,'Q208',Avance_retrait,1); { Avance Retrait }
         Punchb(2);
         PCALL(bcnTAB,'Q203',Pt[2],1);
         Punchb(2);
         cn_fin_pap(2);
         PCALL(bcnTAB,'Q204',r204,1);         
         Punchb(2);

         cn_fin_pap(0);
         PCALL(bcnTAB,'CYCL',0,1);
         Punchb(0);                                
      END;
      202 : BEGIN
         Avance_retrait:=500;
         { Decodage commentaire pour cycle 202, on extrait format comment : Q208=...; }
         IF (ilen>0) THEN Decode_Comment(cycle,comment,Avance_retrait,cote_ex,hauteur,avance_pre_pos);
         
         cn_fin_pap(1);
         PCALL(bcnTAB,'CDEF_INT',202,1);
         PCALL(bcnTAB,'ALES_ALES',0,1);
         Punchb(0);

         cn_fin_pap(3);
         PCALL(bcnTAB,'Q200',ds,1);
         Punchb(2);
         PCALL(bcnTAB,'Q201',-prof,1);
         Punchb(2);
         PCALL(bcnTAB,'Q206',feed,1);
         Punchb(2);
         PCALL(bcnTAB,'Q211',tempofin,1);
         Punchb(2);
         PCALL(bcnTAB,'Q208',Avance_retrait,1);
         Punchb(2);
         PCALL(bcnTAB,'Q203',Pt[2],1);
         Punchb(2);
         PCALL(bcnTAB,'Q204',r204,1);         
         Punchb(2);
         PCALL(bcnTAB,'Q214',Decalage,1);
         Punchb(2);
         cn_fin_pap(2);
         PCALL(bcnTAB,'Q336',angle_indexage,1);  { Angle de broche }
         Punchb(2);

         cn_fin_pap(0);
         PCALL(bcnTAB,'CYCL',0,1);
         Punchb(0);
      END;
      203 : BEGIN
         nbr_brise_copeau:=0;
         Avance_retrait:=500;
         { Decodage commentaire pour cycle 203, on extrait format comment : Q213=...;Q208=...;}
         IF (ilen>0) THEN Decode_Comment(cycle,comment,nbr_brise_copeau,Avance_retrait,hauteur,avance_pre_pos);
         
         cn_fin_pap(1);
         PCALL(bcnTAB,'CDEF_INT',203,1);
         PCALL(bcnTAB,'PERC_UNI',0,1);
         Punchb(0);
         
         Calc_Prof_Pap(prof,pene1,pene2,raison,inbre);
         cn_fin_pap(3);
         
         PCALL(bcnTAB,'Q200',ds,1);
         Punchb(2);
         PCALL(bcnTAB,'Q201',-prof,1);
         Punchb(2);
         PCALL(bcnTAB,'Q206',feed,1);
         Punchb(2);
         PCALL(bcnTAB,'Q202',pene1,1);
         Punchb(2);
         PCALL(bcnTAB,'Q210',tempopass,1);
         Punchb(2);
         PCALL(bcnTAB,'Q203',Pt[2],1);
         Punchb(2);
         PCALL(bcnTAB,'Q204',r204,1);         
         Punchb(2);
         PCALL(bcnTAB,'Q212',raison,1);
         Punchb(2);
         PCALL(bcnTAB,'Q213',nbr_brise_copeau,1); { Nombre de brise copeau, debourrage si =0 }
         Punchb(2);
         IF (ABS(pene2)<TOLERPP) THEN pene2:=0.1; {par def sinon si =0 cn warning }
         PCALL(bcnTAB,'Q205',pene2,1);
         Punchb(2);
         PCALL(bcnTAB,'Q211',tempofin,1);
         Punchb(2);
         cn_fin_pap(2);
         PCALL(bcnTAB,'Q208',Avance_retrait,1);
         Punchb(2);

         cn_fin_pap(0);
         PCALL(bcnTAB,'CYCL',0,1);
         Punchb(0);
      END;
      204 : BEGIN
         avance_pre_pos:=750;
         { Decodage commentaire pour cycle 204, on extrait format comment : Q250=...;Q251=...;Q252=...;Q253=...; }
         IF (ilen>0) THEN Decode_Comment(cycle,comment,epaisseur,cote_ex,hauteur,avance_pre_pos);
         
         Cn_Fin_Pap(1);
         PCALL(bcnTAB,'CDEF_INT',204,1);
         PCALL(bcnTAB_STR,'SP','CONTRE PERCAGE',1);
         Punchb(0);

         Calc_Prof_Pap(prof,pene1,pene2,raison,inbre);
         Cn_Fin_Pap(3);
         
         PCALL(bcnTAB,'Q200',ds,1);
         Punchb(2);
         PCALL(bcnTAB,'Q249',-prof,1); 			  { Prof. contre percage }
         Punchb(2);
         PCALL(bcnTAB,'Q250',epaisseur,1);        { Epaisseur du materiaux }
         Punchb(2);
         PCALL(bcnTAB,'Q251',cote_ex,1);          { Cote excentrique }
         Punchb(2);
         PCALL(bcnTAB,'Q252',hauteur,1);          { Hauteur de la dent }
         Punchb(2);
         PCALL(bcnTAB,'Q253',avance_pre_pos,1);   { Avance pre-posit }
         Punchb(2);
         PCALL(bcnTAB,'Q254',feed,1);       		  { Avance contre-percage }
         Punchb(2);
         PCALL(bcnTAB,'Q255',tempofin,1);         { Temporisation }
         Punchb(2);
         PCALL(bcnTAB,'Q203',Pt[2],1);
         Punchb(2);
         PCALL(bcnTAB,'Q204',r204,1);         
         Punchb(2);
         PCALL(bcnTAB,'Q214',Decalage,1);        { Sens de degagement}
         Punchb(2);
         Cn_Fin_Pap(2);
         PCALL(bcnTAB,'Q336',angle_indexage,1);  { Angle de broche }
         Punchb(2);

         Cn_Fin_Pap(0);
         PCALL(bcnTAB,'CYCL',0,1);
         Punchb(0);
      END;
      205 : BEGIN
         Cn_Fin_Pap(1);
         PCALL(bcnTAB,'CDEF_INT',205,1);
         PCALL(bcnTAB,'PERC_UNI',0,1);
         Punchb(0);

         Calc_Prof_Pap(prof,pene1,pene2,raison,inbre);
         Cn_Fin_Pap(3);
         
         PCALL(bcnTAB,'Q200',ds,1);
         Punchb(2);
         PCALL(bcnTAB,'Q201',-prof,1);
         Punchb(2);
         PCALL(bcnTAB,'Q206',feed,1);
         Punchb(2);
         PCALL(bcnTAB,'Q202',pene1,1);
         Punchb(2);
         PCALL(bcnTAB,'Q203',Pt[2],1);
         Punchb(2);
         PCALL(bcnTAB,'Q204',r204,1);         
         Punchb(2);
         PCALL(bcnTAB,'Q212',raison,1);
         Punchb(2);
         IF (ABS(pene2)<TOLERPP) THEN pene2:=0.1; {par def sinon si =0 cn warning }
         PCALL(bcnTAB,'Q205',pene2,1);
         Punchb(2);
         PCALL(bcnTAB,'Q258',ds,1);
         Punchb(2);
         PCALL(bcnTAB,'Q259',ds,1);
         Punchb(2);
         PCALL(bcnTAB,'Q257',pene1,1);
         Punchb(2);
         PCALL(bcnTAB,'Q256',retrait_inc,1); 
         Punchb(2);
         cn_fin_pap(2);
         PCALL(bcnTAB,'Q211',tempofin,1);
         Punchb(2);
         
         Cn_Fin_Pap(0);
         PCALL(bcnTAB,'CYCL',0,1);
         Punchb(0);
      END;
      208 : BEGIN
         Diam_nominal:=diam_outil+(diam_outil/2);  {par def}
         Diam_pre_perc:=0.1;  {par def}
         { Decodage commentaire pour cycle 208, on extrait format comment : Q335=...; }
         IF (ilen>0) THEN Decode_Comment(cycle,comment,Diam_nominal,Diam_pre_perc,hauteur,avance_pre_pos);
         
         Cn_Fin_Pap(1);
         PCALL(bcnTAB,'CDEF_INT',208,1);
         PCALL(bcnTAB_STR,'SP','FRAISAGE DE TROUS',1);
         Punchb(0);

         Cn_Fin_Pap(3);
         PCALL(bcnTAB,'Q200',ds,1);
         Punchb(2);
         PCALL(bcnTAB,'Q201',-prof,1);
         Punchb(2);
         PCALL(bcnTAB,'Q206',feed,1);
         Punchb(2);
         PCALL(bcnTAB,'Q334',pene1,1);
         Punchb(2);
         PCALL(bcnTAB,'Q203',Pt[2],1);
         Punchb(2);
         PCALL(bcnTAB,'Q204',r204,1);         
         Punchb(2);
         PCALL(bcnTAB,'Q335',Diam_nominal,1); { Diametre nominal }
         Punchb(2);
         Cn_Fin_Pap(2);
         PCALL(bcnTAB,'Q342',Diam_pre_perc,1); { }
         Punchb(2);

         Cn_Fin_Pap(0);
         PCALL(bcnTAB,'CYCL',0,1);
         Punchb(0);
      END;
      END;
   END
   ELSE
   BEGIN
      Pp_Pnt_Plan;
      PCALL(bcnPax3,(Pt[2]+ds),0);
      IF TESTMOVE THEN
      BEGIN
         IF INTRD(STD_RFM)=1 THEN PCALL(bcnTAB,'MSEUL',0,1);
         Complete_Bloc(5);
      END;
   END;
END;                                                                       {@}
{----------------------------------------------------------------------------}
PROCEDURE Exec_Taraudage_Universel{(cycle:INTEGER)};
{----------------------------------------------------------------------------}
VAR     feed,tempofin,tempopass,pene1,pene2,ds,prof,altret,raison,pas,
        Diam_nominal,retrait_inc,distance_retrait,angle_indexage,ri,rj,
        epaisseur,cote_ex,hauteur,Avance_retrait,nbr_brise_copeau,
        avance_pre_pos,diam_outil,r204                                : REAL;
        typtrou,premier,unite,numarro,numcyc,inbre,Decalage,a,ilen    : INTEGER;
        comment,strtmp,str,str_ep,str_cote,str_hauteur                : TC80; 
        pt                                                            : TR3;
BEGIN
   PCALL(ltraFEED,feed,unite);              { lecture infos ppg }
   PCALL(litCOOLANT,numarro);
   PCALL(ltraPOINT,pt);
   PCALL(litTEMPO,tempopass,tempofin);
   PCALL(litPROF_PER,prof,pene1,pene2);
   PCALL(ltraDS,ds);
   PCALL(ltraALTRET,altret);
   PCALL(lit_RTEC,RTF_RETRAIT_INCR,retrait_inc); 
   PCALL(lit_RTEC,RTF_DISTANCE_RETRAIT,distance_retrait);  { Usage futur ! }
   PCALL(lit_RTEC,RTF_ANGLE_INDEXAGE,angle_indexage);		  { Usage futur ! }	
   PCALL(lit_STEC,ST_COMMENTAIRE,comment);
   PCALL(lit_RTEC,RO_DIAMETRE,diam_outil);
   PCALL(lit_RTEC,RTF_AVANCE_PAR_DENT,pas);
   IF Pene1 < TOLERPP THEN Pene1:=Prof;
   ilen:=strlen(comment);
   
   IF (altret-Pt[2] > ds) THEN r204 := altret-Pt[2]
                          ELSE r204 := ds; 
   PCALL(ecnPAX3_CYCLE,(pt[2]+r204));                             
   
   IF ( change_condition(prof,pene1) = DPP_OUI ) THEN
   BEGIN
      Goto_trou(Pt);

      CASE cycle OF
      206 : BEGIN
         Cn_Fin_Pap(1);
         PCALL(bcnTAB,'CDEF_INT',206,1);
         PCALL(bcnTAB_STR,'SP','NOUVEAU TARAUDAGE',1);
         Punchb(0);

         Cn_Fin_Pap(3);
         PCALL(bcnTAB,'Q200',ds,1);
         Punchb(2);
         PCALL(bcnTAB,'Q201',-prof,1);
         Punchb(2);
         PCALL(bcnTAB,'Q206',feed,1);
         Punchb(2);
         PCALL(bcnTAB,'Q211',tempofin,1);
         Punchb(2);
         PCALL(bcnTAB,'Q203',Pt[2],1);
         Punchb(2);
         cn_fin_pap(2);
         PCALL(bcnTAB,'Q204',r204,1);
         Punchb(2);

         Cn_Fin_Pap(0);
         PCALL(bcnTAB,'CYCL',0,1);
         Punchb(0);
      END;
      207 : BEGIN
         Cn_Fin_Pap(1);
         PCALL(bcnTAB,'CDEF_INT',207,1);
         PCALL(bcnTAB_STR,'SP','TARAUDAGE RIGIDE',1);
         Punchb(0);

         Cn_Fin_Pap(3);
         PCALL(bcnTAB,'Q200',ds,1);
         Punchb(2);
         PCALL(bcnTAB,'Q201',-prof,1);
         Punchb(2);
         PCALL(bcnTAB,'Q239',pas,1);
         Punchb(2);
         PCALL(bcnTAB,'Q203',Pt[2],1);
         Punchb(2);
         cn_fin_pap(2);
         PCALL(bcnTAB,'Q204',r204,1);
         Punchb(2);

         Cn_Fin_Pap(0);
         PCALL(bcnTAB,'CYCL',0,1);
         Punchb(0);
      END;
      209 : BEGIN
      	retrait_inc:=1;
      	angle_indexage:=0;
      	
         IF (ilen>0) THEN Decode_Comment(cycle,comment,retrait_inc,angle_indexage,hauteur,avance_pre_pos);
         
         cn_fin_pap(1);
         PCALL(bcnTAB,'CDEF_INT',209,1);
         PCALL(bcnTAB_STR,'SP','TARAUD. BRISE-COP',1);
         Punchb(0);

         cn_fin_pap(3);
         PCALL(bcnTAB,'Q200',ds,1);
         Punchb(2);
         PCALL(bcnTAB,'Q201',-prof,1); 			{ profondeur filet }
         Punchb(2);
         PCALL(bcnTAB,'Q239',pas,1);   
         Punchb(2);
         PCALL(bcnTAB,'Q203',Pt[2],1);
         Punchb(2);
         PCALL(bcnTAB,'Q204',r204,1);         
         Punchb(2);
         PCALL(bcnTAB,'Q257',pene1,1); 			{ Prof. perc. }
         Punchb(2);
         PCALL(bcnTAB,'Q256',retrait_inc,1); 	{ Ret. brise-cop }
         Punchb(2);
         cn_fin_pap(2);
         PCALL(bcnTAB,'Q336',angle_indexage,1); { Angle de broche }
         Punchb(2);

         cn_fin_pap(0);
         PCALL(bcnTAB,'CYCL',0,1);
         Punchb(0);
      END;
      END;
   END
   ELSE
   BEGIN
      Pp_Pnt_Plan;
      PCALL(bcnPax3,(Pt[2]+ds),0);
      IF TESTMOVE THEN
      BEGIN
         IF INTRD(STD_RFM)=1 THEN PCALL(bcnTAB,'MSEUL',0,1);
         Complete_bloc(5);
      END;
   END;
END;                                                                       {@}

{----------------------------------------------------------------------------}
PROCEDURE Percage_Debourrage;
{----------------------------------------------------------------------------}
VAR
   numcyc : INTEGER;
BEGIN
   PCALL(lit_ETEC,ETF_NUMERO_CYCLE,numcyc);
   
   { 
   Cycle 200 possible : 
   - Cycle 200 : PERCAGE 
   - Cycle 203 : PERCAGE UNIVERSEL
   - Cycle 205 : PERCAGE PROFOND UNIVERSEL
   - Cycle 208 : FRAISAGE DE TROUS
   }
   
   IF (numcyc <> 0) THEN
   BEGIN
      IF (numcyc >= 200) THEN Exec_Percage_universel(numcyc)
      ELSE 
      BEGIN
         Exec_Percage(numcyc);
      END;
   END
   ELSE
   BEGIN
      IF (INTRD(STD_TYPE_CYCLE) = 1) THEN
         Exec_Percage_universel(203)
      ELSE         
         Exec_Percage(3);
   END   
END;                                                                       {@}
{----------------------------------------------------------------------------}
PROCEDURE Percage_Brise_Copeau;
{----------------------------------------------------------------------------}
VAR
   numcyc : INTEGER;
BEGIN
   numcyc:=0;
   PCALL(lit_ETEC,ETF_NUMERO_CYCLE,numcyc);
   
   { 
   Cycle 200 possible : 
   - Cycle 200 : PERCAGE 
   - Cycle 203 : PERCAGE UNIVERSEL
   - Cycle 205 : PERCAGE PROFOND UNIVERSEL
   - Cycle 208 : FRAISAGE DE TROUS
   }
   
   IF (numcyc <> 0) THEN
   BEGIN
      IF (numcyc >= 200) THEN Exec_Percage_universel(numcyc)
      ELSE 
      BEGIN
         Exec_Percage(numcyc);
      END;
   END
   ELSE
   BEGIN
      IF (INTRD(STD_TYPE_CYCLE) = 1) THEN
         Exec_Percage_universel(203)
      ELSE         
         Exec_Percage(7);
   END      
END;                                                                       {@}

{----------------------------------------------------------------------------}
PROCEDURE Fin_Operation;
{----------------------------------------------------------------------------}
VAR
	   ischout        : INTEGER;
	   Ilastoperation : INTEGER;
	   
BEGIN
	 ischout   := ICALL(isCHGT_OUTIL);
	 Ilastoperation := ICALL(isDERNIER_OPERATION,CONST_NO);
	 
   IF ( ICALL(isCHGT_OUTIL) = DPP_OUI ) THEN Degagement;
   
   IF (( ICALL(isCHGT_OUTIL) = DPP_NON ) AND (ICALL(isCHGT_PLAN)= DPP_OUI ))THEN std_degagement_ori_mac;

   {IF (Ilastoperation = CONST_NO) THEN
   BEGIN
      IF (ischout = CONST_YES) THEN FMS_PP_TOOLCHANGE
                               ELSE FMS_PP_SECURITY;   
   END;}
   
   

   IF (( ICALL(isCHGT_OUTIL) = DPP_OUI ) AND ( Ilastoperation = DPP_NON ))THEN PCALL(bcnTAB_STR,'SP','CALL LBL "Annulation_Totale"',1);
   ecritb;
   IF (( ICALL(isCHGT_OUTIL) = DPP_NON ) AND (ICALL(isCHGT_PLAN)= DPP_OUI ) AND ( Ilastoperation = DPP_NON )) THEN PCALL(bcnTAB_STR,'SP','CALL LBL "Annulation_Plane"',1);
   ecritb;
   
   IF (Continuous_Work = DPP_OUI) THEN PCALL(bcnM,129,1);
   ecritb;
   
   
     
  
   PCALL(ecnFORCE_PAX3);
   PCALL(ecnFORCE_PPLAN);  
   PCALL(bcnSAUT_LIGNE,DPP_OUI); 
END;                                                                       {@}

{----------------------------------------------------------------------------}
PROCEDURE Modifieur_Pp;
{BEGIN_ENGLISH																					  }
{																									  }
{ Reading and writing of the global variables in the modifieurs              }
{																									  }
{END_ENGLISH																					  }
{																									  }
{ Lecture et ecriture des variables globales se trouvant dans les modifieurs }
{																									  }
{----------------------------------------------------------------------------}
VAR
   str0,str1,msg,strnul,version : TC80;
   ligne,colonne,ival           : INTEGER;
    
BEGIN
   Lib_Test_Butee_Mac;                 { lecture butees fichier Machine}
      
   ligne   := 0;
   colonne := 40;
   strnul[0] := chr(0);

   Version_Specifique;
   {Modifieur_Pp_Spe(strnul,ligne,colonne); } {Utilise pour integrer du specifique client}

   {msg[0] := chr(0);
   Pp_Cfg_Onglet(859,msg);
   ligne   := 0;
   Lib_Config_Cn_V5(strnul,ligne,colonne);	}		
   { configuration librairies }
   { pas de lib_config_cn_v5 , on va forcer les quelques valeurs utilisées avec force_lib_std }
   
   
   msg[0] := chr(0);
   Pp_Cfg_Onglet(857,msg);
    ligne   := 0;  
   Std_Config_Armoire_Cn(strnul,ligne,colonne); 			{ configuration armoire  }
   
 
   strcpy(msg,'Expert Configuration');
   Pp_Cfg_Onglet(-99,msg);  {855}
   ligne   := 0;
   Std_Config_Expert(strnul,ligne,colonne);        { configuration plans avancee TNC530 }
  
     
   Lib_Config_FMS;   { configuration FMS  }  
END;  
                                                                    {@}   
{----------------------------------------------------------------------------}
PROCEDURE Fin_Fichier;
{----------------------------------------------------------------------------}
VAR     I,numbloc : INTEGER;
        rprog     : REAL;
        snom,str1,NOMPRG :Tc80;
BEGIN
   PCALL(lcnNUM_BLOC,numbloc);
   IF (numbloc=0) THEN PCALL(ecnNUM_BLOC,(INTRD(STD_MEMO_NUMBLOC)));
 
   rprog:=INTRD(LIB_PROGRAM_NUMBER);
   
  { IF (rprog>TOLERPP) THEN
   BEGIN
      PCALL(bcnTAB,'END',rprog,1);
      PCALL(bcnTAB,'MM',0,1);
      Punchb(0);
   END
   ELSE}
   BEGIN
      STRINGRD(LIB_NOM_FIC_ISO,Snom);
      strcpy(str1,'END PGM ');
      strcat(str1,Snom);
      strcat(str1,' MM');

      PCALL(bcnTAB_STR,'SP',str1,0);
      Ecritb;
   END;
END;                                                                       {@}

{----------------------------------------------------------------------------}
PROCEDURE Position_Plan_Dev{(typplan_cycle : INTEGER)}; { En plan developpe => positionnement en X0 ou Y0 }
{----------------------------------------------------------------------------}
BEGIN
   CASE Typplan_Cycle OF
      DPP_PLAN_DEVELOPPE_X :
      BEGIN
      	PCALL(bcnTAB,'Y',0.0,0);
      	Complete_bloc(1);
      END;
      DPP_PLAN_DEVELOPPE_Y : 
      BEGIN
      	PCALL(bcnTAB,'X',0.0,0);
      	Complete_bloc(1);
      END;
      DPP_PLAN_DEVELOPPE_Z : 
      BEGIN
      	PCALL(bcnTAB,'X',0.0,0);
      	Complete_bloc(1);      	
      END;
      OTHERWISE
      BEGIN
      END;
   END;
END;                                                                       {@}
                                                                    