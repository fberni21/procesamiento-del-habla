#let argmax = math.op("argmáx", limits: true)

= Teórica 6

== Repaso

- Verosimilitud $p(underline(y)_(1:T) | lambda)$: responde qué tan compatible es un cierto audio dado por $underline(y)_(1:T)$ con un cierto HMM dado por $lambda = (A, B, underline(pi))$.
- Decodificación: obtener el camino óptimo $q_(1:T)^*$.
- Estimación: responde qué parametros $hat(lambda)$ explican mejor un corpus.

=== Ejemplo

$ Q_t = cases(
  1 ", región fricativa" arrow.long "/f/, /s/, /x/," \/integral\/,
  2 ", región vocálica",
), $
$ underline(pi) = mat(1; 0), A = mat(0.6, 0.4; 0, 1). $

#align(center)[
  #table(
    columns: 4,
    [], [$t=1$], [$t=2$], [$t=3$],
    [$b_1 (underline(y)_t)$], [0.5], [0.4], [0.1],
    [$b_2 (underline(y)_t)$], [0.1], [0.5], [0.8],
  )
]

El primer frame es principalmente fricativo, el segundo es parejo, y el tercero es mayormente vocálico.

==== Forward

$ alpha_1 (i) = pi_i b_i (underline(y)_1), alpha_t (j) = sum_(i=1)^2 alpha_(t-1) a_(i j) b_j (underline(y)_t). $

*Valores iniciales:*

$ alpha_1 (1) = 0.5, alpha_1 (2) = 0. $

*Algoritmo recursivo:*

$ alpha_2 (1) = [ alpha_1 (1) a_(11) + alpha_1 (2) a_(21) ] b_1 (underline(y)_2) = (0.5 times 0.6 + 0 times 0) times 0.4 = 0.12. $
$ alpha_2 (2) = 0.1. $

$ alpha_3 (1) = 0.0072, alpha_3 (2) = 0.1184. $

*Verosimilitud:*

$ p(underline(y)_(1:3) | lambda) = sum_(i=1)^2 alpha_3 (i) = 0.0072 + 0.1186 = 0.1256. $

==== Backward

$ beta_t (i) = p(underline(y)_(t+1:T) | Q_t = i, lambda). $

$ beta_T (i) = 1, beta_t (i) = sum_(j=1)^N a_(i j) b_j (underline(y)_(t+1)) beta_(t+1) (j). $

*Valores finales:*

$ beta_3 (1) = beta_3 (2) = 1. $

*Algoritmo recursivo:*
$ beta_2(1) = a_(11) b_1 (underline(y)_3) beta_3 (1) + a_(12) b_2 (underline(y)_3) beta_3 (2) = 0.6  times 0.1 times 1 + 0.4 times 0.8 times 1 = 0.38. $
$ beta_2(2) = 0.8. $

$ beta_1 (1) = 0.2512, beta_1 (2) = 0.4. $

*Probabilidades a posteriori de estado:*

$ gamma_t (i) = P(Q_t = i | underline(y)_(1:3), lambda) = (alpha_t (i) beta_t (i)) / p(underline(y)_(1:3) | lambda). $

#align(center)[
  #table(
    columns: 3,
    [t], [$gamma_t (1)$], [$gamma_t (2)$],
    [1], [1], [0],
    [2], [0.363], [0.637],
    [3], [0.057], [0.943],
  )
]

== Filtrado vs. suavizado

=== Suavizado

La probabilidad de un estado conociendo _todas_ las observaciones.
$ P(Q_t = i | underline(y)_(1:T)) = gamma_t (i). $

=== Filtrado

La probabilidad de un estado en el tiempo $t$ conociendo _únicamente_ las observaciones hasta ese instante $t$. Es causal.
$ P(Q_t = j | underline(y)_(1:t)) = (alpha_t (j)) / (sum_(i=1)^N alpha_t (i)). $

*Ejemplo:*
$ P(Q_2 = 1 | underline(y)_(1:2), lambda) = p(Q_2 = 1, underline(y)_(1:2) | lambda) / p(underline(y)_(1:2) | lambda)
= (alpha_2 (1)) / (sum_(j=1)^2 alpha_2 (j)) = 0.545. $

Notar que es mayor que 0.5, pero $gamma_2 (1)$ es menor. En este ejemplo, la información parcial hasta el instante $t=2$ apunta hacia un estado fricativo, pero al tener todas las observaciones (como en suavizado), se tiene mayor información para determinar que es más probable que haya sido un estado vocálico.

== Algoritmo de Viterbi

Problema de decodificación. Conserva el camino óptimo
$ q_(1:T)^* = argmax_(q_(1:T)) P(q_(1:T) | underline(y)_(1:T), lambda)
= argmax_(q_(1:T)) p(q_(1:T), underline(y)_(1:T) | lambda). $

Definimos la variable de Viterbi
$ delta_t (i) = max_(q_(1:t-1)) p(q_(1:t-1), Q_t = i, underline(y)_(1:t) | lambda). $

*Teorema:* recursión de Viterbi.

+ Inicialización: $ delta_1 (i) = pi_i b_i (underline(y)_1), underbrace(psi_1 (i), "puntero") = 0. $
+ Recursión: $ delta_t (j) = [ max_i delta_(t-1) (i) a_(i j) ] b_j (underline(y)_t),
psi_t (j) = argmax_i delta_(t-1) (i) a_(i j). $ El puntero es el subcamino óptimo del cual se llega al frame $t$.
+ Finalización: $ q_T^* = argmax_i delta_T (i), q_t^* = psi_(t+1) (q_(t+1)^*). $

Básicamente se computan los caminos óptimos que concluyen en cada estado, y se selecciona el que más probabilidad acumuló hasta ese punto.

*Ejemplo:*

$ delta_1 (1) = 0.5, delta_1 (2) = 0. $

$ delta_2 (1) = max{ 0.5 times 0.6; 0 } underbrace(0.4, b_1 (underline(y)_2)) = 0.12. $

$ delta_3 (1) = 0.0072, delta_3 (2) = max{ 0.12 times 0.4; 0.1 times 1 } underbrace(0.8, b_2 (underline(y)_3)) = 0.08. $

_Camino óptimo_:
$ q_3^* = 2, q_2^* = psi_3 (q_3^*) = 2, q_1^* = psi_2 (q_2^*) = 1. $
Quedando
$ q_(1:3)^* = (1, 2, 2). $

== Algoritmo de Baum-Welch

EM aplicado a HMM. Quiero estimar $lambda = (A, B, underline(pi))$.

=== Gaussianas sin mezcla

Primero se asumen emisiones gaussianas sin mezcla.

==== Paso E

Calculamos $gamma_t (i)$ y $xi_t (i, j)$, por definición, a partir de la estimación previa de $lambda$.

==== Paso M

Actualizamos los parámetros como
$ pi_i^("new") = gamma_1 (i), $
$ a_(i j)^("new") = (sum_(t=1)^(T-1) xi_t (i, j)) / (sum_(t=1)^(T-1) gamma_t (i)) = ("estimación de" N_(i j)) / ("estimación de" N_i), $
$ underline(mu)_j^("new") = ( sum_(t=1)^T gamma_t (j) underline(y)_t ) / (sum_(t=1)^T gamma_t (j)), $
$ Sigma_j^("new") = (sum_(t=1)^T gamma_t (j) (underline(y)_t - underline(mu)_j^("new")) (underline(y)_t - underline(mu)_j^("new"))^T ) / (sum_(t=1)^T gamma_t (j)). $

=== GMM

Definimos una responsabilidad conjunta
$ r_t (j, m) &= P(Q_t = j, Z_t = m | underline(y)_(1:T), lambda) \
&= P( Q_t = j | underline(y)_(1:T), lambda) P(Z_t = m | Q_t = j, underline(y)_(1:T), lambda) \
&= gamma_t (j) rho_t (m | j). $

$ rho_t (m | j) = (omega_(j m) cal(N)(underline(y)_t; underline(mu)_(j m), Sigma_(j m))) / (b_j (underline(y)_t)). $

==== Paso E

Se computa $r_t (j, m)$.

==== Paso M

Se calcula $omega_(j m)$ y se reemplaza en el paso M sin mezcla $gamma_t (j)$ por $r_t (j, m)$ para computar los $mu$ y $Sigma$.

== Topología típica de habla (Bakis)

// Agregar imagen
// I -> 1 -> 2 -> 3 -> ... -> N

$ pi = mat(1, 0, 0, dots.c, 0)^T in RR^N, $
$ A = mat(a_11, a_12, 0, dots.c, 0; , a_22, a_23, dots.c, 0; , , , dots.down, dots.v ; , , , a_(N N-1), a_(N N); 0, , , ,  a_(N N)). $

Las transiciones directas representan avance temporal. Los bucles representan duración.
Los saltos opcionales corresponden a hablar rápido o saltearse sonidos.

*Proposición:*

Definimos la V.A. $D_i$ como la cantidad de frames de permanencia en el estado $i$. Entonces,
$ D_i ~ "Geom"(1-a_(i i)), P(D_i = d) = a_(i i)^(d-1) (1 - a_(i i)). $
La esperanza de $D_i$, que representa la cantidad esperada de frames de permanencia en el estado $i$, vale $1 / (1 - a_(i i))$.

=== Puente con palabras aisladas

// (Palabra -> fonema) -> estados -> emisiones -> qué features puede emitir cada estado
//        (1)               (2)         (3)
//  (1) casa ---- modelo de palabra ---> /k/, /a/, /s/, /a/ -----> 3 estados por fonema
//  (2) HMM: en qué orden y cuánto tiempo

- Para un vocabulario pequeño, tenemos $lambda_("casa"), lambda_("cama"), dots$
- Dados los features $underline(y)_(1:T)$ de una grabación, uso forward para obtener $p(underline(y)_(1:T) | lambda_w), forall w in cal(W)$.
- Elegir $hat(w) = argmax_(w in cal(W)) p(underline(y)_(1:T) | lambda_w) P(W=w)$.

// vim: lbr wrap
