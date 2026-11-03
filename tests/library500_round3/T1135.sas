/* T1135 cntlin_generated_format, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/live_birth_rate with bin to find potential relationship between two variables.sas:934 */

data t1135a; length fmtname $32 type $1 label $20; fmtname='t1135f'; type='N'; do start=1 to 6; end=start; label=strip(put(2*start,best32.)); output; end; run;
proc format library=work cntlin=t1135a; run;
data t1135o; actual=input(putn(6,'t1135f.'),best32.); run;

data _null_; if 0 then set t1135o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1135 rows=' rows;
else do; set t1135o; if not missing(actual) and abs(actual-(12))<=1e-10*max(1,abs(12)) then put 'ROUND3_PASS=T1135';
else put 'ERROR: ROUND3_FAIL=T1135 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1135:; quit;
proc catalog catalog=work.formats; delete t1135f.format; quit;
