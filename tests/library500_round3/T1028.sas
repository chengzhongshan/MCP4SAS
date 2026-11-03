/* T1028 contents_label_text, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:18 */

data t1028a; x=9; label x='Field_9'; run;
proc contents data=t1028a out=t1028b noprint; run;
data t1028o; set t1028b; actual=lengthn(label); run;

data _null_; if 0 then set t1028o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1028 rows=' rows;
else do; set t1028o; if not missing(actual) and abs(actual-(7))<=1e-10*max(1,abs(7)) then put 'ROUND3_PASS=T1028';
else put 'ERROR: ROUND3_FAIL=T1028 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1028:; quit;
