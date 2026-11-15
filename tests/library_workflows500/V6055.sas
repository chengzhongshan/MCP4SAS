/* New workflow V6055; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6055i;
length gene $80 tissue $80;
gene='gene01';tissue='c1';expression=-7.87;output;
gene='gene02';tissue='c2';expression=33.33;output;
gene='gene03';tissue='c1';expression=11.39;output;
gene='gene03';tissue='c2';expression=24.46;output;
gene='gene04';tissue='c1';expression=9.52;output;
gene='gene04';tissue='c2';expression=4.59;output;
run;
%n26_longdsd2matlabmatrix(dsd=v6055i,var_row=gene,var_col=tissue,data_var=expression,value2asign4missing=-999,dsdout=v6055o,outdir4matrix=);
data v6055m(keep=metric value);set v6055o;length metric $120;array measured[*] c1 c2;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6055m;set v6055m;format value best32.;run;
proc export data=v6055m outfile="%sysfunc(pathname(work))/V6055.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6055;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6055:;quit;
