/* New workflow V6261; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6261i;
length gene $80;
gene='allele01';ref=8;alt=24;output;
gene='allele02';ref=34;alt=20;output;
gene='allele03';ref=21;alt=1;output;
gene='allele04';ref=35;alt=8;output;
run;
%n26_calculate_binomial_P(dsdin=v6261i,dsdout=v6261o,Allele1_var=ref,Allele2_var=alt,TotReadCutoff=3);
data v6261m(keep=metric value);set v6261o;length metric $120;array measured[*] tot_reads binomial_P logP Ref_Frq A1A2log2Ratio;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6261m;set v6261m;format value best32.;run;
proc export data=v6261m outfile="%sysfunc(pathname(work))/V6261.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6261;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6261:;quit;
