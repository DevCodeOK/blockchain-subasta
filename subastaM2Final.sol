// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title Subasta - Contrato de subasta con reembolsos parciales y comisión del 2%
/// @author Odalis
/// @notice Este contrato permite realizar subastas donde los participantes pueden realizar múltiples ofertas,
/// retirar excedentes durante la subasta y los no-ganadores pueden recuperar sus depósitos (menos una comisión) al finalizar.
contract SubastaFinal {

    // Dirección del dueño del contrato (admin de la subasta)
    address public owner;

    // Dirección del mejor postor actual
    address public mejorOferente;

    // Valor de la mejor oferta hasta el momento
    uint public mejorOferta;

    // Timestamp de inicio de la subasta
    uint public inicio;

    // Duración de la subasta en segundos
    uint public duracion;

    // Estado que indica si la subasta ha sido finalizada
    bool public finalizada;

    // Historial de ofertas por cada participante
    mapping(address => uint[]) public historialOfertas;

    // Total depositado por cada participante
    mapping(address => uint) public depositos;

    // Se emite cuando un usuario realiza una nueva oferta
    event NuevaOferta(address indexed oferente, uint monto);

    // Se emite al finalizar la subasta, indicando el ganador y la mejor oferta
    event SubastaFinalizada(address ganador, uint monto);

    // Se emite cuando se retiran fondos (ya sea el owner o un participante)
    event FondosRetirados(address indexed to, uint amount);

    // Se emite cuando un usuario retira el excedente de sus ofertas durante la subasta
    event ReembolsoParcial(address indexed usuario, uint monto);

    /// @notice Constructor del contrato
    /// @param _duracionEnSegundos Duración de la subasta en segundos desde el despliegue
    constructor(uint _duracionEnSegundos) {
        owner = msg.sender;
        inicio = block.timestamp;
        duracion = _duracionEnSegundos;
    }

    /// @notice Modificador que valida que la subasta esté activa
    modifier subastaActiva() {
        require(!finalizada, "Subasta ya finalizada");
        require(block.timestamp <= inicio + duracion, "Tiempo de subasta finalizado");
        _;
    }

    /// @notice Modificador que permite ejecutar funciones solo al owner
    modifier soloOwner() {
        require(msg.sender == owner, "Solo el OWNER puede ejecutar esta funcion");
        _;
    }

    /// @notice Permite realizar una oferta (debe superar en al menos 5% la mejor oferta)
    /// @dev Almacena el valor ofertado y actualiza al mejor postor
    function ofertar() external payable subastaActiva {
        require(msg.value > 0, "Debes enviar ETH");

        uint total = depositos[msg.sender] + msg.value;
        uint minimoRequerido = mejorOferta == 0 ? 0 : mejorOferta + (mejorOferta * 5) / 100;
        require(total >= minimoRequerido, "La oferta debe superar en al menos 5%");

        historialOfertas[msg.sender].push(msg.value);
        depositos[msg.sender] = total;
        mejorOferente = msg.sender;
        mejorOferta = total;

        emit NuevaOferta(msg.sender, total);
    }

    /// @notice Devuelve la dirección del mejor postor y su oferta
    function mostrarGanador() external view returns (address ganador, uint oferta) {
        return (mejorOferente, mejorOferta);
    }

    /// @notice Devuelve la lista de ofertas hechas por un usuario
    /// @param usuario Dirección del participante
    function mostrarOfertas(address usuario) external view returns (uint[] memory) {
        return historialOfertas[usuario];
    }

    /// @notice Finaliza la subasta si se cumplió el tiempo y no ha sido finalizada antes
    /// @dev Solo el owner puede finalizarla
    function finalizarSubasta() external soloOwner {
        require(!finalizada, "Subasta ya finalizada");
        require(block.timestamp >= inicio + duracion, "La subasta aun esta activa");

        finalizada = true;

        emit SubastaFinalizada(mejorOferente, mejorOferta);
    }

    /// @notice Permite a los no-ganadores retirar su depósito, menos una comisión del 2%
    function retirarDeposito() external {
        require(finalizada, "Subasta aun no finalizada");
        require(msg.sender != mejorOferente, "El ganador no puede retirar");

        uint deposito = depositos[msg.sender];
        require(deposito > 0, "No hay fondos que retirar");

        uint comision = (deposito * 2) / 100;
        uint reembolso = deposito - comision;

        depositos[msg.sender] = 0;
        payable(msg.sender).transfer(reembolso);

        emit FondosRetirados(msg.sender, reembolso);
    }

    /// @notice Permite al owner retirar los fondos recaudados (la mejor oferta)
    function retirarFondos() external soloOwner {
        require(finalizada, "La subasta no ha finalizado");
        require(address(this).balance > 0, "No hay fondos disponibles");

        uint monto = address(this).balance;
        (bool exito, ) = payable(owner).call{value: monto}("");
        require(exito, "Transferencia fallida");

        emit FondosRetirados(owner, monto);
    }

    /// @notice Permite retirar el exceso si el usuario ofertó varias veces
    /// @dev Solo durante la subasta activa
    function retirarExcedente() external subastaActiva {
        require(depositos[msg.sender] > 0, "Sin fondos para retirar");

        uint total = depositos[msg.sender];
        uint ultimaOferta = historialOfertas[msg.sender].length > 0
            ? historialOfertas[msg.sender][historialOfertas[msg.sender].length - 1]
            : 0;

        uint excedente = total - ultimaOferta;
        require(excedente > 0, "No hay excedente para retirar");

        depositos[msg.sender] = ultimaOferta;
        payable(msg.sender).transfer(excedente);

        emit ReembolsoParcial(msg.sender, excedente);
    }

    /// @notice Devuelve el tiempo restante en segundos hasta el fin de la subasta
    function tiempoRestante() external view returns (uint) {
        if (block.timestamp >= inicio + duracion || finalizada) {
            return 0;
        } else {
            return (inicio + duracion) - block.timestamp;
        }
    }

    /// @notice Devuelve el balance actual del contrato
    function verBalance() external view returns (uint) {
        return address(this).balance;
    }
}
