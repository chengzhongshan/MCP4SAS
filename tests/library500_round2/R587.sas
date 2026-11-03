/* R587 sql_intersect, N=8; source: SAS-Useful-Codes/Macros/SAS-macros-master/insect.sas:4 */

data r587a; do x=1 to 2*8; output; end; run;
data r587b; do x=8 to 3*8; output; end; run;
proc sql; create table r587c as select x from r587a intersect select x from r587b;
create table r587o as select sum(x) as actual from r587c; quit;

data _null_; if 0 then set r587o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R587 rows=' rows;
else do; set r587o; if not missing(actual) and abs(actual-(108))<=1e-10*max(1,abs(108)) then put 'ROUND2_PASS=R587';
else put 'ERROR: ROUND2_FAIL=R587 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r587:; quit;
