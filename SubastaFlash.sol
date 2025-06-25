// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title Subasta Flash
/// @author Diego V.
/// @notice Este contrato permite realizar subastas con retiros parciales.

// Estructura de las ofertas
struct Oferta {
    uint tiempo;      // El momento en que se realizó la oferta (timestamp)
    address usuario;     // La dirección del usuario que hizo la oferta
    uint monto;       // El monto de la oferta en wei
}

contract SubastaFlash {
   address public owner;
   address public mejorOferente;
   uint public mejorOferta;
   Oferta[] public historialOfertas;

   uint public inicio;
   uint public tiempoUltimaOferta;
   uint public duracion = 10 minutes;
   bool public finalizada;

   mapping(address => uint) public ultimaOfertaUsuario;
   mapping(address => uint) public depositos;
   mapping(uint => bool) private ofertaYaRetirada;

   event NuevaOferta(address indexed oferente, uint monto);
   event SubastaFinalizada(address ganador, uint monto);
   event FondosRetirados(address indexed to, uint amount);

   constructor() {
       owner = msg.sender;
       inicio = block.timestamp;
       tiempoUltimaOferta = block.timestamp;
   }

   modifier subastaActiva() {
       require(!finalizada, "Subasta finalizada");
       require(block.timestamp <= tiempoUltimaOferta + duracion, "Tiempo terminado");
       _;
   }

   modifier soloOwner() {
       require(msg.sender == owner, "No eres el owner");
       _;
   }

   // Funcion para ofertar un monto
   function ofertar() external payable subastaActiva {
       require(msg.value > 0, "Debes enviar ETH");

       uint minimoRequerido = mejorOferta + (mejorOferta * 5) / 100;

       require(msg.value >= minimoRequerido, "La oferta debe ser al menos 5% mayor de la mejor oferta.");

       uint total = depositos[msg.sender] + msg.value;
       depositos[msg.sender] = total;

       ultimaOfertaUsuario[msg.sender] = msg.value;
       mejorOferente = msg.sender;
       mejorOferta = msg.value;
       tiempoUltimaOferta = block.timestamp;       
       historialOfertas.push(Oferta(block.timestamp, msg.sender, msg.value));

       emit NuevaOferta(msg.sender, total);
   }

   // Funcion para finalizar la subasta.
   function finalizar() external soloOwner {
       require(!finalizada, "Ya finalizo");
       require(block.timestamp >= tiempoUltimaOferta + duracion, "Aun no termina el tiempo limite minimo.");

       finalizada = true;

       emit SubastaFinalizada(mejorOferente, mejorOferta);
   }

   // Funcion para retirar los montos de las ofertas anteriores a la ultima oferta del usuario.
   function retiroParcial(uint posicionHistorial) external {       
       require(posicionHistorial >= 0 && posicionHistorial < historialOfertas.length , "Posicion no existe");
       
       Oferta memory ofertaRetiroParcial = historialOfertas[posicionHistorial];
       require(msg.sender == ofertaRetiroParcial.usuario, "No eres el propietario de la oferta");
       require(ofertaRetiroParcial.monto != ultimaOfertaUsuario[msg.sender], "Esta oferta es tu oferta actual mas alta y no puede ser retirada parcialmente. Si la subasta finalizo usar la funcion retirar.");

       require(!ofertaYaRetirada[posicionHistorial], "Ya se ha realizado un retiro parcial de esta oferta.");

       uint reembolso = ofertaRetiroParcial.monto;

       uint excedenteDisponible = depositos[msg.sender] - ultimaOfertaUsuario[msg.sender];

       require(excedenteDisponible >= reembolso, "Fondos insuficientes en el excedente para este reembolso.");
    
       ofertaYaRetirada[posicionHistorial] = true;
       depositos[msg.sender] -= reembolso;       
       payable(msg.sender).transfer(reembolso);
   }

   // Funcion para retirar el monto de los usuarios que no ganaron la subasta
   function retirar() external {
       require(finalizada, "Subasta no finalizada");
       require(msg.sender != mejorOferente, "Ganador no puede retirar");

       uint deposito = depositos[msg.sender];
       require(deposito > 0, "Nada para retirar");

       uint comision = (deposito * 2) / 100;
       uint reembolso = deposito - comision;

       depositos[msg.sender] = 0;
       payable(msg.sender).transfer(reembolso);
   }

   /// Permite al owner retirar los fondos ganadores
   function retirarFondos() external soloOwner {
       require(finalizada, "Subasta no finalizada");
       require(address(this).balance > 0, "Sin balance disponible");

       uint monto = address(this).balance;
       (bool exito, ) = payable(owner).call{value: monto}("");
       require(exito, "Fallo al transferir al owner");
       emit FondosRetirados(owner, monto);
   }

   /// Retorna los segundos restantes hasta el fin de la subasta
   function tiempoRestante() external view returns (uint) {
       if (block.timestamp >= tiempoUltimaOferta + duracion || finalizada) {
           return 0;
       } else {
           return (tiempoUltimaOferta + duracion) - block.timestamp;
       }
   }

   /// Consulta del balance del contrato
   function verBalance() external view returns (uint) {
       return address(this).balance;
   }
}
