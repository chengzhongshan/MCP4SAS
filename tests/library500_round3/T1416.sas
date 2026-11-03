/* T1416 qscan_quoted_comma, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro function qscan demo_scan black space separated words with special characters _ in it.sas:6 */

%let t1416list=x,"a,7",z;
%let t1416selected=%qscan(%superq(t1416list),2,%str(,),q);
data t1416o; length text $30; text=symget('t1416selected'); actual=lengthn(text); run;
%symdel t1416list t1416selected;

data _null_; if 0 then set t1416o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1416 rows=' rows;
else do; set t1416o; if not missing(actual) and abs(actual-(5))<=1e-10*max(1,abs(5)) then put 'ROUND3_PASS=T1416';
else put 'ERROR: ROUND3_FAIL=T1416 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1416:; quit;
