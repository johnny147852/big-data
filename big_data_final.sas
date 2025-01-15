*ドμ戳砯基;
proc import out = corn_price
	datafile = "C:\Users\johnny\Desktop\paper\CornFutures.csv"
	dbms = csv replace;
run;
*沉戳砯基;
proc import out = wheat_price
	datafile = "C:\Users\johnny\Desktop\paper\WheatFutures.csv"
	dbms = csv replace;
run;
*ě戳砯基;
proc import out = soybean_price
	datafile = "C:\Users\johnny\Desktop\paper\SoybeanFutures.csv"
	dbms = csv replace;
run;
*猳基;
proc import out = CrudeOil_price
	datafile = "C:\Users\johnny\Desktop\paper\CrudeOil.csv"
	dbms = csv replace;
run;
*蹲瞯;
proc import out = exchange_rate
	datafile = "C:\Users\johnny\Desktop\paper\exchangerate.csv"
	dbms = csv replace;
run;
*基;
proc import out = gold_price
	datafile = "C:\Users\johnny\Desktop\paper\Gold.csv"
	dbms = csv replace;
run;
*睫ψ戳砯;
proc import out = leanhog_price
	datafile = "C:\Users\johnny\Desktop\paper\LeanHog.csv"
	dbms = csv replace;
run;
*ψ戳砯;
proc import out = livecattle_price
	datafile = "C:\Users\johnny\Desktop\paper\LiveCattle.csv"
	dbms = csv replace;
run;
*S&P500计;
proc import out = SnP500
	datafile = "C:\Users\johnny\Desktop\paper\S&P500.csv"
	dbms = csv replace;
run;
proc contents data = corn_price;
run;
data corn_price;
	set corn_price;
		*э;
		rename close=corn;*单腹э跑计;
run;
proc contents data = crudeoil_price;
run;
data crudeoil_price;
	set crudeoil_price;
		*э;
		rename close=crudeoil;*单腹э跑计;
run;
data Gold_price;
	set Gold_price;
		*э;
		rename close=gold;*单腹э跑计;
run;
data Leanhog_price;
	set Leanhog_price;
		*э;
		rename close=leanhog;*单腹э跑计;
run;
data Livecattle_price;
	set Livecattle_price;
		*э;
		rename close=Livecattle;*单腹э跑计;
run;
data Snp500;
	set Snp500;
		*э;
		rename close=Snp500index;*单腹э跑计;
run;
data Soybean_price;
	set Soybean_price;
		*э;
		rename close=Soybean;*单腹э跑计;
run;
data Wheat_price;
	set Wheat_price;
		*э;
		rename close=wheat;*单腹э跑计;
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
*闽玒计;
proc corr data=mergedata2;
proc contents data = mergedata2;
run;
*だ猂(factor analysis);
proc factor data = mergedata2 rotate=varimax
n=2 out=factorout;
	var ExchangeRate Livecattle Snp500index Soybean crudeoil gold leanhog wheat;
run;
*Θだだ猂(pca, principle component analysis);
proc princomp data = mergedata2 out=pca_result;
	var ExchangeRate Livecattle Snp500index Soybean crudeoil gold leanhog wheat;
run;
