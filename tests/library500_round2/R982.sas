/* R982 dictionary_column_types, N=3; source: SAS-Useful-Codes/Macros/App_Dsd_Lbl_Fmt_To_Other_Dsd.sas:10 */

data r982a; length label $3; array v[3] x1-x3; do j=1 to 3; v[j]=j; end; drop j; run;
proc sql; create table r982o as select sum(type='num') as actual from dictionary.columns where libname='WORK' and memname=upcase('r982a'); quit;

data _null_; if 0 then set r982o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R982 rows=' rows;
else do; set r982o; if not missing(actual) and abs(actual-(3))<=1e-10*max(1,abs(3)) then put 'ROUND2_PASS=R982';
else put 'ERROR: ROUND2_FAIL=R982 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r982:; quit;
