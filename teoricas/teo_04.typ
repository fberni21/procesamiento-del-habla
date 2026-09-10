#let argmax = math.op("argmáx", limits: true)

= Teórica 4

== Repaso

En ASR tenemos
#align(center)[
#box($x_c (t)$, baseline: horizon)
#box($arrow.long$, baseline: horizon)
#box(rect(align(center)[Procesador\ acústico]), baseline: horizon)
#box($arrow.long$, baseline: horizon)
#box($underline(y)_(1:T)$, baseline: horizon)
#box($arrow.long$, baseline: horizon)
#box(rect(align(center)[Decodificador\ de palabras]), baseline: horizon)
#box($arrow.long$, baseline: horizon)
#box($hat(W)_(1:T)$, baseline: horizon)
]
Y el decodificador de palabras consiste de un modelo acústico que modela $p(underline(Y)_(1:T) | W_(1:K))$, seguido de un modelo del lenguaje que modela $P(W_(1:K))$.

Aquí trabajaremos el modelo acústico. Para un dado frame, veremos el problema de clasificación de decir a qué clase acústica pertenece un $underline(y)_t$.

== Notación

Trabajamos todo dentro de un dado frame $t$.

- $y in RR^D$.
- $ cal(S) = { s_1, dots, s_K }$.

Armamos un dataset
$ cal(D) = { (underline(y)^((i)), s^((i))) }_(i=1)^(N_"train"). $

La salida del clasificador (inferencia) se escribe como
$ hat(s)(underline(y)) in cal(S). $

Las clases acústicas pueden ser
- Fonemas
- Partes de un fonema (inicio, centro o final)
- Silencios
- Risas
- Decisiones de locutor

(Agregar imagen de transformación de fonemas a formantes.)

Hay que hacer una decisión probabilística porque se superponen las nubes de puntos de los fonemas de diferentes hablantes.

== Decisión bayesiana

- $P(S = s_k)$: prior (probablilidad a priori de la clase $s_k$).
- $p(underline(Y) = underline(y) | S=s_k) = p_k (underline(y))$: densidad condicional de los features acústicos dada la clase $s_k$.
- $P(S = s_k | underline(Y) = underline(y))$ : probablilidad a posteriori de la clase $s_k$ dados los features acústicos.

Suponiendo que todos los errores se pesan igualmente:
$ hat(s)(underline(y)) &= argmax_(s_k in cal(S)) P(S = s_k | underline(Y) = underline(y)) \
&stretch(eq)^"bayes" argmax_(s_k in cal(S)) (P(S = s_k) p(underline(Y) = underline(y) | S = s_k)) / (sum_(j=1) P(S=s_j) p(underline(Y) = underline(y) | S=s_j)) \
&= argmax_(s_k in cal(S)) P(S = s_k) p(underline(Y) = underline(y) | S = s_k). $

Definimos el discriminante como:
$ g_k (underline(y)) = log p_k (underline(y)) + log P(S = s_k). $

Entonces, la decisión es
$ hat(s) (underline(y)) = argmax_(s_k in cal(S)) g_k (underline(y)). $

=== Uso del prior

Ejemplo con dos clases $s_0, s_1$, entrada escalar $y in RR$.

- Asumimos $p_0 (y) = p_1 (y)$.
(Agregar gráfico de P*p en función de y.)

El prior pesa una clase más que otra, y esto importa principalmente cuando hay información ambigua de las likelihoods.

== Clasificador gaussiano

Modelizamos $p_k (underline(y))$ como gaussiana:
$ p_k (underline(y)) = cal(N)(underline(y); underline(mu)_k, Sigma_k) \
= 1 / ((2 pi)^(D/2) bar(Sigma_k)^(1/2)) exp{-1/2 (underline(y) - underline(mu)_k)^T Sigma_k^(-1) (underline(y) - underline(mu)_k) }. $

$delta^2 = (underline(y) - underline(mu)_k)^T Sigma_k^(-1) (underline(y) - underline(mu)_k)$ es la distancia de Mahalonobis al cuadrado.

Se tiene para $D=2$:
$ Sigma_k = mat(sigma^2_1, sigma_(12); sigma_(12), sigma^2_2), $
una matriz cuadrada, simétrica y semidefinida positiva.

El discriminante queda
$ g_k (underline(y)) = log P(S = s_k) - 1/2 log|Sigma_k| - 1/2 (underline(y) - underline(mu)_k)^T Sigma_k^(-1) (underline(y) - underline(mu)_k) - D/2 log(2 pi). $
El último término es constante, por lo que se descarta en el $argmax$.

La decisión depende de la frecuencia de la clase, y de la distancia a la media de la clase $mu_k$ pesado por las direcciones de máxima variabilidad ($Sigma_k^(-1)$, distancia de Mahalanobis).

=== Casos particulares

+ Si las matrices de covarianza son iguales para todo $k$, las fronteras de decisión son lineales. Se descarta el segundo término, y el tercero es lineal.

+ Si además $Sigma_k = sigma^2 I_(D times D)$ para todo $k$, y los priors son iguales, entonces solo hace falta observar la distancia euclídea a los centroides $mu_k$.

== Estimación por máxima verosimilitud

Asumimos que tenemos un dataset $cal(D)_k$ con instancias de la clase $k$. Definimos $N_k = |cal(D)_k|$ como el tamaño de ese dataset.

Las estimaciones son:
- $ hat(P)(S=s_k)_("mv") = N_k / N_("train"). $
- $ (hat(mu)_k)_("mv") = 1/N_k sum_(i: s^((i)) = s_k) underline(y)^((i)). $
- $ (hat(Sigma)_k)_("mv") = 1/N_k sum_(i: s^((i)) = s_k) (underline(y)^((i)) - (hat(mu)_k)_("mv"))  (underline(y)^((i)) - (hat(mu)_k)_("mv"))^T. $

=== Covarianza diagonal

Si no se asume covarianza diagonal, se tienen $D(D+1)/2$ parámetros libres. Si se asume, solo $D$.

$ Sigma_k = mat(sigma_k_1, , 0; , dots.down, ; 0, , sigma_k_D). $

Esto es razonable porque luego de usar la DCT las muestras se descorrelacionan bastante.

=== Mezcla de gaussianas (GMM)

$ p(underline(y); theta) = sum_(m=1)^M omega_m cal(N)(underline(y); underline(mu)_m, Sigma_m), $
con $omega_m gt.eq 0$, $sum_(m=1)^M omega_m = 1$, y $theta = {omega_m, underline(mu)_m, Sigma_m}_(m=1)^M$.

En clasificación, tomamos
$ p_k (underline(y); theta) = sum_(m=1)^M_k omega_k_m cal(N)(underline(y); underline(mu)_k_m, Sigma_k_m). $

=== Variables latentes

Definimos $Z = in { 1, 2, dots, M }$ tal que
$ P(Z = m) = omega_m$. Así,
$ p(underline(y) | Z=m) = cal(N)(underline(y); underline(mu)_m, Sigma_m). $
Observar que
$ p(underline(y)) = sum_(m=1)^M P(Z=m) p(underline(y)|Z=m), $
idéntico a GMM.

== Algoritmo EM (expectation-maximization)

Dado un conjunto de features ${underline(y)^((i))}_(i=1)^(N_"train")$, queremos estimar los parámetros de un GMM por máxima verosimilitud. La verosimilitud para una clase en particular es
$ cal(L)(theta) = product_(i=1)^(N_"train") sum_(m=1)^M omega_m cal(N)(underline(y)^((i)); underline(mu)_m, Sigma_m). $
De aquí, la log-verosimilitud es
$ cal(l)(theta) = sum_(i=1)^(N_"train") log{ sum_(m=1)^M omega_m cal(N)(underline(y)^((i)); underline(mu)_m, Sigma_m) }. $

*Paso E*. Asignaciones "suaves" asumiento parámetros constantes. 

Las responsabilidades son valores entre 0 y 1, cuya suma sobre $m=1, dots, M$ es igual a 1. Son "pesos" de asignación soft a cada clase, y se definen como
$ gamma_i_m &= P(Z^((i)) = m | underline(Y)^((i)) = underline(y)^((i)); theta) \
&stretch(=)^("bayes") (omega_m^("prev") cal(N)(underline(y)^((i)); underline(mu)_m^("prev"), Sigma_m^("prev"))) /
(sum_(r=1)^M omega_r^("prev") cal(N)(underline(y)^((i)); underline(mu)_r^("prev"), Sigma_r^("prev"))). $

*Paso M*. Actualización de los parámetros.

Definimos para cada gaussiana
$ N_m = sum_(i=1)^(N_("train")) gamma_i_m, $
que no es necesariamente un entero.

Los nuevos parámetros son
- $ omega_m^("new") = N_m / N_"train". $
- $ underline(mu)_m^("new") = 1/N_m sum_(i=1)^(N_"train") gamma_i_m underline(y)^((i)). $
- $ underline(Sigma)_m^("new") = 1/N_m sum_(i=1)^(N_"train") gamma_i_m (underline(y)^((i)) - underline(mu)_m^("new")) (underline(y)^((i)) - underline(mu)_m^("new"))^T. $

*Observación*: $M$ (o $M_k$ para cada clase), es fijo y definido por quien lo implementa. Esto es un problema. Si aumenta la verosimilitud aumenta, esto no implica que la verosimilitud de los datos no vistos aumente.

== Entrenamiento vs inferencia

=== Entrenamiento

- Juntamos ejemplos de cada clase.
- Estimamos los parámetros del modelo ($omega_k_m$, $underline(mu)_k_m$, $Sigma_k_m$) usando EM.
- Estimamos los priors.

=== Inferencia

- Definimos
$ g_k (underline(y)) = log[ sum_(m=1)^(M_k) omega_k_m cal(N)(underline(y); underline(mu)_k_m, Sigma_k_m) ] + log P(S=s_k) $
- Computamos
$ hat(s)(underline(y)) = argmax_(s_k in cal(S)) g_k (underline(y)). $

Es decir, se evalúa el nuevo $underline(y)$ bajo cada modelo, se suman las contribuciones de cada componente, se combinan con priors, y se elige.

*Observación*: No conviene en entrenamiento e inferencia usar frames cercanos, puesto que hay mucha correlación entre ellos y la respuesta sea correcta por memorización, no generalización. Los frames cercanos se deben poner solo en un conjunto.

== Modelos generativos vs discriminativos

=== Generativos

Se estima $P(S = s_k)$ y $p_k (underline(y))$. Luego computo la probabilidad a posteriori con Bayes.

=== Discriminativos

Se estima directamente $P(S=s_k|underline(Y)=underline(y))$.

== El problema

El orden importa. Si cambiamos los frames de lugar, esto sigue "funcionando", pero no debería. No tiene en cuenta la relación secuencial que tiene que haber entre los frames.

// vim: lbr wrap
