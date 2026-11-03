/* R984 dictionary_column_types, N=5; source: SAS-Useful-Codes/Macros/App_Dsd_Lbl_Fmt_To_Other_Dsd.sas:10 */

data r984a; length label $5; array v[5] x1-x5; do j=1 to 5; v[j]=j; end; drop j; run;
proc sql; create table r984o as select sum(type='num') as actual from dictionary.columns where libname='WORK' and memname=upcase('r984a'); quit;

data _null_; if 0 then set r984o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R984 rows=' rows;
else do; set r984o; if not missing(actual) and abs(actual-(5))<=1e-10*max(1,abs(5)) then put 'ROUND2_PASS=R984';
else put 'ERROR: ROUND2_FAIL=R984 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r984:; quit;
