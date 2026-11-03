/* T1136 cntlin_generated_format, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/live_birth_rate with bin to find potential relationship between two variables.sas:934 */

data t1136a; length fmtname $32 type $1 label $20; fmtname='t1136f'; type='N'; do start=1 to 7; end=start; label=strip(put(2*start,best32.)); output; end; run;
proc format library=work cntlin=t1136a; run;
data t1136o; actual=input(putn(7,'t1136f.'),best32.); run;

data _null_; if 0 then set t1136o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1136 rows=' rows;
else do; set t1136o; if not missing(actual) and abs(actual-(14))<=1e-10*max(1,abs(14)) then put 'ROUND3_PASS=T1136';
else put 'ERROR: ROUND3_FAIL=T1136 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1136:; quit;
proc catalog catalog=work.formats; delete t1136f.format; quit;
