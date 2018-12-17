options ls=80 ps=60 replace;

data test;
set tmp.test;

/*==========Data Filtering==========*/
if age ge 19;
if tenure=5 then delete;
if tenure=6 then delete;
if htype=5 then delete;
if htype=6 then delete;
if htype=7 then delete;
if htype=8 then delete;
if htype=9 then delete;
if htype=10 then delete;


/*==========Dependent Variable==========*/
own=.;
if tenure=1 then own=0;                                                       /*자가*/
if tenure in (2 3 4) then own=1;                                           /*차가(전세(월세없음), 보증금 있는 월세, 보증금 없는 월세)*/

/*==========Independent Variables==========*/
age=age;

if sex=1 then gender=0;                                                     /*남성(참조집단)*/
if sex=0 then gender=1;                                                     /*여성*/

if edu1=6 and edu2=1 then school=4;                                /*대학(참조집단)*/
if edu1=7 and edu2 in (2 3 4) then school=4;
if edu1 in (7 8) and edu2 in (1 2 3 4) then school=3;         /*대학원*/
if edu1=4 and edu=1 then school=2;                                  /*고졸*/
if edu1 in (5 6) and edu2 in (2 3 4) then school=2;
if edu1=5 and edu2=1 then school=2;
if edu1 in (1 2 3) and edu2 in (1 2 3 4) then school=1;      /*중졸*/

if htype=1 then htype=1;                                                     /*단독주택*/
if htype in (3 4) then htype=2;                                            /*연립 및 다세대 주택*/
if htype=3 then htype=3;                                                    /*아파트(참조집단)*/



proc format;  /*각 지역명 부여*/
value areafmt
11='서울특별시'  
010= '종로구'     020= '중구'        030= '용산구'     040= '성동구'     050= '광진구'
060= '동대문구'  070= '중랑구'     080= '성북구'     090= '강북구'     100= '도봉구'
110= '노원구'     120= '은평구'     130= '서대문구'  140= '마포구'     150= '양천구'
160= '강서구'     170= '구로구'     180= '금천구'     190= '영등포구'  200= '동작구'
210= '관악구'     220= '서초구'     230= '강남구'     240= '송파구'     250= '강동구'
;
run;



%temp;
%global _DISK_;
%let _DISK_=on;
%global _PRINT_;
%let _PRINT_=on;

options mprint;


%macro temp;
%glimmix   (data = test,
                    procopt=method=reml covtest,
				    stmts=%str
						 (class w_area;
                          model own = age gender school htype /s;
						  random int/type=un(1) sub=w_area s;
						  format area areafmt;
						  title '모형_2';
						  make 'solutionR' out=sol_lr;
						  ),
						 error=binomial, 
						 link=logit,
						 out=own_2;
						 run;
