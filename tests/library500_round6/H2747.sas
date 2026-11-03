/* H2747 anydigit_position, N=8; source: SAS-Useful-Codes/Macros/MacroNotUsed/xls input macro.sas:251 */

data h2747o; length text $40; text='xxxxxxxx'||'8'; actual=anydigit(text); run;

data _null_; if 0 then set h2747o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2747 rows=' rows;
else do; set h2747o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND6_PASS=H2747';
else put 'ERROR: ROUND6_FAIL=H2747 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2747:; quit;
