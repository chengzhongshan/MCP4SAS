/* R581 sql_intersect, N=2; source: SAS-Useful-Codes/Macros/SAS-macros-master/insect.sas:4 */

data r581a; do x=1 to 2*2; output; end; run;
data r581b; do x=2 to 3*2; output; end; run;
proc sql; create table r581c as select x from r581a intersect select x from r581b;
create table r581o as select sum(x) as actual from r581c; quit;

data _null_; if 0 then set r581o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R581 rows=' rows;
else do; set r581o; if not missing(actual) and abs(actual-(9))<=1e-10*max(1,abs(9)) then put 'ROUND2_PASS=R581';
else put 'ERROR: ROUND2_FAIL=R581 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r581:; quit;
