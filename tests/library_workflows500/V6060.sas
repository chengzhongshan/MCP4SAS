/* New workflow V6060; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6060i;
length gene $80 tissue $80;
gene='gene01';tissue='c2';expression=-29.8;output;
gene='gene02';tissue='c1';expression=64.26;output;
gene='gene02';tissue='c2';expression=-24.669999999999998;output;
gene='gene03';tissue='c1';expression=44.39;output;
gene='gene03';tissue='c2';expression=53.46;output;
gene='gene04';tissue='c1';expression=35.52;output;
gene='gene05';tissue='c2';expression=-15.28;output;
gene='gene06';tissue='c1';expression=-5.22;output;
gene='gene06';tissue='c2';expression=21.85;output;
gene='gene07';tissue='c1';expression=70.91;output;
gene='gene07';tissue='c2';expression=42.98;output;
gene='gene08';tissue='c1';expression=30.04;output;
gene='gene09';tissue='c2';expression=-11.76;output;
run;
%n26_longdsd2matlabmatrix(dsd=v6060i,var_row=gene,var_col=tissue,data_var=expression,value2asign4missing=-999,dsdout=v6060o,outdir4matrix=);
data v6060m(keep=metric value);set v6060o;length metric $120;array measured[*] c1 c2;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6060m;set v6060m;format value best32.;run;
proc export data=v6060m outfile="%sysfunc(pathname(work))/V6060.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6060;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6060:;quit;
