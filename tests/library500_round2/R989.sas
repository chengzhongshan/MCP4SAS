/* R989 dictionary_column_types, N=10; source: SAS-Useful-Codes/Macros/App_Dsd_Lbl_Fmt_To_Other_Dsd.sas:10 */

data r989a; length label $10; array v[10] x1-x10; do j=1 to 10; v[j]=j; end; drop j; run;
proc sql; create table r989o as select sum(type='num') as actual from dictionary.columns where libname='WORK' and memname=upcase('r989a'); quit;

data _null_; if 0 then set r989o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R989 rows=' rows;
else do; set r989o; if not missing(actual) and abs(actual-(10))<=1e-10*max(1,abs(10)) then put 'ROUND2_PASS=R989';
else put 'ERROR: ROUND2_FAIL=R989 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r989:; quit;
