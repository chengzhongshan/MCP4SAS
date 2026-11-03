/* G2099 pdv_character_truncation, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:17 */

data g2099a; length text $10; text='xxxxxxxxxx'; run;
data g2099o; length text $3; set g2099a; actual=lengthn(text); run;

data _null_; if 0 then set g2099o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2099 rows=' rows;
else do; set g2099o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND5_PASS=G2099';
else put 'ERROR: ROUND5_FAIL=G2099 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2099:; quit;
