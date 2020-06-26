# Azure Resource Manager Virtual Machine

## Introducción

Este repositorio contiene un script para el Deploy y Administracion de un Network Security Group.

## Opciones de Ejecución

* Export
* Import
* Create

### Export

Permite la exportacion de reglas a un archivo CSV (por default PS_ARM_NSGAdmin.csv).

### Import

Permite la importacion de reglas provenientes de un archivo CSV (por default PS_ARM_NSGAdmin.csv).

### Import

Permite la creacion de un NSG mediante la importacion de reglas provenientes de un archivo CSV (por default PS_ARM_NSGAdmin.csv).

## Pre-Requisitos

Para poder ejecutar el script hay que tener las siguientes consideraciones:
* Import: Debe de existir el Archivo CSV (por default PS_ARM_NSGAdmin.csv) en la misma ruta donde se encuentra el script
* Create: Debe de existir el Archivo CSV (por default PS_ARM_NSGAdmin.csv) en la misma ruta donde se encuentra el script

## Ejecucion

Se puede deployar mediante el uso de parametros.

###### Powershell

`.\PS_ARM_NSGAdmin.ps1 -resourceGroupName RG_Test -NSGName NSG-Test01 -accion Export`

`.\PS_ARM_NSGAdmin.ps1 -resourceGroupName RG_Test -NSGName NSG-Test01 -CSV fileNSGrules.csv -accion Import`

`.\PS_ARM_NSGAdmin.ps1 -resourceGroupName RG_Test -NSGName NSG-Test01 -accion Create`

Tambien se puede deployar sin el uso de parametros, de esta forma la consola nos pedira de forma interactiva todos los datos necesarios para completar la tarea.

###### Powershell

`.\PS_ARM_NSGAdmin.ps1`

## Help

Para tener mas informacion sobre el contenido del script se puede ver su informcion mediante:

###### Powershell

`Get-Help .\PS_ARM_NSGAdmin.ps1`