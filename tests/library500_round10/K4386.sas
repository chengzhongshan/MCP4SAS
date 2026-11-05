/* K4386 transpose_multiple_id_delimiter, N=7; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:2621 */

data k4386a; label='A'; day=1; expression=7; output; label='B'; day=2; expression=2*7; output; run;
proc transpose data=k4386a out=k4386b delimiter=_; id label day; var expression; run;
data k4386o; set k4386b; actual=A_1+B_2; run;

data _null_; if 0 then set k4386o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4386 rows=' rows;
else do; set k4386o; if not missing(actual) and abs(actual-(21))<=1e-9*max(1,abs(21)) then put 'ROUND10_PASS=K4386';
else put 'ERROR: ROUND10_FAIL=K4386 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4386:; quit;
