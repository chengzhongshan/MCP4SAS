/* New workflow V6010; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6010i;
length gene $80 tissue $80;
gene='gene01';tissue='c1';expression=-28.87;output;
gene='gene01';tissue='c2';expression=37.2;output;
gene='gene02';tissue='c1';expression=-26.74;output;
gene='gene02';tissue='c2';expression=-22.669999999999998;output;
gene='gene03';tissue='c1';expression=5.39;output;
gene='gene03';tissue='c2';expression=48.46;output;
gene='gene04';tissue='c1';expression=-10.48;output;
gene='gene04';tissue='c2';expression=-26.41;output;
gene='gene05';tissue='c1';expression=-17.35;output;
gene='gene05';tissue='c2';expression=44.72;output;
gene='gene06';tissue='c1';expression=0.78;output;
gene='gene06';tissue='c2';expression=24.85;output;
run;
%n26_longdsd2matlabmatrix(dsd=v6010i,var_row=gene,var_col=tissue,data_var=expression,value2asign4missing=0,dsdout=v6010o,outdir4matrix=);
data v6010m(keep=metric value);set v6010o;length metric $120;array measured[*] c1 c2;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6010m;set v6010m;format value best32.;run;
proc export data=v6010m outfile="%sysfunc(pathname(work))/V6010.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6010;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6010:;quit;
