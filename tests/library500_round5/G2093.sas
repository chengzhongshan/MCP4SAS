/* G2093 pdv_character_truncation, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:17 */

data g2093a; length text $4; text='xxxx'; run;
data g2093o; length text $3; set g2093a; actual=lengthn(text); run;

data _null_; if 0 then set g2093o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2093 rows=' rows;
else do; set g2093o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND5_PASS=G2093';
else put 'ERROR: ROUND5_FAIL=G2093 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2093:; quit;
