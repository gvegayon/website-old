################################################################################
# GRAFICOS CLASE 1 COMPLEJIDAD FISICA Y MATEMATICA
# "Caos Determinista"
# date: 12 marzo 2013
# auto: George Vega Yon
# desc: Genera los graficos de modelos revisados en clases. En particular
#  el modelo de crecimiento poblacional
################################################################################
setwd("~")
# (1) DEFINICION DE FUNCIONES
# Funcion de crecimiento poblacional
caos <- function(mu=1.5, x0 = .2, tiempo = 1:100, plotit=FALSE) {
  
  # Crea vector vacio del largo del tiempo
  x <- double(length(tiempo))
  
  # Asigna primer elemento
  x[1] <- x0
  
  # Asigna el resto
  for (i in 2:max(tiempo)) {
    x[i] <- mu*x[i-1]*(1-x[i-1])
  }
  
  # Resultado
  if (plotit) { # Si desea graficar
    plot(x~tiempo, type="l", xlab="Tiempo", ylab="x(t)", 
         sub=paste("mu=",mu,", x0=",x0), main="Modelo Poblacional")
  }
  else return(x) # Caso contrario
}

# Funcion para generar superficie
caos3d <- function(mus=seq(1,3.9,.025), plotit3d=FALSE, x0=.2, zlim=c(0,1)) {
  
  datos <- caos(mu=mus[1], tiempo=1:length(mus), x0=x0)
  for (j in 2:length(mus)) { # Genera matriz con el resto de los mu
    datos <- cbind(datos, caos(mu=mus[j], tiempo=1:length(mus), x0=x0))
  }
  
  # Resultado
  resultado <- list(tiempo=1:length(mus), mu=mus, x=datos)
  
  if (plotit3d) {
    if (!exists("x0")) x0 = .2
    open3d(windowRect=c(700, 100, 1100, 500), userMatrix=rotationMatrix(-1.2, 1,.5,1))
    persp3d(x=resultado$tiempo,y=resultado$mu, z=resultado$x, color="lightblue", 
            main=sprintf("x0=%.3f",x0), zlim=zlim, alpha=.8,
            xlab="tiempo", ylab="mu", zlab="x(t)", cex=10)
  } else return(datos)
}

################################################################################
# (2) GRAFICOS 2D
caos(mu=3.2,plotit=T)

# Graficando x[t] ~ x[t-1]
x_t <- caos(mu=4, x0=.2)
x_t_1 <- x_t[-1] # x(t+1)
x_t <- x_t[-length(x_t)] # x(t)
plot(x_t_1~x_t, type="l", sub=paste("mu=",4, "x0=",.3), ylab="x(t+1)", xlab="x(t)")
abline(a=0,b=1)


################################################################################
# (3) GRAFICOS 3D

# Cargando paquete
library(rgl)

# Crea secuencia de mu's y genera primera ronda de numeros (primer mu)
caos3d(plotit3d=T)

# Si deseas hacer girar el grafico por 5 segundos
play3d(spin3d(axis=c(0,0,1), rpm=5), duration=8)
rgl.close() # Cierra dev

# Cierra espacio grafico
#rgl.close()

# (4) EXTRA : ARMAR UNA ANIMACION GIF USANDO ImagMagick
#for (i in 1:length(x0s<-seq(.2,1,.0025))) {
#  caos3d(mus=seq(1,3.9,.025), plotit3d=TRUE, x0=x0s[i])
#  Sys.sleep(.5)
#  play3d(spin3d(axis=c(0,0,1), rpm=-.5*i), duration=0.1)
#  Sys.sleep(.5)
#  rgl.snapshot(sprintf("snapshot%03.f.png",i), fmt="png")
#  rgl.close()
#}

#convert <- "convert -delay 1x%d %s*.png %s.%s"
#system(sprintf(convert, 30, "snapshot", "animacion", "gif"))
     
for (i in 1:length(x0s)) file.remove(sprintf("snapshot%03.f.png", i))

