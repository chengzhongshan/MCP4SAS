/* Test-only namespaced definition from additive_geno2alleles.sas; original SHA256 cd15486e4d38ce879e5ba21cd397979a2f84a9a48102b90515a738b0eb460fc8. */
%macro n26_additive_geno2alleles(
indsd=,/*Input sas dataset containing additive genotypes, such as 0, 1, and 2*/
snp_varnames=,	 /*The order of snp varnames will be used to generate allelic columns in the same order*/
othervars2keep= ,/*Other potential pheno or covariant vars to be kept*/
sample_id=,/*varname for sample id*/
outdsd= /*output a sas dataset containing allelic columns for these snp varnames in the same order*/
);

%let keep=&snp_varnames;
%let id=id;
%let num=%n26_ntokens(&snp_varnames);
%let tot=%eval(2*&num);

*It is confirmed that the array function will not automatically sort the snp names in the array function;
*Thus, there is no need to use the macro var snpidx4list;

      data &outdsd (keep=&id m1-m&tot &othervars2keep);
			*Keep these columns at the beginning of the table;
			retain &id &othervars2keep;

			*For debugging;
      /*data &outdsd (keep=&id snp1-snp&num m1-m&tot); */
     /*        B (drop=snp1-snp&num m1-m&tot);*/

        set &indsd;
        array snps{&num} &keep;
        array snpname{&num} snp1 - snp&num; /* this for renaming the snps */
        array ms{&tot} $1. m1 - m&tot;
				xi=1; 
        do i= 1 to dim(snps);
          snpname{xi}=snps{i};
          j =2*xi-1;
          k =2*xi;   
          if snps{i} =0 then do;
             ms{j}="0";
             ms{k}="0";
          end;
          else if snps{i}=1 then do;
            ms{j}="0";
            ms{k}="1";
          end;
          else if snps{i}=2 then do;
            ms{k}="1";
            ms{j}="1";
          end;
          else do;
            ms{k}=" ";
            ms{j}=" ";
          end;

          if snps{i} in (99, .) then snpname{i}=.;

					xi=xi+1;
        end;

        /* only keep the obs that are needed for proc haplotype */
        if sum(of snp1 - snp&num)=. then delete;
     run;


%mend;
