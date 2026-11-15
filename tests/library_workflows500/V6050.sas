/* New workflow V6050; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6050i;
length gene $80 tissue $80;
gene='gene01';tissue='c1';expression=-22.87;output;
gene='gene01';tissue='c2';expression=-12.799999999999999;output;
gene='gene02';tissue='c1';expression=52.26;output;
gene='gene03';tissue='c2';expression=-20.54;output;
gene='gene04';tissue='c1';expression=-6.48;output;
gene='gene04';tissue='c2';expression=38.59;output;
gene='gene05';tissue='c1';expression=12.65;output;
gene='gene05';tissue='c2';expression=22.72;output;
gene='gene06';tissue='c1';expression=-15.22;output;
run;
%n26_longdsd2matlabmatrix(dsd=v6050i,var_row=gene,var_col=tissue,data_var=expression,value2asign4missing=-999,dsdout=v6050o,outdir4matrix=);
data v6050m(keep=metric value);set v6050o;length metric $120;array measured[*] c1 c2;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6050m;set v6050m;format value best32.;run;
proc export data=v6050m outfile="%sysfunc(pathname(work))/V6050.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6050;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6050:;quit;
