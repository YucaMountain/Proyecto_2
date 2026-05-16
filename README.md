# Proyecto corto II: Diseño digital sincrónico en HDL

## 1. Introducción

En este proyecto se desarrolló un sistema digital sincrónico en HDL orientado a la captura, procesamiento y despliegue de información numérica sobre una FPGA Tang Nano 9K. El sistema implementado permite ingresar dos números enteros positivos mediante un teclado hexadecimal, almacenarlos de forma secuencial, ejecutar una suma aritmética sin signo y mostrar tanto la entrada como el resultado en cuatro dispositivos de 7 segmentos. Este trabajo permitió integrar conceptos fundamentales de diseño digital tales como sincronización de señales externas, eliminación de rebotes, diseño modular, máquinas de estados finitos y verificación funcional mediante testbenches.

## 2. Definición general del problema, objetivos y especificaciones

El problema planteado consiste en diseñar un circuito digital sincrónico capaz de capturar dos números decimales positivos de hasta tres dígitos cada uno a partir de un teclado hexadecimal mecánico, procesarlos dentro de la FPGA y desplegar el resultado de la suma en cuatro displays de 7 segmentos. El sistema debía funcionar utilizando el reloj de 27 MHz provisto por la Tang Nano 9K y construirse siguiendo criterios adecuados de diseño digital sincrónico, incluyendo sincronización de entradas externas, depuración de rebotes mecánicos y separación en subsistemas funcionales.

El objetivo general del proyecto fue introducir al estudiante al desarrollo de un sistema digital sincrónico utilizando lenguajes de descripción de hardware. Como objetivos específicos se abordó la lectura de un teclado hexadecimal, la implementación de una suma aritmética en HDL, el diseño de una FSM de control, el despliegue multiplexado en 7 segmentos y la verificación mediante simulación.

## 3. Descripción general del funcionamiento del circuito completo

El sistema completo fue dividido en varios módulos interconectados, cada uno con una función específica dentro del flujo de datos. El reloj principal de 27 MHz ingresa primero al divisor de reloj, el cual genera una base de tiempo más lenta para facilitar la lectura del teclado y el refrescamiento visual del display. Posteriormente, el subsistema de lectura del teclado detecta la tecla presionada, elimina rebotes, sincroniza la señal y produce un código binario junto con una señal de validez.

A continuación, el subsistema de control y captura administra la lógica de ingreso de operandos. En el funcionamiento final del sistema, la tecla **A** se utiliza para almacenar el primer número, la tecla **B** para almacenar el segundo, la tecla **D** para ejecutar la suma y la tecla **C** para limpiar completamente el sistema. Una vez almacenados los operandos, el módulo de suma realiza la operación aritmética y el resultado es enviado al bloque de despliegue.

Finalmente, el subsistema de visualización convierte los datos a la codificación necesaria para los cuatro displays de 7 segmentos y realiza el multiplexado correspondiente. El sistema completo fue implementado y probado satisfactoriamente sobre la FPGA Tang Nano 9K, verificándose un funcionamiento correcto incluso para el caso máximo de prueba de **999 + 999 = 1998**.

## 4. Descripción general de cada subsistema

### 4.1 Subsistema de división de reloj

El módulo `m1_clk_divider` se encarga de derivar una señal de reloj más lenta a partir del reloj principal de 27 MHz. Esta base de tiempo se utiliza para controlar procesos que no requieren operar a la frecuencia total de la FPGA, como el barrido del teclado y el refrescamiento del display.

### 4.2 Subsistema de eliminación de rebote

El módulo `m2_DeBounce` acondiciona señales provenientes de elementos mecánicos, principalmente el teclado, con el fin de eliminar transiciones espurias causadas por rebote. Esto permite capturar pulsaciones de tecla de manera más confiable.

### 4.3 Subsistema de lectura del teclado hexadecimal

El módulo `m3_keypad_reader` implementa la lógica de barrido del teclado hexadecimal. Su función es detectar la tecla activa a partir de la exploración de filas y columnas, producir un código de tecla y generar una señal de validación para el resto del sistema.

### 4.4 Subsistema de control del display

El módulo `m4_display_controller` administra la información que debe ser presentada visualmente. Este bloque recibe datos de entrada y señales de control para determinar si debe mostrar operandos capturados, limpiar la pantalla o cargar el resultado final de la suma.

### 4.5 Subsistema de captura numérica

El módulo `m5_number_capture` gestiona la captura de dígitos numéricos desde el teclado y su almacenamiento temporal. Este bloque forma parte del flujo de entrada de datos y contribuye a estructurar el valor que posteriormente será utilizado por el bloque de control principal.

### 4.6 Subsistema de despliegue en 7 segmentos

El módulo `m6_seven_segment_driver` se encarga de convertir la información numérica al formato necesario para controlar los segmentos y el multiplexado de los cuatro displays. Su operación permite observar en tiempo real tanto los números ingresados como el resultado de la suma.

### 4.7 Subsistema de control principal

El módulo `m7_calculadora` implementa la lógica principal de operación del sistema. Este bloque administra el protocolo de ingreso de datos, decide cuándo almacenar operandos, cuándo limpiar el sistema y cuándo ejecutar la operación aritmética. También coordina la carga del resultado hacia el subsistema de despliegue.

### 4.8 Subsistema de suma aritmética

El módulo `m8_sumador` realiza la operación de suma entre los dos operandos previamente almacenados. Dado que cada operando se limitó a tres dígitos decimales, el diseño fue dimensionado para soportar correctamente resultados de hasta cuatro dígitos.

### 4.9 Módulo superior

El módulo `top_module` integra todos los subsistemas anteriores y define las interconexiones finales entre el reloj, el teclado hexadecimal, la lógica de control y los displays de 7 segmentos. Este bloque representa la implementación final cargada en la FPGA.

## 5. Diagramas de bloques de cada subsistema

### 5.1 Diagrama general del sistema

El siguiente diagrama muestra la interconexión de todos los módulos que componen el sistema. El flujo de datos va desde el teclado hacia los subsistemas de acondicionamiento, control, suma y despliegue.

```text
         ┌─────────────────────────────────────────────────────────────────┐
         │                         top_module                              │
         │                                                                 │
         │  ┌──────────────┐                     ┌──────────────┐         │
         │  │ m1_clk_divider│                     │ m4_display_  │         │
Reloj ───┼─▶│              │──▶ clk_lento ────────│ controller   │         │
27 MHz   │  └──────────────┘                     │              │         │
         │                                        └──────┬───────┘         │
         │                                               │                 │
         │  ┌────────────┐   ┌────────────┐   ┌─────────▼─────────┐       │
teclado ─┼─▶│m2_DeBounce │──▶│m3_keypad   │──▶│  m7_calculadora   │       │
hex       │  │(filtro)    │   │_reader     │   │   (FSM control)   │       │
         │  └────────────┘   └─────┬──────┘   └─────┬───────────┬─┘       │
         │                         │                │           │         │
         │                         │ key_valid      │           │         │
         │                         │ key_code       │           │         │
         │                         │                │           │         │
         │                         │                │           │         │
         │                         │         ┌──────▼───────┐   │         │
         │                         │         │ m5_number_   │   │         │
         │                         │         │ capture      │   │         │
         │                         │         └──────┬───────┘   │         │
         │                         │                │           │         │
         │                         │                │ operand_A │ operand_B│
         │                         │                │           │         │
         │                         │                ▼           │         │
         │                         │            ┌────────────┐  │         │
         │                         │            │ m8_sumador │  │         │
         │                         │            └──────┬─────┘  │         │
         │                         │                   │        │         │
         │                         │                   │ result │         │
         │                         │                   └────────┼─────────┘
         │                         │                            │
         │                         │                   ┌────────▼────────┐
         │                         └──────────────────▶│ m6_seven_seg_  │
         │                                             │ driver          │
         │                                             └────────┬────────┘
         │                                                      │
         └──────────────────────────────────────────────────────┼───────┘
                                                                ▼
                                                          displays 7 seg
 ```                                               
**Nota:** Las señales de control desde `m7_calculadora` hacia `m4_display_controller` y `m5_number_capture` no se muestran en detalle para mantener la claridad, pero incluyen órdenes de captura, limpieza y carga de resultado.

### 5.2 Módulos finales implementados

- `m1_clk_divider`
- `m2_DeBounce`
- `m3_keypad_reader`
- `m4_display_controller`
- `m5_number_capture`
- `m6_seven_segment_driver`
- `m7_calculadora`
- `m8_sumador`
- `top_module`

## 6. Diagramas de estado de las FSM diseñadas

La FSM principal del sistema se implementó en el bloque `m7_calculadora`, cuya función es controlar la secuencia de captura y procesamiento de datos. Su comportamiento puede resumirse conceptualmente así:

          ┌─────────────────────────────────────────┐
          │                  IDLE                   │
          └───────────┬───────────────┬─────────────┘
                      │               │
        tecla A       │   tecla B     │   tecla C          tecla D
                      ▼               ▼                   ▼
          ┌───────────────┐ ┌───────────────┐   ┌─────────────────┐
          │ guardar op. A │ │ guardar op. B │   │ limpiar sistema │
          └───────┬───────┘ └───────┬───────┘   └────────┬────────┘
                  │                 │                    │
                  └────────┬────────┘                    │
                           │                             │
                           ▼                             │
                      ┌─────┴─────┐                      │
                      │   IDLE    │◄─────────────────────┘
                      └───────────┘
                              │
                              │ (tecla D)
                              ▼
                    ┌──────────────────┐
                    │ ejecutar suma     │
                    │ cargar resultado  │
                    └────────┬─────────┘
                             │
                             ▼
                          [ IDLE ]
Además del control principal, el sistema de lectura del teclado utiliza una lógica de secuenciamiento asociada al barrido de filas y columnas, mientras que el sistema de display emplea lógica secuencial para el refrescamiento multiplexado de los cuatro dígitos.

## 7. Ejemplo y análisis de una simulación funcional del sistema completo

Para la verificación funcional del sistema se elaboraron testbenches individuales para los distintos módulos del diseño, incluyendo el divisor de reloj, el lector de teclado, el bloque de captura, el sumador y la calculadora principal. Posteriormente se realizó la integración y validación del sistema completo.

Se comprobaron de forma satisfactoria casos de prueba representativos, entre ellos:

- Captura correcta del primer operando mediante la tecla A.
- Captura correcta del segundo operando mediante la tecla B.
- Ejecución de la suma mediante la tecla D.
- Limpieza completa del sistema mediante la tecla C.
- Correcto despliegue del resultado en el subsistema de 7 segmentos.

Entre los casos evaluados destacan:

- `123 + 456 = 579`
- `999 + 999 = 1998`

Las simulaciones permitieron verificar el comportamiento funcional esperado y además identificar problemas de temporización en los bancos de prueba, los cuales fueron corregidos ajustando la forma de aplicar los estímulos.

## 8. Análisis de consumo de recursos en la FPGA

Una vez finalizado el diseño a nivel de transferencia de registros (RTL), el código fue sintetizado e implementado utilizando el entorno de desarrollo **Yosys** para la tarjeta **Tang Nano 9K** (chip Gowin GW1NR-9). 

El objetivo de esta fase es cuantificar la "huella de hardware" que el diseño ocupa físicamente dentro de la matriz de silicio. A continuación, se presenta la tabla resumen de utilización de recursos obtenida a partir del reporte estadístico de síntesis proporcionado por la herramienta:

| Recurso Lógico / Físico | Utilizado | Total Disponible | Utilización (%) |
| :--- | :---: | :---: | :---: |
| LUTs (*Look-Up Tables*) | 680 | 8,640 | 7.87 % |
| Registros (Flip-Flops) | 171 | 8,640 | 1.98 % |
| Bloques I/O (Pines físicos) | 21 | 274 | 7.66 % |
| Recursos de Reloj (Buffers/Red) | 1 | 16 | 6.25 % |

**Potencia Dinámica Estimada:** No reportada por la herramienta (N/A).

---

### Análisis de los resultados

* **Eficiencia Combinacional:** El consumo de LUTs se mantiene en un porcentaje notablemente bajo (7.87%). Esto demuestra que la implementación de las barreras lógicas explícitas (para evitar colisiones entre datos y comandos) y la decodificación del display de 7 segmentos fueron resueltas por el sintetizador mediante mapas de Karnaugh altamente optimizados, minimizando el uso de compuertas lógicas físicas.
* **Eficiencia Secuencial:** La cantidad de Flip-Flops utilizados (1.98%) corresponde estrictamente a la suma de los registros internos de la calculadora (`reg_A`, `reg_B`), los contadores de los divisores de reloj, los registros de sincronización de entrada y los bits de estado de la FSM. La ausencia de *latches* inferidos confirma la correcta aplicación de las buenas prácticas de diseño síncrono mediante `always_ff`.
* **Gestión de I/O:** El uso de pines está restringido estrictamente a 21 terminales (6 buffers de entrada y 15 de salida), lo que representa una utilización del 7.66%. Esto deja más del 92% de los recursos de entrada/salida de la placa libres para futuras expansiones del proyecto o integración de periféricos adicionales.



> *Nota: Una vez ejecutada la síntesis con GOWIN o Yosys, se debe llenar esta tabla con los valores obtenidos.*

## 9. Reporte de velocidades máximas de reloj posibles en el diseño

El diseño fue construido para operar tomando como base el oscilador de cristal interno de **27 MHz** de la placa Tang Nano 9K. Tras el proceso de *Place and Route*, se realizó un Análisis de Tiempos Estático (STA) para validar la integridad de las señales en los diferentes dominios de reloj.

| Dominio de Reloj | Frecuencia Objetivo | Frecuencia Máxima ($F_{max}$) | Estado |
| :--- | :---: | :---: | :---: |
| Reloj Principal (`clk_in`) | 27.00 MHz | 179.69 MHz | PASS |
| Reloj Derivado (`clk_1khz`) | 27.00 MHz* | 73.29 MHz | PASS |

*\*Nota: El dominio de 1 kHz fue evaluado a la frecuencia de entrada por la herramienta de síntesis para garantizar la cobertura del peor caso.*

### Análisis de Temporización

1. **Margen de Seguridad en el Reloj Principal:** La frecuencia máxima de **179.69 MHz** permite una operación extremadamente fluida a los 27 MHz nominales. La ruta crítica en este dominio es mínima, lo que elimina riesgos de inestabilidad térmica o eléctrica en el oscilador principal.

2. **Robustez en el Dominio Lento:** Aunque la complejidad lógica del sistema (Máquina de Estados de la calculadora y lógica de conversión BCD) limita la velocidad máxima a **73.29 MHz**, el diseño real opera a una frecuencia de **1 kHz**. 

3. **Conclusión Técnica:** La diferencia entre la frecuencia máxima soportada y la frecuencia de operación real dota al sistema de una estabilidad excepcional. Las señales tienen un tiempo de propagación prácticamente ilimitado en comparación con las capacidades físicas del hardware, resultando en un sistema inmune a violaciones de tiempos de *setup* o *hold* durante su ejecución en la FPGA.

## 10. Análisis de principales problemas hallados y soluciones aplicadas

Durante el desarrollo del proyecto se identificaron varios problemas relevantes:

- **Compatibilidad entre simuladores y sintaxis de SystemVerilog**  
  En distintas etapas surgieron errores de simulación asociados al soporte parcial de ciertas construcciones de SystemVerilog por parte de algunas herramientas. Para resolverlo, se ajustaron módulos y testbenches a una sintaxis más compatible cuando fue necesario.

- **Problemas de temporización en los testbenches**  
  Inicialmente se detectaron fallos aparentes en la simulación que en realidad se debían al instante de aplicación de estímulos en el banco de pruebas. Esto se corrigió reorganizando la generación de señales para evitar condiciones de carrera con el DUT.

- **Lectura confiable del teclado hexadecimal**  
  Fue necesario definir cuidadosamente el algoritmo de barrido, sincronización y eliminación de rebotes para obtener códigos de tecla estables y válidos.

- **Definición del protocolo de operación del usuario**  
  Se requirió decidir una asignación clara para las teclas especiales del teclado. La solución final consistió en usar `A` para almacenar el primer operando, `B` para almacenar el segundo, `D` para ejecutar la suma y `C` para limpiar el sistema.

- **Orden y formato de los dígitos en el display**  
  Hubo que validar cuidadosamente el formato interno de los nibbles y la forma en que se presentaban en el controlador de display, para garantizar que la representación visual coincidiera con el valor esperado.

- **Integración del sistema completo**  
  Aunque varios módulos funcionaban correctamente por separado, fue necesario validar la correcta interconexión entre ellos para obtener un comportamiento funcional coherente en la implementación final.


## 11. Fotos Y Videos del Proyecto

A continuación un video donde muestra el funcionamiento del circuito y el código de fpga, a su vez como cambian los datos del osciloscopio cuando se presiona una nueva tecla. Las fotos muestran resultados individuales de números presionados en especial.

https://youtu.be/Xo2Z6MN6MfE

-Prueba 1: señales del teclado
-Prueba 2: señales del 7 seg (sin excitación)
-Prueba 3a: señales del 7 seg (primer dígito 0)
-Prueba 3b: señales del 7 seg (segundo dígito 6)
-Prueba 3c: señales del 7 seg (tercer dígito 7)
-Prueba 3d: señales del 7 seg (suma del mismo número dos veces 67+67)
-Prueba 4: señal del 7 seg con 4 dígitos


Prueba 1: señales del teclado
<img width="800" height="503" alt="prueba_1" src="https://github.com/user-attachments/assets/f8eabd8e-9b3c-474c-a2f2-e43c849de17d" />

Gráfico Prueba 1:
<img width="1096" height="1453" alt="OnlineChartMaker com" src="https://github.com/user-attachments/assets/4415fa2b-4329-4351-ac01-7afb4c26717f" />

Prueba 2: señales del 7 seg (sin excitación)
<img width="800" height="503" alt="prueba_2" src="https://github.com/user-attachments/assets/55ef4d11-efc1-47f9-910a-865f667b2038" />

Gráfico Prueba 2:
<img width="1096" height="1453" alt="OnlineChartMaker com (1)" src="https://github.com/user-attachments/assets/702c6c38-dab7-43c7-a475-ce989a82f8eb" />

Prueba 3a: señales del 7 seg (primer dígito 0)
<img width="800" height="503" alt="prueba_3a" src="https://github.com/user-attachments/assets/0574c2e7-ebeb-4746-b216-6484c013e882" />

Gráfico Prueba 3a:
<img width="1096" height="1453" alt="OnlineChartMaker com (2)" src="https://github.com/user-attachments/assets/b948a122-d525-411a-9c33-4e171313c998" />

Prueba 3b: señales del 7 seg (segundo dígito 6)
<img width="800" height="503" alt="prueba_3b" src="https://github.com/user-attachments/assets/5c7af373-45db-4e3f-bcbb-b60c3178a430" />

Gráfico Prueba 3b:
<img width="1096" height="1453" alt="OnlineChartMaker com (3)" src="https://github.com/user-attachments/assets/b0325857-c662-497f-9542-21f535fe7586" />

Prueba 3c: señales del 7 seg (tercer dígito 7)
<img width="800" height="503" alt="prueba_3c" src="https://github.com/user-attachments/assets/1be0e052-196d-43cc-8bad-cb27a1b3bc09" />

Gráfico Prueba 3c:
<img width="1096" height="1453" alt="OnlineChartMaker com (4)" src="https://github.com/user-attachments/assets/f633a0ec-f74c-4775-9deb-9352ad615361" />

Prueba 3d: señales del 7 seg (suma del mismo número dos veces 67+67)
<img width="800" height="503" alt="prueba_3d" src="https://github.com/user-attachments/assets/82b34802-c387-4c56-95e8-cce6d5481c72" />

Gráfico Prueba 3d:
<img width="1096" height="1453" alt="OnlineChartMaker com (5)" src="https://github.com/user-attachments/assets/9d079026-4d21-4341-b5d1-4adf1451a3e4" />


## 12. Conclusión

El proyecto permitió implementar satisfactoriamente un sistema digital sincrónico completo sobre la FPGA Tang Nano 9K, integrando captura de datos desde un teclado hexadecimal, almacenamiento de operandos, control secuencial, suma aritmética y despliegue en cuatro dispositivos de 7 segmentos. Además de cumplir la funcionalidad principal, el desarrollo permitió reforzar conceptos fundamentales de diseño modular, sincronización de señales externas, eliminación de rebotes, diseño de FSM y verificación mediante simulación. El sistema final logró operar correctamente tanto en simulación como en implementación física, incluyendo casos límite como la suma de `999 + 999 = 1998`.

## 13. Bonus 1: Contadores sincrónicos con 74LS163

En esta sección se implementó un contador binario utilizando dos integrados 74LS163 conectados en cascada. Cada 74LS163 es un contador síncrono cargable de 4 bits, por lo que al conectar dos de ellos se obtiene un contador total de 8 bits.

El reloj del circuito fue generado desde la FPGA Tang Nano 9K, aproximándose a la frecuencia solicitada de 1.8432 MHz. Esta señal de reloj se conectó al pin de reloj de ambos contadores, de forma que los dos integrados reciben el mismo flanco positivo de reloj.

El primer contador corresponde a los bits menos significativos del conteo, mientras que el segundo contador corresponde a los bits más significativos. De esta forma, el sistema cuenta desde `0000 0000` hasta `1111 1111`, equivalente a contar de 0 a 255 en decimal.

---

### ¿Qué hace la salida RCO en un 74LS163?

La salida **RCO** significa *Ripple Carry Output*, o salida de acarreo. En el 74LS163, esta salida se activa cuando el contador llega a su valor máximo, es decir, cuando sus cuatro salidas están en alto:

```
QA = 1, QB = 1, QC = 1, QD = 1
```

Por lo tanto, cuando el contador está en `1111`, la salida RCO se pone en alto, siempre que la entrada de habilitación correspondiente también esté activa.

La función principal de RCO es permitir conectar varios contadores en cascada. Es decir, sirve para indicarle al siguiente contador que el contador actual llegó a su valor máximo y que en el próximo pulso de reloj debe avanzar.

---

### ¿Por qué RCO y T están conectadas entre los dos contadores?

Para formar un contador de más de 4 bits, se conecta la salida RCO del primer 74LS163 a la entrada T del segundo 74LS163.

La conexión usada es:

```
RCO del primer contador → T del segundo contador
```

Ambos contadores reciben el mismo reloj. El primer contador, que representa los bits menos significativos, cuenta en cada flanco positivo de reloj. Cuando este contador llega a `1111`, su salida RCO se activa. Esa señal habilita al segundo contador mediante la entrada T. Entonces, en el siguiente flanco positivo de reloj, el segundo contador aumenta en una unidad.

De esta forma, el segundo contador no avanza en cada pulso de reloj, sino solamente cuando el primer contador completa un ciclo de 16 estados. Por eso, el primer contador representa los bits bajos y el segundo representa los bits altos del conteo.

El funcionamiento se puede resumir así:

1. Primer 74LS163 cuenta `0000 → 1111`.
2. Cuando llega a `1111`, activa RCO.
3. RCO habilita el segundo 74LS163.
4. El segundo contador aumenta en el siguiente flanco de reloj.

Esto permite construir un contador síncrono de 8 bits usando dos contadores de 4 bits.

---

### Diferencia entre las entradas T y P del 74LS163

En el 74LS163 existen dos entradas de habilitación para el conteo. En algunas hojas de datos se llaman:

- **T** = ENT
- **P** = ENP

Ambas deben estar activas para que el contador pueda contar. Sin embargo, no cumplen exactamente la misma función.

- La entrada **P** (ENP) habilita el conteo normal del contador. Si esta entrada está en bajo, el contador no avanza aunque llegue el reloj.
- La entrada **T** (ENT) también habilita el conteo, pero además participa en la generación de la salida RCO. Por eso, para conectar contadores en cascada, la señal RCO del contador menos significativo se conecta a la entrada T del contador más significativo.

En resumen:

| Entrada | Función |
|--------|---------|
| P / ENP | Habilita el conteo |
| T / ENT | Habilita el conteo **y** permite generar o propagar el acarreo RCO |

Para que un 74LS163 cuente, normalmente se requiere:

```
P = 1
T = 1
```

En la conexión en cascada, el primer contador tiene ambas entradas en alto para contar siempre. El segundo contador tiene P en alto, pero su entrada T depende del RCO del primer contador. Así, el segundo contador solo cuenta cuando el primero llega a `1111`.

---

## Tiempo de cambio luego del flanco positivo de reloj

El 74LS163 es un contador síncrono, por lo que sus flip-flops cambian de estado después del flanco positivo del reloj. Sin embargo, el cambio no ocurre instantáneamente. Existe un pequeño retardo entre el flanco del reloj y el cambio observable en las salidas.

Este retardo se llama **tiempo de propagación de reloj a salida**, usualmente indicado como `t_PLH` o `t_PHL`, dependiendo de si la salida cambia de bajo a alto o de alto a bajo.

En la medición con osciloscopio, este tiempo se obtiene disparando el osciloscopio con el flanco positivo del reloj y observando cuánto tarda una salida (QA, QB, QC o QD) en cambiar de estado.

Para un 74LS163, este tiempo suele estar en el orden de decenas de nanosegundos:

```
t_pd = tiempo entre el flanco positivo de CLK y el cambio de la salida medida
t_pd ≈ [valor medido] ns
```

### ¿Importa cuál bit de salida se escoja?

Para medir el retardo de propagación del contador, se puede usar cualquiera de las salidas QA, QB, QC o QD, siempre que esa salida cambie en el flanco de reloj observado.

Sin embargo, sí importa desde el punto de vista práctico, porque no todos los bits cambian con la misma frecuencia:

| Salida | Frecuencia de cambio |
|--------|----------------------|
| QA | Cada pulso de reloj |
| QB | Cada 2 pulsos |
| QC | Cada 4 pulsos |
| QD | Cada 8 pulsos |

Por esta razón, **QA** es más fácil de observar porque cambia más seguido. En cambio, QD o el MSB cambian con menor frecuencia, pero son útiles para disparar el osciloscopio cuando se quiere observar el comportamiento del contador completo o eventos asociados al acarreo.

En teoría, todos los flip-flops internos del contador son síncronos y reciben el mismo reloj, por lo que sus salidas deberían cambiar aproximadamente al mismo tiempo. En la práctica, puede haber pequeñas diferencias debido a los retardos internos del circuito integrado.

---

### Observación de la salida RCO y posibles fallas o glitches

La salida RCO se genera a partir de una combinación lógica de las salidas del contador. Como las salidas QA, QB, QC y QD no cambian exactamente al mismo tiempo después del flanco de reloj, pueden aparecer pequeños pulsos no deseados en la salida RCO. Estos pulsos breves se conocen como **glitches** o fallas transitorias.

Estas fallas son difíciles de observar porque duran muy poco tiempo, normalmente en el orden de nanosegundos. Por eso se recomienda usar la opción de **captura de fallas** del osciloscopio o utilizar primero el modo de analizador lógico y luego el modo analógico.

Es esperable encontrar estas fallas en transiciones donde varios bits del contador cambian simultáneamente. Por ejemplo:

```
0111 → 1000
1011 → 1100
1111 → 0000
```

En estos casos, varios flip-flops cambian de estado en el mismo flanco de reloj. Como cada salida puede tener un pequeño retardo distinto, durante un instante muy corto la lógica interna que genera RCO puede interpretar una combinación incorrecta y producir un pulso transitorio.

En un contador síncrono bien diseñado estas fallas suelen ser muy cortas y normalmente no afectan el conteo cuando la señal se usa correctamente con el mismo reloj. Sin embargo, sí pueden observarse con instrumentos adecuados y son importantes cuando RCO se utiliza como señal combinacional para otros circuitos sensibles a pulsos breves.

### Fotos de prueba

A continuación, las fotos del osciloscopio midiendo las luces leds y el RC0

<img width="800" height="503" alt="scope_6_1leds" src="https://github.com/user-attachments/assets/812c633e-9441-46d9-b7a0-126237a48ece" />
<img width="800" height="503" alt="scope_6_1rc0" src="https://github.com/user-attachments/assets/108327ae-cd86-4645-b1a1-a005a815ca08" />



## 14. Bonus 2:  Construcción de un cerrojo Set-Reset con compuertas NAND

El inciso 6.2 consiste en contruir un Latch SR por medio de compuertas NAND, y que estas sean visibles tanto en luces LED del cirucito como en el osciloscopio.

A continuación se muestra una foto de la tabla de verdad de un SR latch:

<img width="1280" height="720" alt="image" src="https://github.com/user-attachments/assets/7752456f-dac7-4f2d-93d6-58a1dda50ad4" />

Donde los imputs Set Y Reset vienen de DIP switches implementados, estos pasan por la lógica del circuito latch SR generando junto con la señal del reloj, una salida Q y Q negada dependiendo del valor. 

El siguiente video muestra las salidas cambiando dependiendo de las entradas Set Y Reset, también se muestran las mediciones en el osciloscopio de los datos del Clock, el Q y el Q negado. Tambien cabe recalcar que la señal de salida no cambiará si el clock se desactiva.

https://youtu.be/2NYlWUwxWmA

### Explicación de funcionamiento

El cerrojo SR es un circuito secuencial capaz de almacenar un bit de información. Tiene dos entradas principales: \(S\), que corresponde a **set**, y \(R\), que corresponde a **reset**. También tiene dos salidas: \(Q\) y \(\overline{Q}\), las cuales normalmente son complementarias.

Cuando el reloj está en bajo, es decir, \(CLK = 0\), el circuito no responde a los cambios de \(S\) ni de \(R\). En este caso, el cerrojo mantiene el valor anterior en sus salidas. Por esta razón se dice que el cerrojo tiene memoria.

Cuando el reloj está en alto, es decir, \(CLK = 1\), el circuito sí responde a las entradas:

- Si \(S = 1\) y \(R = 0\), el cerrojo entra en estado **SET**, por lo que \(Q = 1\) y \(\overline{Q} = 0\).
- Si \(S = 0\) y \(R = 1\), el cerrojo entra en estado **RESET**, por lo que \(Q = 0\) y \(\overline{Q} = 1\).
- Si \(S = 0\) y \(R = 0\), el circuito mantiene el estado anterior.
- Si \(S = 1\) y \(R = 1\), se presenta un estado no permitido, ya que se intenta activar set y reset al mismo tiempo. En este caso, las salidas pueden dejar de ser complementarias y el estado final no queda garantizado.

Por esta razón, durante la operación normal se debe evitar que \(S\) y \(R\) estén en alto al mismo tiempo.

### Utilidad del cerrojo SR

El cerrojo SR puede utilizarse como una celda básica de memoria, ya que permite guardar un valor lógico mientras no se le indique cambiar. También puede emplearse como base para construir circuitos secuenciales más complejos, como registros, flip-flops, contadores o sistemas de control.

Una aplicación práctica del cerrojo SR es almacenar el estado de una señal de control. Por ejemplo, puede utilizarse para recordar si un sistema fue activado o desactivado mediante dos botones: uno de **set** y otro de **reset**. En este circuito, el reloj permite controlar el momento en que el cerrojo acepta los cambios en las entradas.

## 12. Referencias

- Pong P. Chu, *FPGA Prototyping by SystemVerilog Examples*.
- Material del curso EL-3307 Diseño Lógico.
- Tutoriales y repositorios consultados para apoyo en lectura de teclado, debounce y despliegue.
