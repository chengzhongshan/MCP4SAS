/* K4220 beta_integer_symmetry, N=11; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4220o; actual=beta(11,11); run;

data _null_; if 0 then set k4220o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4220 rows=' rows;
else do; set k4220o; if not missing(actual) and abs(actual-(2.57740195820691e-07))<=1e-10*max(1,abs(2.57740195820691e-07)) then put 'ROUND10_PASS=K4220';
else put 'ERROR: ROUND10_FAIL=K4220 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4220:; quit;
