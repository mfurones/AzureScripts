# Creacion de Resource Groups

## Introducción

Este script permite la creacion de un Resource Group en Azure Resource Management por powershell. 

## Ejecución

Se puede ejecutar mediante el uso de parametros.

###### Powershell

`.\PS_ARM_RGCreate.ps1 -resourceGroupName RG_Test -locationName eastus2`

Tambien se puede ejecutar sin el uso de parametros, de esta forma la consola nos pedira de forma interactiva todos los datos necesarios para completar la tarea.

###### Powershell

`.\PS_ARM_RGCreate.ps1`

## Help

Para tener mas informacion sobre el contenido del script se puede ver su informcion mediante:

###### Powershell

`Get-Help .\PS_ARM_RGCreate.ps1`