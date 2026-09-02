#let idft = math.op("IDFT")
#let mel = math.op("mel")

= Teórica 3

== Repaso

- Computamos STFT: $X[k, t]$.
- Espectrograma: $S[k, t] = bar(X[k, t])^2$, con $k=0,dots,N_"FFT"/2$, $t = 1,dots,T$.
- Modelo fuente-filtro: $X[k,t] = underbrace(E[k,t], "fuente") underbrace(H[k,t], "envolvente\n espectral")$.

== Separación de la fuente y el filtro

Para un frame $t$ fijo, un espectrograma representa el espectro de potencia.
El problema es que están mezclados el espectro de la fuente y la envolvente espectral.

El objetivo es poder finalmente generar los features acústicos a partir de las muestras de un frame.
$ x_t [n] arrow.long underline(y)_t in RR^D. $

== Cepstrum

Todo este desarrollo es para un dado frame $t in {1,dots,T}$.
Tomo magnitud del modelo fuente-filtro y aplico logaritmo:
$ log(bar(X[k])) = log(bar(E[k])) + log(bar(H[k])). $
+ Se redujo el rango dinámico por el logaritmo.
+ Se acerca al comportamiento del oído humano (comportamiento cuasi-logarítmico).
+ Un factor de escala en la fuente se convierte en un _offset_ sumando (mejor tratamiento de la señal).


#figure(
  image("teo_03_g01.png"),
  caption: [Ejemplo de espectro y log-espectro de una vocal, donde se observan picos en $F_0$ y sus armónicos, modulados por la envolvente espectral del tracto vocal.]
) <fig:g01>

Los gráficos de la @fig:g01 son en función de la frecuencia correspondiente al $k$-ésimo bin de frecuencia, $f_k = k f_s / N_"FFT"$.
La diferencia en frecuencia entre dos picos es $F_0$.
La variabilidad de la fuente es mucho mayor que la de la envolvente.

El $X_"ref"$ se elige tal que el logaritmo nunca sea mayor que cero (el cociente nunca mayor a uno).
Se agrega un $epsilon$ pequeño, por temas numéricos ($log(bar(frac(X[k],X_"ref", style: "horizontal") + epsilon))$, que evita $log(0)$).
Se mantiene la periodicidad en $f_k$ relacionado a $F_0$.

*Definición*: Cepstrum.
$ c[n] = idft{ log(bar(X[k] + epsilon)) }, $
con $n = 0, dots, N_"FFT"-1$.

El $n$ se denomina _índice de quefrencia_. La _quefrencia física_ asociada a $n$ es $n / f_s$, medida en inverso de frecuencia (o sea, tiempo)
La envolvente suave está asociada a _quefrencias_ bajas, mientras que la fuente se presenta como un pico alrededor de $1/F_0$.
Observar que para una señal $x[n]$ real, existe simetría en $bar(X[k])$, y entonces el _cepstrum_ es real.

(Agregar gráfico de $c_n [n] ~ n/f_s$.)

*Definición*: Liftering.
Sea $l[n]$ una ventana en el dominio _cepstral_. Un _lifter_ pasabajos es:
$ l_"PB" [n] = bb(1){n lt.eq n_c}. $

Se forma una señal _cepstral_ filtrada como
$ c{l[n]} = l_"PB" [n] c[n], $
que permite reconstruir el filtro del modelo fuente-filtro.

== MFCC (Mel-Frequency Cepstral Coefficients)

Los llamaremos coeficientes de mel.

#align(center)[
#box(rect(align(center)[$x_t [n]$]), baseline: horizon)
#box($arrow.long$, baseline: horizon)
#box(rect(align(center)[$X[k,t]$]), baseline: horizon)
#box($arrow.long^(|dot.c|^2)$, baseline: horizon)
#box(rect(align(center)[$S[k,t]$]), baseline: horizon)
#box($arrow.long^("mel")$, baseline: horizon)
#box(rect(align(center)[$E_m [t]$]), baseline: horizon)
#box($arrow.long^(log)$, baseline: horizon)
#box(rect(align(center)[$tilde(E)_m [t]$]), baseline: horizon)
#box($arrow.long^("DCT")$, baseline: horizon)
#box(rect(align(center)[$c_d [t]$]), baseline: horizon)
]

Notar que es similar al _cepstrum_, pero acá no hay transformada inversa, sino una STFT y luego una DCT.

=== Pre-énfasis

A la señal original se le aplica un paso (opcional) de pre-énfasis.

Hay un descenso de $2 "dB"/"octava"$ en las altas frecuencias que generan las fricativas. El pre-énfasis busca compensar este efecto. El pre-énfasis se calcula como
$ x_"PE" [n] = x[n] - alpha x[n-1], $
donde $alpha in [0.95, 0.97]$.
Es un filtro pasa altos donde
$ H_"PE" (e^(j omega)) = 1 - alpha e^(-j omega). $
Para frecuencias bajas (cercanas a $0$) atenúa con $1-alpha$, mientras que amplifica con $1+alpha$ para frecuencias altas (cercanas a $pi$).

=== Banco de filtros de mel

Con el espectro $S[k,t]$ para $k=0,dots,N_"FFT"/2$, $t = 1,dots,T$, las frecuencias son $f_k = k f_s / N_"FFT"$.
La resolución en frecuencia es mala para bajas frecuencias, por lo que el banco de filtros buscará compensar esto.

La conversión a mel desde las frecuencias es
$ mel(f) = 2595 log_(10) (1 + f / 100), $
para $f$ expresada en Hz.

#figure(
  image("teo_03_g02.png"),
  caption: [Ejemplo de banco de filtros de mel (#link("https://www.researchgate.net/figure/Triangular-filter-bank_fig3_318412739")[de ResearchGate]).]
) <fig:g02>

Se convierten los extremos del rango de frecuencias de trabajo a mel, y se divide ese rango en puntos equidistantes en mel.
En el gráfico de la @fig:g02, esos puntos equidistantes en mel se convierten a frecuencia, convirtiéndose en los puntos no equidistantes que se observan. Hay $M$ filtros, con valores típicos de 26 en ASR, y 40 en deep learning.

=== Energías de la banda de mel

Para cada frame $t$, se filtra el espectrograma con cada uno de los $M$ filtros de mel, obteniendo
$ E_m [t] = sum_(k=0)^(N_"FFT"/2) B_m [k] S[k,t], $
para $m = 1,dots,M$.
Cada filtro es un detector de energías que trabaja sobre diferentes bandas, con mayor resolución en las bajas frecuencias.
Como $M lt N_"FFT"/2$, esto reduce la dimensión.

(Agregar gráfico de $E_m [t] ~ m$.)

Luego, se toma logaritmo para obtener $tilde(E)_m [t] = log(E_m [t] + epsilon)$, con todas las ventajas de usar logaritmos.

== DCT (Discrete Cosine Transform)

La entrada de la DCT es un vector $underline(tilde(E))_t = vec(tilde(E)_1 [t] space dots.c space tilde(E)_M [t])^T$.
Definimos $phi_d [m] = cos(pi d (2 m - 1) / (2 M))$, con $d$ el _índice cepstral_.

*Definición:* DCT.
$ c_d [t] = sum_(m=1)^M tilde(E)_m [t] phi_d [m] = <underline(tilde(E))_t, underline(phi)_d>, $
que define un producto interno. El índice cepstral es $d = 0, dots, c-1$.

Lo que indica cada componente es qué tan parecido es la energía de una banda de mel a un coseno de índice cepstral $d$. Es similar a calcular los coeficientes de Fourier. Cada coeficiente tiene información sobre qué tan suave es el cambio entre la salida de un filtro de mel, y el siguiente. Si el cambio es abrupto, responderán los cosenos con $d$ alto, mientras que si es suave lo harán aquellos con $d$ bajo.

La elección de los cosenos es para obtener resultados suaves, puesto que el coseno es suave.
Recordar que los filtros se superponen, por lo que hay correlación entre las bandas de energía. Aplicar la transformada de coseno descorrelaciona las muestras.

=== Rango del índice cepstral

+ Podría tomarse todo el rango: $C = M$.
+ Típicamente se toma $C = 13$. Esto se denomina truncamiento de los coeficientes de mel.

El truncamiento de los MFCC es similar al liftering pasabajos que se hacía en el cepstrum para mantener las quefrencias bajas. Se eliminan las componentes de alta frecuencia.

== Deltas

Sea un índice cepstral $d$. Analizamos frames sucesivos $c_d [t-2], c_d [t-1], c_d [t], c_d [t+1], c_d [t+2]$.
Definimos los deltas como
$ Delta c_d [t] = (sum_(tau=1)^2 tau [c_d [t+tau] - c_d [t-tau]]) / (2 sum_(tau=1)^2 tau^2). $
Son 13 deltas por cada frame.

Si un delta es positivo para un dado $d$, a medida que avanzan los frames la energía se parece cada vez más al coseno asociado a ese índice cepstral a partir del frame $t$.

== Delta-deltas

Definimos los delta-deltas como aplicar la operación delta, a los deltas antes definidos:
$ Delta^2 c_d [t] = Delta(Delta c_d [t]). $

== Vector de características

Definimos el vector de características como
$ underline(y)_t = vec(c_0 [t] space dots.c space c_12 [t] space.quad Delta c_0 [t] space dots.c space Delta c_12 [t] space.quad Delta^2 c_0 [t] space dots.c space Delta^2 c_12 [t])^T in RR^D, $
con $D = 39$.

Observar que $c_0 [t] = sum_(m=1)^M tilde(E)_m [t]$ da la energía total del banco de filtros de mel. Es el menos útil de los coeficientes pues es un factor de escala.

Cuando se trabaja con redes neuronales, generalmente el vector de características de la entrada suelen ser las log-energías, sin usar la DCT.

// vim: lbr wrap
