*�פJ���;
proc import out = mydata 
	datafile = "C:\Users\johnny\Downloads\Findata_201420.xls"
	dbms = excel replace;
run;
*�ܼƮ榡;
proc contents data = mydata;
run;
*�򥻲έp�q;
proc means data = mydata nmiss n mean median;
	var Current_Ratio Quick_Ratio;
run;
*�Ƨ�;
proc sort data=mydata;*�Ƨǥ�sort;
by year;*�M�w��year�Ƨ�;
run;
*���s�򥻲έp�q;
proc means data = mydata nmiss n mean median;
	var Current_Ratio Quick_Ratio;
	by year; *���~�פ��s;
run;
*��ƳB�z;
data mydata2;*�B�z��smydata2;
	set mydata;*�B�z�e�smydata;

		*���r�ܼƦr;
		roa2=roa + 0 ;
		roe2=input(roe, 8.);

		*�R���¸��;
		drop roa2 roe2;

		*��W�r;
		*rename roa2=roa;*�@�ӵ����u���@���ܼ�;

		*�W�[�s�ܼ�;
		v1=Cash_Flow_Ratios/Days_Payable_Outstanding;
		
		if v1=. or v1>100000 or v1<-100000  then delete;
		
		*�R���ŭ�(�ŭȦbsas�|�ܦ�.)�A�����{���ŭȷ|�η��ݭ�;
		
		if roe=. or roa=. or tobins_Q=. then delete;
		drop v1;
		*�Ѩ��r�� substr(�ܼƦW��,�}�l�r��,�s��Ѩ��X�Ӧr��);
		temp=substr(name,1,4);
		*�̲��~������;
		ind=int(Company/100);
run;
proc means data = mydata2;
run;
*�����Y��;
proc corr data=mydata2;
run;
*�]�^�k;
proc reg data=mydata2;
	model roe=Cash_Flow_Ratios sales_growth_rate 
	Current_Ratio TA_turnover Debt_Ratio / vif seletion=stepwise;
	*model y = x1 x2 x3...
	*�٥i�H��vif�M�۰���Cash_Flow_Ratios sales_growth_rate 
	Current_Ratio TA_turnover Debt_Ratio���ܼ�;
run;
*��ƦX��;
data mydata2_1;
	set mydata2;
	keep name year company roe roa;
run;

data mydata2_2;
	set mydata2;
	keep company year Cash_Flow_Ratios sales_growth_rate 
	Current_Ratio TA_turnover Debt_Ratio;
	rename company=company2 year=year2;
run;
proc sql;
create table mergedata1
as select e.*,s.*
from mydata2_1 as e
left join mydata2_2 as s
on e.company=s.company2 and e.year=s.year2;
*�]�i�H�k�X��right join;
quit;
*�Y�n����Ʈt1��;
proc sql;
create table mergedata2
as select e.*,s.*
from mydata2_1 as e
left join mydata2_2 as s
on e.company=s.company2 and ( e.year-s.year2 )=1;
*�]�i�H�k�X��right join;
quit;
*�U���~�]�^�k;
proc sort data = mydata2;*�n���Ƨ�;
	by ind;
run;
proc reg data=mydata2 noprint outest=coef rsquare;
	*noprint ���L���n��b�ù��W
	*outset=sas�ɮצW�A�|����p�Y�Ʃ�b�o���ɮפ��A�̭��|��r-square;
	model roe=Cash_Flow_Ratios sales_growth_rate 
	Current_Ratio TA_turnover Debt_Ratio / vif seletion=stepwise;
	*model y = x1 x2 x3...
	*�٥i�H��vif�M�۰���Cash_Flow_Ratios sales_growth_rate 
	Current_Ratio TA_turnover Debt_Ratio���ܼ�;
	by ind;
run;
*�ץXexcel��;
proc export
data = coef.xlsx
dbms = excel
outfile = "C:\Users\johnny\Downloads"
replace;
run;
*�t�@�ئ��p����kods output;
proc reg data=mydata2 outest=coef rsquare;
	*noprint ���L���n��b�ù��W
	*outset=sas�ɮצW�A�|����p�Y�Ʃ�b�o���ɮפ��A�̭��|��r-square;
	model roe=Cash_Flow_Ratios sales_growth_rate 
	Current_Ratio TA_turnover Debt_Ratio / vif seletion=stepwise;
	*model y = x1 x2 x3...
	*�٥i�H��vif�M�۰���Cash_Flow_Ratios sales_growth_rate 
	Current_Ratio TA_turnover Debt_Ratio���ܼ�;
	by year;
	ods output ParameterEstimates=parms;
run;
*���Ƨ�;
proc sort data = mydata2;
	by year ind;
run;
*�p��roe�BTA_turnover���~�~�פ����;
proc means data=mydata2 ;
	var roe TA_turnover;
	by year ind;
	output out =yrind_med (drop= _FREQ_ _TYPE_)
	median=med_roe med_TA_turnover;
run;
*���ɦW;
data yrind_med;
	set yrind_med;
	rename year=year2 ind=ind2;
	run;
*�X�ֲ��~��������ƩM��l�����;
proc sql;
create table mydata3
as select e.*,s.*
from mydata2 as e
left join yrind_med as s
on e.ind=s.ind2 and e.year=s.year2;
*�]�i�H�k�X��right join;
quit;
*���͵����ܼ�,high_roe,high_TA_turn;
data mydata4;
	set mydata3;
		if roe>=med_roe then high_roe=1;
		else high_roe=0;
		if TA_turnover>=med_TA_turnover then high_TA_turnover=1;
		else high_TA_turnover=0;
	drop year2 ind2 temp;
run;
*�R���ɮ�;
proc delete data=mydata3 Mydata2_1 Mydata2_2;
run;
*logis regression;
*output�w��y=1�o�;��v��sas�ɮ�
�䤤�ɮ��ح�p��y=1���o�;��v;
proc logistic data = mydata4 desc ;
model high_roe=Cash_Flow_Ratios sales_growth_rate 
	Current_Ratio TA_turnover Debt_Ratio / selection=stepwise rsquare;
	output out=estimates p=est_response;
run;
data estimates2;
	set estimates;
		if est_response >= 0.5 then pre_y=1;
		else pre_y=0;
run;
*�V�c�x�};
proc freq data=estimates2;
	tables high_roe*pre_y;
run;
*�D�������R(pca, principle component analysis);
proc princomp data = mydata4 out=pca_result;
	var Cash_Flow_Ratios Current_Ratio Quick_Ratio;
run;
*�]�����R(factor analysis);
proc factor data = mydata4_st rotate=varimax
n=2 out=factorout;
*�����ܼƸ�2��factor���Y�����j�ɡA�i�H�Ҽ{����;
	*var Cash_Flow_Ratios Current_Ratio Quick_Ratio
		  inventory_turnover TA_turnover debt_ratio;
	*inventory_turnover�Ϥ��^�ӡA�����R��;
	var Cash_Flow_Ratios Current_Ratio Quick_Ratio
		  TA_turnover debt_ratio;
run;
*�зǤ��ܼ�;
proc standard data=mydata4 mean=0 std=1 
	out=mydata4_st;
run;
*�פJ���;
proc import out = stock
	datafile = "C:\Users\johnny\Downloads\twstock_mon13_20.csv"
	dbms = csv replace;
run;
data stock2;
	set stock;
	year=year(Var3);
	month=month(var3);
	rename var1=id var2=name var4=ret 
				var5=num_sharesout var6=cap; 
	drop var3;
run;
proc delete data=stock;
run;
proc contents data=stock2;
run;
/*���N�j�L���S�q�Ѳ�����ɮ׵Ѩ��X��*/
data mktret;
  set stock2;
   if id = . ;
   keep year month ret cap;
   rename ret=mkt_ret  cap=mkt_cap;
 run;
*�R��stock2�̪��j�L����;
data stock2;
	set stock2;
	if id=. then delete;
run;
 *�Ƨ�;
 proc sort data=stock2;
 	by id year month;
 run;
 /*�A�N�j�L���S��V�P��Ӫѳ��S�v�X��*/
 proc sql;
 create table stock2_temp
 as select e.*,s.*
 from stock2  as e
 left join  mktret  as s
 on e.year=s.year and e.month=s.month;
quit;
/*���N�ؼФ��q�P�ؼЦ~��²��Ѩ��X��, �����K�ѻ��X��*/
data target_capm;
  set stock2_temp ;
    keep id year month  ;
run;
data stock2_temp ;
 set stock2_temp ;
  rename id=id2 year=year2 month=month2;
 run;

 proc sql;
 create table stock2_temp2
 as select e.*,s.*
 from  target_capm as e
 left join   stock2_temp   as s
 on e.id=s.id2 and ( 1 <= ( ( 12*e.year +e.month ) - (12*s.year2 + s.month2 ) ) <= 12 ) ;
quit;

proc sort data=stock2_temp2 ;
 by id year month year2 month2;
run;

/*��X�֤����\���R��*/
data stock2_capm ;
  set stock2_temp2 ;
    if id2=. then delete;*�R�ŭ�;
	drop id2;
run;

proc sort data=stock2_capm;
  by id year month;
run;

/*CAPM(�u��)-�C�Ӥ��q�C�~��beta�O�Ϋe12�Ӥ����S�p��*/
proc reg data=stock2_capm noprint outest=capm ;
   model ret = mkt_ret;
      by id year month;
 run;
 quit;

 data capm2;
  set capm;
  test=1;*�ΨӦX��;
    keep id year month intercept mkt_ret test;
    rename intercept=alpha mkt_ret=beta;
run;

/*��beta���C����3�s,��U�s��equal-weighted return*/
proc sort data=capm2;
    by year month beta;
run;

/*���@�ǯS�w����ƨS�k��proc means*/
proc univariate  data=capm2 noprint  ;
  var beta ;
  output out=qtile
  pctlpts= 33 66 pctlpre=beta_pct ;
  by year month;
run;

data qtile;
  set qtile;
    test=1;
  run;

/*�X�֦^��Ӹ���ɮ�
 (�]���@�P���@�ˡA������sas���ئX��merge���O
  �n���ƧǤ~�i�H�ϥ�*/
data target_capm2;
   merge capm2 qtile;
    by year month;
 run;


/*����beta���C���T�sbeta_port*/
data target_capm2;
  set target_capm2;
      if beta <= beta_pct33 then beta_port=1 ;
      else if beta <= beta_pct66 then beta_port=2;
	  else beta_port=3;
	  drop test; 
run;
*�Ѩ��Ӫ�return;
data reti_data;
	set stock2_capm;
	keep year month name id ret;
run;
/*�X�֭Ӫѳ��S�v�Mbeta*/
 proc sql;
 create table target_capm3
 as select e.*,s.*
 from  reti_data as e
 left join   target_capm2   as s
 on e.id=s.id and e.year=s.year and e.month=s.month ;
quit;

proc sort  data=target_capm3;
  by  year month beta_port;
run;
/*�p��Hbeta���C��3�s��portfolio��equal-weighed-portfolio beta*/
proc means  data=target_capm3 noprint;
   var beta ret;
    by year month beta_port;
	output out =capm_Result (drop= _type_ _freq_)
	mean=mean_ret mean_beta;
run;
