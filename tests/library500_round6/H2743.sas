/* H2743 anydigit_position, N=4; source: SAS-Useful-Codes/Macros/MacroNotUsed/xls input macro.sas:251 */

data h2743o; length text $40; text='xxxx'||'4'; actual=anydigit(text); run;

data _null_; if 0 then set h2743o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2743 rows=' rows;
else do; set h2743o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND6_PASS=H2743';
else put 'ERROR: ROUND6_FAIL=H2743 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2743:; quit;
