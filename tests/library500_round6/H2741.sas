/* H2741 anydigit_position, N=2; source: SAS-Useful-Codes/Macros/MacroNotUsed/xls input macro.sas:251 */

data h2741o; length text $40; text='xx'||'2'; actual=anydigit(text); run;

data _null_; if 0 then set h2741o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2741 rows=' rows;
else do; set h2741o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND6_PASS=H2741';
else put 'ERROR: ROUND6_FAIL=H2741 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2741:; quit;
