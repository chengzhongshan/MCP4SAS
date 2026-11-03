/* T1418 qscan_quoted_comma, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro function qscan demo_scan black space separated words with special characters _ in it.sas:6 */

%let t1418list=x,"a,9",z;
%let t1418selected=%qscan(%superq(t1418list),2,%str(,),q);
data t1418o; length text $30; text=symget('t1418selected'); actual=lengthn(text); run;
%symdel t1418list t1418selected;

data _null_; if 0 then set t1418o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1418 rows=' rows;
else do; set t1418o; if not missing(actual) and abs(actual-(5))<=1e-10*max(1,abs(5)) then put 'ROUND3_PASS=T1418';
else put 'ERROR: ROUND3_FAIL=T1418 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1418:; quit;
