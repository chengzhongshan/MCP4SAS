/* G2091 pdv_character_truncation, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:17 */

data g2091a; length text $2; text='xx'; run;
data g2091o; length text $3; set g2091a; actual=lengthn(text); run;

data _null_; if 0 then set g2091o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2091 rows=' rows;
else do; set g2091o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND5_PASS=G2091';
else put 'ERROR: ROUND5_FAIL=G2091 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2091:; quit;
