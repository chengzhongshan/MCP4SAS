/* R988 dictionary_column_types, N=9; source: SAS-Useful-Codes/Macros/App_Dsd_Lbl_Fmt_To_Other_Dsd.sas:10 */

data r988a; length label $9; array v[9] x1-x9; do j=1 to 9; v[j]=j; end; drop j; run;
proc sql; create table r988o as select sum(type='num') as actual from dictionary.columns where libname='WORK' and memname=upcase('r988a'); quit;

data _null_; if 0 then set r988o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R988 rows=' rows;
else do; set r988o; if not missing(actual) and abs(actual-(9))<=1e-10*max(1,abs(9)) then put 'ROUND2_PASS=R988';
else put 'ERROR: ROUND2_FAIL=R988 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r988:; quit;
