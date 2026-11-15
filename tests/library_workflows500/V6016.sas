/* New workflow V6016; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6016i;
length gene $80 tissue $80;
gene='gene01';tissue='c1';expression=51.13;output;
gene='gene01';tissue='c2';expression=-23.8;output;
gene='gene01';tissue='c3';expression=-4.73;output;
gene='gene02';tissue='c1';expression=22.26;output;
gene='gene02';tissue='c2';expression=49.33;output;
gene='gene02';tissue='c3';expression=44.4;output;
gene='gene03';tissue='c1';expression=65.39;output;
gene='gene03';tissue='c2';expression=13.46;output;
gene='gene03';tissue='c3';expression=13.530000000000001;output;
gene='gene04';tissue='c1';expression=5.52;output;
gene='gene04';tissue='c2';expression=-15.41;output;
gene='gene04';tissue='c3';expression=52.660000000000004;output;
gene='gene05';tissue='c1';expression=38.65;output;
gene='gene05';tissue='c2';expression=-24.28;output;
gene='gene05';tissue='c3';expression=45.79;output;
run;
%n26_longdsd2matlabmatrix(dsd=v6016i,var_row=gene,var_col=tissue,data_var=expression,value2asign4missing=0,dsdout=v6016o,outdir4matrix=);
data v6016m(keep=metric value);set v6016o;length metric $120;array measured[*] c1 c2 c3;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6016m;set v6016m;format value best32.;run;
proc export data=v6016m outfile="%sysfunc(pathname(work))/V6016.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6016;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6016:;quit;
