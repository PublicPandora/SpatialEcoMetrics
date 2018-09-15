*---- This is a ENDNOTE ------------------------;
/* This is a ENDNOTE ---------------------------*/

OPTIONS LS=80 PS=60 REPLACE;
LIBNAME ysd 'c:\testdata';                                             /*c드라이브에 testdata에 저장, 대신 먼저 폴더 만들기*/

DATA ysd.student;                                                      /*만든 ysd폴더에 데이터 저장*/*혹은 다른 주석 방법;
 INPUT name $ birth sex $ dept $ exam1  exam2  exam3;                  /* $문자로 인식하라*/
 CARDS;
SungDo   1980 m stat 90 80 20
SeongMi  1978 f econ 55 85 95
SooHyun  1982 f math 29 94 80
HyungBae 1969 m educ 95 92 41
RUN;

PROC PRINT;
 TITLE "DataReading1";
RUN; /*F8*/


DATA student1;
 INPUT name $ 1-9 birth 10-13 sex $ 15 dept $ 17-20                    /*name은 1-9까지 birth 10-13*/
      exam1 22-23 exam2 25-26 exam3 28-29;                             /*text파일로 받은 경우 이런 식으로 입력할 수 밖에 없음*/
 CARDS;
SungDo   1980 m stat 90 80 20
SeongMi  1978 f econ 55 85 95
SooHyun  1982 f math 29 94 80
HyungBae 1969 m educ 95 92 41
RUN;
PROC PRINT;
 TITLE "DataReading2";
RUN;

DATA student2;
 INPUT name $ 1-9 birth 10-13 sex $ 15 dept $ 17-20 
      exam1 22-23 exam2 25-26 exam3 28-29;
 CARDS;
SuYeon   1974 f info 80 30 40
SeungJu  1978 f math 50 80 40 
EunHaJeo 1980 f stat 30 40 85 
RUN;
PROC PRINT;
 TITLE  "DataReading2";
RUN ;

DATA student3;
 INPUT name $ 1-9 exam4 10-11 ;
 CARDS;
SuYeon   40
SeungJu  40 
EunHaJeo 85 
RUN;
PROC PRINT;
 TITLE "Added Data";
RUN;

*------- Import TXT Type Data --------------------;
DATA st1;
 INFILE 'c:\testdata\st1.txt';                                           /*경로 너무 복잡하지 않게 할 것*/
 INPUT name $ 1-9 birth 10-13 sex $ 15 dept $ 17-20 
      exam1 22-23 exam2 25-26 exam3 28-29;
RUN;
*--------- Import CSV Type Data -----------------------;
DATA st2;
 INFILE 'c:\testdata\st1.csv' DELIMITER=',';
 INPUT name $ birth sex $ dept $ exam1 exam2 exam3;
RUN;
*--------- Import EXCEL Type Data ---------------------;
PROC IMPORT OUT=st1_2
        DATAFILE="c:\testdata\st1.xls"
        DBMS=EXCEL REPLACE;
        SHEET="st1$";
        GETNAMES=YES;
RUN;
/* DATA Manipulation*/
*-Set (세로병합)-----------------------------------;
DATA t1;
 SET student1 student2;
RUN;
PROC PRINT;
 TITLE "Data Adding from Up to Down";
RUN;

*-Merge (가로병합, 데이터가 정렬되어 있어야함)------------;
PROC SORT DATA=student2; BY name;RUN;                                      /*먼저 정렬해야함. name으로 정렬*/
PROC SORT DATA=student3; BY name;RUN;
DATA t2;
 MERGE student2 student3; BY name;
RUN;
PROC PRINT;
 TITLE "Data Adding from Left to Right";
RUN;

*----I want to DROP Some Variables ------------;
DATA drop(DROP=exam1 exam2 exam3);
  SET t1;
   exam=exam1+exam2+exam3;
RUN;
PROC PRINT;
 TITLE "Drop Some Variables";
RUN;
*---I want to KEEP Some Variables ------------;
DATA kep(KEEP=name birth sex dept exam);
  SET t2;
   exam=exam1+exam2+exam3;
RUN;
PROC PRINT;
 TITLE "KEEP Some Variables";
RUN;

*---I Have Lots of DATA on a certain Row----------;
DATA b;
 INPUT name $ age height weight children @@;
 CARDS;
LEE 33 180 80 2 KIM 40 168 65 1 CHOI 25 174 73 0
RUN;
PROC PRINT;
 TITLE "Reading DATA EX";
RUN;

/*PROCEDURE 맛보기*/
*---Calculate Average-----------------------;
PROC MEANS DATA=t1;                                                          /*by쓰려면 정렬해야함, 그룹별로 class*/
 CLASS sex;
 VAR exam1;
RUN;

*---Frequency Analysis----------------------;
PROC FREQ DATA=t1;
 TABLES exam1 exam2 exam3;                                                   /*각각에 대해서 빈도테이블*/
 TABLES sex*exam1;                                                           /*성별과 exam1에 대한 교차빈도테이블*/
    TABLES birth*sex*exam1; 
RUN;

/* Do You Know Loop?? */
DATA score1(drop=i exam1-exam4);                                             /*다음실습때 설명예정*/
SET t2; 
   ARRAY score{4} exam1-exam4;
   DO i=1 TO 4;
       mid=score[i];
       OUTPUT;
   END;
PROC PRINT NOOBS DATA=score1;
   TITLE 'Data Set SCORE1';
RUN;

/*2000년 인구주택 총조사 DATA 불러오기*/
/*==================================================================================
For the perfect data
Data: 2000 2% Korea census  
===================================================================================*/
OPTIONS LS=80 PS=60 REPLACE;
LIBNAME ysd 'c:\testdata';
DATA samp;
RETAIN area area1 area2 place hhid h_cha hsize h_kind res_long use_room living dining
       kitchen1 kitchen2 toilet1 toilet2 bath1 bath2 fuel heating water_s water
 fax internet cable l_cable sa_tv telephon pc car_1 car_2 car_3 car_4
 park_1 park_2 t_kind tenure unit s_unit m_house scale1 scale2 tot_room
 t_living t_dining houseage t_kit t_toi t_enter nuclear gen_com n_family h_type;
INFILE 'c:\testdata\pc00.txt' MISSOVER;
INPUT col 14-16 @;
IF col=0 THEN
INPUT area 1-5 area1 1-2 area2 3-5 place 6-7 hhid 8-12 h_cha $ 13 hsize 17-19 
 h_kind 20-21 res_long 22 use_room 23-24 living 25 dining 26 kitchen1 27 
 kitchen2 28 toilet1 29 toilet2 30 bath1 31 bath2 32 fuel 33 heating 34-35 
 water_s 36 water 37 fax 38 internet 39 cable 40 l_cable 41 sa_tv 42 telephon 43
 pc 44 car_1 45 car_2 46 car_3 47 car_4 48 park_1 49 park_2 50 t_kind 51
 tenure 52 unit 53 s_unit 54 m_house 55 scale1 56-58 scale2 59-61
 tot_room 62-63 t_living 64-65 t_dining 66-67 houseage 68-69 t_kit 70-71
 t_toi 72-73 t_enter 74-75 nuclear 76 gen_com 77-78 n_family 79 h_type $ 80;
IF col NE 0 THEN
INPUT relate 17-18 sex 19 age 20-22 edu1 23 edu2 24 major 25-26 nurture1 27-28
      nurture2 29-30 pobid 31 pob 32-36 pob1 32-33 pob2 34-36 preid 37
 prearea 38-42 prearea1 38-39 prearea2 40-42 migid 43 migarea 44-48
 migarea1 44-45 migrarea2 46-48 pc_st 49 inter_st 50 hand_ph 51 commute 52
 c_id 53 c_area 54-58 c_area1 54-55 c_area2 56-58 mean1 59-60 mean2 61-62
 ampm 63 s_time 64-65 s_minute 66-67 t_time 68 t_minute 69-70 work1 71
 work2 72 work3 73 status 74 industry 75-77 job $ 78-80 workyear 81 marital 82
 child1 83-84 child2 85-86 t_child 87-88 o_ch_pla 89 o_live 90 o_supp1 91
 o_supp2 92 o_move1 93 o_move2 94;
RUN;
DATA ysd.korea2000;
SET samp;
IF col ne 0               /*Redundant Obs. Due to Merge*/
/*Because Raw Data treat if pobid in (1 2) then Missing*/
IF pobid=. THEN pobid=10;
IF pob=. THEN DO pob=area;END;
IF pob1=. THEN DO pob1=area1;END;
IF pob2=. THEN DO pob2=area2;END;
IF preid=. THEN preid=10;
IF prearea=. THEN DO prearea=area;END;
IF prearea1=. THEN DO prearea1=area1;END;
IF prearea2=. THEN DO prearea2=area2;END;
IF migid=. THEN migid=10;
IF migarea=. THEN DO migarea=area;END;
IF migarea1=. THEN DO migarea1=area1;END;
IF migarea2=. THEN DO migarea2=area2;END;
RUN;
DATA test;
SET cjk.korea2000;
PROC FREQ;
TABLES h_cha hsize h_kind res_long use_room living dining kitchen1 kitchen2 toilet1  toilet2 bath1 bath2 fuel heating water_s water fax internet cable l_cable sa_tv  telephon pc car_1 car_2 car_3 car_4 park_1 park_2 t_kind tenure unit s_unit  m_house scale1 scale2 tot_room t_living t_dining houseage t_kit t_toi t_enter  nuclear gen_com n_family h_type relate sex age edu1 edu2 major nurture1 nurture2  pc_st inter_st hand_ph commute mean1 mean2 ampm s_time s_minute t_time t_minute  work1 work2 work3 status industry job workyear marital child1 child2 t_child  o_ch_pla o_live o_supp1 o_supp2 o_move1 o_move2;
RUN;
/*Excel DATA를 SAS DATA로 만들기*/
/*==============================================================================
EXCEL DATA--------> SAS DATA
For the region2000
================================================================================*/
OPTIONS LS=80 PS=60 REPLACE;
LIBNAME ysd 'c:\testdata';
DATA region;
INFILE 'c:\testdata\region2000.csv' DELIMITER=',';
INPUT area pop_65 ag_pop car finance pop loc_tax;
RUN;
DATA ysd.region2000;
SET region;
PROC FREQ;
TABLES area pop_65 ag_pop car finance pop loc_tax;
TITLE 'freq of region2000';
RUN;

/* 무작위 추출 DATA */
/*===============================================================================
CENSUS DATA SAMPLING (1%)
================================================================================*/
OPTIONS LS=80 PS=60 REPLACE;
LIBNAME cjk 'c:\lab\exe\data';
DATA s;
SET cjk.k2000;
rannum=UNIFORM(161328064);
run;
DATA cjk.sample;
SET s;
IF rannum < 0.01;
RUN;

/* 지역 DATA MERGE 하기 */
/*============================================================================
data merge 
Data: 1% sampling data of 2000 2% Korea census + region2000
============================================================================*/
OPTIONS ls=80 ps=60 REPLACE;
LIBNAME ysd 'c:\testdata';
DATA exe1;
SET ysd.sample;
*============== area coding==========================================;
w_area=.;
IF area GE 11000 AND area LT 21000 THEN w_area=11000;/*seoul*/
IF area GE 21000 AND area LT 22000 THEN w_area=21000;/*busan*/
IF area GE 22000 AND area LT 23000 THEN w_area=22000;
IF area GE 23000 AND area LT 24000 THEN w_area=23000;
IF area GE 24000 AND area LT 25000 THEN w_area=24000;
IF area GE 25000 AND area LT 26000 THEN w_area=25000;
IF area GE 26000 AND area LT 27000 THEN w_area=26000;
IF area GE 31000 AND area LT 32000 THEN w_area=31000;
IF area GE 32000 AND area LT 33000 THEN w_area=32000;
IF area GE 33000 AND area LT 34000 THEN w_area=33000;
IF area GE 34000 AND area LT 35000 THEN w_area=34000;
IF area GE 35000 AND area LT 36000 THEN w_area=35000;
IF area GE 36000 AND area LT 37000 THEN w_area=36000;
IF area GE 37000 AND area LT 38000 THEN w_area=37000;
IF area GE 38000 AND area LT 39000 THEN w_area=38000;
IF area GE 39000 AND area LT 40000 THEN w_area=39000;
PROC SORT; BY w_area;
RUN;
DATA exe2;
SET ysd.region2000;
*============== area coding==========================================;
w_area=.;
IF area GE 11000 AND area LT 21000 THEN w_area=11000;
IF area GE 21000 AND area LT 22000 THEN w_area=21000;
IF area GE 22000 AND area LT 23000 THEN w_area=22000;
IF area GE 23000 AND area LT 24000 THEN w_area=23000;
IF area GE 24000 AND area LT 25000 THEN w_area=24000;
IF area GE 25000 AND area LT 26000 THEN w_area=25000;
IF area GE 26000 AND area LT 27000 THEN w_area=26000;
IF area GE 31000 AND area LT 32000 THEN w_area=31000;
IF area GE 32000 AND area LT 33000 THEN w_area=32000;
IF area GE 33000 AND area LT 34000 THEN w_area=33000;
IF area GE 34000 AND area LT 35000 THEN w_area=34000;
IF area GE 35000 AND area LT 36000 THEN w_area=35000;
IF area GE 36000 AND area LT 37000 THEN w_area=36000;
IF area GE 37000 AND area LT 38000 THEN w_area=37000;
IF area GE 38000 AND area LT 39000 THEN w_area=38000;
IF area GE 39000 AND area LT 40000 THEN w_area=39000;
PROC SORT; BY w_area;
RUN;
DATA ysd.kg2000;
MERGE exe1 exe2; BY w_area;
TITLE 'merging of census and region';
RUN;
 
DATA exe3; SET ysd.kg2000;
RUN;
RUN;
RUN;
