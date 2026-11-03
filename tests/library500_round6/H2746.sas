/* H2746 anydigit_position, N=7; source: SAS-Useful-Codes/Macros/MacroNotUsed/xls input macro.sas:251 */

data h2746o; length text $40; text='xxxxxxx'||'7'; actual=anydigit(text); run;

data _null_; if 0 then set h2746o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2746 rows=' rows;
else do; set h2746o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND6_PASS=H2746';
else put 'ERROR: ROUND6_FAIL=H2746 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2746:; quit;
