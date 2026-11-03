/* G2094 pdv_character_truncation, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:17 */

data g2094a; length text $5; text='xxxxx'; run;
data g2094o; length text $3; set g2094a; actual=lengthn(text); run;

data _null_; if 0 then set g2094o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2094 rows=' rows;
else do; set g2094o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND5_PASS=G2094';
else put 'ERROR: ROUND5_FAIL=G2094 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2094:; quit;
