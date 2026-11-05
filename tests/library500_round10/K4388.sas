/* K4388 transpose_multiple_id_delimiter, N=9; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:2621 */

data k4388a; label='A'; day=1; expression=9; output; label='B'; day=2; expression=2*9; output; run;
proc transpose data=k4388a out=k4388b delimiter=_; id label day; var expression; run;
data k4388o; set k4388b; actual=A_1+B_2; run;

data _null_; if 0 then set k4388o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4388 rows=' rows;
else do; set k4388o; if not missing(actual) and abs(actual-(27))<=1e-9*max(1,abs(27)) then put 'ROUND10_PASS=K4388';
else put 'ERROR: ROUND10_FAIL=K4388 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4388:; quit;
