# Creacion de SQL Logic Server

## Introducción

Este script permite la creacion de un SQL Logic Server en Azure Resource Management por powershell. 

## Ejecución

Se puede ejecutar mediante el uso de parametros.

###### Powershell

`.\PS_ARM_SQLLogicServerCreate.ps1  -resourceGroupName RG-Demo -SQLServerName sqlserverdemo01 -sqlUSR usuariodemo -sqlPASS P4ssw0rd@1`

Tambien se puede ejecutar sin el uso de parametros, de esta forma la consola nos pedira de forma interactiva todos los datos necesarios para completar la tarea.

###### Powershell

`.\PS_ARM_SQLLogicServerCreate.ps1`

## Help

Para tener mas informacion sobre el contenido del script se puede ver su informcion mediante:

###### Powershell

`Get-Help .\PS_ARM_SQLLogicServerCreate.ps1`