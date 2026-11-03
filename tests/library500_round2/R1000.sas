/* R1000 fileref_include, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Test4Lattice_gscatter_over_bed_track_after_modification.sas:2 */

filename rtemp temp;
data _null_; file rtemp; put 'data r1000o; actual=11*7; run;'; run;
%include rtemp;
filename rtemp clear;

data _null_; if 0 then set r1000o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R1000 rows=' rows;
else do; set r1000o; if not missing(actual) and abs(actual-(77))<=1e-10*max(1,abs(77)) then put 'ROUND2_PASS=R1000';
else put 'ERROR: ROUND2_FAIL=R1000 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r1000:; quit;
