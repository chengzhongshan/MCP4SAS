/* R983 dictionary_column_types, N=4; source: SAS-Useful-Codes/Macros/App_Dsd_Lbl_Fmt_To_Other_Dsd.sas:10 */

data r983a; length label $4; array v[4] x1-x4; do j=1 to 4; v[j]=j; end; drop j; run;
proc sql; create table r983o as select sum(type='num') as actual from dictionary.columns where libname='WORK' and memname=upcase('r983a'); quit;

data _null_; if 0 then set r983o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R983 rows=' rows;
else do; set r983o; if not missing(actual) and abs(actual-(4))<=1e-10*max(1,abs(4)) then put 'ROUND2_PASS=R983';
else put 'ERROR: ROUND2_FAIL=R983 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r983:; quit;
