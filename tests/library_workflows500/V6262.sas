/* New workflow V6262; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6262i;
length gene $80;
gene='allele01';ref=23;alt=12;output;
gene='allele02';ref=9;alt=6;output;
gene='allele03';ref=4;alt=27;output;
gene='allele04';ref=15;alt=28;output;
gene='allele05';ref=0;alt=5;output;
run;
%n26_calculate_binomial_P(dsdin=v6262i,dsdout=v6262o,Allele1_var=ref,Allele2_var=alt,TotReadCutoff=4);
data v6262m(keep=metric value);set v6262o;length metric $120;array measured[*] tot_reads binomial_P logP Ref_Frq A1A2log2Ratio;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6262m;set v6262m;format value best32.;run;
proc export data=v6262m outfile="%sysfunc(pathname(work))/V6262.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6262;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6262:;quit;
