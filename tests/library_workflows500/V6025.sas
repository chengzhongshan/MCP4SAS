/* New workflow V6025; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6025i;
length gene $80 tissue $80;
gene='gene01';tissue='c1';expression=42.13;output;
gene='gene01';tissue='c2';expression=19.2;output;
gene='gene02';tissue='c1';expression=-29.74;output;
gene='gene02';tissue='c2';expression=-13.67;output;
gene='gene03';tissue='c1';expression=7.39;output;
gene='gene04';tissue='c2';expression=66.58999999999999;output;
gene='gene05';tissue='c1';expression=42.65;output;
gene='gene05';tissue='c2';expression=61.72;output;
gene='gene06';tissue='c1';expression=53.78;output;
gene='gene06';tissue='c2';expression=30.85;output;
gene='gene07';tissue='c1';expression=-14.09;output;
gene='gene08';tissue='c2';expression=21.11;output;
run;
%n26_longdsd2matlabmatrix(dsd=v6025i,var_row=gene,var_col=tissue,data_var=expression,value2asign4missing=0,dsdout=v6025o,outdir4matrix=);
data v6025m(keep=metric value);set v6025o;length metric $120;array measured[*] c1 c2;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6025m;set v6025m;format value best32.;run;
proc export data=v6025m outfile="%sysfunc(pathname(work))/V6025.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6025;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6025:;quit;
