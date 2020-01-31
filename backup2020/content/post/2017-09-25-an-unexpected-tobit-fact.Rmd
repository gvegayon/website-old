---
title: An Unexpected Tobit Fact
author: George G. Vega Yon
date: '2017-09-25'
slug: an-unexpected-tobit-fact
categories:
  - Stats
tags:
  - regression
  - aer
summary: "Today I figured out a somewhat interesting property of the Tobit model. While models such as $y = f(X, g(y))$ are usually wrong under iid, here I present an interesting example in which running such models makes no difference in the context of tobit regressions. While this has no use in practical scenarios, it does when it comes to have a better understanding of this meethod."
draft: true
math: true
---

```{r, echo=FALSE}
knitr::opts_chunk$set(cache = TRUE)
```

Hoy recibí un correo inesperado de mi jefe aca en USC quejándose (preguntándome mas bien) que por qué algunos pares de especificaciones Tobit eran idénticas. Mi primera impresión fue "seguro R guardó la misma tabla con nombre distinto... ups!", algo que podía ser posible pues, además de que soy humano, el proceso para correr los modelos lo había automatizado pues en total son 270 especificaciones... no iba a escribir una por una!

Al volver a correr un par de modelos de manera "manual", me di cuenta que efectivamente los resultados eran idénticos, algo que no esperaba. Cuáles eran las especifaciones?

\begin{align*}
y & = X\beta + \varepsilon,\quad \mbox{if }y_{miss} \neq 0\tag{1} \\
y & = X\beta + y_{miss} + \varepsilon \tag{2}
\end{align*}

Donde y_miss es una dummy igual a 0 si es que y es missing. En otras palabras, el primer modelo excluye aquellas observaciones en las cuales y es missing, y el segundo las incluye assumiendo que son iguales a 0, pero además agrega una dummy indicando cuando tal supuesto se aplicó. Se que están pensando que el modelo es endógeno y todo eso (no me miren feo), pero solo lo corrí para complacer a mi jefe y ver que pasaba :). Obviamente no incluiremos ese modelo en nuestro paper!

Para estar seguro de lo que estaba haciendo, decidí hacer una simulación con datos similares, una variable y truncada en < 0 y aleatoriamente agregando zeros en y para simular la imputación que hicimos en nuestros datos. Sorprendentemente, ambas especificaciones resultaron en lo mismo!

Acá va el codigo:

```{r}
rm(list = ls())
library(AER)

# Seeds and parameters
set.seed(1123)
N <- 1e3
K <- 4

# Data Generating Proccess
a     <- 5
b     <- cbind(runif(K, -1,1))
X     <- matrix(rnorm(N*K), ncol = K)
y        <- a + X %*% b + rnorm(N)
y[y < 0] <- 0

# The zero dummy
zero_dummy <- cbind(runif(N)>.9) # 10% of non-reporting
y[zero_dummy] <- 0

# Running the specifications
summary(tobit(y~ X, subset = !zero_dummy))
summary(tobit(y~ X + zero_dummy))
```


Luego de darle algunas vueltas, me di cuenta que lo que pasaba era los siguiente: En el modelo 1, MLE hace su trabajo, estima los parametros y ya. En el segundo modelo, cuando agregamos las observaciones con y=0 por supuesto junto con la dummy zero_dummy, lo unico que cambia de la función de Máxima Verosimilitud es el componente Probit (pues solo estamos agregando ceros), el componente OLS se mantiene igual pues zero_dummy = 0 en esa parte de la función. Luego, en la parte Tobit, y aquí es donde no estoy tan seguro como explicar esto con matemática, el MLE estima el modelo y, dado que zero_dummy predice a la parfección ceros cuando es igual a 1, asigna un valor grande a su coeficiente, haciendo que al final del día las observaciones adicionales no agreguen información al modelo, lo que termina en obtener el mismo set de estimadores.
