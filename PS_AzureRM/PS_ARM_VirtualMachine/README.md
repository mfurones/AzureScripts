# Azure Resource Manager Virtual Machine

## Introducci�n

Este repositorio contiene una serie de script para el Deploy y Administracion de Maquinas Virtuales.

## Creacion de Maquina Virtual (PS_ARM_VMCreate.ps1)

Este script permite la creacion de una VM en Azure mediante powershell, el script puede ser ejecutado con parametros o mediante la consola interactiva

### Pre-Requisitos

Para poder crear con exito una VM se requiere de la previa existencia de:
* Resource Group
* Virtual Network
* Storage Account
* Availability Set (*)

(*) No es de caracter obligatorio, no obstante al necesitar incluirse, debe de existir un feature creado para su posterior selecci�n.

### Deploy

Se puede deployar mediante el uso de parametros.

###### Powershell

`.\PS_ARM_VMCreate.ps1 -resourceGroupName RG-Demo -vmName VM-Demo-01`

Tambien se puede deployar sin el uso de parametros, de esta forma la consola nos pedira de forma interactiva todos los datos necesarios para completar la tarea.

###### Powershell

`.\PS_ARM_VMCreate.ps1`

### Help

Para tener mas informacion sobre el contenido del script se puede ver su informcion mediante:

###### Powershell

`Get-Help .\PS_ARM_VMCreate.ps1`

## Maquina Virtual Start/Stop/Restart (PS_ARM_VMStartStop.ps1)

Este script permite la administracion del estado de una VM en Azure mediante powershell, el script puede ser ejecutado con parametros o mediante la consola interactiva

### Acciones

- Start
- Stop
- Restart

###### Powershell

`.\PS_ARM_VMStartStop.ps1 -resourceGroupName RG-Demo -vmName VM-Demo-01 -accion Start`

Tambien se puede deployar sin el uso de parametros, de esta forma la consola nos pedira de forma interactiva todos los datos necesarios para completar la tarea.

###### Powershell

`.\PS_ARM_VMStartStop.ps1`

### Help

Para tener mas informacion sobre el contenido del script se puede ver su informcion mediante:

###### Powershell

`Get-Help .\PS_ARM_VMStartStop.ps1`
