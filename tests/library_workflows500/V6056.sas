/* New workflow V6056; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6056i;
length gene $80 tissue $80;
gene='gene01';tissue='c2';expression=13.200000000000001;output;
gene='gene01';tissue='c3';expression=-23.73;output;
gene='gene02';tissue='c1';expression=62.26;output;
gene='gene02';tissue='c2';expression=-10.67;output;
gene='gene02';tissue='c3';expression=-20.599999999999998;output;
gene='gene03';tissue='c1';expression=5.39;output;
gene='gene03';tissue='c2';expression=53.46;output;
gene='gene04';tissue='c1';expression=61.52;output;
gene='gene04';tissue='c3';expression=4.659999999999999;output;
gene='gene05';tissue='c2';expression=39.72;output;
gene='gene05';tissue='c3';expression=-29.21;output;
run;
%n26_longdsd2matlabmatrix(dsd=v6056i,var_row=gene,var_col=tissue,data_var=expression,value2asign4missing=-999,dsdout=v6056o,outdir4matrix=);
data v6056m(keep=metric value);set v6056o;length metric $120;array measured[*] c1 c2 c3;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6056m;set v6056m;format value best32.;run;
proc export data=v6056m outfile="%sysfunc(pathname(work))/V6056.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6056;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6056:;quit;
