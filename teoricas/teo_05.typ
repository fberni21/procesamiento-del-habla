#let argmax = math.op("argmáx", limits: true)

= Teórica 5

== Notación

- $underline(y)_(1:T)$: secuencia de features acústicos (e.g. MFCC).
- $hat(q)_t = argmax_j p(underline(y)_t | Q_t = j) P(Q_t = j)$.

*Definición*: cadena de Markov de primer orden.

Una secuencia $Q_1, dots, Q_T in {1, dots, N}$ satisface la propiedad de Markov (o propiedad markoviana) si
$ P(Q_(t+1) = j | Q_t = i_t, dots, Q_1 = i_1) = P(Q_(t+1) = j | Q_t = i_t), $
es decir, la probabilidad de transición solo depende del estado actual.

Asumimos que las probabilidades no dependen del tiempo $t$. A esto se lo llama cadena homogénea.

*Definición*: probabilidad y matriz de transición.

Para una cadena homogénea, definimos la probabilidad de transición del estado $i$ al estado $j$ como
$ a_(i j) = P(Q_(t+1) = j | Q_t = i). $
La matriz de transición es
$ A = [ a_(i j) ]. $
Notar que por filas suma 1 (la suma sobre los $j$ es 1). También notar que para una cadena homogénea, $A$ es única.

*Definición*: probabilidad inicial.

La probabilidad inicial del estado $i$ es
$ pi_i = P(Q_1 = i), $
donde las $pi_i$ suman 1.

*Lema*: probabilidad de una trayectoria.

La probabilidad de una trayectoria es:
$ P(Q_(1:T) = q_(1:T)) = pi_(q_1) product_(t=2)^T a_(q_(t-1), q_t). $

_Demostración_:
$ P(q_(1:T)) = P(q_1) product_(t=2)^T P(q_t | q_(1:t-1)). $
Pero $q_1, dots, q_t$ es una cadena de Markov homogénea, por lo que
$ P(q_t | q_(1:t-1)) = P(q_t | q_(t-1)) = a_(q_(t-1), q_t) space.quad qed $

*Ejemplo*:
$ underline(pi) = vec(1, 0),  A = mat(0.6, 0.4; 0, 1). $

$ P(Q_(1:3) = (1, 1, 2)) = 1 times a_(1 1) times a_(1 2) = 0.24. $

== Modelos Ocultos de Markov (HMM)

// -> Q(t-1) -> Q(t) -> Q(t+1)
//      v        v        v
//    Y(t-1)    Y(t)    Y(t+1)

Cada Q es un estado oculto que emite a las observaciones $Y$. En habla, los $Q$ pueden ser fonemas (o partes de fonemas), mientras que los observables pueden ser MFCC.

*Definición*: modelo oculto de Markov.

Un HMM está determinado por los parámetros
$ lambda = (A, B, underline(pi)), $
donde $A$ es la matriz de transiciones, $underline(pi)$ es la distribución inicial, y $B$ es la distribución de emisión tal que
$ b_j (underline(y)_t) = P(underline(Y)_t = underline(y)_t | Q_t = j). $

*Observación*: para observaciones continuas
$ B = { b_1, dots, b_N }, $
es una colección de distribuciones.

*Hipótesis*:
- Propiedad markoviana: $ P(Q_t | Q_(1:t-1)) = P(Q_t | Q_(t-1)). $
- Independencia condicional de las observaciones: $ p(underline(Y)_t | Q_(1:T), underline(Y)_(eq.not t)) = p(underline(Y)_t | Q_t). $

=== Historia generativa

Analizamos cómo el HMM asume que se generaron las muestras.

- Sampleamos el estado inicial: $ Q_1 ~ underline(pi). $
- Sampleamos la primera observación: $ underline(Y_1) ~ b_(Q_1). $
- Sampleamos el siguiente estado: $ Q_2 ~ A_(Q_(1,:)). $
- Sampleamos la siguiente observación: $ underline(Y_2) ~ b_(Q_2). $
- Se continúa idénticamente, haciendo: $ Q_t ~ A_(Q_(t-1, :)), space.quad underline(Y)_t ~ b_(Q_t). $

*Proposición*: factorización conjunta.
$ p(underline(y)_(1:T), q_(1:T) | lambda) = pi_(q_1) b_(q_1) (underline(y)_1) product_(t=2)^T a_(q_(t-1), q_t) b_(q_t) (underline(y)_t). $

=== Problemas canónicos de HMM

+ Evaluación: mediante el algoritmo de forward, se computa la verosimilitud $p(underline(y)_(1:T) | lambda)$.
+ Probabilidades a posteriori locales: mediante el algoritmo forward-backward.
+ Decodificación: mediante el algoritmo de Viterbi, responde cuál es la mejor secuencia de estados.
+ Aprendizaje: mediante el algoritmo de Baum-Welch, estima $lambda = (A, B, underline(pi))$.

=== Algoritmo forward

Busca reducir el cómputo para calcular la verosimilitud de las observaciones. Si se hiciera naïve, tendríamos que recorrer $N^T$ caminos, lo que es excesivo.

Definimos la variable de forward
$ alpha_t (i) = p(underline(y)_(1:T), Q_t = i | lambda). $
Representa la probabilidad conjunta de todos los caminos que llegan al estado $i$ en el tiempo $t$.

*Teorema*: de la correctitud de la recursión de forward.

+ Inicialización: $alpha_1 (i) = pi_i b_i (underline(y)_1)$.
+ Recursión: para $t=2, dots, T$, $ alpha_t (j) = [sum_(i=1)^N alpha_(t-1) (i) a_(i j) ] b_j (underline(y)_t). $
+ Finalización: $ p(underline(y)_(1:T) | lambda) = sum_(i=1)^N alpha_T (i). $
La complejidad se reduce a $O(N^2 T)$.

=== Algoritmo backward

Definimos la variable de backward
$ beta_t (i) = p(underline(y)_(t+1:T) | Q_t = i, lambda). $

*Proposición*: algoritmo de backward.
- $ beta_T (i) = 1. $
- $ beta_t (i) = sum_(j=1)^N a_(i j) b_j (underline(y)_(t+1)) beta_(t+1) (j). $
Estamos generando el vector de features futuros a partir del estado presente.

*Lema*: forward-backward.

Para cualquier instante $t$, $ p(underline(y)_(1:T) | lambda) = sum_(i=1)^N alpha_t (i) beta_t (i). $

*Corolario 1*: probabilidad a posteriori de estado.

La probabilidad a posteriori del estado $i$ en el frame $t$ es
$ gamma_t (i) = P(Q_t = i | underline(y)_(1:T), lambda) = (alpha_t (i) beta_t (i)) / p(underline(y)_(1:T) | lambda). $
Responde la probabilidad de que $underline(y)_t$ haya sido emitido por el estado $i$.

La suma $sum_(t=1)^T gamma_t (i)$ representa a cuántos frames, típicamente, se asignan al estado $i$.

*Corolario 2*: probabilidad a posteriori de transición.

$ xi_t (i, j) = P(Q_t = i, Q_(t+1) = j | underline(y)_(1:T), lambda) = (alpha_t (i) a_(i j) b_j (underline(y)_(t+1)) beta_(t+1) (j)) / p(underline(y)_(1:T) | lambda). $

*Observación*: en habla, típicamente se tiene un $lambda$ por cada palabra. Se arma un HMM para cada palabra, donde hay varios estados por cada fonema (por ejemplo, tres estados por fonema).

// vim: lbr wrap
