/* R985 dictionary_column_types, N=6; source: SAS-Useful-Codes/Macros/App_Dsd_Lbl_Fmt_To_Other_Dsd.sas:10 */

data r985a; length label $6; array v[6] x1-x6; do j=1 to 6; v[j]=j; end; drop j; run;
proc sql; create table r985o as select sum(type='num') as actual from dictionary.columns where libname='WORK' and memname=upcase('r985a'); quit;

data _null_; if 0 then set r985o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R985 rows=' rows;
else do; set r985o; if not missing(actual) and abs(actual-(6))<=1e-10*max(1,abs(6)) then put 'ROUND2_PASS=R985';
else put 'ERROR: ROUND2_FAIL=R985 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r985:; quit;
