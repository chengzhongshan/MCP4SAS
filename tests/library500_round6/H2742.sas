/* H2742 anydigit_position, N=3; source: SAS-Useful-Codes/Macros/MacroNotUsed/xls input macro.sas:251 */

data h2742o; length text $40; text='xxx'||'3'; actual=anydigit(text); run;

data _null_; if 0 then set h2742o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2742 rows=' rows;
else do; set h2742o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND6_PASS=H2742';
else put 'ERROR: ROUND6_FAIL=H2742 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2742:; quit;
