= Ejercicio 1. Verosimilitud gaussiana de una vocal

Sea y = [500 1500]⊤ Hz un punto del plano (F1, F2). Evaluar su log-verosimilitud bajo una clase
modelada por
μ = 300 2200,
Σ = 1600 0
    0 10000.

(a) Calcular la distancia de Mahalanobis al cuadrado
δ^2 = (y − μ)⊤ Σ^−1 (y − μ).
(b) Calcular log p(y) usando la densidad gaussiana en R2.
(c) Interpretar el resultado: ¿es razonable asignar y a esa clase? ¿Qué vocal del español podría
corresponder a la media μ?

= Ejercicio 2. Del espectro al vector MFCC

Considerar el pipeline de MFCC para un frame xt[n]:
xt[n] −→ S[k, t] −→ Em[t] −→ eEm[t] −→ cd[t].

(a) Indicar qué representa cada cantidad: S[k, t], Em[t], eEm[t] y cd[t].

$S[k, t]$ es la potencia del bin $k$ en el frame $t$.
$E_m$ es la energía ponderada que pasa por el $m$-ésimo filtro de mel.
$tilde(E)_m$ es la log-energía del anterior.
$c_d$ es el $d$-ésimo coeficiente DCT del frame t.

(b) Explicar por qué se toma logaritmo antes de la DCT. Relacionar con compresión de rango
dinámico y con el modelo fuente-filtro.

El logaritmo se aplica para reducir el rango dinámico y para convertir factores multiplicativos en offsets aditivos.

Pero respecto del modelo fuente-filtro, se aplica por lo siguiente:
- Ya no se aplica "temprano" en el pipeline, por lo que *no* tenemos:
$ log|X(e^(j omega))| = log|E(e^(j omega))| + log|H(e^(j omega))|. $
- Tenemos
$ E_m [t] = sum_k B_m [k] underbrace(|E[k]|^2 |H[k]|^2, S[k,t]), $
- Se asume que $H[k]$ es lo suficientemente suave dentro del rango de un filtro de mel dado, por lo que aproximadamente vale
$ E_m [t] approx |H_m|^2 sum_k B_m [k] |E[k]|^2, $
y el logaritmo separa la fuente del filtro.
- Finalmente,
$ tilde(E)_m [t] approx log|H_m|^2 + log( sum_k B_m [k] |E[k]|^2 ). $


(c) Explicar por qué la DCT es útil al considerar GMM con covarianza diagonal.

Pues la DCT descorrelaciona, haciendo más válida la hipótesis de covarianzas nulas ($Sigma$ diagonal). Los $tilde(E)_m$ vienen correlacionados pues los filtros de mel se solapan.

La DCT descorrelaciona porque se proyectan las log-energías sobre diferentes cosenos progresivamente más rápidos (según su índice cepstral). Los cosenos son una base ortogonal, que permiten reconstruir los $tilde(E)_m$ sin "repetición".

(d) Si se conservan C = 13 coeficientes estáticos y se agregan deltas y delta-deltas, ¿cuál es la
dimensión final D del vector yt?

La dimensión final es 39 ($3 times 13$).

// vim: lbr wrap
