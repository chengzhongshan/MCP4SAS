/* H2748 anydigit_position, N=9; source: SAS-Useful-Codes/Macros/MacroNotUsed/xls input macro.sas:251 */

data h2748o; length text $40; text='xxxxxxxxx'||'9'; actual=anydigit(text); run;

data _null_; if 0 then set h2748o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2748 rows=' rows;
else do; set h2748o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND6_PASS=H2748';
else put 'ERROR: ROUND6_FAIL=H2748 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2748:; quit;
