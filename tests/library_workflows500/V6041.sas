/* New workflow V6041; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6041i;
length gene $80 tissue $80;
gene='gene01';tissue='c1';expression=54.13;output;
gene='gene01';tissue='c2';expression=-10.799999999999999;output;
gene='gene01';tissue='c3';expression=-20.73;output;
gene='gene02';tissue='c1';expression=47.26;output;
gene='gene02';tissue='c2';expression=36.33;output;
gene='gene03';tissue='c1';expression=67.39;output;
gene='gene03';tissue='c3';expression=-9.469999999999999;output;
gene='gene04';tissue='c2';expression=34.59;output;
gene='gene04';tissue='c3';expression=37.660000000000004;output;
run;
%n26_longdsd2matlabmatrix(dsd=v6041i,var_row=gene,var_col=tissue,data_var=expression,value2asign4missing=-999,dsdout=v6041o,outdir4matrix=);
data v6041m(keep=metric value);set v6041o;length metric $120;array measured[*] c1 c2 c3;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6041m;set v6041m;format value best32.;run;
proc export data=v6041m outfile="%sysfunc(pathname(work))/V6041.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6041;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6041:;quit;
