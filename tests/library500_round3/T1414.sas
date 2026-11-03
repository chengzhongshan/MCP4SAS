/* T1414 qscan_quoted_comma, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro function qscan demo_scan black space separated words with special characters _ in it.sas:6 */

%let t1414list=x,"a,5",z;
%let t1414selected=%qscan(%superq(t1414list),2,%str(,),q);
data t1414o; length text $30; text=symget('t1414selected'); actual=lengthn(text); run;
%symdel t1414list t1414selected;

data _null_; if 0 then set t1414o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1414 rows=' rows;
else do; set t1414o; if not missing(actual) and abs(actual-(5))<=1e-10*max(1,abs(5)) then put 'ROUND3_PASS=T1414';
else put 'ERROR: ROUND3_FAIL=T1414 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1414:; quit;
