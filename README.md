
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

**Pendiente de completar con datos del reporte de síntesis/place and route.**

En esta sección deben colocarse los recursos consumidos por el diseño final en la Tang Nano 9K, por ejemplo:

- LUTs utilizadas
- Flip-Flops utilizados
- Bloques de I/O
- Buffers o recursos de reloj
- Potencia estimada

> *Nota: Una vez ejecutada la síntesis con GOWIN o Yosys, se debe llenar esta tabla con los valores obtenidos.*

## 9. Reporte de velocidades máximas de reloj posibles en el diseño

**Pendiente de completar con datos del reporte temporal.**

El diseño fue construido para operar con el reloj de 27 MHz de la Tang Nano 9K. En esta sección debe indicarse la frecuencia máxima estimada por la herramienta de implementación, junto con el margen de operación respecto a la especificación mínima requerida.

> *Por ejemplo: “La herramienta reporta una frecuencia máxima de 120 MHz, lo que da un margen amplio respecto a los 27 MHz de operación.”*

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
