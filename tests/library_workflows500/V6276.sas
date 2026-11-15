/* New workflow V6276; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6276i;
length gene $80;
gene='allele01';ref=30;alt=8;output;
gene='allele02';ref=25;alt=40;output;
gene='allele03';ref=23;alt=3;output;
gene='allele04';ref=30;alt=23;output;
gene='allele05';ref=33;alt=27;output;
run;
%n26_calculate_binomial_P(dsdin=v6276i,dsdout=v6276o,Allele1_var=ref,Allele2_var=alt,TotReadCutoff=9);
data v6276m(keep=metric value);set v6276o;length metric $120;array measured[*] tot_reads binomial_P logP Ref_Frq A1A2log2Ratio;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6276m;set v6276m;format value best32.;run;
proc export data=v6276m outfile="%sysfunc(pathname(work))/V6276.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6276;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6276:;quit;
