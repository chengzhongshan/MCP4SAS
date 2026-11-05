/* K4384 transpose_multiple_id_delimiter, N=5; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:2621 */

data k4384a; label='A'; day=1; expression=5; output; label='B'; day=2; expression=2*5; output; run;
proc transpose data=k4384a out=k4384b delimiter=_; id label day; var expression; run;
data k4384o; set k4384b; actual=A_1+B_2; run;

data _null_; if 0 then set k4384o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4384 rows=' rows;
else do; set k4384o; if not missing(actual) and abs(actual-(15))<=1e-9*max(1,abs(15)) then put 'ROUND10_PASS=K4384';
else put 'ERROR: ROUND10_FAIL=K4384 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4384:; quit;
