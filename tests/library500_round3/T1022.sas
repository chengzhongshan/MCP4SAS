/* T1022 contents_label_text, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:18 */

data t1022a; x=3; label x='Field_3'; run;
proc contents data=t1022a out=t1022b noprint; run;
data t1022o; set t1022b; actual=lengthn(label); run;

data _null_; if 0 then set t1022o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1022 rows=' rows;
else do; set t1022o; if not missing(actual) and abs(actual-(7))<=1e-10*max(1,abs(7)) then put 'ROUND3_PASS=T1022';
else put 'ERROR: ROUND3_FAIL=T1022 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1022:; quit;
