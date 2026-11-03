/* T1412 qscan_quoted_comma, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro function qscan demo_scan black space separated words with special characters _ in it.sas:6 */

%let t1412list=x,"a,3",z;
%let t1412selected=%qscan(%superq(t1412list),2,%str(,),q);
data t1412o; length text $30; text=symget('t1412selected'); actual=lengthn(text); run;
%symdel t1412list t1412selected;

data _null_; if 0 then set t1412o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1412 rows=' rows;
else do; set t1412o; if not missing(actual) and abs(actual-(5))<=1e-10*max(1,abs(5)) then put 'ROUND3_PASS=T1412';
else put 'ERROR: ROUND3_FAIL=T1412 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1412:; quit;
