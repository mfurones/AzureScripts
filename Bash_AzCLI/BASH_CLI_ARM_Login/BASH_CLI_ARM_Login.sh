
#!/bin/bash

#### Verificacion de Variables ####
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
  #### Help ####
  echo "
   .SYNOPSIS
      Allow to login to Azure RM CLI.

   .DESCRIPTION
      This script allows to login to Azure RM CLI. It must fill all parameters to run the command.

   .PARAMETER
      Put the parameter in the correct order as specified in the following Help

   . 1- Parameter: [usuario]
      Defines the user name.
      Variable type [string].
      Example: usuario@outlook.com

  . 2- Parameter: [contraseña]
      Defines the password of the user.
      Variable type [string].
      Example: C0ntr4s3ñ4

  . 3- Parameter: [subscripcion]
      Defines the suscription of the Azure Tenant.
      Variable type [string].
      Example: 6e4aca29-e826-4edf-aafc-cc276e1d08db

  .EXAMPLE

      ./PS_CLI_ARM_Login.ps1 usuario@outlook.com \"C0ntr4s3ñ4\" \"6e4aca29-e826-4edf-aafc-cc276e1d08db\"

  "
  exit 1
elif [ $# != 3 ] ; then
  #### Check Parameters ####
  echo "Error en los parametros, la escturctura es: $0 [usuario] [contraseña] [subscripcion]" 1>&2;
  exit 1;
fi

#### Variables ####
USUARIO=$1
PASSWORD=$2
SUB=$3

#### Script ####
echo "$(date +%d/%m/%Y) | Inicio de Login..."
az login -u $USUARIO -p $PASSWORD >/dev/null 2>&1
echo "$(date +%d/%m/%Y) | Seteando subscripción..."
az account set --subscription $SUB
echo "$(date +%d/%m/%Y) | el usuario $USUARIO ya se encuentra logueado en Azure."
