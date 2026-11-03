/* R986 dictionary_column_types, N=7; source: SAS-Useful-Codes/Macros/App_Dsd_Lbl_Fmt_To_Other_Dsd.sas:10 */

data r986a; length label $7; array v[7] x1-x7; do j=1 to 7; v[j]=j; end; drop j; run;
proc sql; create table r986o as select sum(type='num') as actual from dictionary.columns where libname='WORK' and memname=upcase('r986a'); quit;

data _null_; if 0 then set r986o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R986 rows=' rows;
else do; set r986o; if not missing(actual) and abs(actual-(7))<=1e-10*max(1,abs(7)) then put 'ROUND2_PASS=R986';
else put 'ERROR: ROUND2_FAIL=R986 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r986:; quit;
