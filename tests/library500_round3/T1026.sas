/* T1026 contents_label_text, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:18 */

data t1026a; x=7; label x='Field_7'; run;
proc contents data=t1026a out=t1026b noprint; run;
data t1026o; set t1026b; actual=lengthn(label); run;

data _null_; if 0 then set t1026o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1026 rows=' rows;
else do; set t1026o; if not missing(actual) and abs(actual-(7))<=1e-10*max(1,abs(7)) then put 'ROUND3_PASS=T1026';
else put 'ERROR: ROUND3_FAIL=T1026 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1026:; quit;
