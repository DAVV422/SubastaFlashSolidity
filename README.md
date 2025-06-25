# Subasta Flash - Contrato Inteligente

## 📌 Descripción
Contrato de subastas con:
- Retiros parciales de ofertas
- Extensión automática del tiempo
- Mínimo incremento del 5% por oferta

## 📋 Requisitos
- Solidity ^0.8.26
- EVM compatible
- Hardhat/Foundry (recomendado para testing)

## 🏗️ Estructura del Contrato

### 📊 Variables de Estado
```solidity
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
```
