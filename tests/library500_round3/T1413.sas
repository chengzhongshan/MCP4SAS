/* T1413 qscan_quoted_comma, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro function qscan demo_scan black space separated words with special characters _ in it.sas:6 */

%let t1413list=x,"a,4",z;
%let t1413selected=%qscan(%superq(t1413list),2,%str(,),q);
data t1413o; length text $30; text=symget('t1413selected'); actual=lengthn(text); run;
%symdel t1413list t1413selected;

data _null_; if 0 then set t1413o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1413 rows=' rows;
else do; set t1413o; if not missing(actual) and abs(actual-(5))<=1e-10*max(1,abs(5)) then put 'ROUND3_PASS=T1413';
else put 'ERROR: ROUND3_FAIL=T1413 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1413:; quit;
