OPTIONS LS=80 PS=60 REPLACE;
LIBNAME kdw 'c:\testdata';

DATA temp;
SET tmp2.multi_logit;

*=============Filters================================================;
IF age ge 15;
IF work1=1;                 /*worker only*/
IF area1 in (11 23 31);     /*seoul, kyongki, incheon*/
IF c_area1 in (11 23 31);
IF commute=1;               /*commuter only*/   
IF area_id=4 THEN DELETE;
IF dist=. THEN DELETE;
IF c_id=3;                  
IF mean1 in (2 3 4 5 6 7 8);         

*=====Dependent Variable(Mode Type)===================================;
mtype=.;
IF mean1 in (2 3 4 8) THEN mtype=1; /*버스,택시*/
IF mean1 in (5 6) THEN mtype=2;     /*기차,전철*/
IF mean1=7 THEN mtype=3;            /*승용차 (참조집단, 가장 큰 숫자를 참조집단으로 인식하는 것을 확인하세요)*/

*=====Independent Variables Coding===================================;
*-----Householder Characteristics-------------------------------;
age=age;
age_sq=age*age; /*square term만들어준 것임, 그냥 곱하기 해주면 됨*/

gender=.;
IF sex=1 THEN gender=1; /*Men*/
IF sex=2 THEN gender=0; /*Women, Ref. Group*/

marry=.;
IF marital=2 THEN marry=1;        /*Married*/
else marry=0;

school=.;
IF edu1 in (1 2 3 4) THEN school=1;   /*고졸이하, Ref. Group*/
IF edu1 in (5 6) THEN school=2;       /*대졸이하*/
IF edu1 in (7 8) THEN school=3;       /*대학원*/
school1=0;school2=0;school3=0;
IF school=2 THEN school2=1;
IF school=3 THEN school3=1;

status_2=.;
IF status=3 THEN status_2=1;                   /*Corporate Owner*/
IF status in (2 4) THEN status_2=2;            /*Self-operated*/
IF status=1 THEN status_2=3;                   /*Salary*/
status1=0;status2=0;status3=0;status4=0;
IF status_2=1 THEN status1=1;
IF status_2=2 THEN status2=1;
IF status_2=3 THEN status3=1;

job_2=.; /*예전 데이터이기 때문에 분류가 좀 복잡하게 되어 있음*/
IF job ge 0 and job le 199 THEN job_2=1;        /*Managerial,Professional*/
ELSE IF job ge 200 and job le 399 THEN job_2=2;   /*Technical,Sales,Administrative*/
ELSE IF job ge 400 and job le 599 THEN job_2=3;   /*Services*/
ELSE IF job ge 600 and job le 699 THEN job_2=4;   /*Farming,Fishing*/
ELSE IF job ge 700 and job le 899 THEN job_2=5;   /*Craft,Repair*/
ELSE IF (job ge 900 and job le 999) or (work9=1 and job=.) or (job le 99)
                             THEN job_2=6;        /*Laborers*/
job1=0;job2=0;job3=0;job4=0;job5=0;job6=0;
IF job_2=1 THEN job1=1;
IF job_2=2 THEN job2=1;
IF job_2=3 THEN job3=1;
IF job_2=4 THEN job4=1;
IF job_2=5 THEN job5=1;

/*통근시간보정*/ 
IF t_time=. THEN t_time=0;  /*시간*/
IF t_minute=. THEN t_minute=0; /*분*/
t_min=(t_time*60)+t_minute;

dist=dist;
RUN;

PROC FORMAT; * 변수명을 한글로 지정;
  VALUE areafmt /*areafmt을 지정하겠다*/
  1='서울' 2='서울-시외'  3='시외-서울';
  VALUE modefmt
  1='버스' 2='기차' 3='승용차';
  VALUE sexfmt
  1='Men' 0='Women';
  VALUE marryfmt
  1='Married' 0='Single, Div. Wid.';
  VALUE edufmt
  1='고졸이하' 2='대졸이하' 3='대학원';
  VALUE stafmt
  1='Corporate Owner' 2='Self-operated' 3='Salary';
  VALUE jobfmt
  1='Managerial' 2='Technical' 3='Services'
  4='Farm' 5='Repair' 6='Laborer/Unemployed';
RUN;
  
PROC FREQ; 
FORMAT area_id areafmt. mtype modefmt. gender sexfmt. marry marryfmt.
       school edufmt. status_2 stafmt. job_2 jobfmt.; 
TABLES area_id mtype gender marry school status_2 job_2;
RUN;


PROC MEANS; /*평균*/
VAR mtype age age_sq gender marry school2 school3 status1 status2 
    job1 job2 job3 job4 job5 t_min dist;
RUN;
/* 두가지 방법이 있음*/
PROC CATMOD ; * Multinomial Logit;
DIRECT age age_sq gender marry school2 school3 status1 status2 
       job1 job2 job3 job4 job5 t_min dist; *direct는 정성변수(qualitative variables)을 정량변수(quantitative variables)로 다를 수 있도록 등록 ;
MODEL mtype=age age_sq gender marry school2 school3 status1 status2 
            job1 job2 job3 job4 job5 t_min dist
            / ML NOPROFILE nogls; *ML : MLE로 추정,  NOPROFILE: 데이터셋 작성하지 않음, nogls: gls에 의한 회귀계수를 추정하지 않음 ;
RUN;





