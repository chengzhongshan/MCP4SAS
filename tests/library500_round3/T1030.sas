/* T1030 contents_label_text, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:18 */

data t1030a; x=11; label x='Field_11'; run;
proc contents data=t1030a out=t1030b noprint; run;
data t1030o; set t1030b; actual=lengthn(label); run;

data _null_; if 0 then set t1030o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1030 rows=' rows;
else do; set t1030o; if not missing(actual) and abs(actual-(8))<=1e-10*max(1,abs(8)) then put 'ROUND3_PASS=T1030';
else put 'ERROR: ROUND3_FAIL=T1030 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1030:; quit;
