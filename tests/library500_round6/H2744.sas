/* H2744 anydigit_position, N=5; source: SAS-Useful-Codes/Macros/MacroNotUsed/xls input macro.sas:251 */

data h2744o; length text $40; text='xxxxx'||'5'; actual=anydigit(text); run;

data _null_; if 0 then set h2744o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2744 rows=' rows;
else do; set h2744o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND6_PASS=H2744';
else put 'ERROR: ROUND6_FAIL=H2744 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2744:; quit;
