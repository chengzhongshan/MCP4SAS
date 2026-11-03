/* T1024 contents_label_text, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:18 */

data t1024a; x=5; label x='Field_5'; run;
proc contents data=t1024a out=t1024b noprint; run;
data t1024o; set t1024b; actual=lengthn(label); run;

data _null_; if 0 then set t1024o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1024 rows=' rows;
else do; set t1024o; if not missing(actual) and abs(actual-(7))<=1e-10*max(1,abs(7)) then put 'ROUND3_PASS=T1024';
else put 'ERROR: ROUND3_FAIL=T1024 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1024:; quit;
