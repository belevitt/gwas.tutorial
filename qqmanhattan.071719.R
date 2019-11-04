rm(list=ls())


#################################################################################################3#####
#######################################################################################################
#######################################################################################################

#only change these variables
outcome = 'bmi'
path = '/ifs/sec/cpc/addhealth/users/adamg93/res/'

#################################################################################################3#####
#######################################################################################################
#######################################################################################################

suppressPackageStartupMessages(c(library(data.table),library(tidyverse),library(png),library(qqman)))

combined = data.frame(matrix(ncol=6,nrow=0))
variables = c('CHROM','POS','VCF_ID','ALT_AF','N_INFORMATIVE','PVALUE')
names(combined)=variables

r2 = fread('/ifs/sec/cpc/addhealth/users/belevitt/fresh/bmi/individuallyreviewed/res/correctedint2/allrmr2_3.txt') %>%
  filter(V2>=0.4) %>%
  rename(VCF_ID=V1) %>%
  rename(R2=V2) %>%
  mutate(VCF_ID = as.character(VCF_ID))

for (i in 1:22) {
  combined=data.frame(fread(paste0(path,outcome,'/rawfiles/',outcome,'.chr',i,'RM.wald.out'))) %>%
    na.omit() %>%
    select(CHROM,POS,VCF_ID,ALT_AF,N_INFORMATIVE,PVALUE) %>%
    filter(ALT_AF>=0.01) %>%
    mutate(VCF_ID=as.character(VCF_ID)) %>%
    rbind(combined) 
}

combined = combined %>%
  left_join(r2,by='VCF_ID') %>%
  mutate(effn=2*(ALT_AF)*(1-ALT_AF)*(R2)*(N_INFORMATIVE)) %>%
  filter(effn>=30) %>%
  select(VCF_ID,CHROM,POS,PVALUE) %>%
  rename(SNP=VCF_ID) %>%
  rename(CHR=CHROM) %>%
  rename(BP=POS) %>%
  rename(P=PVALUE)

rm(r2,i,variables)

write.table(combined,'results',row.names=F,quote=F,sep='\t')

png("qq.png",width=1600,height=800)
qq(combined$P,pch=18,col='blue4',cex=1.5,las=1)

png("manhattan.png",width=1600,height=800)
manhattan(combined,col = c("blue4", "orange3"),cex=.6,suggestiveline=T)

dev.off()

z1 = qnorm(combined$P/2)
lambda1 = round(median(z1^2)/.454,3)
lambda1
