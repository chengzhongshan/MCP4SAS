/* T1137 cntlin_generated_format, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/live_birth_rate with bin to find potential relationship between two variables.sas:934 */

data t1137a; length fmtname $32 type $1 label $20; fmtname='t1137f'; type='N'; do start=1 to 8; end=start; label=strip(put(2*start,best32.)); output; end; run;
proc format library=work cntlin=t1137a; run;
data t1137o; actual=input(putn(8,'t1137f.'),best32.); run;

data _null_; if 0 then set t1137o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1137 rows=' rows;
else do; set t1137o; if not missing(actual) and abs(actual-(16))<=1e-10*max(1,abs(16)) then put 'ROUND3_PASS=T1137';
else put 'ERROR: ROUND3_FAIL=T1137 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1137:; quit;
proc catalog catalog=work.formats; delete t1137f.format; quit;
