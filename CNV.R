a = read.table("~/samp_with.txt",header=F)
pheno = read.delim("~/phenotypes.txt",sep='\t', header=T)

f = merge(a,pheno,by=1)
234
206

a = matrix(c(30,46*234/(234+206) ,16,46*206/(234+206)),nrow=2,ncol=2)
             
samps = as.data.frame(t(t(c("AT0549","AT0735"))))
merger = merge(samps, pheno,by=1)
chisq.test(t(a))
b = read.table("~/samp_with.txt",header=F)
t = merge(b,pheno,by=1)


library(VariantAnnotation)
vcf = readVcf("~/poly.vcf","hg19")
