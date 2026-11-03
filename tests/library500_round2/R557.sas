/* R557 sql_union, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Merge Function IMPORTANT NOTES.sas:66 */

data r557a; do x=1 to 8; output; end; run;
data r557b; do x=8 to 2*8; output; end; run;
proc sql; create table r557c as select x from r557a union select x from r557b;
create table r557o as select sum(x) as actual from r557c; quit;

data _null_; if 0 then set r557o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R557 rows=' rows;
else do; set r557o; if not missing(actual) and abs(actual-(136))<=1e-10*max(1,abs(136)) then put 'ROUND2_PASS=R557';
else put 'ERROR: ROUND2_FAIL=R557 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r557:; quit;
