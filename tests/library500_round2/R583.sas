/* R583 sql_intersect, N=4; source: SAS-Useful-Codes/Macros/SAS-macros-master/insect.sas:4 */

data r583a; do x=1 to 2*4; output; end; run;
data r583b; do x=4 to 3*4; output; end; run;
proc sql; create table r583c as select x from r583a intersect select x from r583b;
create table r583o as select sum(x) as actual from r583c; quit;

data _null_; if 0 then set r583o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R583 rows=' rows;
else do; set r583o; if not missing(actual) and abs(actual-(30))<=1e-10*max(1,abs(30)) then put 'ROUND2_PASS=R583';
else put 'ERROR: ROUND2_FAIL=R583 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r583:; quit;
