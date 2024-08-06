# Desafío meli-proxy

Mercadolibre hoy en día corre sus aplicaciones en más de 20.000 servidores, estos suelen comunicarse entre sí a través de apis, algunas accesibles desde el exterior (api.mercadolibre.com).
Uno de los problemas que tenemos actualmente es como controlar y medir estas interconexiones. Para esto necesitamos crear e implementar un "proxy de apis". 

Este proxy debe poder cumplir al menos con los siguientes requisitos:
- Permitir ejecutar la función de proxy, sobre el dominio api.mercadolibre.com
Ejemplo "curl 127.0.0.1:8080/categories/MLA97994" debera retornar el contenido de https://api.mercadolibre.com/categories/MLA97994 (no redirect ni cache)
- Se deberá poder controlar la cantidad máxima de llamados (rate limit) por ejemplo
  - IP de origen 152.152.152.152 : 1000 requests por minuto
  - path /categories/* : 10000 requests por minuto
  - IP 152.152.152.152 y path /items/* : 10 requests por minuto
  - Otros criterios u alternativas de control son bien vistas
- La carga media del proxy (como solución) debe poder superar los 50.000 request/segundo. Por lo cual como escala la solución es muy importante.


Una idea macro del producto:
![Una idea macro del producto](/images/ejemplo.png)


Extras bienvenidos:

- Estadísticas de uso: se deben almacenar (y en lo posible visualizar) estadísticas de uso del proxy 
- El código debe estar en un repo git para poder pegarle un vistazo y discutir 
- La interfaz para estadísticas y control podría soportar rest
- Tener todos los puntos completos (y funcionando), aunque cualquier nivel de completitud es aceptable
- Tener algún dibujo, diagrama u otros sobre como es el diseño, funcionamiento y escalabilidad del sistema suma mucho
- Funcionar contra el api de mercadolibre real, estaría buenísimo, de todas formas son conocidos algunos errores con HTTP’s, por lo que cualquier otra alternativa (mocks, otra api, etc) que pruebe el funcionamiento también es válido

# Resolucion

## Solucion propuesta
A continuacion se muestra un diagrama de la solucion propuesta:
![Una idea macro del producto](/images/diagram.png)

## Componentes de la arquitectura

### Users
Usuarios de la api que envian sus requests a meli-proxy.

### WAF
Web firewall que aplica las reglas de limite de requests para ciertas IP/API paths.

### API Gateway
El corazon de meli-proxy, encargado de recibir los requests de los clientes y fowardear el request a la api de MeLi.

### CloudWatch
Servicio encargado de recibir logs y metricas del uso de meli-proxy.

### CloudWatch Dashboard
Dashboard con metricas del uso de meli-proxy.

### API MeLi
API de MercadoLibre a la cual se le envian los requests, por ejemplo /categories/MLA1055.

## Stack 

### AWS
Se utilizo exclusivamente AWS como cloud provider.

### Terraform
Utilizado para deployar toda la infraestructura de meli-proxy.

### Python
Lenguaje de programacion utilizado para desarrollar el script que corre el comando "terraform apply -auto-approve", y luego genera trafico hacia la api en forma de GET requests.

## Documentacion consultada

MeLi API
https://developers.mercadolibre.com.ar/es_ar/categorias-y-atributos

AWS API Gateway
https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-create-api-as-simple-proxy-for-http.html

Set up CloudWatch logging for REST APIs in API Gateway
https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-logging.html

How do I turn on CloudWatch Logs for troubleshooting my API Gateway REST API or WebSocket API?
https://repost.aws/knowledge-center/api-gateway-cloudwatch-logs

Set up CloudWatch logging for REST APIs in API Gateway
https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-logging.html#apigateway-cloudwatch-log-formats

## Agradecimientos especiales

- ChatGPT
- Mama
- Papa
- Metallica (Mi gatita, no la banda)
- ChatGPT de nuevo