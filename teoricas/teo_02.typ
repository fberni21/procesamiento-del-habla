= Teórica 2

== Producción del habla

#align(center)[
#box(rect(align(center)[Aire de los\ pulmones]), baseline: horizon)
#box(math.arrow.long, baseline: horizon)
#box(rect(align(center)[Laringe\ (glotis / cuerdas vocales)]), baseline: horizon)
#box(math.arrow.long, baseline: horizon)
#box(rect(align(center)[Faringe]), baseline: horizon)
#box(math.arrow.long, baseline: horizon)
#box(rect(align(center)[Cavidad\ nasal y bucal]), baseline: horizon)
#box(math.arrow.long, baseline: horizon)
#box(rect(align(center)[Micrófono]), baseline: horizon)
]

El mecanismo de la fonación ocurre en la laringe.

Se modeliza considerando al aire de los pulmones y la laringe como una fuente; al tracto vocal (faringe, nariz y boca) como un filtro variable en el tiempo.

El flujo de aire proviene de la subglotis, pasa por las cuerdas vocales, y cierra la glotis pues la velocidad aumenta en esa región bajando la presión (efecto Bernoulli).

=== Fuente

Tiene una frecuencia fundamental $F_0$, más sus armónicos múltiplos $m F_0$.

=== Filtro

Se consideran formantes $F_1, F_2, F_3, dots$, que son resonancias donde se amplifica la fuente.

=== Sonidos

- Sonoros: las vocales y algunas consonantes. Las cuerdas vocales vibran según una $F_0 in [80, 250] "Hz"$. La fuente es glótica o glotal.
- Sordos: la mayoría de las consonantes. Producción aperiódica. La fuente es no glótica y el aire es turbulento.

== Deseables para las características acústicas.

- No deben considerar los detalles de la fase.
- No deben considerar los detalles de $F_0$.
- Importa la información capturada sobre el tracto vocal.

== Modelo fuente-filtro

Excitación $e_c (t)$ pasa por un filtro $h_c (t)$ (el tracto vocal) y produce $x_c (t)$, la señal de habla observada. Matemáticamente
$ x_c (t) = (e_c ast h_c)(t) = integral_(-infinity)^(infinity) e_c (tau) h_c (t - tau) "d"tau. $

- Transformada de Fourier (DTFT):
$ E_c (Omega) = integral_(-infinity)^(infinity) e_c (t) e^(-j Omega t) "d"t arrow X_c (Omega) = E_c (Omega) H_c (Omega). $

Se define $Omega_0 = 2 pi F_0$, la frecuencia angular de la frecuencia fundamental de la fuente del hablante.

#figure(
  image("teo_02_g01.png"),
  caption: [Espectros típicos de la excitación $e_c (t)$ y del filtro $h_c (t)$]
) <fig:espectros>

Los espectros de $e_c (t)$ y $h_c (t)$ se muestran en la~@fig:espectros.
El espectro de $e_c (t)$ consiste de varias deltas en $Omega_0$ y sus armónicos $m Omega_0$.
El espectro de $h_c (t)$ consiste de varios picos suaves alrededor de las frecuencias de los diferentes formantes $Omega_k = 2 pi F_k, k = 1, 2, 3, dots$. Por ejemplo, para la letra "a" tenemos $F_1 = 750 "Hz"$, $F_2 = 1200 "Hz"$ y $F_3 = 2000 "Hz"$.

La idea es separar ambos espectros a partir de $x_c (t)$, pues lo interesante para entender el habla está en $H_c (Omega)$.

- Transformada de Fourier en tiempo discreto (DFT):
$ X_O (e^(j omega)) = E_O (e^(j omega)) H_O (e^(j omega)), $
con $omega in RR$, $[omega] = "rad"/"s"$, $pi lt.eq omega lt pi$, $omega = Omega / f_s$.

- Transformada discreta de Fourier:
$ E[k] = sum_(n=0)^(N-1) e^(-j omega_k n), $
con $omega_k = (2 pi k) / N$, con $k = 0, dots, N - 1$. Es decir, se tiene igual cantidad de muestras en frecuencia que en tiempo.

=== Modelo fuente-filtro sin ventaneo

$ X[k] = E[k] H[k], && " con " k = 0, dots, N-1. $

== Fonética acústica

Escribimos una palabra ejemplo "dedo".

- Su grafía es \<dedo\>.
- Su fonema es \/\'dedo\/.
- Su realización fonética (o simplemente fonética) es \[\'deðo\].

El apóstrofe indica el inicio de la sílaba tónica.

Las dos variantes del fonema \/d\/ se llaman variedades alofónicas. La \[d\] es oclusiva, mientras que la \[ð\] es aproximante (suave).

El fono es la realización fonética de un hablante en particular. Es lo que efectivamente se dice, en lugar de las abstracciones mostradas antes. Es, por ejemplo, la entrada a un ASR.

=== Fonema

Unidad mínima distintiva del sistema fonológico de una lengua.

==== Vocales

Son: \/a\/, \/e\/, \/i\/, \/o\/, /u\/.

#figure[
  #table(
    columns: 4,
    stroke: none,
    align: (center, center, center, left),
    [Vocal], [$F_1$ / Hz], [$F_2$ / Hz], [Nombre],
    table.hline(),
    [/i/], [300], [2300], [Cerrada anterior],
    [/e/], [450], [2100], [Media anterior],
    [/a/], [750], [1300], [Abierta central],
    [/o/], [500], [1000], [Media posterior],
    [/u/], [350], [800], [Cerrada posterior],
  )
]

$F_2$ tiene que ver con la anterioridad de la lengua, mientras que $F_1$ tiene que ver con el inverso de la altura de la lengua.

==== Consonantes

#figure[
  #table(
    columns: 2,
    stroke: none,
    align: left,
    [Grupo], [Fonemas],
    table.hline(),
    [Oclusivas], [\/p\/, \/t\/, /\k\/],
    [Obstruyentes sonoras\ o aproximantes], [\/b\/, \/d\/, /\g\/],
    [Africada], [\/t#math.integral\/],
    [Fricativas], [\/s\/, \/f\/, \/x\/, \/#math.integral\/],
    [Nasales], [\/m\/, \/n\/, \/\u{0272}\/],
    [Líquidas], [\/l\/, \/\u{027e}\/, \/ r \/],
  )
]

=== Sistema fonológico del español rioplatense

Cuenta con 22 fonemas, de los cuales 5 son vocales y 17 consonantes.

Se reduce la cantidad de fonemas respecto del español de España.

- Seseo: casa y caza son ambas \/\'kasa\/.
- Aspiración de la \/s\/: pasto es \['pahto\].
- Debilitamiento de las aproximantes: lago es \[\'la\u{0263}\o\], la vaca es \[la \'\u{03b2}\aka\].
- Asimilación de la \/n\/: un vaso es \[um \'baso\], un gato es \[u\u{014b} \'gato\].

== STFT y espectrograma

El habla  no es estacionaria en ningún sentido. Se realiza un ventaneo de la señal, donde se asume cuasi-estacionariedad dentro de cada pequeña ventana. Se muestrea con frecuencia $f_s$ (del orden de 16 kHz). El ventaneo se hace de a $L$ muestras (del orden de 400). Cada ventana tiene una duración del orden de 25 ms con valores típicos. Las ventanas se solapan, desplazándose de una a la siguiente una distancia $H_("hop")$ (por ejemplo 160 muestras). Sobre cada ventana, se hace una FFT de tamaño $N_("FFT")$, generalmente la siguiente potencia de 2 a $L$. (Agregar gráfico).

Estando dentro de un _frame_ $t in {1, dots, T}$, tenemos
$ x_t [n] = x[n + (t-1) H_("hop")] w[n], $
con $w[n]$ la ventana. La transformada FFT es
$ X[k,t] = sum_(n=0)^(L-1) x[n + (t-1) H_("hop")] w[n] e^(-j omega_k n), $
con $omega_k = (2 pi k) / N_("FFT")$, $k = 0, dots, N_("FFT") / 2$ (se descarta una mitad pues es simétrica para señales reales).

Lo que determina la resolución es $L$ y la ventana.

El paso en frecuencia es $Delta f_k = f_s / N_("FFT")$, pero esto _no_ es la resolución.

El espectrograma es un gráfico de $bar(X[k, t])^2$.

El tiempo de un dado frame es $t H_("hop") / f_s$, por lo que el paso de tiempo es $Delta "tiempo" = H_("hop") / f_s$.

Si $L$ es grande, tengo un espectrograma de banda angosta, que permite ver $F_0$ y sus armónicos.

Si $L$ es chico, tengo un espectrograma de banda ancha, que permite ver formantes y sonidos muy cortos.

(Agregar espectrograma de palabra "asa".)

// vim: lbr wrap
