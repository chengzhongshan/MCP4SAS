/* H2745 anydigit_position, N=6; source: SAS-Useful-Codes/Macros/MacroNotUsed/xls input macro.sas:251 */

data h2745o; length text $40; text='xxxxxx'||'6'; actual=anydigit(text); run;

data _null_; if 0 then set h2745o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2745 rows=' rows;
else do; set h2745o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND6_PASS=H2745';
else put 'ERROR: ROUND6_FAIL=H2745 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2745:; quit;
