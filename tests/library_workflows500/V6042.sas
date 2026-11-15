/* New workflow V6042; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6042i;
length gene $80 tissue $80;
gene='gene01';tissue='c1';expression=56.13;output;
gene='gene01';tissue='c2';expression=19.2;output;
gene='gene01';tissue='c4';expression=54.34;output;
gene='gene02';tissue='c1';expression=59.26;output;
gene='gene02';tissue='c3';expression=59.4;output;
gene='gene02';tissue='c4';expression=-2.5300000000000002;output;
gene='gene03';tissue='c2';expression=6.46;output;
gene='gene03';tissue='c3';expression=10.530000000000001;output;
gene='gene03';tissue='c4';expression=3.6;output;
gene='gene04';tissue='c1';expression=30.52;output;
gene='gene04';tissue='c2';expression=-18.41;output;
gene='gene04';tissue='c3';expression=-24.34;output;
gene='gene05';tissue='c1';expression=57.65;output;
gene='gene05';tissue='c2';expression=57.72;output;
gene='gene05';tissue='c4';expression=65.86;output;
run;
%n26_longdsd2matlabmatrix(dsd=v6042i,var_row=gene,var_col=tissue,data_var=expression,value2asign4missing=-999,dsdout=v6042o,outdir4matrix=);
data v6042m(keep=metric value);set v6042o;length metric $120;array measured[*] c1 c2 c3 c4;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6042m;set v6042m;format value best32.;run;
proc export data=v6042m outfile="%sysfunc(pathname(work))/V6042.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6042;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6042:;quit;
