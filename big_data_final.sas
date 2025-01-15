*�ɦ̴��f����;
proc import out = corn_price
	datafile = "C:\Users\johnny\Desktop\paper\CornFutures.csv"
	dbms = csv replace;
run;
*�p�����f����;
proc import out = wheat_price
	datafile = "C:\Users\johnny\Desktop\paper\WheatFutures.csv"
	dbms = csv replace;
run;
*�j�����f����;
proc import out = soybean_price
	datafile = "C:\Users\johnny\Desktop\paper\SoybeanFutures.csv"
	dbms = csv replace;
run;
*��o����;
proc import out = CrudeOil_price
	datafile = "C:\Users\johnny\Desktop\paper\CrudeOil.csv"
	dbms = csv replace;
run;
*�ײv;
proc import out = exchange_rate
	datafile = "C:\Users\johnny\Desktop\paper\exchangerate.csv"
	dbms = csv replace;
run;
*����;
proc import out = gold_price
	datafile = "C:\Users\johnny\Desktop\paper\Gold.csv"
	dbms = csv replace;
run;
*�ަ״��f;
proc import out = leanhog_price
	datafile = "C:\Users\johnny\Desktop\paper\LeanHog.csv"
	dbms = csv replace;
run;
*���״��f;
proc import out = livecattle_price
	datafile = "C:\Users\johnny\Desktop\paper\LiveCattle.csv"
	dbms = csv replace;
run;
*S&P500����;
proc import out = SnP500
	datafile = "C:\Users\johnny\Desktop\paper\S&P500.csv"
	dbms = csv replace;
run;
proc contents data = corn_price;
run;
data corn_price;
	set corn_price;
		*��W�r;
		rename close=corn;*�@�ӵ����u���@���ܼ�;
run;
proc contents data = crudeoil_price;
run;
data crudeoil_price;
	set crudeoil_price;
		*��W�r;
		rename close=crudeoil;*�@�ӵ����u���@���ܼ�;
run;
data Gold_price;
	set Gold_price;
		*��W�r;
		rename close=gold;*�@�ӵ����u���@���ܼ�;
run;
data Leanhog_price;
	set Leanhog_price;
		*��W�r;
		rename close=leanhog;*�@�ӵ����u���@���ܼ�;
run;
data Livecattle_price;
	set Livecattle_price;
		*��W�r;
		rename close=Livecattle;*�@�ӵ����u���@���ܼ�;
run;
data Snp500;
	set Snp500;
		*��W�r;
		rename close=Snp500index;*�@�ӵ����u���@���ܼ�;
run;
data Soybean_price;
	set Soybean_price;
		*��W�r;
		rename close=Soybean;*�@�ӵ����u���@���ܼ�;
run;
data Wheat_price;
	set Wheat_price;
		*��W�r;
		rename close=wheat;*�@�ӵ����u���@���ܼ�;
run;
proc sql;
create table mergedata1 as 
select e.*,i.*,s.*,q.*,w.*,r.*,t.*,y.*,u.*
from corn_price as e
left join exchange_rate as i
on e.date=i.date
left join wheat_price as s
on e.date=s.date
left join soybean_price as q
on e.date=q.date
left join crudeoil_price as w
on e.date=w.date
left join gold_price as r
on e.date=r.date
left join leanhog_price as t
on e.date=t.date
left join livecattle_price as y
on e.date=y.date
left join snp500 as u
on e.date=u.date;
quit;
data mergedata2;
	set mergedata1;
		if exchangerate=. then delete;
run;
*�����Y��;
proc corr data=mergedata2;
proc contents data = mergedata2;
run;
*�]�����R(factor analysis);
proc factor data = mergedata2 rotate=varimax
n=2 out=factorout;
	var ExchangeRate Livecattle Snp500index Soybean crudeoil gold leanhog wheat;
run;
*�D�������R(pca, principle component analysis);
proc princomp data = mergedata2 out=pca_result;
	var ExchangeRate Livecattle Snp500index Soybean crudeoil gold leanhog wheat;
run;
