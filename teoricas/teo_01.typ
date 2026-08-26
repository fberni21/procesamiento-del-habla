#let argmax = math.op("argmáx", limits: true)

= Teórica 1

== Notación

Tenemos una señal $x_c (t)$ que se muestrea a un $T_s = 1/f_s$, resultando en una señal $ x[n] = x_c (n T_s), n in ZZ. $ Esta señal es típicamente la variación de presión respecto de una presión de referencia.

Se divide un segmento de audio en $T$ fragmentos, y de cada uno se extraen _features acústicas_ $underline(y)_i, i=1,dots,T$.

- Vector de _features_: $underline(y)_(1:T) = (y_1, dots, y_T)$.
- Palabras: $W_(1:K) = (W_1, dots, W_K)$, con $W_k in WW$ el diccionario o vocabulario.

En general debe cumplirse que $T >> K$, o sea quiero muchos más _frames_ que palabras.

El bloque que muestrea y produce los _frames_ se llama procesador acústico.

== Problemas típicos

- ASR: _automatic speech recognition_.
- Síntesis de voz.
- Identificación del hablante, puede ser binario o no.
- Traducción.
- Diarización: transcripción de conversaciones con identificación de cada hablante.

=== _Automatic speech recognition_

1. Procesador acústico: convierte la señal de entrada en una secuencia de _features acústicos_. Su salida es $underline(y)_(1:T)$. Cada $underline(y)_t in RR^D$.
2. Decodificador de palabras: devuelve una predicción de la secuencia de palabras en función de los _features acústicos_. Su salida es $W_(1:K)$.

Conceptualmente, el decodificador de palabras modela la probabilidad condicional de cada palabra dadas las _features acústicas_, $P(W_(1:K)=w_(1:K)|underline(Y)_(1:T) = underline(y)_(1:T))$. Cada una de las posibles secuencias de palabras que se corresponden con la señal se denota $W^((m))$, $m=1,dots,M$. Esto es en realidad poco práctico, pues requiere considerar todas las posibles combinaciones de palabras del diccionario.

Por Bayes:
$ argmax_W P(W_(1:K)=w_(1:K)|underline(Y)_(1:T) = underline(y)_(1:T)) = argmax_W P(W_(1:K)=w_(1:K)) p(Y=y_(1:T)|W=w_(1:K)), $
donde se descartó el denominador pues no afecta el argumento máximo.

Al término $P(W_(1:K)=w_(1:K))$ se lo llama modelo de lenguage. Intuitivamente, describe qué tan frecuente es una secuencia de palabras en el lenguaje. El término $p(underline(Y)_(1:T)=underline(y)_(1:T) | W_(1:K)=w_(1:K))$ es el modelo acústico, que describe qué tan probable es obtener una secuencia de _features_ bajo la suposición de que se habló una secuencia de palabras.

==== Construcción del modelo del lenguaje

Ejemplo sobre la frase: "identificación de cada hablante".

La forma naïve de determinar $P(W_(1:K))$ es contar la cantidad de veces que aparece la frase completa en el dataset, y dividirla por el largo del dataset, es decir
$ P("\"identificación de cada hablante\"") = N("\"identificación\"", "\"de\"", "\"cada\"", "\"hablante\"") / N. $
Esto no es práctico, porque esa probabilidad sería casi siempre nula. Estamos tratando de calcular una probabilidad conjunta, por lo que podemos separar
$ P(W_1, dots, W_K) &= P(W_1)P(W_2|W_1)P(W_3|W_1,W_2) dots P(W_K|W_1,dots,W_(K-1))\
&= P(W_1) product_(k=2)^K P(W_k | W_1,dots,W_(k-1)). $

Para el término $P("\"identificación\"", "\"de\"", "\"cada\"")$, separo en
$ P("\"identificación\"") P("\"de\"" | "\"identificación\"") P("\"cada\"" | "\"identificación\"", "\"de\""). $
Se puede reescribir
$ P("\"de\"" | "\"identificación\"") = P("\"identificación\"", "\"de\"") / P("\"identificación\""), $
que es fácil de calcular porque es más probable que dos palabras ocurran juntas. Para el término restante, se usa la aproximación por bigramas, haciendo
$ P("\"cada\"" | "\"identificación\"", "\"de\"") approx P("\"de\"", "\"cada\"") / P("\"de\""), $
descartando los demás términos.
Si un bigrama no existe, puede usarse suavización (asumir que cada bigrama aparece al menos una vez), o hacer _backoff_, reemplazando
$ P("\"de\"", "\"cada\"") approx P("\"cada\""). $
Es decir, cada vez se condiciona menos.

== Métricas

Ejemplo sobre la frase: "el gato come pescado fresco".

Suponemos una predicción: "el gata corre pescado ---".

Notar que se realizó un alineamiento entre la predicción y el _ground truth_.

=== _Word error rate_

Definido como
$ "WER" = (S + I + D) / N_r, $
con $S$ las sustituciones, $I$ las inserciones, $D$ las eliminaciones (_deletions_), y $N_r$ la cantidad de palabras de la frase de referencia. Por como se define, tiene algunos inconvenientes pues puede ser mayor al 100 %.

El ejemplo de antes tiene dos sustituciones ("gato" #math.arrow "gata", "come" #math.arrow "corre"), ninguna inserción, y una eliminación ("fresco"). La frase de referencia tiene cinco palabras.

Equivalentemente, puede definirse el _character error rate_, basado en los caracteres de la frase.

=== Otras métricas

1. MOS (_mean opinion score_): usado en síntesis de voz, donde se mide la percepción del humano ante la voz sintetizada.
2. EER (_equal error rate_): usado en identificación del habla (curvas ROC).

== Métodos de diseño de sistemas

1. _Pipeline_ modular: divide al sistema en bloques. Tiene como desventaja que se propagan los errores con menos control.
2. _Pipeline end-to-end_: considera al sistema como un todo. Su desventaja es menor interpretabilidad.

// vim: lbr wrap
