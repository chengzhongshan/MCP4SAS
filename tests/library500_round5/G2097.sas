/* G2097 pdv_character_truncation, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:17 */

data g2097a; length text $8; text='xxxxxxxx'; run;
data g2097o; length text $3; set g2097a; actual=lengthn(text); run;

data _null_; if 0 then set g2097o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2097 rows=' rows;
else do; set g2097o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND5_PASS=G2097';
else put 'ERROR: ROUND5_FAIL=G2097 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2097:; quit;
