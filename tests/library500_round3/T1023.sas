/* T1023 contents_label_text, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:18 */

data t1023a; x=4; label x='Field_4'; run;
proc contents data=t1023a out=t1023b noprint; run;
data t1023o; set t1023b; actual=lengthn(label); run;

data _null_; if 0 then set t1023o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1023 rows=' rows;
else do; set t1023o; if not missing(actual) and abs(actual-(7))<=1e-10*max(1,abs(7)) then put 'ROUND3_PASS=T1023';
else put 'ERROR: ROUND3_FAIL=T1023 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1023:; quit;
