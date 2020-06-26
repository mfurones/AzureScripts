# Creacion de Container Storage Account en Azure RM por powershell

## Introduccion

Este script permite la creacion de un Container para un Storage Account en Azure RM por powershell.

## Ejecucion

### Parametros

El script puede ser ejecutado mediante el pasaje de parametros o de caso contrario la consola solicitara la informacion necesaria para su ejecucion.

### Ejemplos

###### Powershell

`.\PS_ARM_StorageAccountContainerCreate.ps1`

`.\PS_ARM_StorageAccountContainerCreate.ps1 -resourceGroupName RG-Demo -StorageAccountName sademo01 -StorageAccountContainerName ContLog`

## Help

Para tener mas informacion sobre el contenido del script se puede ver su informcion mediante:

###### Powershell

`Get-Help .\PS_ARM_StorageAccountContainerCreate.ps1`