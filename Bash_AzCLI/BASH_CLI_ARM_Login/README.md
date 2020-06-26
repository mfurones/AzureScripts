# Azure RM CLI Login in BASH

## Introducción



Este repositorio contiene un script (en CLI con BASH) para el login a Azure.
La forma de trabajo es mediante el pasaje de parametros.



## Ejecución



Es mandatorio el pasaje de parametros y en su orden indicado para su correcta ejecucion.

###### Parametros

- [usuario]: Define al usuario de la cuenta.
- [contraseña]: Define la contraseña del [usuario].
- [subscripcion]: Define el ID de subscripcion del tenant de Azure que se este utilizando.


###### BASH



`.\BASH_CLI_ARM_Login.ps1 [usuario] [contraseña] [subscripcion]`




## Help



Para tener mas informacion sobre el contenido del script se puede ver su informcion mediante los parametros __--help__ o __-h__:



###### BASH



`.\BASH_CLI_ARM_Login.ps1 --help`

`.\BASH_CLI_ARM_Login.ps1 -h`

