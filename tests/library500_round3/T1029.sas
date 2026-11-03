/* T1029 contents_label_text, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:18 */

data t1029a; x=10; label x='Field_10'; run;
proc contents data=t1029a out=t1029b noprint; run;
data t1029o; set t1029b; actual=lengthn(label); run;

data _null_; if 0 then set t1029o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1029 rows=' rows;
else do; set t1029o; if not missing(actual) and abs(actual-(8))<=1e-10*max(1,abs(8)) then put 'ROUND3_PASS=T1029';
else put 'ERROR: ROUND3_FAIL=T1029 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1029:; quit;
