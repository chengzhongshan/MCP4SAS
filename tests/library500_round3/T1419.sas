/* T1419 qscan_quoted_comma, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro function qscan demo_scan black space separated words with special characters _ in it.sas:6 */

%let t1419list=x,"a,10",z;
%let t1419selected=%qscan(%superq(t1419list),2,%str(,),q);
data t1419o; length text $30; text=symget('t1419selected'); actual=lengthn(text); run;
%symdel t1419list t1419selected;

data _null_; if 0 then set t1419o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1419 rows=' rows;
else do; set t1419o; if not missing(actual) and abs(actual-(6))<=1e-10*max(1,abs(6)) then put 'ROUND3_PASS=T1419';
else put 'ERROR: ROUND3_FAIL=T1419 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1419:; quit;
