#let argmax = math.op("arg máx", limits: true)

= Teórica 7

== Repaso

Venimos trabajando con un HMM $lambda = (A, B, underline(pi))$. Dadas unas observaciones de $T$ frames, nos interesaba la verosimilitud $p(underline(y)_(1:T) | lambda)$.

Ahora tendremos
- $underline(y)_(1:T) = (underline(y)_1, dots, underline(y)_T), y_t in RR^D$,
- $lambda_w$: un HMM para cada palabra $w in cal(W)$.

La idea es que dado un audio y una serie de modelos para cada audio de los dígitos ($lambda_"cero", dots, lambda_"nueve"$), computar los _scores_ para elegir a qué palabra se corresponde.

=== Regla map para ASR

Sea un vocabulario $cal(W)$. Para palabras aisladas,
$ hat(w) &= argmax_(w in cal(W)) P(W=w | underline(Y)_(1:T) = underline(y)_(1:T)) \
&= argmax_(w in cal(W)) p(underline(Y)_(1:T) = underline(y)_(1:T) | W = w) P(W = w) \
&= argmax_(w in cal(W)) p(underline(Y)_(1:T) = underline(y)_(1:T) | lambda_w) P(W = w). $

== Arquitectura del reconocedor de dígitos

Diccionario $cal(W) = { "\"cero\"", dots, "\"nueve\"" }$.

#align(center)[
#box([Audio $x_c (t)$], baseline: horizon)
#box($stretch(arrow, size: #120%)^"procesador\nacústico"$, baseline: horizon)
#box($underline(y)_(1:T)$, baseline: horizon)
#box($arrow.long$, baseline: horizon)
#box($cases(stretch(->, size: #120%)^(lambda_"cero"), space.quad dots.v, stretch(->)^(lambda_"nueve"))$, baseline: horizon)
#box($cases(s_"cero", space.quad dots.v, s_"nueve", reverse: #true)$, baseline: horizon)
#box($stretch(arrow, size: #120%)^argmax$, baseline: horizon)
#box($hat(W)_(1:T)$, baseline: horizon)
]

Verosimilitudes $ s_w = log p(underline(y)_(1:T) | lambda_w). $

Salida: $ hat(w) = argmax_(w in cal(W)) s_w. $

=== Relación entre scores y forward/Viterbi

$ p(underline(y)_(1:T) | lambda_w) = sum_(q_(1:T)) p(underline(y)_(1:T), q_(1:T) | lambda_w). $

$ s_w^("Viterbi") = max_(q_(1:T)) log p(underline(y)_(1:T), q_(1:T) | lambda_w). $

Notar que
$ max_(q_(1:T)) p(underline(y)_(1:T), q_(1:T) | lambda_w) lt.eq p(underline(y)_(1:T) | lambda_w). $

Pero si el término del máximo domina, puede aproximarse $ p(underline(y)_(1:T) | lambda_w) approx max_(q_(1:T)) p(underline(y)_(1:T), q_(1:T) | lambda_w), $
es decir, se puede estimar por Viterbi en lugar de forward.

=== Modelo de palabra

*Definición:* modelo de palabra.

$ lambda_w = (A^w, B^w, underline(pi)^w). $
Recordar que $B^w = { b_1^w, dots, b_N^w }. $
Se tiene $ underline(pi)^w = mat(1; 0; dots.v; 0), " y " a_(i,i) + a_(i,i+1) = 1. $

Las emisiones son gaussianas,
$ b^w_j (underline(y)_t) = p(underline(y)_t | Q_t = j, lambda_w) = sum_(m=1)^(M_j) omega^w_(j,m) cal(N)(underline(y)_t; underline(mu)^w_(j,m), Sigma^w_(j,m)), $
con $Sigma^w_(j,m) = "diag"((sigma^2)^w_(j,m,1), dots, (sigma^2)^w_(j,m,D))$.

$A$ determina orden y duración, mientras que $B$ determina la compatibilidad entre las observaciones.

=== Score de un camino

$ log p(underline(y)_(1:T), q_(1:T) | lambda_w) &= log pi_(q_1) + log b_(q_1) (underline(y)_t) + sum_(t=2)^T [ log a_(q_(t-1), q_t) + log b_(q_t) (underline(y)_t) ]. $

Recompensa un inicio posible (primer término), emisiones compatibles (segundo término, y segundo de la sumatoria), y transiciones plausibles (primero de la sumatoria).

=== Entrenamiento del reconocedor

Para cada $w$, defino
$ cal(D)_w = { underline(y)_(1:T_(N_("train")))^((1)), dots, underline(y)_(1:T_(N_("train")))^((N_("train")^w)) }, $
y etiquetas
$ w^(n_"train") = w, n_("train") in {1, dots, N_("train")^w}. $
Equivalentemente,
$ cal(D)_w = { (underline(y)_(1:T_(N_("train")))^((n_("train"))), w^((n_("train")))) }_(n_("train") = 1)^(N_("train")^w). $

Queremos aprender los $lambda_w$, usando Baum-Welch.

==== Inicialización por segmentación uniforme

Tomo
$ underline(y)^((n_("train")))_1, dots, underline(y)^((n_("train")))_(t_1)
space.quad underline(y)^((n_("train")))_(t_1 + 1), dots, underline(y)^((n_("train")))_(t_2)
space.quad dots.c space.quad
underline(y)^((n_("train")))_(t_3), dots, underline(y)^((n_("train")))_(T_(n_("train"))). $

Asigno cada estado $q_1, dots, q_N$ a cada una de las porciones en las que se dividió la muestra, de forma que
$ q_t^((n_"train", 0)) = 1 + floor((N (t-1))/T), space.quad t = 1, dots, T. $

Definimos para el estado $j$ el valor incial de $tau$ como
$ tau_j^((0)) = { (n_"train", t) : q_t^((n_"train", 0)) = j }. $

Computamos
$ underline(mu)^((0))_j &= 1 / abs(tau_j^((0))) sum_((n_"train", t) in tau_j^((0))) underline(y)_t^((n_"train")), \
(sigma_(j,d)^2)^((0)) &= 1 / abs(tau_j^((0))) sum_((n_"train", t) in tau_j^((0))) (underline(y)_(t, d)^((n_"train")) - mu_(j, d)^((0)))^2, \
a_(i,j)^((0)) &= N_(i,j)^((0)) / (sum_(j'=1)^N N_(i,j')^((0))). $

La inicialización de $lambda_w$ es
$ lambda_w^((0)) = (A^((0), w), B^((0), w), underline(pi)^((0), w)). $

==== Iteración de Baum-Welch

Partimos de $lambda_w^((k))$.

Realizamos forward-backward, para calcular $gamma$ y $xi$. Se debe promediar por todas las muestras del dataset $cal(D)$. Esto es el paso E. Luego, hacemos el paso M para computar $lambda_w^((k+1))$.

==== Criterio de convergencia

Se computa
$ ell^((k)) = sum_(n_"train")^(N_"train") log p(underline(y)_(1:T_(n_"train"))^((n_"train")) | lambda_w^(k)) $
y se detiene si
$ ell^((k)) - ell^((k-1)) < epsilon. $

Los parámetros obtenidos al finalizar son $lambda_w^(*)$.
El camino óptimo por Viterbi será
$ q_(1:T)^* = argmax_(q_(1:T)) p(underline(y)_(1:T), q_(1:T) | lambda_w^*). $

=== Unidades subléxicas y lexicón

*Definición:* lexicón.

Es una función $L$ que mapea una palabra a una secuencia de fonemas. Conecta la representación escrita con la representación.

*Definición:* trifonema.
Se toma un fonema central $phi_0$ (el fonema de interés), un contexto izquierdo $phi_(-1)$ (el fonema anterior), y un contexto derecho $phi_(+1)$ (el fonema siguiente).
La notación es /k/-/a/+/s/ para el fonema central /a/ entre los fonemas /k/ y /s/. Si un fonema es el último o primero, el contexto faltante se denota con el silencio $emptyset$.

Si tenemos $|Phi|$ fonemas, hay $|Phi|^3$ trifonemas.

*Definición:* estados atados.
Es una familia de estados contextuales que comparte sus parámetros de emisión.

Sea $u in {1, 2, 3}$ la posición dentro de un fonema. Un estado contextual queda definido como $(phi_(-1) - phi_0 + phi_(+1), u)$. Se mapea cada estado contextual por un árbol de decisión $g$ a una clase $c in { 1, 2, dots, N_"atados" }$.

*Ejemplo:*
Estado contextual | Estado atado
(k-a+m, 2) | 1
(k-a+s 2) | 2
(p-a+t,2) | 2

El árbol de decisión primero pregunta si el contexto derecho es nasal: para "sí" clasifica como 1; para "no", continúa. La segunda pregunta es si el contexto derecho obstruyente, si responde "sí" clasifica como 3; para "no", clasifica como 2.

Todo estado atado correspondiente a la clase $c$ emite según $b_c (underline(y)_t) = sum_(m=1)^(M_c) omega_(c,m) cal(N)(underline(y)_t; underline(mu)_(c,m), Sigma_(c,m)). $

// vim: lbr wrap
