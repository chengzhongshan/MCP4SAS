/* T1417 qscan_quoted_comma, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro function qscan demo_scan black space separated words with special characters _ in it.sas:6 */

%let t1417list=x,"a,8",z;
%let t1417selected=%qscan(%superq(t1417list),2,%str(,),q);
data t1417o; length text $30; text=symget('t1417selected'); actual=lengthn(text); run;
%symdel t1417list t1417selected;

data _null_; if 0 then set t1417o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1417 rows=' rows;
else do; set t1417o; if not missing(actual) and abs(actual-(5))<=1e-10*max(1,abs(5)) then put 'ROUND3_PASS=T1417';
else put 'ERROR: ROUND3_FAIL=T1417 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1417:; quit;
