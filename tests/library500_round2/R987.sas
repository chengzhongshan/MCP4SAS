/* R987 dictionary_column_types, N=8; source: SAS-Useful-Codes/Macros/App_Dsd_Lbl_Fmt_To_Other_Dsd.sas:10 */

data r987a; length label $8; array v[8] x1-x8; do j=1 to 8; v[j]=j; end; drop j; run;
proc sql; create table r987o as select sum(type='num') as actual from dictionary.columns where libname='WORK' and memname=upcase('r987a'); quit;

data _null_; if 0 then set r987o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R987 rows=' rows;
else do; set r987o; if not missing(actual) and abs(actual-(8))<=1e-10*max(1,abs(8)) then put 'ROUND2_PASS=R987';
else put 'ERROR: ROUND2_FAIL=R987 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r987:; quit;
