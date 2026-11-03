/* G2098 pdv_character_truncation, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:17 */

data g2098a; length text $9; text='xxxxxxxxx'; run;
data g2098o; length text $3; set g2098a; actual=lengthn(text); run;

data _null_; if 0 then set g2098o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2098 rows=' rows;
else do; set g2098o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND5_PASS=G2098';
else put 'ERROR: ROUND5_FAIL=G2098 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2098:; quit;
