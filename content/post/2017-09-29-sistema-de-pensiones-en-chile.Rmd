---
title: Sistema de Pensiones en Chile
author: George G. Vega Yon
date: '2017-09-29'
slug: sistema-de-pensiones-en-chile
categories:
  - Policy
  - Econ
  - Stats
tags:
  - simulations
  - rstats
summary: "Hola mundo"
math: true
html_document:
  code_folding: show
  code_download: true
draft: true
---

```{r setup, echo=FALSE}
knitr::opts_chunk$set(echo=FALSE, message=FALSE, cache=TRUE)
```

Con todo el tema del plebiscito anti AFP (porque no es más que eso), y varios correos que he recibido en los últimos años con personas preguntándome acerca de como funciona el sistema de pensiones (que me parece genial!), me decidí a escribir este pequeño post con algunas de las ideas que tengo al respecto. Y qué mejor forma que partir por los mitos sobre el sistema!

## Mitos sobre el sistema de pensiones

http://www.latercera.com/noticia/mitos-y-verdades-del-sistema-de-pensiones-chileno/

http://www.quepasa.cl/articulo/negocios/2017/08/mitos-leyendas-y-pensiones-parte-i.shtml/

http://www.pulso.cl/empresas-mercados/los-ocho-mitos-y-realidades-del-sistema-de-pensiones-chileno/

http://www.uchile.cl/noticias/125298/no--afp-mitos-y-realidades

https://www.aafp.cl/mitos-y-realidades-de-los-sistemas-de-pensiones/

http://www.elmercurio.com/Inversiones/Noticias/Pensiones/2015/11/19/Mitos-y-realidades-del-sistema-de-pensiones.aspx

https://www8.gsb.columbia.edu/faculty/jstiglitz/sites/jstiglitz/files/2001_Rethinking_Pension_Reform_Ten_Myths.pdf

El problema es que hay muchos mitos y los "líderes" son los que los difunden. Aquí van algunos:

1.  __Te calculan la pension hasta los 110 años!__ Falso! Cuando se calcula el monto de pension por retiro programado (la modalidad mas comun), se utilizan lo que se conocen como tablas de mortalidad. En ellas se considera la posibilidad (que es diferente a certeza) de sobrevivir hasta los 110 años. De no usar esas tablas la alternativa seria, por ejemplo, calcular pago de pensiones hasta los 85 años (que es mas menos la edad de sobrevida promedio del hombre en Chile), y que pasa si pasas los 85, 90 años? Eso es lo que se trata de evitar.

2.  __Las AFP se estan haciendo ricas con mi plata!__ Falso. Las AFP cobran comision por contribución, lo que quiere decir que te cobran por cada aporte que tu haces, en otras palabras, las AFPs NO TOCAN TU FONDO DE PENSION. Hoy las comisiones van de 0.41% (Planvital) a 1.5% (Cuprum)... Si quieres que las AFP no ganen tanto, entonces cambiate a una que cobre poco...

3.  __Trabaje toda mi vida y me pagan una $\#\#$?% de pensión! Obviamente la culpa es del sistema!__ Lamentablemente no es así. Luego de cientos de estudios científicos muy complejos, los expertos llegaron a increíble conclusión de que para gastar más mañana hay que ahorrar más hoy. Si hay algo que se debería cambiar en el sistema, es que la tasa de contribución deberia de ser de al menos 15% y sin tope. Hoy es de 10%.

4.  __Mi [[elija un familiar]] trabajó toda su vida, se jubiló y ahora gana mucho menos de la mitad!__ Tiene que ver con lo anterior. Resulta que muchas personas que se están jubilando con el "sistema nuevo" se vieron perjudicadas por faltas por parte de sus empleadores. Muchas personas o cotizaron por el mínimo (que equivale a decir que cotizaron por menos del 10%), o de frentón llegaron a arreglos con sus empleadores donde les pagaron "retroactivamente" las cotizaciones. El problema es el siguiente, las cotizaciones más importantes son las de los primeros años. Al momento de acercarse a la edad de jubilación, lo único que queda es aportar más dinero en grandes cantidades, pero si nunca ahorraste cuando joven, no puedes esperar tener una pensión similar a la de tus últimos años trabajando.

5.  __El estado manejaría mejor la plata__ Aun que lo dudo, puede ser. Pero de todas formas, como ya he dicho antes, la clave está en aumentar la tasa de ahorro. Aún cuando tengas al mejor administrador de fondos (ya sea estatal o privado), nada cambiará si la tasa de ahorro no cambia.

Al final del día, si bien el sistema no es perfecto, lo unique que si es seguro es que volver a un sistema de reparto no es solución. En mi opinión, los sistemas mixtos (que de hecho es lo que tenemos en Chile hoy) son la solución, y quizás dar más opciones de ahorro a la gente. Pero al final del día, la clave está en ahorrar más. Si no ahorramos lo suficiente, el sistema en el que se administre nuestro dinero da lo mismo...

## Simulando política

Para entender de mejor manera el problema, a continuación presento un set de simulaciones sencillas donde varío dos parámetros del sistema de pensiones: La tasa de contribución, y el año de retiro. Antes de continuar es importante notar que estas simulaciones se realizan bajo los siguientes supuestos:

1.  No hay lagunas, en otras palabras, el trabajador nunca está desempleado

2.  Sólo existe un fondo, por lo tanto no hablaré de los tipos de fondos en que se invierte el dinero.

3.  Al momento del retiro, el cálculo de la pensión se hace assumiendo que la persona es soltera.

Las siguientes equaciones describen el modelo de simulación:

$$
\begin{aligned}
I_1 &= 300 \\
I_t &= I_{t-1}\times\left(1 + \frac{r_I}{\log(t)}\right), \quad t>1\mbox{ y }r_I\sim N(0.02, 0.02)\\
C_t &= 12I_{t}\times a\\
S_t & = (S_{t-1} + C_t)\times(1 + R_t),\quad R_t\sim N(.04, .1)
\end{aligned}
$$

Donde $I_t$ es el nivel de ingreso (remuneración) en el año $t$, $r_t$ es la tasa de crecimiento anual del ingreso en el año $t$, $S_t$ es el saldo del fondo de capitalización individual en el año $t$, $C_t$ es el monto anual de contribución en el año $t$, y $a$ es la tasa de contribución mensual.

```{r}

library(magrittr)

set.seed(1231)

# Parametros
edad0 <- 30
edadN <- 67
Nsim  <- 1e4

# Ingreso
tasa_crecimiento_renta_prom <- 0.2
tasa_crecimiento_renta_sd   <- 0.2
renta0 <- 300

# Edades de retiro
tasas_de_cotizacion <- c(.07, .1, .15) 
edades <- as.character(c(60, 63, 65, 67))

# CNUs aproximados... 
cnus <- c(14.87, 13.83, 13.11, 12.36)
```

```{r Simulando-renta, echo=FALSE}
# Funcion para simular la trayectoria de ingresos anuales
sim_ingresos <- function(...) {
  
  lapply(1:Nsim, function(i) {
    ingresos <- rnorm(edadN - edad0, tasa_crecimiento_renta_prom, tasa_crecimiento_renta_sd)
    c(renta0, renta0*cumprod(1 + ingresos/(2:(edadN-edad0 + 1))))
  }) %>% do.call(rbind, .) %>%
  `colnames<-`(., edad0:edadN)
}

# Como se ven los ingresos
set.seed(1)
ingresos <- sim_ingresos()

boxplot(ingresos, xlab="Edad", ylab="Ingreso (Miles de CLP$)", outline=FALSE,
        main = "Trayectorias de Ingresos Simuladas")
```

```{r Simulando-Rentabilidad, echo=FALSE, results='asis'}

# Leyendo datos: Tres primeras columnas no seran usadas
rent <- readr::read_tsv("rentabilidad_anual_historica.tsv", TRUE)[,-c(1:3)] %>%
  as.matrix %>% t %>% rowMeans

rent <- rent/100
rent <- c(mean(rent), sd(rent))
rent <- c(.04, .1)
# Como se ve en promedio
sim_retornos <- function(...) {
  rnorm((edadN - edad0 + 1)*Nsim, rent[1], rent[2]) %>% 
    matrix(ncol=edadN-edad0 + 1, dimnames = list(NULL,edad0:edadN))
}

set.seed(1)
retornos <- sim_retornos()

library(xtable)
quantile(retornos*100, probs = c(.025, .1, .5, .9, .975)) %>%
  as.matrix %>% t %>% 
  xtable(caption="Distribución de Rentabilidad Anual simulada (en %)") %>%
  print(digits=2, type="html", include.rownames = FALSE)
```

```{r Juntando-Todo, echo=FALSE}

# Simulando tasas de reemplazo por tasa de cotizacion
resultados <- vector("list", length(tasas_de_cotizacion))
names(resultados) <- tasas_de_cotizacion

for (tcot in tasas_de_cotizacion) {
  
  # Calculando cotizaciones anuales
  cotizaciones <- ingresos*12*tcot

  # Rentabilidad
  saldo <- cotizaciones
  saldo[,1] <- saldo[,1]*(1 + retornos[,1])
  for (t in 2:ncol(cotizaciones))
    saldo[,t] <- (saldo[,t-1] + cotizaciones[,t])*(1 + retornos[,t])

  # Distribucion de tasa de reemplazo
  resultados[[as.character(tcot)]] <- lapply(seq_along(edades), function(i) {
    
    # Tasa de reemplazo
    tasa_de_reemplazo <- saldo/(12*cnus[i])/ingresos*100
    
    quantile(tasa_de_reemplazo[,edades[i]], probs = c(.025,.1, .5, .9 ,.975))
  }) %>%
    do.call(rbind, .) %>% `rownames<-`(., edades)
  
}


```

```{r Reporte, echo=FALSE, results='asis'}
for (r in names(resultados))
  print(xtable::xtable(
    resultados[[r]], digits=2,
    caption = sprintf("Distribución de tasas de reemplazo fijando tasa de cotizacion en %.0f%%. Filas representan edad de retiro y columnas percentil.", as.numeric(r)*100)),
    type="html")
```



