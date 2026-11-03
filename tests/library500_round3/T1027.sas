/* T1027 contents_label_text, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:18 */

data t1027a; x=8; label x='Field_8'; run;
proc contents data=t1027a out=t1027b noprint; run;
data t1027o; set t1027b; actual=lengthn(label); run;

data _null_; if 0 then set t1027o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1027 rows=' rows;
else do; set t1027o; if not missing(actual) and abs(actual-(7))<=1e-10*max(1,abs(7)) then put 'ROUND3_PASS=T1027';
else put 'ERROR: ROUND3_FAIL=T1027 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1027:; quit;
