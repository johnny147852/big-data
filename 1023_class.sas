*匯入資料;
proc import out = mydata 
	datafile = "C:\Users\johnny\Downloads\Findata_201420.xls"
	dbms = excel replace;
run;
*變數格式;
proc contents data = mydata;
run;
*基本統計量;
proc means data = mydata nmiss n mean median;
	var Current_Ratio Quick_Ratio;
run;
*排序;
proc sort data=mydata;*排序用sort;
by year;*決定用year排序;
run;
*分群基本統計量;
proc means data = mydata nmiss n mean median;
	var Current_Ratio Quick_Ratio;
	by year; *按年度分群;
run;
*資料處理;
data mydata2;*處理後叫mydata2;
	set mydata;*處理前叫mydata;

		*把文字變數字;
		roa2=roa + 0 ;
		roe2=input(roe, 8.);

		*刪除舊資料;
		drop roa2 roe2;

		*改名字;
		*rename roa2=roa;*一個等號只能改一個變數;

		*增加新變數;
		v1=Cash_Flow_Ratios/Days_Payable_Outstanding;
		
		if v1=. or v1>100000 or v1<-100000  then delete;
		
		*刪掉空值(空值在sas會變成.)，有的程式空值會用極端值;
		
		if roe=. or roa=. or tobins_Q=. then delete;
		drop v1;
		*萃取字元 substr(變數名稱,開始字元,連續萃取幾個字元);
		temp=substr(name,1,4);
		*依產業做分類;
		ind=int(Company/100);
run;
proc means data = mydata2;
run;
*相關係數;
proc corr data=mydata2;
run;
*跑回歸;
proc reg data=mydata2;
	model roe=Cash_Flow_Ratios sales_growth_rate 
	Current_Ratio TA_turnover Debt_Ratio / vif seletion=stepwise;
	*model y = x1 x2 x3...
	*還可以看vif和自動幫Cash_Flow_Ratios sales_growth_rate 
	Current_Ratio TA_turnover Debt_Ratio選變數;
run;
*資料合併;
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
*也可以右合併right join;
quit;
*若要讓資料差1期;
proc sql;
create table mergedata2
as select e.*,s.*
from mydata2_1 as e
left join mydata2_2 as s
on e.company=s.company2 and ( e.year-s.year2 )=1;
*也可以右合併right join;
quit;
*各產業跑回歸;
proc sort data = mydata2;*要先排序;
	by ind;
run;
proc reg data=mydata2 noprint outest=coef rsquare;
	*noprint 讓他不要放在螢幕上
	*outset=sas檔案名，會把估計係數放在這個檔案中，裡面會有r-square;
	model roe=Cash_Flow_Ratios sales_growth_rate 
	Current_Ratio TA_turnover Debt_Ratio / vif seletion=stepwise;
	*model y = x1 x2 x3...
	*還可以看vif和自動幫Cash_Flow_Ratios sales_growth_rate 
	Current_Ratio TA_turnover Debt_Ratio選變數;
	by ind;
run;
*匯出excel檔;
proc export
data = coef.xlsx
dbms = excel
outfile = "C:\Users\johnny\Downloads"
replace;
run;
*另一種估計的方法ods output;
proc reg data=mydata2 outest=coef rsquare;
	*noprint 讓他不要放在螢幕上
	*outset=sas檔案名，會把估計係數放在這個檔案中，裡面會有r-square;
	model roe=Cash_Flow_Ratios sales_growth_rate 
	Current_Ratio TA_turnover Debt_Ratio / vif seletion=stepwise;
	*model y = x1 x2 x3...
	*還可以看vif和自動幫Cash_Flow_Ratios sales_growth_rate 
	Current_Ratio TA_turnover Debt_Ratio選變數;
	by year;
	ods output ParameterEstimates=parms;
run;
*先排序;
proc sort data = mydata2;
	by year ind;
run;
*計算roe、TA_turnover產業年度中位數;
proc means data=mydata2 ;
	var roe TA_turnover;
	by year ind;
	output out =yrind_med (drop= _FREQ_ _TYPE_)
	median=med_roe med_TA_turnover;
run;
*改檔名;
data yrind_med;
	set yrind_med;
	rename year=year2 ind=ind2;
	run;
*合併產業平均中位數和原始資料檔;
proc sql;
create table mydata3
as select e.*,s.*
from mydata2 as e
left join yrind_med as s
on e.ind=s.ind2 and e.year=s.year2;
*也可以右合併right join;
quit;
*產生虛擬變數,high_roe,high_TA_turn;
data mydata4;
	set mydata3;
		if roe>=med_roe then high_roe=1;
		else high_roe=0;
		if TA_turnover>=med_TA_turnover then high_TA_turnover=1;
		else high_TA_turnover=0;
	drop year2 ind2 temp;
run;
*刪除檔案;
proc delete data=mydata3 Mydata2_1 Mydata2_2;
run;
*logis regression;
*output預測y=1發生機率到sas檔案
其中檔案裏面p為y=1的發生機率;
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
*混淆矩陣;
proc freq data=estimates2;
	tables high_roe*pre_y;
run;
*主成分分析(pca, principle component analysis);
proc princomp data = mydata4 out=pca_result;
	var Cash_Flow_Ratios Current_Ratio Quick_Ratio;
run;
*因素分析(factor analysis);
proc factor data = mydata4_st rotate=varimax
n=2 out=factorout;
*當有些變數跟2個factor關係都不大時，可以考慮旋轉;
	*var Cash_Flow_Ratios Current_Ratio Quick_Ratio
		  inventory_turnover TA_turnover debt_ratio;
	*inventory_turnover救不回來，直接刪掉;
	var Cash_Flow_Ratios Current_Ratio Quick_Ratio
		  TA_turnover debt_ratio;
run;
*標準化變數;
proc standard data=mydata4 mean=0 std=1 
	out=mydata4_st;
run;
*匯入資料;
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
/*先將大盤報酬從股票資料檔案萃取出來*/
data mktret;
  set stock2;
   if id = . ;
   keep year month ret cap;
   rename ret=mkt_ret  cap=mkt_cap;
 run;
*刪掉stock2裡的大盤指數;
data stock2;
	set stock2;
	if id=. then delete;
run;
 *排序;
 proc sort data=stock2;
 	by id year month;
 run;
 /*再將大盤報酬橫向與原個股報酬率合併*/
 proc sql;
 create table stock2_temp
 as select e.*,s.*
 from stock2  as e
 left join  mktret  as s
 on e.year=s.year and e.month=s.month;
quit;
/*先將目標公司與目標年度簡單萃取出來, 之後方便股價合併*/
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

/*把合併不成功的刪掉*/
data stock2_capm ;
  set stock2_temp2 ;
    if id2=. then delete;*刪空值;
	drop id2;
run;

proc sort data=stock2_capm;
  by id year month;
run;

/*CAPM(滾動)-每個公司每年的beta是用前12個月月報酬計算*/
proc reg data=stock2_capm noprint outest=capm ;
   model ret = mkt_ret;
      by id year month;
 run;
 quit;

 data capm2;
  set capm;
  test=1;*用來合併;
    keep id year month intercept mkt_ret test;
    rename intercept=alpha mkt_ret=beta;
run;

/*按beta高低分成3群,算各群的equal-weighted return*/
proc sort data=capm2;
    by year month beta;
run;

/*有一些特定分位數沒法用proc means*/
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

/*合併回原來資料檔案
 (因為共同欄位一樣，直接用sas內建合併merge指令
  要先排序才可以使用*/
data target_capm2;
   merge capm2 qtile;
    by year month;
 run;


/*按照beta高低分三群beta_port*/
data target_capm2;
  set target_capm2;
      if beta <= beta_pct33 then beta_port=1 ;
      else if beta <= beta_pct66 then beta_port=2;
	  else beta_port=3;
	  drop test; 
run;
*萃取個股return;
data reti_data;
	set stock2_capm;
	keep year month name id ret;
run;
/*合併個股報酬率和beta*/
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
/*計算以beta高低分3群的portfolio的equal-weighed-portfolio beta*/
proc means  data=target_capm3 noprint;
   var beta ret;
    by year month beta_port;
	output out =capm_Result (drop= _type_ _freq_)
	mean=mean_ret mean_beta;
run;
