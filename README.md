# blockchain-subasta
Contrato de subasta con reembolso parcial y depósitos

Funcionalidades Requeridas
📦 Constructor
Inicializa la subasta ingresando el tiempo en segundos.

🏷️ Función para ofertar
	Permite a los participantes ofertar por el artículo.
	Una oferta es válida si:
	Es mayor en al menos 5% que la mayor oferta actual.
	Se realiza mientras la subasta está activa.
 
🥇 Mostrar ganador
	Devuelve el oferente ganador y el valor de la oferta ganadora.
 
📜 Mostrar ofertas
	Devuelve la lista de oferentes y sus respectivos montos ofrecidos.
 
💸 Devolver depósitos
	Al finalizar la subasta:
	Se devuelve el depósito a los oferentes no ganadores.
	Se descuenta una comisión del 2%.
 
💰 Manejo de depósitos
	Las ofertas deben:
	Ser depositadas en el contrato.
	Estar asociadas a las direcciones de los oferentes.
 
📢 Eventos requeridos
	Nueva Oferta: Emitido cuando se realiza una nueva oferta.
	Subasta Finalizada: Emitido cuando finaliza la subasta.
 
🚀 Funcionalidades Avanzadas
🔁 Reembolso parcial
Durante la subasta, los participantes pueden retirar el importe por encima de su última oferta válida.
Ejemplo:
Tiempo	Usuario	Oferta
T0	Usuario 1	1 ETH
T1	Usuario 2	2 ETH
T2	Usuario 1	3 ETH
→ Usuario 1 puede pedir el reembolso de la oferta T0 (1 ETH).

