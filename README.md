# Código del Algoritmo Final de Asignación de RIS a usuarios basado en Radios de Conectividad - TFG

Esta carpeta contiene la implementación del algoritmo de asignación de RIS a usuarios para entornos *cell-free* mMIMO asistidos por RIS, propuesto como conclusión de este TFG.

## Archivos incluidos

### 1. `assignRIS_AlgoritmoFinal.m`
Es la implementación real y práctica del Algoritmo propuesto en la memoria.

**¿Qué hace especial a este script?**
Recibe los parámetros de la red (`tau_c`, `N_RIS` y `squareLength`), aplica instantáneamente la ecuación descrita en la memoria y descubierta en la investigación para calcular el radio óptimo ($R_{opt}$). Además, ejecuta una asignación exclusiva (1 a 1) entre RIS y usuario.

### 2. `launcher_simulacion.m` (Uso general)
Script diseñado para lanzar una simulación de un único escenario de forma sencilla. Permite cambiar parámetros libremente y elegir el modo de asignación de RIS:
- **`final`**: Usa el algoritmo del TFG calculando su propio radio óptimo.
- **`exclusive`**: Asignación 1 a 1 estricta (requiere proporcionar un radio manual).
- **`inclusive`**: Múltiples RIS pueden compartir a un mismo usuario (requiere radio manual).

Imprime el resultado final de eficiencia espectral (SE al 10% de CDF) directamente en la consola y, además, genera automáticamente la gráfica de la CDF guardándola en la carpeta `figures/`.

### 3. `launcher_busca_optimo.m` (Verificación de la Fórmula)
Es un script de comprobación para demostrar que la fórmula matemática del algoritmo funciona. 
Permite definir un escenario, y el script hará lo siguiente:
1. **Predice:** Imprime en consola cuál debería ser el radio óptimo según la fórmula del TFG.
2. **Simula:** Hace un barrido fino (precision de 5 metros) alrededor de esa predicción probando diferentes radios (usando internamente el modo `exclusive`).
3. **Verifica:** Al terminar, te dice a cuántos metros se ha quedado la fórmula de acertar en el radio de conectividad óptimo (con un error de aproximadamente 2,5 metros).
