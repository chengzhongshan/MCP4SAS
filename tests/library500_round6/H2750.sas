/* H2750 anydigit_position, N=11; source: SAS-Useful-Codes/Macros/MacroNotUsed/xls input macro.sas:251 */

data h2750o; length text $40; text='xxxxxxxxxxx'||'11'; actual=anydigit(text); run;

data _null_; if 0 then set h2750o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2750 rows=' rows;
else do; set h2750o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND6_PASS=H2750';
else put 'ERROR: ROUND6_FAIL=H2750 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2750:; quit;
