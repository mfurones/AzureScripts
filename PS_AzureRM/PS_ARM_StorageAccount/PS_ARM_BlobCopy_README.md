# Crear una copia de un Blob en Azure RM por powershell

## Introduccion

Este script permite la copia de un Blob, tanto para realizarla en el mismo Storage Account como para uno ubicado en otra suscripcion en Azure RM por powershell.

## Ejecucion

### Parametros

El script puede ser ejecutado mediante el pasaje de parametros o de caso contrario la consola solicitara la informacion necesaria para su ejecucion.

#### -placeCopy

Indica la ubicacion donde se generara la copia
* Same: Utiliza la misma ubicacion que el Blob original.
* Another: Solicitara los parametros para la nueva ubicacion.

### Ejemplos

###### Powershell

`.\PS_ARM_BlobCopy.ps1`

`.\PS_ARM_BlobCopy.ps1 -resourceGroupOrigName RG-Demo -StorageAccountOrigName sademo01 -StorageAccountContainerOrigName vhds -BlobOrigName vm-demo.vhd -placeCopy Same`

`.\PS_ARM_BlobCopy.ps1 -resourceGroupOrigName RG-Demo -StorageAccountOrigName sademo01 -StorageAccountContainerOrigName vhds -BlobOrigName vm-demo.vhd -placeCopy Another`
`                      -resourceGroupDestName RG-Test -StorageAccountDestName satest01 -StorageAccountContainerDestName vhds -BlobDestName vm-test.vhd`

## Help

Para tener mas informacion sobre el contenido del script se puede ver su informcion mediante:

###### Powershell

`Get-Help .\PS_ARM_BlobCopy.ps1`