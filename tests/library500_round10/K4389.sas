/* K4389 transpose_multiple_id_delimiter, N=10; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:2621 */

data k4389a; label='A'; day=1; expression=10; output; label='B'; day=2; expression=2*10; output; run;
proc transpose data=k4389a out=k4389b delimiter=_; id label day; var expression; run;
data k4389o; set k4389b; actual=A_1+B_2; run;

data _null_; if 0 then set k4389o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4389 rows=' rows;
else do; set k4389o; if not missing(actual) and abs(actual-(30))<=1e-9*max(1,abs(30)) then put 'ROUND10_PASS=K4389';
else put 'ERROR: ROUND10_FAIL=K4389 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4389:; quit;
