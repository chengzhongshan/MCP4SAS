/* T1411 qscan_quoted_comma, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro function qscan demo_scan black space separated words with special characters _ in it.sas:6 */

%let t1411list=x,"a,2",z;
%let t1411selected=%qscan(%superq(t1411list),2,%str(,),q);
data t1411o; length text $30; text=symget('t1411selected'); actual=lengthn(text); run;
%symdel t1411list t1411selected;

data _null_; if 0 then set t1411o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1411 rows=' rows;
else do; set t1411o; if not missing(actual) and abs(actual-(5))<=1e-10*max(1,abs(5)) then put 'ROUND3_PASS=T1411';
else put 'ERROR: ROUND3_FAIL=T1411 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1411:; quit;
