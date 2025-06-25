# 🧾 SubastaFlash – Contrato Solidity

**Autor:** Diego V.  
**Licencia:** MIT  
**Versión Solidity:** ^0.8.26

---

## 📌 Descripción

`SubastaFlash` es un contrato inteligente para ejecutar subastas rápidas en la blockchain. Tiene las siguientes características:

- Las ofertas deben superar en al menos un 5% a la mejor oferta actual.
- Permite a los usuarios retirar **parcialmente** sus ofertas anteriores (excepto la última y más alta).
- La subasta se extiende 10 minutos tras cada nueva oferta.
- El `owner` (creador del contrato) puede finalizar la subasta y retirar los fondos.
- Los participantes no ganadores pueden retirar sus depósitos con una comisión del 2%.

---

## 📦 Variables del contrato

### 🔐 Control y estado

| Variable              | Tipo         | Descripción |
|-----------------------|--------------|-------------|
| `owner`               | `address`    | Dirección del creador del contrato. |
| `finalizada`          | `bool`       | Indica si la subasta ha finalizado. |

### 🏆 Mejor oferta

| Variable              | Tipo         | Descripción |
|-----------------------|--------------|-------------|
| `mejorOferente`       | `address`    | Dirección del oferente actual más alto. |
| `mejorOferta`         | `uint`       | Valor de la mejor oferta. |

### ⏱ Tiempo

| Variable              | Tipo         | Descripción |
|-----------------------|--------------|-------------|
| `inicio`              | `uint`       | Timestamp de inicio del contrato. |
| `tiempoUltimaOferta` | `uint`       | Timestamp de la última oferta. |
| `duracion`            | `uint`       | Tiempo extra desde la última oferta (10 minutos). |

### 💰 Gestión de fondos

| Variable                | Tipo                        | Descripción |
|-------------------------|-----------------------------|-------------|
| `historialOfertas`      | `Oferta[]`                  | Lista de todas las ofertas registradas. |
| `ultimaOfertaUsuario`   | `mapping(address => uint)`  | Última oferta válida de cada usuario. |
| `depositos`             | `mapping(address => uint)`  | Total depositado por cada usuario. |
| `ofertaYaRetirada`      | `mapping(uint => bool)`     | Marca si una oferta ya fue retirada parcialmente. |

---

## 🧱 Estructuras

### `struct Oferta`

```solidity
struct Oferta {
    uint tiempo;       // Timestamp de la oferta
    address usuario;   // Dirección del ofertante
    uint monto;        // Monto ofertado
}
```
---
## ⚙️ Funciones

### `constructor()`
Inicializa el contrato y guarda el owner y el tiempo de inicio.

---

### `ofertar() external payable`
Realiza una nueva oferta.  
✔ Requisitos:
- Subasta activa.
- Oferta ≥ 5% mayor que la actual.
- Se actualizan mejor oferta, mejor oferente, y tiempo.

📤 Emite `NuevaOferta`.

---

### `finalizar() external soloOwner`
Finaliza la subasta.  
✔ Requiere ser el owner y que haya pasado el tiempo de duración desde la última oferta.

📤 Emite `SubastaFinalizada`.

---

### `retiroParcial(uint posicionHistorial) external`
Permite retirar una oferta **anterior** que **no sea la última y más alta**.  
✔ Verifica:
- Que el `msg.sender` sea el oferente.
- Que no se haya retirado antes.
- Que exista excedente suficiente.

---

### `retirar() external`
Permite retirar el depósito a usuarios **no ganadores**.

✔ Aplica una comisión del 2% sobre el total depositado.  
📤 Transfiere el 98%.

---

### `retirarFondos() external soloOwner`
Permite al `owner` retirar todos los fondos del contrato si la subasta finalizó.  
📤 Emite `FondosRetirados`.

---

### `tiempoRestante() external view returns (uint)`
Devuelve el tiempo (en segundos) hasta que termine la subasta. Si ya finalizó, retorna 0.

---

### `verBalance() external view returns (uint)`
Muestra el balance actual del contrato (en wei).

---

## 📢 Eventos

| Evento                | Parámetros                             | Descripción |
|-----------------------|-----------------------------------------|-------------|
| `NuevaOferta`         | `address oferente`, `uint monto`        | Se emite con cada nueva oferta válida. |
| `SubastaFinalizada`   | `address ganador`, `uint monto`         | Se emite al finalizar la subasta. |
| `FondosRetirados`     | `address to`, `uint amount`             | Se emite cuando el owner retira los fondos del contrato. |

---

## ✅ Seguridad

- Verificaciones estrictas de estado (`subastaActiva`, `finalizada`, etc.).
- El ganador no puede retirar su depósito.
- Evita reentradas y dobles reembolsos con `ofertaYaRetirada`.

---

## 📄 Licencia

Este proyecto está licenciado bajo la licencia **MIT**.

Autor: **Diego V.**
