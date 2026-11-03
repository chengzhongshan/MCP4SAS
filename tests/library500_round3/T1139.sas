/* T1139 cntlin_generated_format, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/live_birth_rate with bin to find potential relationship between two variables.sas:934 */

data t1139a; length fmtname $32 type $1 label $20; fmtname='t1139f'; type='N'; do start=1 to 10; end=start; label=strip(put(2*start,best32.)); output; end; run;
proc format library=work cntlin=t1139a; run;
data t1139o; actual=input(putn(10,'t1139f.'),best32.); run;

data _null_; if 0 then set t1139o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1139 rows=' rows;
else do; set t1139o; if not missing(actual) and abs(actual-(20))<=1e-10*max(1,abs(20)) then put 'ROUND3_PASS=T1139';
else put 'ERROR: ROUND3_FAIL=T1139 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1139:; quit;
proc catalog catalog=work.formats; delete t1139f.format; quit;
