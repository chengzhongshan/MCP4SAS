/* T1420 qscan_quoted_comma, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro function qscan demo_scan black space separated words with special characters _ in it.sas:6 */

%let t1420list=x,"a,11",z;
%let t1420selected=%qscan(%superq(t1420list),2,%str(,),q);
data t1420o; length text $30; text=symget('t1420selected'); actual=lengthn(text); run;
%symdel t1420list t1420selected;

data _null_; if 0 then set t1420o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1420 rows=' rows;
else do; set t1420o; if not missing(actual) and abs(actual-(6))<=1e-10*max(1,abs(6)) then put 'ROUND3_PASS=T1420';
else put 'ERROR: ROUND3_FAIL=T1420 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1420:; quit;
