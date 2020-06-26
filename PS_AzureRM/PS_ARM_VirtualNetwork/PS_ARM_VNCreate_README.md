# Azure Resource Manager Virtual Network

## Introducción

Este  script es para la creación de una Virtual Network en Azure Resource Management por powershell. 
La forma de trabajo es mediante el pasaje de parametros o por medio de la consola interactiva.

## Ejecución

Se puede ejecutar mediante el uso de parametros.

###### Powershell

`.\PS_ARM_VNCreate.ps1 -resourceGroupName RG_Test -virtualNetworkName VN-Test01 -AddressPrefix 192.168.0.0/16 -SubnetName LAN -SubnetAddressPrefix 192.168.0.0/16`

Tambien se puede ejecutar sin el uso de parametros, de esta forma la consola nos pedira de forma interactiva todos los datos necesarios para completar la tarea.

###### Powershell

`.\PS_ARM_VNCreate.ps1`

## Help

Para tener mas informacion sobre el contenido del script se puede ver su informcion mediante:

###### Powershell

`Get-Help .\PS_ARM_VNCreate.ps1`
