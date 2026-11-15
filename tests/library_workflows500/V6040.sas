/* New workflow V6040; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6040i;
length gene $80 tissue $80;
gene='gene01';tissue='c2';expression=69.19999999999999;output;
gene='gene02';tissue='c1';expression=54.26;output;
gene='gene02';tissue='c2';expression=-21.669999999999998;output;
gene='gene03';tissue='c1';expression=-12.61;output;
gene='gene03';tissue='c2';expression=43.46;output;
gene='gene04';tissue='c1';expression=21.52;output;
gene='gene05';tissue='c2';expression=2.7199999999999998;output;
gene='gene06';tissue='c1';expression=52.78;output;
gene='gene06';tissue='c2';expression=27.85;output;
gene='gene07';tissue='c1';expression=29.91;output;
gene='gene07';tissue='c2';expression=-18.02;output;
gene='gene08';tissue='c1';expression=20.04;output;
gene='gene09';tissue='c2';expression=-12.76;output;
run;
%n26_longdsd2matlabmatrix(dsd=v6040i,var_row=gene,var_col=tissue,data_var=expression,value2asign4missing=0,dsdout=v6040o,outdir4matrix=);
data v6040m(keep=metric value);set v6040o;length metric $120;array measured[*] c1 c2;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6040m;set v6040m;format value best32.;run;
proc export data=v6040m outfile="%sysfunc(pathname(work))/V6040.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6040;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6040:;quit;
