#packages
library(knitr)
library(dplyr)
library(flextable)
library(magrittr)
library(kableExtra)
library(tidytext)
library(tidyverse)
library(plot.matrix)
library(stringr)
library(micropan)
library(ggpubr)
library(highcharter)
library(ggpubr)



token_in = read.csv('D:/jazz/Jazz_visual/csv/instrument.csv', header = TRUE)[1]
colnames(token_in)='word'
token_in = token_in$word
token_matrix_in = as.data.frame(matrix(data = 0, nrow = length(musicians), ncol = length(token_in)))
rownames(token_matrix_in) = musicians
colnames(token_matrix_in) = token_in

#token
for(tokens_i in token_in){
  for(mu_i in 1:length(musicians)){
    if(grepl(tokens_i, token_list[[mu_i]])==TRUE){
      token_matrix_in[mu_i, tokens_i]=1
    }
  }
}


ins = c()
for(i in token_in){
  ins = rbind(ins, i)
}

ins = as.data.frame(ins)
colnames(ins) = 'ins'
rownames(ins) = 1:23

print(as.matrix(ins))


#same instrument into one column
token_matrix_ins = token_matrix_in
col_pair = matrix(data = c(3,16,
                           4,12,
                           5,13,
                           6,15,
                           8,14,
                           9,11,
                           18,17), nrow = 7, ncol = 2, byrow = T)
col_pair = as.data.frame(col_pair)

for(i in 1:7){
  i1 = col_pair$V1[i]
  i2 = col_pair$V2[i]
  token_matrix_ins[,i1] = token_matrix_ins[,i1]+token_matrix_ins[,i2]
}

token_matrix_ins = token_matrix_ins%>%
  select(1:10, 18:23)



for(i in 1:236){
  for(j in 1:16){
    if(token_matrix_ins[i,j]>=2){
      token_matrix_ins[i,j] = 1
    }
  }
}





for(i in 1:236){
  sum_ins = sum(token_matrix_ins[i,])
  if(sum_ins==0){
    print(c(i,musicians[i]))
  }
}



token_matrix_ins = token_matrix_ins[c(-5,-65,-72,-107,-109,-182,-205,-219,-224),]


# Jaccard function
dis_jac = function(M){
  M = as.matrix(M)
  library("jaccard")
  n = nrow(M)
  # n*n matrix
  af_matrix = matrix(data = 1, nrow = n, ncol = n)
  for(i in 1:(n-1)){
    for(j in (i+1):n){
      jac = jaccard(M[i,],M[j,])
      af_matrix[i,j] = af_matrix[j,i] = jac
    }
  }
  return(as.data.frame(af_matrix))
}


ins_jac = as.data.frame(dis_jac(token_matrix_ins))
rownames(ins_jac) = colnames(ins_jac) = rownames(token_matrix_ins)


in_PCA = prcomp(ins_jac[,1:16], center = TRUE,scale. = TRUE)


summary(in_PCA)


ins_PC12 = cbind(in_PCA$x[,1], in_PCA$x[,2])
ins_PC12 = as.data.frame(ins_PC12)
colnames(ins_PC12)=c('J1', 'J2')


p = length(colnames(token_matrix_ins))

cor_coe = matrix(data = 0, nrow = p, ncol = 2)

for(j in 1:2){
  for(i in 1:p){
    cor_coe_val = cor(ins_PC12[,j], token_matrix_ins[,i])
    cor_coe[i,j] = cor_coe_val
  }
}



cor_coe = as.data.frame(cor_coe)
colnames(cor_coe) = colnames(ins_PC12)
rownames(cor_coe) = colnames(token_matrix_ins)


inst = colnames(token_matrix_ins)
tm_ins_j1 = as.data.frame(cbind(token_matrix_ins, ins_PC12$J1))
colnames(tm_ins_j1)[17] = 'J1'
tm_ins_j2 = as.data.frame(cbind(token_matrix_ins, ins_PC12$J2))
colnames(tm_ins_j2)[17] = 'J2'


J1_lm = lm(J1 ~. , data = tm_ins_j1)
J2_lm = lm(J2 ~. , data = tm_ins_j2)



summary(J1_lm)
