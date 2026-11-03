/* G2096 pdv_character_truncation, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:17 */

data g2096a; length text $7; text='xxxxxxx'; run;
data g2096o; length text $3; set g2096a; actual=lengthn(text); run;

data _null_; if 0 then set g2096o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2096 rows=' rows;
else do; set g2096o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND5_PASS=G2096';
else put 'ERROR: ROUND5_FAIL=G2096 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2096:; quit;
