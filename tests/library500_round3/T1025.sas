/* T1025 contents_label_text, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:18 */

data t1025a; x=6; label x='Field_6'; run;
proc contents data=t1025a out=t1025b noprint; run;
data t1025o; set t1025b; actual=lengthn(label); run;

data _null_; if 0 then set t1025o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1025 rows=' rows;
else do; set t1025o; if not missing(actual) and abs(actual-(7))<=1e-10*max(1,abs(7)) then put 'ROUND3_PASS=T1025';
else put 'ERROR: ROUND3_FAIL=T1025 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1025:; quit;
