# Graficas Proy 1 Inteligencia

#########################
# Multicapa 1000

jpeg('data1000.jpg')
data1000azules <- read.table(file="datos_r6_n1000.txt_0", header= FALSE, sep=",")
data1000rojos <- read.table(file="datos_r6_n1000.txt_1", header= FALSE, sep=",")
plot(data1000azules[,1], data1000azules[,2], main="1000 Patrones", xlab="Eje X", ylab="Eje Y",col = "darkblue", col.main="blue", pch = 20, xlim= c(0, 20), ylim=c(0,20))
points(data1000rojos[,1], data1000rojos[,2], col = "red", pch = 20)

legend("topright", inset=.02, title="Tipos de puntos", c("En circulo","En cuadrado"),fill= c("blue", "red") , horiz=FALSE)

dev.off()

##################

# Multicapa 500

jpeg('data500.jpg')
data500azules <- read.table(file="datos_r6_n500.txt_0", header= FALSE, sep=",")
data500rojos <- read.table(file="datos_r6_n500.txt_1", header= FALSE, sep=",")
plot(data500azules[,1], data500azules[,2], main="500 Patrones", xlab="Eje X", ylab="Eje Y",col = "darkblue", col.main="blue", pch = 20, xlim= c(0, 20), ylim=c(0,20))
points(data500rojos[,1], data500rojos[,2], col = "red", pch = 20)

legend("topright", inset=.02, title="Tipos de puntos", c("En circulo","En cuadrado"),fill= c("blue", "red") , horiz=FALSE)

dev.off()
     
##################

# Multicapa 2000

jpeg('data2000.jpg')
data2000azules <- read.table(file="datos_r6_n2000.txt_0", header= FALSE, sep=",")
data2000rojos <- read.table(file="datos_r6_n2000.txt_1", header= FALSE, sep=",")
plot(data2000azules[,1], data2000azules[,2], main="2000 Patrones", xlab="Eje X", ylab="Eje Y",col = "darkblue", col.main="blue", pch = 20, xlim= c(0, 20), ylim=c(0,20))
points(data2000rojos[,1], data2000rojos[,2], col = "red", pch = 20)

legend("topright", inset=.02, title="Tipos de puntos", c("En circulo","En cuadrado"),fill= c("blue", "red") , horiz=FALSE)

dev.off()

##################

# Multicapa own 500

jpeg('dataown500.jpg')
data2000azules <- read.table(file="own_500_0", header= FALSE, sep=",")
data2000rojos <- read.table(file="own_500_1", header= FALSE, sep=",")
plot(data2000azules[,1], data2000azules[,2], main="500 Patrones", xlab="Eje X", ylab="Eje Y",col = "darkblue", col.main="blue", pch = 20, xlim= c(0, 20), ylim=c(0,20))
points(data2000rojos[,1], data2000rojos[,2], col = "red", pch = 20)

legend("topright", inset=.02, title="Tipos de puntos", c("En circulo","En cuadrado"),fill= c("blue", "red") , horiz=FALSE)

dev.off()

##################

# Multicapa own 2000

jpeg('dataown2000.jpg')
data2000azules <- read.table(file="own_2000_0", header= FALSE, sep=",")
data2000rojos <- read.table(file="own_2000_1", header= FALSE, sep=",")
plot(data2000azules[,1], data2000azules[,2], main="2000 Patrones", xlab="Eje X", ylab="Eje Y",col = "darkblue", col.main="blue", pch = 20, xlim= c(0, 20), ylim=c(0,20))
points(data2000rojos[,1], data2000rojos[,2], col = "red", pch = 20)

legend("topright", inset=.02, title="Tipos de puntos", c("En circulo","En cuadrado"),fill= c("blue", "red") , horiz=FALSE)

dev.off()

##################

# Multicapa own 1000

jpeg('dataown1000.jpg')
data2000azules <- read.table(file="own_1000_0", header= FALSE, sep=",")
data2000rojos <- read.table(file="own_1000_1", header= FALSE, sep=",")
plot(data2000azules[,1], data2000azules[,2], main="1000 Patrones", xlab="Eje X", ylab="Eje Y",col = "darkblue", col.main="blue", pch = 20, xlim= c(0, 20), ylim=c(0,20))
points(data2000rojos[,1], data2000rojos[,2], col = "red", pch = 20)

legend("topright", inset=.02, title="Tipos de puntos", c("En circulo","En cuadrado"),fill= c("blue", "red") , horiz=FALSE)

dev.off()

########### Pregunta 3

jpeg('bupa0.5.jpg')
dataB <- read.table(file="bupa_0.5", header= FALSE, sep=",")
plot(dataB[,1], dataB[,2], main="Bupa Data al 50%",xlab="Iteraciones", ylab="Error",col = "darkblue", col.main="blue", ylim=c(0, 2), xlim=c(0,1000), pch = 20)
lines(dataB[,1], dataB[,2], col="darkblue")

dev.off()

###########

jpeg('bupa0.6.jpg')
dataB <- read.table(file="bupa_0.6", header= FALSE, sep=",")
plot(dataB[,1], dataB[,2], main="Bupa Data al 60%",xlab="Iteraciones", ylab="Error",col = "darkblue", col.main="blue", ylim=c(0, 2), xlim=c(0,1000), pch = 20)
lines(dataB[,1], dataB[,2], col="darkblue")

dev.off()

###########

jpeg('bupa0.7.jpg')
dataB <- read.table(file="bupa_0.7", header= FALSE, sep=",")
plot(dataB[,1], dataB[,2], main="Bupa Data al 70%",xlab="Iteraciones", ylab="Error",col = "darkblue", col.main="blue", ylim=c(0, 2), xlim=c(0,1000), pch = 20)
lines(dataB[,1], dataB[,2], col="darkblue")

dev.off()

###########

jpeg('bupa0.8.jpg')
dataB <- read.table(file="bupa_0.8", header= FALSE, sep=",")
plot(dataB[,1], dataB[,2], main="Bupa Data al 80%",xlab="Iteraciones", ylab="Error",col = "darkblue", col.main="blue", ylim=c(0, 2), xlim=c(0,1000), pch = 20)
lines(dataB[,1], dataB[,2], col="darkblue")

dev.off()

###########

jpeg('bupa0.9.jpg')
dataB <- read.table(file="bupa_0.9", header= FALSE, sep=",")
plot(dataB[,1], dataB[,2], main="Bupa Data al 90%",xlab="Iteraciones", ylab="Error",col = "darkblue", col.main="blue", ylim=c(0, 2), xlim=c(0,1000), pch = 20)
lines(dataB[,1], dataB[,2], col="darkblue")

dev.off()


