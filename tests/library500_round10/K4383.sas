/* K4383 transpose_multiple_id_delimiter, N=4; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:2621 */

data k4383a; label='A'; day=1; expression=4; output; label='B'; day=2; expression=2*4; output; run;
proc transpose data=k4383a out=k4383b delimiter=_; id label day; var expression; run;
data k4383o; set k4383b; actual=A_1+B_2; run;

data _null_; if 0 then set k4383o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4383 rows=' rows;
else do; set k4383o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND10_PASS=K4383';
else put 'ERROR: ROUND10_FAIL=K4383 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4383:; quit;
