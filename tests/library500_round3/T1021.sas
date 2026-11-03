/* T1021 contents_label_text, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:18 */

data t1021a; x=2; label x='Field_2'; run;
proc contents data=t1021a out=t1021b noprint; run;
data t1021o; set t1021b; actual=lengthn(label); run;

data _null_; if 0 then set t1021o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1021 rows=' rows;
else do; set t1021o; if not missing(actual) and abs(actual-(7))<=1e-10*max(1,abs(7)) then put 'ROUND3_PASS=T1021';
else put 'ERROR: ROUND3_FAIL=T1021 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1021:; quit;
