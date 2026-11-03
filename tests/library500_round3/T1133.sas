/* T1133 cntlin_generated_format, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/live_birth_rate with bin to find potential relationship between two variables.sas:934 */

data t1133a; length fmtname $32 type $1 label $20; fmtname='t1133f'; type='N'; do start=1 to 4; end=start; label=strip(put(2*start,best32.)); output; end; run;
proc format library=work cntlin=t1133a; run;
data t1133o; actual=input(putn(4,'t1133f.'),best32.); run;

data _null_; if 0 then set t1133o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1133 rows=' rows;
else do; set t1133o; if not missing(actual) and abs(actual-(8))<=1e-10*max(1,abs(8)) then put 'ROUND3_PASS=T1133';
else put 'ERROR: ROUND3_FAIL=T1133 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1133:; quit;
proc catalog catalog=work.formats; delete t1133f.format; quit;
