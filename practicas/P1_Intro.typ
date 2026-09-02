#set enum(numbering: "(a)")

= Práctica 1

== Ejercicio 1. Discriminación espectral de dos senoides

Sea la señal continua $x_c (t) = A cos(2 pi f_1 t) + B cos(2 pi f_2 t)$, con $f_1 = 100 "Hz"$, $f_2 = 200 "Hz"$, $A = B = 1$, muestreada a $f_s = 500 "Hz"$ para obtener $x[n] = x_c (n T_s)$.

#enum(
enum.item()[
  Calcular analíticamente el espectro $X_c (Omega)$ de $x_c (t)$ y el espectro $X(omega)$ de $x[n]$ para $f_s$ mayor a la frecuencia de Nyquist.

  _Solución:_

  $ X_c (Omega) = pi [delta(Omega - 200 pi) + delta(Omega + 200 pi) + delta(Omega - 400 pi) + delta(Omega + 400 pi)]. $
  $ X (omega) = pi sum_(l in ZZ) [delta(omega - 0.4 pi - 2 pi l) + delta(Omega + 200 pi  - 2 pi l) + delta(Omega - 0.8 pi - 2 pi l) + delta(Omega + 0.8 pi - 2 pi l)]. $
],
enum.item()[
  Tomando una ventana temporal $x_t [n]$ de duración $L$ muestras, determinar el menor $L$ y el menor
  $N_"FFT"$ que hacen evidente la presencia de las dos senoidales en el espectro discreto. Justificar
  usando la respuesta en frecuencia de la ventana rectangular.

  _Solución_:

  $ x_t [n] = x[n] w_L [n], && w_L [n] = bb(1){0 lt.eq n lt L}. $
  $ W_L (omega) = e^(-j (L-1)/2) sin(L omega/2) / sin(omega/2). $

  El lóbulo principal va entre $plus.minus 2 pi /L$. La transformada de $x_t[n]$ es la convolución entre la sinc periódica de la ventana y las deltas de $x[n]$.
  Se montan las copias unas sobre otras, por lo que el lóbulo principal debe ser lo suficientemente angosto para que no se superpongan las copias sobre $0.4 pi$ y $0.8 pi$.
  En particular, se busca que haya medio lóbulo de distancia entre las deltas (el máximo de uno coincida con el mínimo del otro), o sea
  $ 0.4 pi = 2 pi / L_min therefore L_min = 5. $

  Otra forma:

  $ Delta f = f_2 - f_1 = 100 "Hz". $
  Por el criterio de Rayleigh, la cantidad de puntos es
  $ L_min = f_s / (Delta f) = f_s / (f_2 - f_1) = 5. $

  Para $N_"FFT"$, se necesitan al menos $L$ puntos, idealmente potencia de 2, así que $N_"FFT" = 8$.
]
)

== Ejercicio 2. Pitch matemático vs. pitch percibido

Para una señal $x_c(t) = A cos(2 pi f_1 t) + B cos(2 pi f_2 t)$, determinar el período fundamental $T_0$ y la
frecuencia fundamental $F_0 = 1/T_0$ en cada caso.

+ $f_1 = 220 "Hz"$, $f_2 = 440 "Hz"$, $A = B = 1$.
+ $f_1 = 220 "Hz"$, $f_2 = 660 "Hz"$, $A = 2$, $B = 1$.
+ $f_1 = 660 "Hz"$, $f_2 = 880 "Hz"$, $A = 1$, $B = 0.1$.

¿Qué papel juegan A y B en la definición de F0 matemáticamente? ¿Y perceptualmente? Anticipar
qué se va a escuchar antes de sintetizar.

Solución:

Condición de periodicidad: $f_1 T_0 in ZZ$ y $f_2 T_0 in ZZ$.

$ F_0 = gcd(f_1, f_2). $

+ $F_0 = 220 "Hz"$.
+ $F_0 = 220 "Hz"$.
+ $F_0 = 220 "Hz"$.

A y B no importan, matemáticamente, para el período fundamental. Pero perceptualmente cambia mucho el resultado. Buscar _missing fundamental_.

// vim: lbr wrap
