# Código del Algoritmo Final - TFG

Esta carpeta contiene la implementación definitiva del algoritmo de asignación de RIS a usuarios para entornos *cell-free* masivos, propuesto como conclusión de este Trabajo de Fin de Grado. Es un entorno 100% independiente con sus propias dependencias.

## Archivos incluidos

### 1. `assignRIS_AlgoritmoFinal.m`
Es la implementación real y práctica del Algoritmo propuesto en la memoria. Sustituye por completo a los antiguos scripts de asignación (`assignRIS_radius_inclusive.m` o `assignRIS_radius_exclusive.m`).

**¿Qué hace especial a este script?**
No requiere que se le pase un radio de conectividad a probar. En su lugar, recibe los parámetros físicos de la red (`tau_c`, `N_RIS` y `squareLength`), aplica instantáneamente la **Ecuación Empírica Unificada** descubierta en la investigación para calcular el radio óptimo ($R_{opt}$), y ejecuta una asignación exclusiva (1 a 1) ultrarrápida protegiendo el factor *pre-log*.

Para utilizarlo de forma definitiva en el simulador global, simplemente hay que sustituir en `main1.m` la llamada de asignación original por esta:
```matlab
[risAssignment, tau_p] = assignRIS_AlgoritmoFinal(n, AP_radius, N_RIS, K, L, S, tau_c, squareLength);
```

### 2. `launcher_simulacion.m` (Uso general)
Script diseñado para lanzar una simulación de un único escenario de forma sencilla. Permite cambiar parámetros libremente y elegir el modo de asignación de RIS:
- **`final`**: Usa el algoritmo del TFG calculando su propio radio óptimo.
- **`exclusive`**: Asignación 1 a 1 estricta (requiere proporcionar un radio manual).
- **`inclusive`**: Múltiples RIS pueden compartir a un mismo usuario (requiere radio manual).

Imprime el resultado final de Eficiencia Espectral (SE al 10% de CDF) directamente en la consola y, además, genera automáticamente la gráfica de la Función de Distribución Acumulada (CDF) guardándola en la carpeta `figures/`.

### 3. `launcher_busca_optimo.m` (Verificación de la Fórmula)
Es un script de comprobación para demostrar que la fórmula matemática del algoritmo funciona. 
Permite definir un escenario, y el script hará lo siguiente:
1. **Predice:** Imprime en consola cuál debería ser el radio óptimo según la fórmula del TFG.
2. **Simula:** Hace un barrido fino (precision de 5 metros) alrededor de esa predicción probando diferentes radios (usando internamente el modo `exclusive`).
3. **Verifica:** Al terminar, te dice a cuántos metros se ha quedado la fórmula de dar exactamente en el blanco absoluto de la simulación.