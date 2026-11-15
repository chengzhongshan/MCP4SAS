/* New workflow V6264; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6264i;
length gene $80;
gene='allele01';ref=32;alt=18;output;
gene='allele02';ref=38;alt=26;output;
gene='allele03';ref=35;alt=16;output;
gene='allele04';ref=36;alt=36;output;
gene='allele05';ref=30;alt=17;output;
gene='allele06';ref=35;alt=26;output;
gene='allele07';ref=12;alt=39;output;
run;
%n26_calculate_binomial_P(dsdin=v6264i,dsdout=v6264o,Allele1_var=ref,Allele2_var=alt,TotReadCutoff=6);
data v6264m(keep=metric value);set v6264o;length metric $120;array measured[*] tot_reads binomial_P logP Ref_Frq A1A2log2Ratio;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6264m;set v6264m;format value best32.;run;
proc export data=v6264m outfile="%sysfunc(pathname(work))/V6264.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6264;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6264:;quit;
