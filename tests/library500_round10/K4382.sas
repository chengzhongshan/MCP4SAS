/* K4382 transpose_multiple_id_delimiter, N=3; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:2621 */

data k4382a; label='A'; day=1; expression=3; output; label='B'; day=2; expression=2*3; output; run;
proc transpose data=k4382a out=k4382b delimiter=_; id label day; var expression; run;
data k4382o; set k4382b; actual=A_1+B_2; run;

data _null_; if 0 then set k4382o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4382 rows=' rows;
else do; set k4382o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND10_PASS=K4382';
else put 'ERROR: ROUND10_FAIL=K4382 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4382:; quit;
