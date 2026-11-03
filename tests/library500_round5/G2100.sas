/* G2100 pdv_character_truncation, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:17 */

data g2100a; length text $11; text='xxxxxxxxxxx'; run;
data g2100o; length text $3; set g2100a; actual=lengthn(text); run;

data _null_; if 0 then set g2100o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2100 rows=' rows;
else do; set g2100o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND5_PASS=G2100';
else put 'ERROR: ROUND5_FAIL=G2100 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2100:; quit;
