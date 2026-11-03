/* G2092 pdv_character_truncation, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:17 */

data g2092a; length text $3; text='xxx'; run;
data g2092o; length text $3; set g2092a; actual=lengthn(text); run;

data _null_; if 0 then set g2092o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2092 rows=' rows;
else do; set g2092o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND5_PASS=G2092';
else put 'ERROR: ROUND5_FAIL=G2092 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2092:; quit;
