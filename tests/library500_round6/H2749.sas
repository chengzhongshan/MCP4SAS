/* H2749 anydigit_position, N=10; source: SAS-Useful-Codes/Macros/MacroNotUsed/xls input macro.sas:251 */

data h2749o; length text $40; text='xxxxxxxxxx'||'10'; actual=anydigit(text); run;

data _null_; if 0 then set h2749o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2749 rows=' rows;
else do; set h2749o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND6_PASS=H2749';
else put 'ERROR: ROUND6_FAIL=H2749 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2749:; quit;
