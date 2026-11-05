/* K4390 transpose_multiple_id_delimiter, N=11; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:2621 */

data k4390a; label='A'; day=1; expression=11; output; label='B'; day=2; expression=2*11; output; run;
proc transpose data=k4390a out=k4390b delimiter=_; id label day; var expression; run;
data k4390o; set k4390b; actual=A_1+B_2; run;

data _null_; if 0 then set k4390o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4390 rows=' rows;
else do; set k4390o; if not missing(actual) and abs(actual-(33))<=1e-9*max(1,abs(33)) then put 'ROUND10_PASS=K4390';
else put 'ERROR: ROUND10_FAIL=K4390 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4390:; quit;
