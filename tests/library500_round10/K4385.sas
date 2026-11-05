/* K4385 transpose_multiple_id_delimiter, N=6; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:2621 */

data k4385a; label='A'; day=1; expression=6; output; label='B'; day=2; expression=2*6; output; run;
proc transpose data=k4385a out=k4385b delimiter=_; id label day; var expression; run;
data k4385o; set k4385b; actual=A_1+B_2; run;

data _null_; if 0 then set k4385o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4385 rows=' rows;
else do; set k4385o; if not missing(actual) and abs(actual-(18))<=1e-9*max(1,abs(18)) then put 'ROUND10_PASS=K4385';
else put 'ERROR: ROUND10_FAIL=K4385 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4385:; quit;
