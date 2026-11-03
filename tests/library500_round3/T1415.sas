/* T1415 qscan_quoted_comma, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro function qscan demo_scan black space separated words with special characters _ in it.sas:6 */

%let t1415list=x,"a,6",z;
%let t1415selected=%qscan(%superq(t1415list),2,%str(,),q);
data t1415o; length text $30; text=symget('t1415selected'); actual=lengthn(text); run;
%symdel t1415list t1415selected;

data _null_; if 0 then set t1415o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1415 rows=' rows;
else do; set t1415o; if not missing(actual) and abs(actual-(5))<=1e-10*max(1,abs(5)) then put 'ROUND3_PASS=T1415';
else put 'ERROR: ROUND3_FAIL=T1415 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1415:; quit;
