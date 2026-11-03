/* G2095 pdv_character_truncation, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:17 */

data g2095a; length text $6; text='xxxxxx'; run;
data g2095o; length text $3; set g2095a; actual=lengthn(text); run;

data _null_; if 0 then set g2095o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2095 rows=' rows;
else do; set g2095o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND5_PASS=G2095';
else put 'ERROR: ROUND5_FAIL=G2095 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2095:; quit;
