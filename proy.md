# **Estrategias de Desarrollo y Arquitectura de Proyectos para el Hackatón CALL-E: Integración de Call Analyzer y el Modelo HumanAgentCard**

## **Análisis de la Infraestructura Tecnológica de CALL-E y Capacidades Base**

El ecosistema CALL-E, concebido por la empresa AI Rudder, constituye una evolución sustancial en la intersección entre la telefonía tradicional y los agentes autónomos basados en modelos de lenguaje1. A diferencia de los sistemas de respuesta de voz interactiva (IVR) convencionales o las plataformas telefónicas basadas en scripts estáticos, CALL-E está diseñado como una capa de infraestructura orientada a tareas de larga duración guiadas por objetivos específicos (*goal-driven long tasks*)2. La arquitectura del sistema traduce intenciones expresadas en lenguaje natural en ejecuciones telefónicas complejas sobre la red telefónica conmutada (PSTN), gestionando de forma dinámica las interrupciones, las fluctuaciones de tono, la detección de buzones de voz y la navegación en menús audibles en tiempo real3.  
Desde la perspectiva de la integración de sistemas, CALL-E proporciona un abanico diversificado de interfaces que abarcan el protocolo de contexto de modelos (MCP \- *Model Context Protocol*), bibliotecas cliente de servidor para TypeScript (@call-e/calle) y Python (calle-ai), complementos para entornos de desarrollo (Cursor, Claude Code, OpenClaw) e interfaces de programación de aplicaciones (API) REST públicas para servicios del lado del servidor1.

| Superficie de Integración | Paquete / Componente | Herramientas / Endpoints Principales | Casos de Uso Recomendados |
| :---- | :---- | :---- | :---- |
| **Model Context Protocol (MCP)** | Servidor MCP Remoto / CLI (@call-e/cli)4 | plan\_call, run\_call, get\_call\_run \[cite: 4\] | Agentes de escritorio, asistentes en IDEs, flujos conversacionales dinámicos1. |
| **Server SDK (TypeScript)** | @call-e/calle (v0.2.0)4 | client.calls.createAndWait(), client.calls.create() \[cite: 4\] | Backends NodeJS/NextJS, orquestadores de microservicios, eventos asíncronos4. |
| **Server SDK (Python)** | calle-ai (v0.2.0)4 | CalleClient(api\_key=...), gestión de llamadas4 | Pipelines de datos, modelos de Machine Learning, flujos agénticos en Python4. |
| **REST API Directa** | https://api.heycall-e.com \[cite: 4\] | POST /v1/calls, GET /v1/calls/{call\_id}, POST /calle/webhook \[cite: 4\] | Integración en CRMs, automatizaciones serverless, webhooks de estado terminal3. |

El ciclo de vida de una llamada ejecutada mediante CALL-E no se limita a la marcación telefónica. El motor inicia con una fase de aclaración inteligente del objetivo si faltan datos fundamentales en el prompt del usuario (como el destinatario, la hora, el idioma o los criterios de éxito)4. Posteriormente, la infraestructura gestiona la provisión y gobernanza de números telefónicos3, ejecuta la llamada manteniendo un runtime de voz realista y empático3, y retorna un objeto estructurado (structured\_result) guiado por un esquema JSON estricto definido por el desarrollador, complementado con transcripciones completas y metadatos de telemetría4.

## **Integración Teórica del Repositorio Altur: Paradigma HumanAgentCard y Análisis Sintáctico/Semántico**

El análisis del repositorio altur y los planteamientos conceptuales asociados revelan una postura crítica hacia los patrones de diseño predominantes en la interacción humano-agente6. Específicamente, se señala que la implementación del "botón de aprobación" (*approve button*) representa una falla estructural de usabilidad y escala, ya que interrumpe constantemente al operador humano para autorizar decisiones repetitivas, degradando la eficiencia del sistema autónomo6. Como alternativa superior, se propone el modelo **HumanAgentCard**6.  
El marco *HumanAgentCard* sustituye la supervisión explícita e síncrona por un proceso de aprendizaje implícito basado en la observación6. Durante las etapas iniciales de operación, el sistema detecta ambigüedades o excepciones en la ejecución de las tareas y escala la consulta al usuario humano6. Al analizar la respuesta y el comportamiento de resolución del operador, el agente deduce reglas de negocio no codificadas explícitamente (como umbrales de costos aceptables, políticas de confirmación o tolerancia a cambios en horarios)6. Con cada observación, la métrica de confianza asociada a esa categoría de decisión se incrementa gradualmente6. Cuando la confianza supera un umbral prestablecido, el agente asume la autonomía completa, ejecutando la acción directamente sin notificar ni interrumpir al humano6.  
Adicionalmente, el trasfondo técnico reflejado en el trabajo con analizadores sintácticos estrictos (como los parsers PEG)7 y representaciones vectoriales avanzadas (como los arquitecturas RAG basadas en codificadores JEPA)6 proporciona una base matemática sólida. Esta capacidad resulta decisiva para analizar la calidad de las transcripciones emitidas por CALL-E, verificar el cumplimiento de gramáticas conversacionales estrictas y evaluar la alineación semántica entre la intención inicial del usuario y el resultado final obtenido en la llamada4.

## **Propuestas Estratégicas de Proyectos para el Hackatón**

Con el objetivo de maximizar el impacto en el hackatón "CALL-E: Your Code Is Calling"9, se han diseñado tres propuestas de proyecto diferenciadas. Cada opción combina las capacidades de llamada orientadas a objetivos de CALL-E3 con los avances conceptuales del repositorio altur6.

### **Propuesta 1 (Recomendada): VoiceCard AI — Agente Telefónico Autónomo con Aprendizaje Implícito de Preferencias y Umbrales de Confianza**

VoiceCard AI es un orquestador de voz que utiliza el SDK y las APIs de CALL-E para ejecutar tareas telefónicas del mundo real (como negociaciones con proveedores, reservas complejas, cualificación de prospectos o coordinación logística)1, mientras integra el motor *HumanAgentCard* para aprender progresivamente las políticas operativas del usuario6.  
En lugar de solicitar autorización humana antes de realizar una llamada o al aceptar condiciones sobre la línea (por ejemplo, un recargo por cambio de reserva o una ventana de entrega modificada)1, VoiceCard AI evalúa su nivel de confianza histórico para esa categoría de tarea6. Si la confianza es baja, consulta al usuario, registra la decisión y actualiza su matriz de reglas implícitas6. Si la confianza es alta, el agente ejecuta la llamada directamente mediante CALL-E, toma las decisiones negociadas dentro de los márgenes aprendidos y entrega el resultado estructurado final4. Esta propuesta ataca de manera directa el problema de la fricción operativa en agentes de voz, transformando a CALL-E de una simple herramienta de llamadas a un colaborador autónomo adaptable3.

### **Propuesta 2: CallGuard JEPA — Analizador Semántico en Tiempo Real y Auditor de Alucinaciones Telefónicas**

CallGuard JEPA es una plataforma de auditoría y análisis de calidad conversacional diseñada para monitorear ejecuciones telefónicas realizadas por CALL-E en sectores altamente regulados como la banca, los seguros y la atención médica3.  
El sistema consume los eventos en tiempo real de las llamadas (GET /v1/calls/{call\_id}/events) y las transcripciones finales generadas por la infraestructura4. Utilizando un motor de evaluación basado en la arquitectura de predicción de incrustaciones conjuntas (JEPA) y reglas gramaticales PEG estricta6, CallGuard JEPA compara la trayectoria conversacional contra el objetivo original y las normativas de cumplimiento. La plataforma detecta desviaciones, promesas no autorizadas hechas por la IA o alucinaciones durante la llamada, generando un informe de riesgo y un certificado de auditoría auditable inmediatamente después de que concluye la comunicación4.

### **Propuesta 3: Altur-Voice Ops — Sistema de Resiliencia Operativa y Conmutación por Error a Red Telefónica**

Altur-Voice Ops actúa como un plano de control de resiliencia para infraestructuras digitales y flujos de trabajo orientados a eventos. Cuando un servicio web crítico, un webhook o una API de integración entre sistemas experimenta una falla prolongada o interrumpe un acuerdo de nivel de servicio (SLA), el sistema activa de forma autónoma una vía de mitigación basada en voz4.  
Haciendo uso de las herramientas del protocolo MCP de CALL-E (plan\_call y run\_call)4, Altur-Voice Ops realiza una llamada telefónica directa a los equipos de soporte de guardia, proveedores de TI o administradores de sistemas1. El agente conversacional explica la naturaleza del incidente técnico, recopila instrucciones verbales de resolución, navega sistemas IVR de escalación si es necesario y ejecuta las acciones de recuperación indicadas, puentando de forma transparente el mundo digital de las APIs con el canal físico telefónico3.

## **Arquitectura Técnica Detallada y Ciclo de Vida del Dato para VoiceCard AI**

Debido a su perfecta alineación con el modelo *HumanAgentCard* y su capacidad para demostrar un uso completo de las capacidades de CALL-E4, se presenta la arquitectura detallada para la implementación de la **Propuesta 1 (VoiceCard AI)**.

### **Componentes del Sistema**

| Componente | Tecnología | Función dentro del Sistema |
| :---- | :---- | :---- |
| **Panel de Gestión y Contexto** | Next.js / React / TypeScript | Dashboard para la definición de objetivos de negocio, visualización de llamadas y matriz de confianza4. |
| **Motor HumanAgentCard** | Python / Node.js | Módulo encargado de calcular los niveles de confianza, extraer reglas de interacción y gestionar el perfil de autonomía del usuario6. |
| **Orquestador de Voz** | @call-e/calle (TS SDK v0.2.0)4 | Despacho de tareas telefónicas (createAndWait), definición de esquemas output\_schema y consumo de webhooks4. |
| **Runtime de Telefonía** | Infraestructura CALL-E (AI Rudder) | Manejo de la llamada sobre la red PSTN, emulación de voz realista, supresión de ruido y gestión de interrupciones1. |
| **Capa de Persistencia** | PostgreSQL / Redis | Almacenamiento del historial de llamadas, transcripciones, datos estructurados y reglas de decisión implícitas4. |

### **Ciclo de Vida del Dato y Flujo de Autonomía**

El ciclo operativo inicia cuando un usuario o un sistema externo ingresa un objetivo telefónico en lenguaje natural, como por ejemplo: *"Llamar a la distribuidora para cambiar la fecha de entrega del pedido C1023 al viernes a las 9 AM y verificar si aplican recargos"*1.

> 1. **Evaluación de Confianza**: El motor *HumanAgentCard* intercepta la solicitud y consulta la base de conocimiento para la categoría "Gestión de Pedidos y Proveedores"6. Se calcula la puntuación de confianza ![][image1] combinando la frecuencia de decisiones previas similares y la tasa de éxito registrada.  
> 2. **Determinación del Modo de Ejecución**: Si ![][image1] es menor al umbral operativo (ejemplo: ![][image2]), el sistema realiza una pausa preventiva y formula una pregunta puntual al usuario para acotar los márgenes de negociación4. Si ![][image3], el sistema procede inmediatamente a la ejecución sin solicitar intervención alguna6.  
> 3. **Invocación del SDK de CALL-E**: Se construye la petición hacia la infraestructura de CALL-E invocando el método createAndWait o la API REST POST /v1/calls, adjuntando un esquema estricto de validación para garantizar la estructura del resultado4.

TypeScript  
import { CalleClient } from "@call-e/calle";

const client \= new CalleClient({  
  apiKey: process.env.CALLE\_API\_KEY\!,  
});

async function ejecutarTareaTelefonicadeAutonomia(  
  numeroTelefono: string,   
  instruccionObjetivo: string  
) {  
  const resultadoLlamada \= await client.calls.createAndWait({  
    task: instruccionObjetivo,  
    recipient: {  
      phone\_number: numeroTelefono,  
    },  
    output\_schema: {  
      type: "object",  
      properties: {  
        pedido\_modificado: { type: "boolean" },  
        nueva\_hora\_confirmada: { type: "string" },  
        aplica\_penalizacion: { type: "boolean" },  
        monto\_penalizacion: { type: "number" },  
        resumen\_conversacion: { type: "string" }  
      },  
      required: \["pedido\_modificado", "aplica\_penalizacion"\]  
    }  
  });

  return resultadoLlamada;  
}

> 4. **Ejecución sobre PSTN y Recepción de Webhooks**: CALL-E realiza la llamada telefónica en vivo, procesando el diálogo mediante su motor agéntico de voz3. Al finalizar la interacción, la plataforma envía una notificación webhook al servidor (POST /calle/webhook) conteniendo la transcripción, la telemetría del audio y el objeto structured\_result4.  
> 5. **Ajuste Implícito de Reglas y Confianza**: El motor *HumanAgentCard* analiza el resultado retornado por CALL-E4. Si el proveedor aceptó el cambio imponiendo un recargo dentro de los límites implícitos previamente observados6, el sistema registra el evento como una confirmación exitosa, incrementa el valor de confianza ![][image1] en la tarjeta del usuario y fortalece la regla de autonomía para futuras llamadas similares6.

## **Evaluación Comparativa de Proyectos**

| Criterio de Evaluación | Opción 1: VoiceCard AI (Recomendada) | Opción 2: CallGuard JEPA | Opción 3: Altur-Voice Ops |
| :---- | :---- | :---- | :---- |
| **Innovación Arquitectónica** | **Sobresaliente**: Elimina la supervisión síncrona mediante aprendizaje implícito de decisiones6. | **Alta**: Aporta rigor técnico con auditoría de voz y representaciones semánticas6. | **Media-Alta**: Aplicación práctica directa de resiliencia y conmutación a telefonía4. |
| **Uso de la Plataforma CALL-E** | **Extensivo**: Requiere creación de llamadas, esquemas de salida estrictos y webhooks4. | **Medio-Alto**: Centrado en la lectura y evaluación de eventos y transcripciones4. | **Alto**: Utiliza herramientas del protocolo MCP (plan\_call, run\_call) en tiempo real4. |
| **Viabilidad en Hackatón** | **Alta**: La lógica de confianza se implementa sobre bases de datos ligeras junto al SDK de CALL-E4. | **Media**: El ajuste finos de representaciones JEPA requiere mayor tiempo de preparación6. | **Alta**: Requiere simular fallas en servicios web para disparar la llamada4. |
| **Alineación con Repositorio altur** | **Perfecta**: Traslada directamente el paradigma *HumanAgentCard* a agentes de voz6. | **Alta**: Reutiliza la experiencia en parsers gramaticales y codificación vectorial6. | **Media**: Enfoque predominantemente orientado a infraestructura de TI. |

## **Hoja de Ruta Ejecutiva para la Implementación en el Hackatón**

Para garantizar una ejecución eficiente durante el desarrollo del hackatón "CALL-E: Your Code Is Calling"9, se establece una hoja de ruta estructurada en cuatro fases secuenciales de trabajo.

### **Fase 1: Configuración de Infraestructura y Conectividad de Voz (Horas 0 a 12\)**

La primera fase se centra en la preparación del entorno de desarrollo y la verificación de las integraciones base. Se realiza la instalación de los paquetes oficiales del SDK @call-e/calle o calle-ai y la configuración de las credenciales CALLE\_API\_KEY4. Se procede a ejecutar llamadas de prueba iniciales sobre números de prueba para validar la correcta transmisión de parámetros, el comportamiento del tiempo de ejecución en la red telefónica y la recepción de eventos de estado terminal a través de webhooks (POST /calle/webhook)4.

### **Fase 2: Desarrollo del Motor HumanAgentCard y Lógica de Confianza (Horas 12 a 28\)**

En esta etapa se implementa el modelo de datos correspondiente a la tarjeta del operador (*HumanAgentCard*)6. Se codifica la matriz de perfiles de usuario, el cálculo del índice de confianza ![][image1] y el módulo de inferencia de reglas implícitas6. Asimismo, se desarrolla la lógica de derivación que decide si una tarea telefónica se envía directamente al SDK de CALL-E con un output\_schema definido o si requiere una fase previa de aclaración con el usuario4.

### **Fase 3: Construcción de la Interfaz y Casos de Uso (Horas 28 a 40\)**

Durante este bloque se construye la interfaz gráfica de usuario en Next.js, diseñada para mostrar el estado en vivo de las llamadas gestionadas por CALL-E, la transcripción en tiempo real y la evolución gráfica de los niveles de autonomía del agente4. Se preparan y calibran dos escenarios de demostración del mundo real: la modificación de un pedido con un proveedor comercial y la gestión de una cita de servicio con restricciones específicas1.

### **Fase 4: Validación, Pruebas Integrales y Preparación de la Demostración (Horas 40 a 48\)**

La fase final se destina a la ejecución de pruebas de extremo a extremo realizando llamadas telefónicas reales a través de CALL-E3. Se graba el flujo de demostración destacando el factor diferenciador principal: en la primera interacción, el sistema consulta al usuario para aprender su criterio; en la segunda interacción idéntica, el motor *HumanAgentCard* detecta el incremento en la puntuación de confianza y ejecuta la llamada de forma 100% autónoma, entregando el resultado estructurado sin interrumpir al operador4.

#### **Works cited**

> 1. How to Use \- CALL-E, [https://www.heycall-e.com/how-to-use/](https://www.heycall-e.com/how-to-use/)  
> 2. Freelancer Developer Advocate(A74677) Job in San Francisco, CA at AI Rudder, [https://www.ziprecruiter.com/c/AI-Rudder/Job/Freelancer-Developer-Advocate(A74677)/-in-San-Francisco,CA?jid=0b6c7e9b2a1dcb1d](https://www.ziprecruiter.com/c/AI-Rudder/Job/Freelancer-Developer-Advocate\(A74677\)/-in-San-Francisco,CA?jid=0b6c7e9b2a1dcb1d)  
> 3. CALL-E | AI Voice Agent for Business Communication, [https://www.heycall-e.com/](https://www.heycall-e.com/)  
> 4. CALLE-AI/call-e-integrations \- GitHub, [https://github.com/CALLE-AI/call-e-integrations](https://github.com/CALLE-AI/call-e-integrations)  
> 5. @call-e/cli | Yarn, [https://classic.yarnpkg.com/en/package/@call-e/cli](https://classic.yarnpkg.com/en/package/@call-e/cli)  
> 6. The Human as an Agent: Why the “APPROVE” Button Is a Design Mistake | by Enrique Meza, [https://medium.com/@emezac/the-human-as-an-agent-why-the-approve-button-is-a-design-mistake-e38e9b236f13](https://medium.com/@emezac/the-human-as-an-agent-why-the-approve-button-is-a-design-mistake-e38e9b236f13)  
> 7. pgn · GitHub Topics, [https://github.com/topics/pgn?l=java\&o=asc\&s=stars](https://github.com/topics/pgn?l=java&o=asc&s=stars)  
> 8. pgn · GitHub Topics, [https://github.com/topics/pgn?l=java\&o=asc\&s=updated](https://github.com/topics/pgn?l=java&o=asc&s=updated)  
> 9. Hackathons and student competitions in Thailand \- Rally, [https://rally.kamolpop.dev/en/hackathons](https://rally.kamolpop.dev/en/hackathons)

[image1]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAaCAYAAAC+aNwHAAAAuElEQVR4XmNgGPZAGogLgHgmECshiVshsbGCxUD8H4hvA7E3EKsC8TQgfg7EllA5nAAk+Q+I+dElgKCSASJ/CV0CBv4wEDCdASIfhC4IAh8YIJKc6BJoAKsFugwQiVvoElgAVgP+MkAksPmbKADSjNVkYgFFBjAzQDS/RJfAAnBaQowLLIA4AV0QBu4yQAwAuQYbAIm/QhdEByADQAkJ3RAjIH6NJoYT7GZAeOcrlE5FUTEKRgEtAAA6VitB6iN1UwAAAABJRU5ErkJggg==>

[image2]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACYAAAAZCAYAAABdEVzWAAABsklEQVR4Xu2VPShGURjHHyUfKVEWm5ASg2JSJpkkWXyVCaWMNmUxKQYGE4uy2WQTm3yUokRkkmRQikIi/k/nHJ73cZ/rvokM91e/3vP8z7nvOfee9z2XKOX/0KGDCBp08JvUwSf/+QKbMrs/OINdOtQcwh04CgdgH+yFPV7JBLyDD3BQ9TFvsMq3S+EjfIVjsA0u+DHXfkwsPNDyVow7huuiPoJbomb4Gqsu95/8RBPBF7eQe/zVsNIrv7RY1QHOSny7zNcSXY9Tgi0M7OsAbMN6UR/Q10kYzhZVLZF1LiXcQotmuKKysLUanT/Dft9uhcOq70ckWUAgKud6Gd6IbBJ2ijprlryaqAUwVi7Jg1eiriX3r94U2bfwJBU6JHsBVi7h8ywg/0RF8ET0mQyRPYm1ACsPTMF2UV/AVVGfi7YJn8bWJPcU3ceZddcF8FJlPH5e1LOibRJ3990U3cdZow49fOJr9MLmRNskbmEM942IetpnUcyQOy40u3BN1Im2kieRP1RNIbkxe+Ter/xqyckY4eAttCbMp8+b4R8/v9b+jFMdKGrIHbYbuiMlJSUlS94BuQl7cpPHMhYAAAAASUVORK5CYII=>

[image3]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAFEAAAAaCAYAAADPELCZAAACvklEQVR4Xu2XS6hNURjHP3nn5lEMblI3FyWUUO5VRjKSxMCrlEIpJWVEmRgpBgyoGxMhAzOZiZTkUQqJvFKSdxF55vX/t9Z2P19r7bPXPsdBrV/9Ovv7vn3OWmc/1kMkk8n8fRbbRICZNpHKeLgF9sGJKj9PHf+PTIOf/OdXOOf38i/uwqU2WZUj8Ae8BxfByfAAfAp7fa3dXIeX4Ca4Bq6CK+EKr2YHfAs/wHWmRtj/bn88Bn6E3+BWuBAe9Oc88+ckwy9/h6NsAWwTV79hC4YO+B4es4UmYLsxX6vzbsHTKr4JL6iY2IdAx53+k09qLfho2wYsrC+zyQgj4XN4EQ4wtVTY7nxxr+AkccML1f1le6H+MzfaH4/1scbG26Xma/xG3I8NtwWDbbAKg+Bt+BAOM7WqXLUJcTdnuoqvSbh/zB0ysUbH7Gut13iGuB/iQNoI24FUzom7YeNMPhVObidMjn0L9c/mv8DV/ngB3GBqteCgykZC4+Cf4jj8LP0DfCpVLlZBKM/4KHylcjvhEhUnEWqkHZyHL22yAoe9ltj/iOU1Q+ATFU8VN7ufVblSqjTSKgbDO+KWT+x4HdjXLpuU+P+I5TWcVAv0BDVC3HheykBxX+As2ohGHSmDs+MLcU9fM6yXeD9iFyuWL9glbj1c8AieVPF9dRylUSOkB661yQp0iVvMcgxsBZz8Yn19J+Eac7GniauFxybH8/ereK86jvJA3Bf5VIZgnk9RCtxzctG+2xaapOyGL5dwjbnZNunhpGqxF3GfOi6FX+S4YC/kLEkf/CfAzTbZIsouImFto4p5E2Pn7xG3xLFchqdUXOl1LuB2qegkt2381Guof4HiZsfgZoHnXBG33+b2LbRb4mscuzhDpf/Cc2Lh1jETgCuEMqaIW3ifsYV2wtmuqpkIcxPMZDKZTCaTaSE/AUp2viMK9WD5AAAAAElFTkSuQmCC>