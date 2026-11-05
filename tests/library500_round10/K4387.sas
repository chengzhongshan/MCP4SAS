/* K4387 transpose_multiple_id_delimiter, N=8; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:2621 */

data k4387a; label='A'; day=1; expression=8; output; label='B'; day=2; expression=2*8; output; run;
proc transpose data=k4387a out=k4387b delimiter=_; id label day; var expression; run;
data k4387o; set k4387b; actual=A_1+B_2; run;

data _null_; if 0 then set k4387o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4387 rows=' rows;
else do; set k4387o; if not missing(actual) and abs(actual-(24))<=1e-9*max(1,abs(24)) then put 'ROUND10_PASS=K4387';
else put 'ERROR: ROUND10_FAIL=K4387 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4387:; quit;
