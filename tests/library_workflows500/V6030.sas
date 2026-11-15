/* New workflow V6030; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6030i;
length gene $80 tissue $80;
gene='gene01';tissue='c1';expression=28.13;output;
gene='gene01';tissue='c2';expression=27.2;output;
gene='gene02';tissue='c1';expression=10.26;output;
gene='gene03';tissue='c2';expression=64.46;output;
gene='gene04';tissue='c1';expression=-10.48;output;
gene='gene04';tissue='c2';expression=-21.41;output;
gene='gene05';tissue='c1';expression=-29.35;output;
gene='gene05';tissue='c2';expression=2.7199999999999998;output;
gene='gene06';tissue='c1';expression=39.78;output;
run;
%n26_longdsd2matlabmatrix(dsd=v6030i,var_row=gene,var_col=tissue,data_var=expression,value2asign4missing=0,dsdout=v6030o,outdir4matrix=);
data v6030m(keep=metric value);set v6030o;length metric $120;array measured[*] c1 c2;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6030m;set v6030m;format value best32.;run;
proc export data=v6030m outfile="%sysfunc(pathname(work))/V6030.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6030;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6030:;quit;
