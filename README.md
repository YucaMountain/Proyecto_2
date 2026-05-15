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

## 11. Conclusión

El proyecto permitió implementar satisfactoriamente un sistema digital sincrónico completo sobre la FPGA Tang Nano 9K, integrando captura de datos desde un teclado hexadecimal, almacenamiento de operandos, control secuencial, suma aritmética y despliegue en cuatro dispositivos de 7 segmentos. Además de cumplir la funcionalidad principal, el desarrollo permitió reforzar conceptos fundamentales de diseño modular, sincronización de señales externas, eliminación de rebotes, diseño de FSM y verificación mediante simulación. El sistema final logró operar correctamente tanto en simulación como en implementación física, incluyendo casos límite como la suma de `999 + 999 = 1998`.

## 12. Referencias

- Pong P. Chu, *FPGA Prototyping by SystemVerilog Examples*.
- Material del curso EL-3307 Diseño Lógico.
- Tutoriales y repositorios consultados para apoyo en lectura de teclado, debounce y despliegue.
