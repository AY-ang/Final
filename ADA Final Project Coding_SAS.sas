/* DATA Import*/
libname xptfile xport 'D:\SAS\DATA Files\ADA\DEMO_J.XPT';
libname sasfile 'D:\SAS\DATA Files\ADA';
proc copy inlib=xptfile outlib=sasfile; 
run;

libname xptfile xport 'D:\SAS\DATA Files\ADA\DPQ_J.XPT';
libname sasfile 'D:\SAS\DATA Files\ADA';
proc copy inlib=xptfile outlib=sasfile; 
run;

libname xptfile xport 'D:\SAS\DATA Files\ADA\DR1TOT_J.XPT';
libname sasfile 'D:\SAS\DATA Files\ADA';
proc copy inlib=xptfile outlib=sasfile; 
run;

libname xptfile xport 'D:\SAS\DATA Files\ADA\DR2TOT_J.XPT';
libname sasfile 'D:\SAS\DATA Files\ADA';
proc copy inlib=xptfile outlib=sasfile; 
run;


/* DATA Cleaning */
LIBNAME ADA 'D:\SAS\DATA Files\ADA';
RUN;

DATA demo;
set ada.demo_j;
keep seqn ridreth3 riagendr ridageyr indfmpir dmdeduc2;
proc sort; by seqn;
run;

DATA caf1;
set ada.dr1tot_j;
keep seqn dr1tcaff;
proc sort; by seqn;
run;

DATA caf2;
set ada.dr2tot_j;
keep seqn dr2tcaff;
proc sort; by seqn;
run;

data depress;
set ada.dpq_j;
drop dpq100;
proc sort; by seqn;
run;

data nodepress;
merge demo caf1 caf2; by seqn;
run;
data alldata;
merge nodepress depress; by seqn;
run;

data ada.alldata;
set alldata; run;


/* recoding */
data alldata;
set ada.alldata;

rename ridreth3=race riagendr=gender ridageyr=age indfmpir=income dmdeduc2=education;

if dr1tcaff=. then delete;
if dr2tcaff=. then delete;
caff = (dr1tcaff + dr2tcaff)/2;

if dpq010>3 then delete;
if dpq020>3 then delete;
if dpq030>3 then delete;
if dpq040>3 then delete;
if dpq050>3 then delete;
if dpq060>3 then delete;
if dpq070>3 then delete;
if dpq080>3 then delete;
if dpq090>3 then delete;

depress = dpq010+dpq020+dpq030+dpq040+dpq050+dpq060+dpq070+dpq080+dpq090;

run;

data ada.rawdata;
set alldata; 
keep caff depress race gender age income education;
run;


data raw;
set ada.rawdata;

if depress=. then delete;
else if 0<=depress<=4 then depress_cat=1;
else if depress<=9 then depress_cat=2;
else if depress<=14 then depress_cat=3;
else if depress<=19 then depress_cat=4;
else depress_cat=5;

if race=. then delete;
else if race=3 then race_cat=1;
else if 1<=race<=2 then race_cat=2;
else if race=4 then race_cat=3;
else if race=6 then race_cat=4;
else if race=7 then race_cat=5;

if age=. then delete;
else if 20<=age<30 then age_cat=1;
else if age<50 then age_cat=2;
else if age<=65 then age_cat=3;
else delete;

if income=. then delete;
else if 0<income<0.5 then income_cat=1;
else if income<=1.3 then income_cat=2;
else if income<=2.5 then income_cat=3; 
else if income>2.5 then income_cat=4;

if 0<education<3 then edu_cat=1;
else if education=3 then edu_cat=2;
else if education=4 then edu_cat=3;
else if education=5 then edu_cat=4;
else delete;

proc format;
	value depress_cat 1="no depression" 
					  2="mild depression" 
					  3="moderate depression" 
					  4="moderately severe depression" 
					  5="severe depression";

	value race_cat  1="Non-Hispanic White"
					2="Hispanic"
					3="Non-Hispanic Black"
					4="Non-Hispanic Asian"
					5="Other race";
	value gender	1="Male"
					2="Female";
	value age_cat	1="aged 20-29"
					2="aged 30-49"
					3="aged 50-65";
	value income_cat 1="< 50% of FPL"
					2="50%-130% of FPL"
					3="130%-250% of FPL"
					4=" > 250% of FPL";
	value edu_cat	1="less than high school"
					2="high school"
					3="some college"
					4="college";

proc print; 
run;

data ada.mydata;
set raw;
run;


/*linearity*/
ods graphics on;
proc reg data=ada.mydata;
model depress_cat=caff/ partial;
run;
quit;
ods graphics off;

run;




proc contents data=raw; run;
data capstone.mydata;
set raw; run;

proc freq data = capstone.mydata; tables ;
