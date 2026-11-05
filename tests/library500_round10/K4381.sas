/* K4381 transpose_multiple_id_delimiter, N=2; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:2621 */

data k4381a; label='A'; day=1; expression=2; output; label='B'; day=2; expression=2*2; output; run;
proc transpose data=k4381a out=k4381b delimiter=_; id label day; var expression; run;
data k4381o; set k4381b; actual=A_1+B_2; run;

data _null_; if 0 then set k4381o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4381 rows=' rows;
else do; set k4381o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND10_PASS=K4381';
else put 'ERROR: ROUND10_FAIL=K4381 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4381:; quit;
