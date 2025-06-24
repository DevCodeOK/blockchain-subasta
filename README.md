# blockchain-subasta
Contrato de subasta con reembolso parcial y depósitos

# Subasta - Contrato Inteligente

Este es un contrato inteligente desarrollado en Solidity que permite realizar una subasta descentralizada con manejo de depósitos, reembolsos parciales, comisión y eventos.

## Funcionalidades

- Registro de ofertas por dirección.
- La nueva oferta debe superar en al menos **5%** la mejor oferta actual.
- Solo se puede ofertar **mientras la subasta está activa**.
- El **ganador** es quien tenga la mejor oferta al finalizar.
- Los **no ganadores** pueden retirar sus fondos con un **2% de comisión**.
- Se permite retirar el **excedente** en tiempo real si se ofertó más de una vez.
- Uso de `msg.sender` para identificar a cada participante.
- Emisión de eventos: `NuevaOferta`, `SubastaFinalizada`, `FondosRetirados`, `ReembolsoParcial`.

## Tecnologías

- Solidity ^0.8.26
- Remix IDE para desarrollo y pruebas
- Red de pruebas Ethereum (como Sepolia)

## Estructura del Proyecto

blockchain-subasta/
│
└── SubastaM2Final.sol # Contrato inteligente principal
│
└── README.md # Este archivo


## Cómo Funciona

1. Abrir el contrato en [Remix IDE](https://remix.ethereum.org/)
2. Compilar con la versión 0.8.26
3. Desplegar el contrato indicando la duración en segundos (por ejemplo, `120` para 2 minutos)
4. Cambiar de cuenta para simular distintos usuarios
5. Llamar a `ofertar()` enviando ETH (recuerda superar la oferta en +5%)
6. Finalizar la subasta con `finalizarSubasta()`
7. Llamar a `retirarDeposito()` si no eres el ganador o `retirarFondos()` si eres el owner

## Autor

*Odalis*
Ethereum Developer - M2 Trabajo final de curso Solidity


